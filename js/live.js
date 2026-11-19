// Live fractals in the page: a few of UltraIterator Demo's ported Ultra Fractal
// parameters (uprLib's uprPort/liveexport.py, the app's assets/live/), drawn by the
// browser's GPU as they are on the phone, diving slowly towards detail.
// No pictures are downloaded for it: each is a shader and its gradients.
//
// Each frame takes one jittered sample a pixel (more where the frame rate allows: LADDER) and
// blends it into the frames before, lined up exactly where they were (the camera's a known
// pan and zoom over a fractal that doesn't change), so the noisy ones settle smooth.
(function () {
  'use strict';

  const HEAD = `#version 300 es
precision highp float;
uniform sampler2D uGrad;   // its gradients' 400 colours, a row a layer (UF's rows only)
uniform int uAA;           // samples a side
uniform vec3 uView;        // the view's middle (x, y) and height (z), in the picture's units (its 2k's height = 1)
uniform vec2 uRes;
uniform vec2 uJitter;      // this frame's sub-pixel offset
out vec4 frag;
`;
  // As the app's LIVE_GEN_MAIN, but `o` from the view rather than a tile.
  const MAIN = `
void main() {
    vec3 sum = vec3(0.0);
    float px = uView.z / uRes.y;
    for (int j = 0; j < uAA; j++) for (int i = 0; i < uAA; i++) {
        vec2 f = gl_FragCoord.xy + uJitter + (vec2(i, j) + 0.5) / float(uAA) - 0.5;
        sum += liveColour(uView.xy + (f - 0.5 * uRes) * px);
    }
    frag = vec4(clamp(sum / float(uAA * uAA), 0.0, 1.0), 1.0);
}`;
  const VS = `#version 300 es
in vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }`;
  // The blend: this frame's samples with the history, read back where this pixel was in the
  // last frame's view (Catmull-Rom, so repeated resampling doesn't blur it).
  const RESOLVE_FS = `#version 300 es
precision highp float;
uniform sampler2D uCur, uHist;
uniform vec2 uRes;
uniform vec3 uView, uPrev;
uniform float uKeep;       // the history's weight (0: start afresh)
uniform float uClip;       // how far (in the neighbourhood's spreads) history may stray from this frame
out vec4 frag;
vec3 catmullRom(vec2 p) {
    vec2 tc = floor(p - 0.5) + 0.5, f = p - tc;
    vec2 w0 = f * (-0.5 + f * (1.0 - 0.5 * f)), w1 = 1.0 + f * f * (-2.5 + 1.5 * f);
    vec2 w2 = f * (0.5 + f * (2.0 - 1.5 * f)), w3 = f * f * (-0.5 + 0.5 * f);
    vec2 w12 = w1 + w2, t12 = (tc + w2 / w12) / uRes, t0 = (tc - 1.0) / uRes, t3 = (tc + 2.0) / uRes;
    vec3 c = texture(uHist, vec2(t12.x, t0.y)).rgb * w12.x * w0.y
           + texture(uHist, vec2(t0.x, t12.y)).rgb * w0.x * w12.y + texture(uHist, t12).rgb * w12.x * w12.y + texture(uHist, vec2(t3.x, t12.y)).rgb * w3.x * w12.y
           + texture(uHist, vec2(t12.x, t3.y)).rgb * w12.x * w3.y;
    return c / (w12.x * w0.y + w0.x * w12.y + w12.x * w12.y + w3.x * w12.y + w12.x * w3.y);
}
void main() {
    vec2 f = gl_FragCoord.xy;
    vec3 c = texelFetch(uCur, ivec2(f), 0).rgb;
    vec2 o = uView.xy + (f - 0.5 * uRes) * (uView.z / uRes.y);
    vec2 pf = (o - uPrev.xy) * (uRes.y / uPrev.z) + 0.5 * uRes;
    // Pixels drifting in at an edge have no history of their own: they take the nearest edge's,
    // at most a pixel or so away, rather than showing one noisy sample (sparkles round the frame).
    if (uKeep > 0.0) {
        vec3 h = clamp(catmullRom(clamp(pf, vec2(1.5), uRes - 1.5)), 0.0, 1.0);
        // Variance clipping: the history may only stray from this frame's 3x3 neighbourhood by a
        // little more than its own spread. Noise (a wide spread) still averages away, but detail
        // the history hasn't caught up with (zooming in shows new detail every frame) comes
        // through rather than being fuzzed by older, coarser frames.
        vec3 m1 = vec3(0.0), m2 = vec3(0.0);
        for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) {
            vec3 s = texelFetch(uCur, clamp(ivec2(f) + ivec2(i, j), ivec2(0), ivec2(uRes) - 1), 0).rgb;
            m1 += s; m2 += s * s;
        }
        m1 /= 9.0; m2 /= 9.0;
        vec3 sd = sqrt(max(m2 - m1 * m1, 0.0));
        h = clamp(h, m1 - uClip * sd, m1 + uClip * sd);
        c = mix(c, h, uKeep);
    }
    frag = vec4(c, 1.0);
}`;
  const SHOW_FS = `#version 300 es
precision highp float;
uniform sampler2D uTex;
uniform float uFade;
uniform vec2 uRes;
out vec4 frag;
void main() {
    // A slight vignette: corners down to ~70%, the middle untouched.
    vec2 q = (gl_FragCoord.xy / uRes - 0.5) * 2.0;
    float r = length(q * vec2(uRes.x / length(uRes), uRes.y / length(uRes))) * 1.4142;
    float v = mix(1.0, 0.7, smoothstep(0.45, 1.0, r));
    frag = vec4(texelFetch(uTex, ivec2(gl_FragCoord.xy), 0).rgb * uFade * v, 1.0);
}`;

  const ZOOM_RATE = 0.085;     // octaves a second
  const DRIFT_MAX = 0.045;     // the most it drifts sideways, in screen heights a second
  const RETARGET = 4.5;        // seconds between looks for detail
  const PROBE = 40;            // the look's size, px square
  const IDLE_RESUME = 9;       // seconds after a touch before it steers itself again
  const FADE = 1.5;            // seconds to fade between fractals
  const KEEP_MAX = 0.9;        // the history's most weight: about the last ten frames
  const KEEP_DEEP = 0.75;      // ...and at the end of its depth
  const CLIP = 2.0;            // variance clipping's reach (RESOLVE_FS) while it moves
  const CLIP_DEEP = 1.25;      // ...and at the end of its depth
  // Still (paused, or left alone after a touch): nothing new to show, so it keeps averaging, up to
  // this many frames' worth, unclipped, and once settled stops drawing (the canvas keeps its picture).
  // Still for STILL_HI frames, it also goes to the screen's full resolution (frame rate doesn't
  // matter while nothing moves), so it keeps getting sharper the longer it's left.
  const STILL_FRAMES = 128;
  const STILL_HI = 15;
  const STILL_DONE = 400;
  // ...on a desktop (a mouse to hover with): a phone keeps its usual resolution, for its battery.
  const HI_OK = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
  const PRECISION_MARGIN = 2;  // stop this many times short of where fp32 runs out
  const TAA = new URLSearchParams(location.search).get('taa') !== '0';   // ?taa=0: no blending, to compare
  // Render scale (CSS px a pixel, up to the screen's own) and samples a side, cheapest first.
  const LADDER = [[0.4, 1], [0.5, 1], [0.65, 1], [0.8, 1], [1, 1], [1.25, 1], [1.5, 1], [1.5, 2]];

  const canvas = document.getElementById('live');
  const info = document.getElementById('live-name');
  const poster = document.getElementById('live-poster');
  if (!canvas) return;
  const gl = canvas.getContext('webgl2', { antialias: false, alpha: false, preserveDrawingBuffer: false });
  if (!gl) { document.body.classList.add('no-live'); return; }
  const floatHist = !!gl.getExtension('EXT_color_buffer_float');

  let common = '';
  let order = [];
  let cur = null;          // { pick, prog, tex, uni }
  let at = 0;              // place in `order`
  let view = { x: 0, y: 0, h: 1 }, prevView = null;
  let target = { x: 0, y: 0 }, aim = { x: 0, y: 0 }, vel = { x: 0, y: 0 };
  let startH = 1, minH = 1e-3, lastLook = 0, lastTouch = -1e9, steerT = 0;
  let fade = 0, fadeDir = 1, paused = false, leaving = false;
  let frames = 0, jitterI = 0, still = 0, hi = false;

  const quad = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

  function target2d(w, h, internal) {
    const tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texStorage2D(gl.TEXTURE_2D, 1, internal, w, h);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    const fb = gl.createFramebuffer();
    gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    return { tex, fb, w, h, free() { gl.deleteTexture(tex); gl.deleteFramebuffer(fb); } };
  }
  const probe = target2d(PROBE, PROBE, gl.RGBA8);
  const probePx = new Uint8Array(PROBE * PROBE * 4);
  let sampled = null, hist = [null, null], histAt = 0;

  function shader(type, src) {
    const s = gl.createShader(type);
    gl.shaderSource(s, src); gl.compileShader(s);
    return s;
  }
  // Compiles without waiting where the browser can (KHR_parallel_shader_compile).
  const parallel = gl.getExtension('KHR_parallel_shader_compile');
  function link(fs) {
    const p = gl.createProgram();
    const f = shader(gl.FRAGMENT_SHADER, fs);
    gl.attachShader(p, shader(gl.VERTEX_SHADER, VS)); gl.attachShader(p, f);
    gl.bindAttribLocation(p, 0, 'aPos');
    gl.linkProgram(p);
    return { p, f };
  }
  function program(fs) {
    const { p, f } = link(fs);
    return new Promise((resolve, reject) => {
      const check = () => {
        if (parallel && !gl.getProgramParameter(p, parallel.COMPLETION_STATUS_KHR)) { setTimeout(check, 30); return; }
        if (!gl.getProgramParameter(p, gl.LINK_STATUS)) reject(new Error(gl.getShaderInfoLog(f) || gl.getProgramInfoLog(p)));
        else resolve(p);
      };
      check();
    });
  }
  function uniforms(p, names) { const u = {}; for (const n of names) u[n] = gl.getUniformLocation(p, n); return u; }
  const resolve = link(RESOLVE_FS).p, show = link(SHOW_FS).p;
  const RU = uniforms(resolve, ['uCur', 'uHist', 'uRes', 'uView', 'uPrev', 'uKeep', 'uClip']);
  const SU = uniforms(show, ['uTex', 'uFade', 'uRes']);

  // Its gradients: the PNG's top half, UF's rows (the bottom half is the same in linear light).
  async function gradient(id) {
    const blob = await (await fetch('live/' + id + '.png')).blob();
    const bmp = await createImageBitmap(blob, { colorSpaceConversion: 'none', premultiplyAlpha: 'none' });
    const rows = Math.max(1, bmp.height >> 1);
    const c = document.createElement('canvas');
    c.width = bmp.width; c.height = rows;
    c.getContext('2d', { colorSpace: 'srgb' }).drawImage(bmp, 0, 0);
    const tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.pixelStorei(gl.UNPACK_COLORSPACE_CONVERSION_WEBGL, gl.NONE);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, gl.RGBA, gl.UNSIGNED_BYTE, c);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    return tex;
  }

  const loaded = new Map();
  function load(pick) {
    if (!loaded.has(pick.id)) {
      loaded.set(pick.id, (async () => {
        const src = await (await fetch('live/' + pick.id + '.glsl')).text();
        const [prog, tex] = await Promise.all([program(HEAD + common + src + MAIN), gradient(pick.id)]);
        return { pick, prog, tex, uni: uniforms(prog, ['uGrad', 'uAA', 'uView', 'uRes', 'uJitter']) };
      })());
    }
    return loaded.get(pick.id);
  }

  function showName(pick) {
    if (info) info.textContent = pick.name.replace(/_dotdotdot_/g, ' … ').replace(/_/g, ' ');
    if (poster) poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)';
  }

  async function begin(i) {
    at = (i + order.length) % order.length;
    const pick = order[at];
    let next;
    try { next = await load(pick); }
    catch (e) { console.warn('live: ' + pick.id + ' did not compile', e); order.splice(at, 1); if (order.length) begin(at); return; }
    cur = next;
    showName(pick);
    // The whole 2k to start with, then in until fp32 runs out (its depth past the 2k).
    startH = 1.0;
    // Its depth is how far past its 2k fp32 holds: a pixel no finer than 1/(2048 depth) of the
    // picture's height. Taken at the screen's own pixels (not the render's, which can be coarser
    // for a while), with a margin, since the sub-pixel samples go finer still.
    const screenPx = canvas.getBoundingClientRect().height * Math.min(window.devicePixelRatio || 1, 2);
    minH = Math.max(startH / 4096, screenPx * PRECISION_MARGIN / (2048 * pick.depth));
    view = { x: 0, y: 0, h: startH };
    target = { x: 0, y: 0 }; aim = { x: 0, y: 0 }; vel = { x: 0, y: 0 };
    lastLook = performance.now() / 1000 - RETARGET + 1.0; steerT = 0;
    fade = 0; fadeDir = 1; leaving = false; frames = 0; still = 0; prevView = null;
    load(order[(at + 1) % order.length]).catch(() => {});   // the next one compiles meanwhile
  }

  function quadDraw(w, h) {
    gl.viewport(0, 0, w, h);
    gl.bindBuffer(gl.ARRAY_BUFFER, quad);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
  function drawFractal(w, h, v, aa, jx, jy) {
    const u = cur.uni;
    gl.useProgram(cur.prog);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, cur.tex);
    gl.uniform1i(u.uGrad, 0);
    gl.uniform1i(u.uAA, aa);
    gl.uniform3f(u.uView, v.x, v.y, v.h);
    gl.uniform2f(u.uRes, w, h);
    gl.uniform2f(u.uJitter, jx, jy);
    quadDraw(w, h);
  }

  // Where's the detail? A small render of the view, and the cell with the most contrast among
  // its neighbours, leaning towards the middle and towards the way it's already drifting, so
  // its course bends gently rather than doubling back.
  function look() {
    gl.bindFramebuffer(gl.FRAMEBUFFER, probe.fb);
    drawFractal(PROBE, PROBE, view, 1, 0, 0);
    gl.readPixels(0, 0, PROBE, PROBE, gl.RGBA, gl.UNSIGNED_BYTE, probePx);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    const L = (x, y) => { const k = (y * PROBE + x) * 4; return 0.3 * probePx[k] + 0.59 * probePx[k + 1] + 0.11 * probePx[k + 2]; };
    const sp = Math.hypot(vel.x, vel.y);
    let best = -1, bx = PROBE / 2, by = PROBE / 2;
    for (let y = 4; y < PROBE - 4; y += 2) for (let x = 4; x < PROBE - 4; x += 2) {
      let s = 0, s2 = 0;
      for (let j = -2; j <= 2; j++) for (let i = -2; i <= 2; i++) { const l = L(x + i, y + j); s += l; s2 += l * l; }
      const sd = Math.sqrt(Math.max(s2 / 25 - (s / 25) * (s / 25), 0));
      const dx = x / PROBE - 0.5, dy = y / PROBE - 0.5, r = Math.hypot(dx, dy);
      const along = sp > 1e-4 && r > 1e-3 ? (dx * vel.x + dy * vel.y) / (r * sp) : 0;
      const score = sd * (1 - 1.8 * r * r) * (1 + 0.5 * along) + Math.random() * 2;
      if (score > best) { best = score; bx = x; by = y; }
    }
    // (The probe's square, view.h each way, so only the middle of a wide screen is looked at.)
    target = { x: view.x + (bx / PROBE - 0.5) * view.h * 0.7, y: view.y + (by / PROBE - 0.5) * view.h * 0.7 };
  }

  // Quality: a step on LADDER, moved by how long frames take. A step that proved too slow is
  // kept off for a while (longer each time), so it doesn't see-saw.
  const maxScale = () => Math.min(window.devicePixelRatio || 1, 1.5);
  const steps = () => LADDER.filter(s => s[0] <= maxScale() + 1e-6);
  let step = 2, ceiling = 99, ceilingUntil = 0, ceilingFor = 15, frameTimes = [];
  function adapt(dt, now) {
    if (hi) { frameTimes = []; return; }   // (slow frames at full resolution are fine while still)
    frameTimes.push(dt);
    if (frameTimes.length < 30) return;
    frameTimes.sort((a, b) => a - b);
    const med = frameTimes[15];
    frameTimes = [];
    const top = steps().length - 1;
    if (now > ceilingUntil) ceiling = 99;
    if (med > 0.03 && step > 0) { ceiling = step - 1; ceilingUntil = now + ceilingFor; ceilingFor = Math.min(ceilingFor * 2, 240); step--; }
    else if (med < 0.019 && step < Math.min(top, ceiling)) step++;
    step = Math.min(step, top);
  }

  function resize() {
    const r = canvas.getBoundingClientRect();
    const s = hi ? Math.min(window.devicePixelRatio || 1, 2) : steps()[step][0];
    const w = Math.max(16, Math.round(r.width * s)), h = Math.max(16, Math.round(r.height * s));
    if (canvas.width === w && canvas.height === h && sampled) return;
    canvas.width = w; canvas.height = h;
    for (const t of [sampled, hist[0], hist[1]]) if (t) t.free();
    sampled = target2d(w, h, gl.RGBA8);
    hist = [target2d(w, h, floatHist ? gl.RGBA16F : gl.RGBA8), target2d(w, h, floatHist ? gl.RGBA16F : gl.RGBA8)];
    frames = 0;
  }

  // Halton (2, 3): sub-pixel offsets that cover the pixel evenly.
  function halton(i, b) { let f = 1, r = 0; while (i > 0) { f /= b; r += f * (i % b); i = Math.floor(i / b); } return r; }

  function render() {
    const w = canvas.width, h = canvas.height;
    jitterI = (jitterI % 64) + 1;
    gl.bindFramebuffer(gl.FRAMEBUFFER, sampled.fb);
    drawFractal(w, h, view, steps()[step][1], halton(jitterI, 2) - 0.5, halton(jitterI, 3) - 0.5);
    const src = hist[histAt], dst = hist[1 - histAt];
    gl.bindFramebuffer(gl.FRAMEBUFFER, dst.fb);
    gl.useProgram(resolve);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, sampled.tex);
    gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, src.tex);
    gl.uniform1i(RU.uCur, 0); gl.uniform1i(RU.uHist, 1);
    gl.uniform2f(RU.uRes, w, h);
    gl.uniform3f(RU.uView, view.x, view.y, view.h);
    const pv = prevView || view;
    gl.uniform3f(RU.uPrev, pv.x, pv.y, pv.h);
    // More careful the deeper it is (Dan: the blending fuzzed the detail zoomed in): less history,
    // clipped tighter, by how far through its depth it's got.
    const deep = Math.min(1, Math.max(0, Math.log(startH / view.h) / Math.log(startH / minH)));
    const keepMax = still > 0 ? 1 - 1 / (floatHist ? STILL_FRAMES : 12) : KEEP_MAX - (KEEP_MAX - KEEP_DEEP) * deep;   // still: a plain running average
    gl.uniform1f(RU.uKeep, frames > 0 && TAA ? Math.min(1 - 1 / (frames + 1), keepMax) : 0);
    gl.uniform1f(RU.uClip, still > 0 ? 1e3 : CLIP - (CLIP - CLIP_DEEP) * deep);
    quadDraw(w, h);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.useProgram(show);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, dst.tex);
    gl.uniform1i(SU.uTex, 0);
    gl.uniform1f(SU.uFade, fade * fade * (3 - 2 * fade));
    gl.uniform2f(SU.uRes, w, h);
    quadDraw(w, h);
    histAt = 1 - histAt;
    prevView = { ...view };
    frames++;
  }

  let visible = true;
  new IntersectionObserver(es => { visible = es[0].isIntersecting; }).observe(canvas);

  const smooth = (a, b, x) => { const t = Math.min(1, Math.max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t); };
  let prev = performance.now() / 1000;
  function frame() {
    requestAnimationFrame(frame);
    const now = performance.now() / 1000;
    const dt = Math.min(now - prev, 0.1); prev = now;
    if (!cur || !visible || document.hidden) { frames = 0; return; }
    adapt(dt, now);
    resize();
    if (!paused && now - lastTouch > IDLE_RESUME) {
      // Ease in after a start or a touch, and out towards the end of its depth.
      steerT += dt;
      const ease = smooth(0, 4, steerT) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h));
      view.h *= Math.pow(2, -ZOOM_RATE * ease * dt);
      if (now - lastLook > RETARGET) { lastLook = now; look(); }
      // The aim glides to the target, and a critically damped spring follows the aim, so the
      // drift's speed and direction both change smoothly (no kinks when the target moves).
      const k = 1 - Math.exp(-dt * 0.4);
      aim.x += (target.x - aim.x) * k; aim.y += (target.y - aim.y) * k;
      const w0 = 0.6;
      for (const c of ['x', 'y']) {
        const err = (aim[c] - view[c]) / view.h;   // in screen heights
        vel[c] += (w0 * w0 * err - 2 * w0 * vel[c]) * dt;
      }
      const sp = Math.hypot(vel.x, vel.y), cap = DRIFT_MAX * ease + 1e-6;
      if (sp > cap) { vel.x *= cap / sp; vel.y *= cap / sp; }
      view.x += vel.x * view.h * dt; view.y += vel.y * view.h * dt;
      if (view.h <= minH * 1.2 && !leaving) { leaving = true; fadeDir = -1; }
    }
    fade = Math.min(1, Math.max(0, fade + fadeDir * dt / FADE));
    if (leaving && fade <= 0) { begin(at + 1); return; }
    const pv = prevView;
    still = pv && pv.x === view.x && pv.y === view.y && pv.h === view.h ? still + 1 : 0;
    if (hi !== (HI_OK && still > STILL_HI)) { hi = !hi; resize(); }
    if (still > STILL_HI + STILL_DONE && fade >= 1) return;
    render();
    if (poster && fade > 0.99) poster.classList.add('gone');
  }

  // After the hand: carry on from here, still.
  function touched() {
    lastTouch = performance.now() / 1000;
    target = { x: view.x, y: view.y }; aim = { ...target }; vel = { x: 0, y: 0 }; steerT = 0;
  }
  // The plane under a point on the canvas (client px).
  function planeAt(cx, cy) {
    const r = canvas.getBoundingClientRect();
    return { x: view.x + (cx - r.left - r.width / 2) / r.height * view.h, y: view.y - (cy - r.top - r.height / 2) / r.height * view.h };
  }
  // Zoom by f about a client point, which stays put.
  function zoomAbout(f, cx, cy) {
    const a = planeAt(cx, cy);
    const h = Math.min(1e6, Math.max(minH, view.h * f));   // out as far as you like (1e6: well short of fp32 trouble)
    view.x = a.x + (view.x - a.x) * h / view.h; view.y = a.y + (view.y - a.y) * h / view.h;
    view.h = h;
    touched();
  }
  function panBy(dx, dy) {
    const r = canvas.getBoundingClientRect();
    view.x -= dx / r.height * view.h; view.y += dy / r.height * view.h;
    touched();
  }

  // Mouse and pen: drag to move, Ctrl+wheel (or a trackpad's pinch, which sends that) to zoom.
  let mouse = null;
  canvas.addEventListener('pointerdown', e => { if (e.pointerType === 'touch') return; canvas.setPointerCapture(e.pointerId); mouse = { x: e.clientX, y: e.clientY }; touched(); });
  canvas.addEventListener('pointermove', e => { if (!mouse || e.pointerType === 'touch') return; panBy(e.clientX - mouse.x, e.clientY - mouse.y); mouse = { x: e.clientX, y: e.clientY }; });
  canvas.addEventListener('pointerup', () => { mouse = null; });
  canvas.addEventListener('pointercancel', () => { mouse = null; });
  canvas.addEventListener('wheel', e => {
    if (!e.ctrlKey) return;   // a plain wheel scrolls the page
    e.preventDefault(); zoomAbout(Math.pow(2, e.deltaY * 0.01), e.clientX, e.clientY);
  }, { passive: false });

  // Touch, by touch events (the canvas is touch-action: pan-y): two fingers pinch and move it;
  // one finger moving sideways first moves it, and moving up or down first scrolls the page.
  let tmode = null, t0 = null, pinchD = 0, pinchM = null;
  const mid = ts => ({ x: (ts[0].clientX + ts[1].clientX) / 2, y: (ts[0].clientY + ts[1].clientY) / 2 });
  const dist = ts => Math.hypot(ts[0].clientX - ts[1].clientX, ts[0].clientY - ts[1].clientY);
  canvas.addEventListener('touchstart', e => {
    if (e.touches.length >= 2) {
      e.preventDefault();
      tmode = 'pinch'; pinchD = dist(e.touches); pinchM = mid(e.touches); touched();
    } else if (e.touches.length === 1) {
      tmode = null; t0 = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    }
  }, { passive: false });
  canvas.addEventListener('touchmove', e => {
    if (e.touches.length >= 2) {
      if (e.cancelable) e.preventDefault();
      if (tmode !== 'pinch') { tmode = 'pinch'; pinchD = dist(e.touches); pinchM = mid(e.touches); return; }
      const d = dist(e.touches), m = mid(e.touches);
      panBy(m.x - pinchM.x, m.y - pinchM.y);
      zoomAbout(pinchD / Math.max(d, 1), m.x, m.y);
      pinchD = d; pinchM = m;
      return;
    }
    const t = e.touches[0];
    if (!t0 || tmode === 'scroll' || tmode === 'pinch') return;
    const dx = t.clientX - t0.x, dy = t.clientY - t0.y;
    if (!tmode) {
      if (Math.hypot(dx, dy) < 6) return;
      tmode = Math.abs(dx) > Math.abs(dy) ? 'pan' : 'scroll';
      if (tmode === 'scroll') return;
    }
    if (e.cancelable) e.preventDefault();
    panBy(dx, dy);
    t0 = { x: t.clientX, y: t.clientY };
  }, { passive: false });
  canvas.addEventListener('touchend', e => {
    if (e.touches.length === 0) { tmode = null; t0 = null; }
    else if (e.touches.length === 1) { tmode = 'pan'; t0 = { x: e.touches[0].clientX, y: e.touches[0].clientY }; }
  });

  window.UILive = {
    next() { leaving = true; fadeDir = -1; lastTouch = -1e9; },
    togglePause() { paused = !paused; if (!paused) steerT = 0; return paused; },
  };

  canvas.addEventListener('webglcontextlost', e => { e.preventDefault(); cur = null; });

  (async () => {
    let picks;
    [common, picks] = await Promise.all([
      fetch('live/common.glsl').then(r => r.text()),
      fetch('live/picks.json').then(r => r.json()),
    ]);
    order = picks.slice();
    for (let i = order.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [order[i], order[j]] = [order[j], order[i]]; }
    // ?pick=<id or the start of its name>: start with that one.
    const want = (new URLSearchParams(location.search).get('pick') || '').toLowerCase();
    const first = want ? order.findIndex(p => p.id.startsWith(want) || p.name.toLowerCase().startsWith(want)) : -1;
    if (first > 0) order.unshift(...order.splice(first, 1));
    showName(order[0]);
    await begin(0);
    requestAnimationFrame(frame);
  })();
})();
