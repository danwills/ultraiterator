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
uniform vec2 uRot;         // the view's turn, (cos, sin)
out vec4 frag;
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
`;
  // As the app's LIVE_GEN_MAIN, but `o` from the view rather than a tile.
  const MAIN = `
void main() {
    vec3 sum = vec3(0.0);
    float px = uView.z / uRes.y;
    for (int j = 0; j < uAA; j++) for (int i = 0; i < uAA; i++) {
        vec2 f = gl_FragCoord.xy + uJitter + (vec2(i, j) + 0.5) / float(uAA) - 0.5;
        sum += liveColour(uView.xy + uiTurn(uRot, (f - 0.5 * uRes) * px));
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
uniform vec2 uRot, uPrevRot;   // their turns, (cos, sin)
uniform float uKeep;       // the history's weight (0: start afresh)
uniform float uClip;       // how far (in the neighbourhood's spreads) history may stray from this frame
out vec4 frag;
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
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
    vec2 o = uView.xy + uiTurn(uRot, (f - 0.5 * uRes) * (uView.z / uRes.y));
    vec2 pf = uiTurn(uPrevRot * vec2(1.0, -1.0), o - uPrev.xy) * (uRes.y / uPrev.z) + 0.5 * uRes;
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
        // Moving fast, the history counts for less and is clipped closer (it smeared into
        // streaks on quick pans and zooms), and pixels that came in past the edge only borrow
        // the edge's history when they're within a pixel or two of it.
        float speed = length(pf - f);   // this pixel's travel since last frame, in pixels
        float outside = length(pf - clamp(pf, vec2(1.5), uRes - 1.5));
        float clip = uClip / (1.0 + 0.12 * speed);
        h = clamp(h, m1 - clip * sd, m1 + clip * sd);
        c = mix(c, h, uKeep * exp(-outside / 2.5) / (1.0 + 0.08 * speed));
    }
    frag = vec4(c, 1.0);
}`;
  // To the screen: the moving view's blend, or (still) the refinement's sum over its count,
  // read where this pixel's plane point was when it began (so it can fade out as the view moves).
  const SHOW_FS = `#version 300 es
precision highp float;
uniform sampler2D uTex;    // the moving view's blend, at its own size
uniform sampler2D uAcc;    // the refinement: colour sums, and their count in alpha
uniform float uFade, uRefMix;
uniform float uSeed;       // the moving view's picture counts as this many samples in the refinement
uniform vec2 uRes, uAccRes;
uniform vec2 uHistRes;      // the blend's size (it reaches a little past the screen all round)
uniform vec3 uView, uRefView, uHistView;
uniform vec2 uRot, uRefRot, uHistRot;
uniform bool uSmooth;      // the refinement's turned under the view (a rest): read it bilinearly
out vec4 frag;
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
// The sums and counts both blend linearly, so a bilinear read of each (by hand: float textures
// needn't filter) still divides out to a proper average.
vec4 accAt(vec2 pf) {
    if (!uSmooth) return texelFetch(uAcc, ivec2(pf), 0);
    vec2 p = pf - 0.5, t = fract(p);
    ivec2 i = ivec2(floor(p)), hi = ivec2(uAccRes) - 1;
    ivec2 i0 = clamp(i, ivec2(0), hi), i1 = clamp(i + 1, ivec2(0), hi);
    return mix(mix(texelFetch(uAcc, i0, 0), texelFetch(uAcc, ivec2(i1.x, i0.y), 0), t.x),
               mix(texelFetch(uAcc, ivec2(i0.x, i1.y), 0), texelFetch(uAcc, i1, 0), t.x), t.y);
}
void main() {
    vec2 f = gl_FragCoord.xy;
    vec2 o = uView.xy + uiTurn(uRot, (f - 0.5 * uRes) * (uView.z / uRes.y));
    // The blend, where its view was (it waits while refining, as the view turns on in a rest).
    vec2 hq = uiTurn(uHistRot * vec2(1.0, -1.0), o - uHistView.xy) / uHistView.z;
    vec3 c = texture(uTex, vec2(hq.x * uHistRes.y / uHistRes.x, hq.y) + 0.5).rgb;
    if (uRefMix > 0.0) {
        vec2 pf = uiTurn(uRefRot * vec2(1.0, -1.0), o - uRefView.xy) * (uAccRes.y / uRefView.z) + 0.5 * uAccRes;
        if (all(greaterThanEqual(pf, vec2(0.0))) && all(lessThan(pf, uAccRes))) {
            vec4 a = accAt(pf);
            // From the first sample on: the moving view's picture, worth uSeed samples, and the
            // refinement's, so it improves at once and smoothly takes over.
            c = mix(c, (c * uSeed + a.rgb) / (uSeed + a.a), uRefMix);
        }
    }
    // A slight vignette: corners down to ~70%, the middle untouched.
    vec2 q = (gl_FragCoord.xy / uRes - 0.5) * 2.0;
    float r = length(q * vec2(uRes.x / length(uRes), uRes.y / length(uRes))) * 1.4142;
    float v = mix(1.0, 0.7, smoothstep(0.45, 1.0, r));
    frag = vec4(c * uFade * v, 1.0);
}`;

  // The refinement so far, as a picture, into the moving view's buffer (at the view as it is now):
  // what a refinement started again at another resolution fades in from (rather than back from
  // the blurrier moving view), and what the moving view carries on from after a rest.
  const BAKE_FS = `#version 300 es
precision highp float;
uniform sampler2D uAcc;
uniform vec2 uRes, uAccRes;
uniform vec3 uView, uRefView;
uniform vec2 uRot, uRefRot;
out vec4 frag;
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
void main() {
    vec2 o = uView.xy + uiTurn(uRot, (gl_FragCoord.xy - 0.5 * uRes) * (uView.z / uRes.y));
    vec2 pf = uiTurn(uRefRot * vec2(1.0, -1.0), o - uRefView.xy) * (uAccRes.y / uRefView.z) + 0.5 * uAccRes;
    vec4 a = texelFetch(uAcc, clamp(ivec2(pf), ivec2(0), ivec2(uAccRes) - 1), 0);
    frag = vec4(a.a > 0.0 ? a.rgb / a.a : vec3(0.0), 1.0);
}`;

  const ZOOM_RATE = 0.2;       // octaves a second (quicker since the rests show it sharp; was 0.085, then 0.13)
  const TURN_MAX = 0.015;      // the most it turns, radians a second (~0.9°; ~0.6° a second on average)
  let turnT = 0, turnPh = Math.random() * 6.283, turnSteer = 0;   // (turnSteer: s since a start or a touch)
  // Its rate, radians a second, at turn time t: a low, signed noise (two slow sines).
  const turnRate = (t, ease) => TURN_MAX * ease * (0.6 * Math.sin(0.043 * t + turnPh) + 0.4 * Math.sin(0.0187 * t + 2.1 * turnPh));
  const DRIFT_MAX = 0.045;     // the most it drifts sideways, in screen heights a second
  const RETARGET = 4.5;        // seconds between looks for detail
  const PROBE = 40;            // the look's size, px square
  const IDLE_RESUME = 9;       // seconds after a touch before it steers itself again
  // Rests: the dive eases to a stop now and then (after REST_EVERY s of moving) and holds still for
  // REST_HOLD s, so the refinement gets to show; the pause pearl counts it down as after a touch.
  const REST_EVERY = [15, 30], REST_HOLD = 10, REST_SETTLE = 3, REST_RESUME = 3;
  // A word under the pause pearl as a rest begins and ends.
  const sayEl = document.getElementById('live-say'), SAY_FOR = 3.5;
  let sayTimer = 0, restHolding = false;
  function say(text) {
    if (!sayEl) return;
    const pp = document.getElementById('pause-pearl'), box = sayEl.parentElement;
    if (pp && box) sayEl.style.right = (box.clientWidth - pp.offsetLeft - pp.offsetWidth) + 'px';   // (under the pearl, its right edges level)
    sayEl.textContent = text; sayEl.classList.add('on');
    clearTimeout(sayTimer); sayTimer = setTimeout(() => sayEl.classList.remove('on'), SAY_FOR * 1000);
  }
  function onWeGo() {
    let n = 0;
    try { n = (parseInt(localStorage.getItem('ultraiterator-resumes'), 10) || 0) + 1; localStorage.setItem('ultraiterator-resumes', n); } catch (e) { n = (onWeGo.n = (onWeGo.n || 0) + 1); }
    say(n % 20 === 0 ? "on y'va" : 'on we go');
  }
  const restIn = () => REST_EVERY[0] + Math.random() * (REST_EVERY[1] - REST_EVERY[0]);
  const FADE = 1.5;            // seconds to fade between fractals
  const KEEP_MAX = 0.9;        // the history's most weight: about the last ten frames
  const KEEP_DEEP = 0.75;      // ...and at the end of its depth
  const CLIP = 2.0;            // variance clipping's reach (RESOLVE_FS) while it moves
  const CLIP_DEEP = 1.25;      // ...and at the end of its depth
  // Still (paused, or left alone after a touch) for STILL_REFINE frames, it refines: each frame
  // adds one sample a pixel to a running sum, at a fresh sub-pixel spot (Halton, so they never
  // repeat), spread as a Gaussian of REF_SIGMA px, so after N frames it's as if rendered at √N×
  // and downsampled with a soft filter: 2× by 4, 8× by 64, 32× by REF_MAX. On a desktop (a mouse
  // to hover with) it refines at the screen's full resolution; a phone keeps its own, for its
  // battery. Once done it stops drawing (the canvas keeps its picture).
  const STILL_REFINE = 15;
  const REF_SIGMA = 0.42;
  const HI_OK = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
  // It keeps refining up to this many samples a pixel (256x on a desktop: an hour or so, gently).
  // The sum is one 32-bit buffer whatever the count, so going on costs time, not memory.
  const REF_MAX = HI_OK ? 65536 : 1024;
  // ...using about this share of the GPU: after each piece of work it rests as long as that took.
  // A sample a pixel that takes too long in one go is split into bands of rows, so nothing else
  // on the machine waits long behind it.
  const REF_DUTY = 0.4;
  // A band's GPU time at most: a GPU can't stop part-way through a draw, so the desktop's own
  // drawing waits behind each one; short ones keep the whole machine responsive, not just the page.
  const REF_BAND_MAX_MS = 3;
  // ...but the page must stay smooth (Dan: full resolution on a modest GPU made everything sluggish).
  // Its frame rate's watched while refining: under REF_MIN_FPS it takes a smaller share of the GPU,
  // down to REF_DUTY_MIN, and past that refines at a lower resolution (a step of REF_SCALE_STEP,
  // starting the sum again there). The resolution that kept up is remembered in this browser.
  const REF_MIN_FPS = 30;
  const REF_DUTY_MIN = 0.25;
  const REF_SCALE_STEP = 0.75;
  const REF_SCALE_KEY = 'ultraiterator-refine-scale';
  // And back up: comfortable (REF_UP_FPS at its full share) for REF_UP_AFTER s, it tries a step
  // higher; a step that then proves too slow isn't tried again for REF_UP_WAIT s (doubling).
  const REF_UP_FPS = 50;
  const REF_UP_AFTER = 45;
  const REF_UP_WAIT = 300;
  // Slower than this a frame even at the ladder's bottom: it gives up and shows the picture.
  const TOO_SLOW = 0.3;
  const REF_SEED = 6;          // the moving view's picture's worth, in samples, as refinement begins (SHOW_FS)
  const REF_IN = 1.5;          // seconds the refinement takes to fade in
  let refStartT = 0;
  const REF_OUT = 0.5;         // seconds to fade back out once the view moves
  // Without float blending: a plain running average in the moving view's blend instead, this long.
  const STILL_FRAMES = 128;
  const PRECISION_MARGIN = 2;  // stop this many times short of where fp32 runs out
  const TAA = new URLSearchParams(location.search).get('taa') !== '0';   // ?taa=0: no blending, to compare
  // Render scale (CSS px a pixel, up to the screen's own) and samples a side, cheapest first.
  // Slower hardware goes down to a quarter: softer, but its blend (LOW_*) keeps it steady and
  // smooth, which looks better than a sharper picture that sizzles (Dan, 2026-11-19).
  const LADDER = [[0.25, 1], [0.32, 1], [0.4, 1], [0.5, 1], [0.65, 1], [0.8, 1], [1, 1], [1.25, 1], [1.5, 1], [1.5, 2]];
  const LOW_SCALE = 0.5;       // at or below this render scale...
  const LOW_KEEP = 0.95;       // ...it keeps more history (about twenty frames)
  const LOW_CLIP = 3.5;        // ...and clips it less

  const canvas = document.getElementById('live');
  const info = document.getElementById('live-name');
  const poster = document.getElementById('live-poster');
  if (!canvas) return;
  const gl = canvas.getContext('webgl2', { antialias: false, alpha: false, preserveDrawingBuffer: false });
  if (!gl) { document.body.classList.add('no-live'); return; }
  const floatHist = !!gl.getExtension('EXT_color_buffer_float');
  const canRefine = floatHist && !!gl.getExtension('EXT_float_blend');
  const timer = gl.getExtension('EXT_disjoint_timer_query_webgl2');

  let common = '';
  let wanted = null;   // UILive.show's, before the list's loaded
  let order = [];
  let cur = null;          // { pick, prog, tex, uni }
  let at = 0;              // place in `order`
  let view = { x: 0, y: 0, h: 1, a: 0 }, prevView = null;   // (a: its turn, radians anticlockwise)
  let target = { x: 0, y: 0 }, aim = { x: 0, y: 0 }, vel = { x: 0, y: 0 };
  let startH = 1, minH = 1e-3, lastLook = 0, steerT = 0, easeFor = 4;   // (easeFor: s to reach full speed)
  // Held still till holdUntil (a touch, or a rest), holdLen s in all; moving for movedT s since the
  // last rest, the next after nextRest; settleAt: when a rest began easing to a stop (or null).
  let holdUntil = -1e9, holdLen = IDLE_RESUME, movedT = 0, nextRest = restIn(), settleAt = null;
  let fade = 0, fadeDir = 1, paused = false, leaving = false;
  let frames = 0, jitterI = 0, still = 0;
  const READY_FRAMES = 8;   // frames blended before it fades in
  let refining = false, refN = 0, refMix = 0, refView = null, acc = null, refTurns = false;
  let refSync = null, refSubmit = 0, refRest = 0, band = 0, bands = 1;

  const quad = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

  function target2d(w, h, internal) {
    const tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texStorage2D(gl.TEXTURE_2D, 1, internal, w, h);
    const filter = internal === gl.RGBA32F ? gl.NEAREST : gl.LINEAR;   // (32-bit float isn't filterable everywhere)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, filter);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, filter);
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
  const resolve = link(RESOLVE_FS).p, show = link(SHOW_FS).p, bake = link(BAKE_FS).p;
  const BU = uniforms(bake, ['uAcc', 'uRes', 'uAccRes', 'uView', 'uRefView', 'uRot', 'uRefRot']);
  const RU = uniforms(resolve, ['uCur', 'uHist', 'uRes', 'uView', 'uPrev', 'uKeep', 'uClip', 'uRot', 'uPrevRot']);
  const SU = uniforms(show, ['uTex', 'uAcc', 'uFade', 'uRefMix', 'uSeed', 'uRes', 'uAccRes', 'uView', 'uRefView', 'uRot', 'uRefRot', 'uHistView', 'uHistRot', 'uSmooth', 'uHistRes']);

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

  const SLOW = +(new URLSearchParams(location.search).get('slow') || 0);
  const loaded = new Map();
  function load(pick) {
    if (!loaded.has(pick.id)) {
      loaded.set(pick.id, (async () => {
        const src = await (await fetch('live/' + pick.id + '.glsl')).text();
        if (SLOW) await new Promise(r => setTimeout(r, SLOW));   // (?slow=ms: a slow compile, to test the wait)
        const [prog, tex] = await Promise.all([program(HEAD + common + src + MAIN), gradient(pick.id)]);
        return { pick, prog, tex, uni: uniforms(prog, ['uGrad', 'uAA', 'uView', 'uRes', 'uJitter', 'uRot']) };
      })());
    }
    return loaded.get(pick.id);
  }

  function showName(pick) {
    if (info) info.textContent = pick.name.replace(/_dotdotdot_/g, ' … ').replace(/_/g, ' ');
    if (poster) poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)';
  }

  // (starting: a begin is waiting for its fractal; frames meanwhile mustn't start more. They had,
  // one a frame, each the next along, compiling several at once: black for ages between fractals.)
  let starting = false, beganAt = 0, queued = null;
  const WAIT_SHOW = 0.4;   // s of waiting before the render's shown   // (queued: a show() that came while starting)
  async function begin(i) {
    if (starting) return;
    starting = true;
    at = (i + order.length) % order.length;
    const pick = order[at];
    // A slow compile (a shader not ready yet, ~10 s for some): its 2k render shows meanwhile, not
    // black, and the live one cross-fades in over it once it's ready.
    const waitT = setTimeout(() => {
      if (!starting) return;
      if (poster) { poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)'; poster.classList.remove('gone'); }
      document.body.classList.add('waiting');
    }, WAIT_SHOW * 1000);
    let next;
    try { next = await load(pick); }
    catch (e) { console.warn('live: ' + pick.id + ' did not compile', e); order.splice(at, 1); starting = false; if (order.length) begin(at); return; }
    starting = false;
    clearTimeout(waitT);
    if (queued !== null) { const q = queued; queued = null; begin(q); return; }
    cur = next; beganAt = performance.now() / 1000;
    showName(pick);
    // The whole 2k to start with, then in until fp32 runs out (its depth past the 2k).
    startH = 1.0;
    // Its depth is how far past its 2k fp32 holds: a pixel no finer than 1/(2048 depth) of the
    // picture's height. Taken at the screen's own pixels (not the render's, which can be coarser
    // for a while), with a margin, since the sub-pixel samples go finer still.
    const screenPx = canvas.getBoundingClientRect().height * Math.min(window.devicePixelRatio || 1, 2);
    minH = Math.max(startH / 4096, screenPx * PRECISION_MARGIN / (2048 * pick.depth));
    view = { x: 0, y: 0, h: startH, a: 0 };
    target = { x: 0, y: 0 }; aim = { x: 0, y: 0 }; vel = { x: 0, y: 0 };
    lastLook = performance.now() / 1000 - RETARGET + 1.0; steerT = 0; easeFor = 4; turnSteer = 0;
    // (the first rest a quarter of the usual way in, as if it had joined a cycle partway through)
    holdUntil = -1e9; movedT = 0; nextRest = restIn() / 4; settleAt = null; restHolding = false;
    fade = 0; fadeDir = 1; leaving = false; frames = 0; still = 0; prevView = null; stopRefine(); refMix = 0;
    if (document.body.classList.contains('waiting')) fade = 1;   // (the canvas's own opacity does the cross-fade)
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
    gl.uniform2f(u.uRot, Math.cos(v.a), Math.sin(v.a));
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
    const sp = Math.hypot(vel.x, vel.y), ca = Math.cos(view.a), sa = Math.sin(view.a);
    const sv = { x: ca * vel.x + sa * vel.y, y: -sa * vel.x + ca * vel.y };   // (its drift on screen)
    let best = -1, bx = PROBE / 2, by = PROBE / 2;
    for (let y = 4; y < PROBE - 4; y += 2) for (let x = 4; x < PROBE - 4; x += 2) {
      let s = 0, s2 = 0;
      for (let j = -2; j <= 2; j++) for (let i = -2; i <= 2; i++) { const l = L(x + i, y + j); s += l; s2 += l * l; }
      const sd = Math.sqrt(Math.max(s2 / 25 - (s / 25) * (s / 25), 0));
      const dx = x / PROBE - 0.5, dy = y / PROBE - 0.5, r = Math.hypot(dx, dy);
      const along = sp > 1e-4 && r > 1e-3 ? (dx * sv.x + dy * sv.y) / (r * sp) : 0;
      const score = sd * (1 - 1.8 * r * r) * (1 + 0.5 * along) + Math.random() * 2;
      if (score > best) { best = score; bx = x; by = y; }
    }
    // (The probe's square, view.h each way, so only the middle of a wide screen is looked at.)
    const ox = (bx / PROBE - 0.5) * view.h * 0.7, oy = (by / PROBE - 0.5) * view.h * 0.7;
    target = { x: view.x + ca * ox - sa * oy, y: view.y + sa * ox + ca * oy };
  }

  // Quality: a step on LADDER, moved by how long frames take. A step that proved too slow is
  // kept off for a while (longer each time), so it doesn't see-saw.
  // Down a step under ~12 fps (Dan: a sharper moving view is worth a slower one, on a slow GPU),
  // and up one only where the next (~1.5x the pixels) would still be over it.
  const MOVE_SLOW = 1 / 12, MOVE_UP = 1 / 20;
  const maxScale = () => Math.min(window.devicePixelRatio || 1, 1.5);
  const steps = () => LADDER.filter(s => s[0] <= maxScale() + 1e-6);
  let step = 4, ceiling = 99, ceilingUntil = 0, ceilingFor = 15, frameTimes = [];
  function adapt(dt, now) {
    if (refining) { frameTimes = []; return; }   // (slow frames are fine while still)
    frameTimes.push(dt);
    // Every 30 frames, or every second once there are a few (slow hardware shouldn't wait long).
    const span = frameTimes.reduce((a, b) => a + b, 0);
    if (frameTimes.length < 30 && !(span > 1 && frameTimes.length >= 5) && !(span > 3 && frameTimes.length >= 3)) return;
    frameTimes.sort((a, b) => a - b);
    const med = frameTimes[frameTimes.length >> 1];
    baseFrame = med;   // (refinement's frame-rate watch compares against this)
    frameTimes = [];
    if (med > TOO_SLOW && step === 0) { giveUp(); return; }
    if (med > TOO_SLOW * 2) { step = 0; ceiling = 0; ceilingUntil = now + 600; return; }   // hopeless: straight to the bottom
    if (med > 0.15 && step > 1) step--;   // very slow: a step more
    const top = steps().length - 1;
    if (now > ceilingUntil) ceiling = 99;
    if (med > MOVE_SLOW && step > 0) { ceiling = step - 1; ceilingUntil = now + ceilingFor; ceilingFor = Math.min(ceilingFor * 2, 240); step--; }
    else if (med < MOVE_UP && step < Math.min(top, ceiling)) step++;
    step = Math.min(step, top);
  }

  // The moving view's buffers, at the ladder's scale, and HIST_MARGIN of the height more all round:
  // a blend's edge pixels have the least history (things come in there, reprojected from nowhere)
  // and sparkled, so they're drawn but kept just off the screen. ov(v): v as the buffers see it.
  const HIST_MARGIN = 0.03;
  let histOver = 1;
  const ov = v => ({ ...v, h: v.h * histOver });
  function resize() {
    const r = canvas.getBoundingClientRect();
    const s = steps()[step][0];
    const hi = Math.max(16, Math.round(r.height * s)), m = Math.ceil(hi * HIST_MARGIN) + 2;
    const w = Math.max(16, Math.round(r.width * s)) + 2 * m, h = hi + 2 * m;
    histOver = h / hi;
    if (sampled && sampled.w === w && sampled.h === h) return;
    const old = hist[histAt] || null;
    if (sampled) sampled.free();
    sampled = target2d(w, h, gl.RGBA8);
    const fresh = [target2d(w, h, floatHist ? gl.RGBA16F : gl.RGBA8), target2d(w, h, floatHist ? gl.RGBA16F : gl.RGBA8)];
    if (old && frames > 0) {
      // A new size (the quality ladder): carry the old blend over, scaled, rather than starting
      // again from one noisy sample (it flickered noisy just after the start, while it found its size).
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, old.fb);
      gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, fresh[histAt].fb);
      gl.blitFramebuffer(0, 0, old.w, old.h, 0, 0, w, h, gl.COLOR_BUFFER_BIT, gl.LINEAR);
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, null); gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, null);
      frames = Math.min(frames, READY_FRAMES);   // (it re-sharpens at the new size from there)
    } else frames = 0;
    for (const t of hist) if (t) t.free();
    hist = fresh;
  }

  // Halton (2, 3): sub-pixel offsets that cover the pixel evenly.
  function halton(i, b) { let f = 1, r = 0; while (i > 0) { f /= b; r += f * (i % b); i = Math.floor(i / b); } return r; }

  // The moving view: this frame's samples blended into the reprojected history.
  function renderTaa() {
    const w = sampled.w, h = sampled.h;
    jitterI = (jitterI % 64) + 1;
    gl.bindFramebuffer(gl.FRAMEBUFFER, sampled.fb);
    drawFractal(w, h, ov(view), steps()[step][1], halton(jitterI, 2) - 0.5, halton(jitterI, 3) - 0.5);
    const src = hist[histAt], dst = hist[1 - histAt];
    gl.bindFramebuffer(gl.FRAMEBUFFER, dst.fb);
    gl.useProgram(resolve);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, sampled.tex);
    gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, src.tex);
    gl.uniform1i(RU.uCur, 0); gl.uniform1i(RU.uHist, 1);
    gl.uniform2f(RU.uRes, w, h);
    gl.uniform3f(RU.uView, view.x, view.y, view.h * histOver);
    const pv = prevView || view;
    gl.uniform3f(RU.uPrev, pv.x, pv.y, pv.h * histOver);
    gl.uniform2f(RU.uRot, Math.cos(view.a), Math.sin(view.a));
    gl.uniform2f(RU.uPrevRot, Math.cos(pv.a), Math.sin(pv.a));
    // More careful the deeper it is (Dan: the blending fuzzed the detail zoomed in): less history,
    // clipped tighter, by how far through its depth it's got.
    const deep = Math.min(1, Math.max(0, Math.log(startH / view.h) / Math.log(startH / minH)));
    const low = steps()[step][0] <= LOW_SCALE;
    const keepMax = still > 0 ? 1 - 1 / (floatHist ? STILL_FRAMES : 12)   // still: a plain running average
      : low ? LOW_KEEP : KEEP_MAX - (KEEP_MAX - KEEP_DEEP) * deep;
    gl.uniform1f(RU.uKeep, frames > 0 && TAA ? Math.min(1 - 1 / (frames + 1), keepMax) : 0);
    gl.uniform1f(RU.uClip, still > 0 ? 1e3 : low ? LOW_CLIP : CLIP - (CLIP - CLIP_DEEP) * deep);
    quadDraw(w, h);
    histAt = 1 - histAt;
    prevView = { ...view };
    frames++;
  }

  let refDuty = REF_DUTY, refFps = [], refFpsAt = 0;
  let refScale = null;   // CSS px a pixel it refines at (null: the most for this screen)
  try { const v = parseFloat(localStorage.getItem(REF_SCALE_KEY)); if (v > 0) refScale = v; } catch (e) {}
  const refScaleMax = () => HI_OK ? Math.min(window.devicePixelRatio || 1, 2) : steps()[step][0];
  const refScaleNow = () => Math.max(steps()[step][0], Math.min(refScaleMax(), refScale || 1e9));
  let baseFrame = 1 / 60;   // the page's frame time while moving, refinement's yardstick
  let refComfort = 0, refUpAt = 0, refUpWait = REF_UP_WAIT, refWentUp = false;
  // The page's frame rate while refining, each second: too slow, less of the GPU, then a lower
  // resolution; comfortable for a good while, a higher one. (True: begun again at the new one.)
  function watchFps(now, raw) {
    refFps.push(raw);
    if (now - refFpsAt < 1 || refFps.length < 10) return false;
    refFps.sort((a, b) => a - b);
    const med = refFps[refFps.length >> 1], span = now - refFpsAt;
    refFps = []; refFpsAt = now;
    const s = refScaleNow();
    // Too slow is under REF_MIN_FPS, or (where moving was already slower) clearly slower than moving.
    if (med <= Math.max(1 / REF_MIN_FPS, baseFrame * 1.3)) {
      if (med < 1 / REF_UP_FPS) refDuty = Math.min(REF_DUTY, refDuty * 1.15);
      refComfort = med < 1 / REF_UP_FPS && refDuty >= REF_DUTY - 1e-6 ? refComfort + span : 0;
      if (refComfort > REF_UP_AFTER && now > refUpAt && s < refScaleMax() - 1e-6) {
        refWentUp = true;
        return rescale(Math.min(refScaleMax(), s / REF_SCALE_STEP));
      }
      return false;
    }
    refComfort = 0;
    if (refDuty > REF_DUTY_MIN + 1e-6) { refDuty = Math.max(REF_DUTY_MIN, refDuty * 0.7); return false; }
    if (s <= steps()[step][0] + 1e-6) return false;   // as low as the moving view's already
    // A step up that didn't hold: don't try again for a while (longer each time).
    if (refWentUp) { refUpAt = now + refUpWait; refUpWait *= 2; }
    refWentUp = false;
    return rescale(Math.max(steps()[step][0], s * REF_SCALE_STEP));
  }
  function rescale(to) {
    refScale = to;
    try { localStorage.setItem(REF_SCALE_KEY, String(refScale)); } catch (e) {}
    // What it has so far goes into the moving view's buffer, for the new one to fade in from.
    if (acc && refN > 0) bakeRefined();
    stopRefine(); startRefine();
    refComfort = 0;
    return true;
  }

  function bakeRefined() {
    const t = hist[histAt];
    gl.bindFramebuffer(gl.FRAMEBUFFER, t.fb);
    gl.useProgram(bake);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, acc.tex);
    gl.uniform1i(BU.uAcc, 0);
    gl.uniform2f(BU.uRes, t.w, t.h); gl.uniform2f(BU.uAccRes, acc.w, acc.h);
    gl.uniform3f(BU.uView, view.x, view.y, view.h * histOver); gl.uniform3f(BU.uRefView, refView.x, refView.y, refView.h);
    gl.uniform2f(BU.uRot, Math.cos(view.a), Math.sin(view.a)); gl.uniform2f(BU.uRefRot, Math.cos(refView.a), Math.sin(refView.a));
    quadDraw(t.w, t.h);
    prevView = { ...view };   // (the buffer's view now)
  }

  function startRefine() {
    const r = canvas.getBoundingClientRect();
    const s = refScaleNow();
    let w = Math.max(16, Math.round(r.width * s)), h = Math.max(16, Math.round(r.height * s));
    // In a rest the view keeps turning, so it refines a little more all round: enough for the turn
    // the rest of the hold will make (worked out ahead, the noise being known), and the screen just
    // reads it turned. ~8° at the most, a third more pixels for a wide screen.
    let ang = 0;
    if (restHolding && !paused) {
      const now = performance.now() / 1000, ease = turnEase();
      for (let t = 0, T = Math.max(0, holdUntil - now) + 0.5; t < T; t += 0.1) ang += turnRate(turnT + t, ease) * 0.1;
      ang = Math.min(0.5, Math.abs(ang) * 1.15 + 0.002);
    }
    refTurns = ang > 0;
    const c = Math.cos(ang), sn = Math.sin(ang), h0 = h;
    [w, h] = [Math.ceil(w * c + h * sn), Math.ceil(w * sn + h * c)];
    if (!acc || acc.w !== w || acc.h !== h) { if (acc) acc.free(); acc = target2d(w, h, gl.RGBA32F); }
    gl.bindFramebuffer(gl.FRAMEBUFFER, acc.fb);
    gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
    refN = 0; refView = { ...view, h: view.h * h / h0 }; refining = true; refStartT = performance.now() / 1000; band = 0; bands = 1; refRest = 0; bandMs = 0;
    refFps = []; refFpsAt = performance.now() / 1000;
  }
  function stopRefine() {
    refining = false;
    if (refSync) { gl.deleteSync(refSync); refSync = null; }
    for (const q of refQueue) gl.deleteQuery(q);
    refQueue = [];
  }
  // Refinement's share of the GPU (REF_DUTY). With the GPU's own timer (desktop browsers mostly
  // have it) each band's time is measured, and each frame gets as many bands as fit in its share,
  // several whole samples a frame for a light fractal, one band every few frames for a heavy one;
  // the bands are sized so one fits a frame's share. Without the timer (phones, mostly) it can only
  // tell how many frames a band took, so it sends one at a time and rests as long again.
  // Each pass of the bands adds one more sample a pixel (alpha counts them), its sub-pixel spot a
  // Gaussian by Box-Muller from Halton. True when work's finished (so there's something new to show).
  let frameInt = 1 / 60, bandMs = 0, refQueue = [];
  function refineTick(now, raw) {
    frameInt += (Math.min(Math.max(raw, 0.004), 0.1) - frameInt) * 0.1;
    if (watchFps(now, raw)) return false;   // (it's starting again, smaller)
    const budget = refDuty * frameInt * 1000;   // ms of GPU a frame
    let done = false;
    if (timer) {
      while (refQueue.length && gl.getQueryParameter(refQueue[0], gl.QUERY_RESULT_AVAILABLE)) {
        const q = refQueue.shift();
        const ms = gl.getQueryParameter(q, gl.QUERY_RESULT) / 1e6;
        if (!gl.getParameter(timer.GPU_DISJOINT_EXT)) bandMs = bandMs ? bandMs * 0.7 + ms * 0.3 : ms;
        gl.deleteQuery(q); done = true;
      }
    } else if (refSync) {
      if (gl.clientWaitSync(refSync, 0, 0) === gl.TIMEOUT_EXPIRED) return false;
      gl.deleteSync(refSync); refSync = null; done = true;
      const busy = now - refSubmit;
      bandMs = busy * 1000;
      refRest = now + busy * (1 / refDuty - 1);
    }
    if (refQueue.length || refSync || refN >= REF_MAX || now < refRest) return done;
    let spent = 0;
    do { sendBand(budget); spent += bandMs || budget; }
    while (timer && refN < REF_MAX && spent + (bandMs || budget) <= budget);
    // Over its share (a band bigger than a frame's): rest until the average is back to it.
    if (timer && spent > budget) refRest = now + spent / 1000 / refDuty - frameInt;
    return done;
  }
  function sendBand(budget) {
    const n = refN + 1;
    const rad = REF_SIGMA * Math.sqrt(-2 * Math.log(halton(n, 2))), th = 2 * Math.PI * halton(n, 3);
    const y0 = Math.floor(acc.h * band / bands), y1 = Math.floor(acc.h * (band + 1) / bands);
    gl.bindFramebuffer(gl.FRAMEBUFFER, acc.fb);
    gl.enable(gl.SCISSOR_TEST); gl.scissor(0, y0, acc.w, y1 - y0);
    gl.enable(gl.BLEND); gl.blendFunc(gl.ONE, gl.ONE);
    let q = null;
    if (timer) { q = gl.createQuery(); gl.beginQuery(timer.TIME_ELAPSED_EXT, q); }
    drawFractal(acc.w, acc.h, refView, 1, rad * Math.cos(th), rad * Math.sin(th));
    if (q) { gl.endQuery(timer.TIME_ELAPSED_EXT); refQueue.push(q); gl.flush(); }
    gl.disable(gl.BLEND); gl.disable(gl.SCISSOR_TEST);
    if (!timer) { refSync = gl.fenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0); gl.flush(); refSubmit = performance.now() / 1000; }
    if (++band < bands) return;
    // A pass done: one more sample a pixel. Size the bands for the next, so one fits a frame's share
    // (without the timer, a band known only to the frame: more bands if it took over two).
    band = 0; refN++;
    if (!bandMs) return;
    const pass = bandMs * bands;
    const want = timer ? Math.min(1024, 2 ** Math.ceil(Math.log2(Math.max(1, pass / Math.min(budget, REF_BAND_MAX_MS)))))
      : bandMs > 2.5 * frameInt * 1000 ? Math.min(1024, bands * 2) : bandMs < 1.5 * frameInt * 1000 && bands > 1 ? bands / 2 : bands;
    if (want !== bands) { bandMs *= bands / want; bands = want; }
  }

  // Too slow even at its lowest: show the fractal's own render, sharp, instead.
  function giveUp() {
    cur = null;
    document.body.classList.add('no-live');
    if (poster) poster.classList.remove('gone');
    const note = document.querySelector('.live-note');
    if (note && order[at]) note.innerHTML = 'One of the fractals, as rendered in Ultra Fractal. (This browser is a bit slow to draw it live.)<br><span id="live-name"></span>';
    if (order[at]) { const n = document.getElementById('live-name'); if (n) n.textContent = order[at].name.replace(/_dotdotdot_/g, ' … ').replace(/_/g, ' '); }
  }

  function present() {
    // Always at the refinement's size (the moving view's blend is scaled up here): switching the
    // canvas between the two sizes as refinement began was a one-frame jump of its own.
    const r = canvas.getBoundingClientRect(), s = refScaleNow();
    const w = Math.max(16, Math.round(r.width * s)), h = Math.max(16, Math.round(r.height * s));
    if (canvas.width !== w || canvas.height !== h) { canvas.width = w; canvas.height = h; }
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.useProgram(show);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, hist[histAt].tex);   // (renderTaa's newest)
    gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, acc ? acc.tex : null);
    gl.uniform1i(SU.uTex, 0); gl.uniform1i(SU.uAcc, 1);
    gl.uniform1f(SU.uFade, fade * fade * (3 - 2 * fade));
    gl.uniform1f(SU.uRefMix, acc ? refMix * refMix * (3 - 2 * refMix) : 0);
    gl.uniform1f(SU.uSeed, REF_SEED);
    gl.uniform2f(SU.uRes, w, h);
    gl.uniform2f(SU.uAccRes, acc ? acc.w : 1, acc ? acc.h : 1);
    gl.uniform3f(SU.uView, view.x, view.y, view.h);
    const rv = refView || view;
    gl.uniform3f(SU.uRefView, rv.x, rv.y, rv.h);
    gl.uniform2f(SU.uRot, Math.cos(view.a), Math.sin(view.a));
    gl.uniform2f(SU.uRefRot, Math.cos(rv.a), Math.sin(rv.a));
    const hv = prevView || view;   // (the blend's view: renderTaa's last)
    gl.uniform3f(SU.uHistView, hv.x, hv.y, hv.h * histOver);
    gl.uniform2f(SU.uHistRes, hist[histAt].w, hist[histAt].h);
    gl.uniform2f(SU.uHistRot, Math.cos(hv.a), Math.sin(hv.a));
    gl.uniform1i(SU.uSmooth, refTurns ? 1 : 0);
    quadDraw(w, h);
  }

  // The pause pearl says which it's doing: dim, near the ↻ pearl's black, while it moves (drawing
  // in real time), brightening to white nacre as a still view refines (by samples, on a log scale:
  // the first few dozen show the most). Without refinement, by its still frames' averaging.
  const pausePearl = document.getElementById('pause-pearl');
  // After a touch it's half paused: the pearl shows hollow pause bars in a ring that runs down
  // till the dive carries on (a tap on it pauses for good), and over the last CALL_LEAD s a warm
  // glow grows over it, the reminder, till it takes the pearl and the dive starts again.
  const GLOW_PLAY = 0.05, GLOW_FULL_AT = 1024, CALL_LEAD = 3, ORBIT_SPEED = 9, ORBIT_HALF = 2.7;   // (rad/s at first, a lap in 0.7 s; half that by ORBIT_HALF samples; by ~16, "pretty sharp", a crawl (a lap a minute), slower still after)
  const pauseGlyph = pausePearl && pausePearl.querySelector('.glyph');
  let shownMode = '';
  function showState() {
    if (!pausePearl) return;
    const n = refining ? refN : !canRefine && still > 0 ? Math.min(still, STILL_FRAMES) * 2 : 0;
    const prog = Math.min(1, Math.log2(1 + n) / Math.log2(1 + GLOW_FULL_AT));
    pausePearl._glow = GLOW_PLAY + (1 - GLOW_PLAY) * prog;
    // While it refines, a tiny moon circles the pearl: briskly over the first few dozen samples, where
    // the picture visibly improves, then hardly moving through the long tail (js/pearls.js integrates its angle).
    const working = refining || (!canRefine && still > 0 && still < STILL_FRAMES);
    const fresh = 1 / (1 + Math.pow(n / ORBIT_HALF, 2.5));
    pausePearl._orbit = working ? { speed: ORBIT_SPEED * fresh, fresh, show: 1 - smooth(0.85, 1, prog) } : null;
    const left = holdUntil - performance.now() / 1000;
    const half = !paused && left > 0;
    pausePearl._count = half ? left / holdLen : -1;
    pausePearl._call = half ? smooth(CALL_LEAD, 0, left) : 0;
    const mode = paused ? 'paused' : half ? 'half' : 'playing';
    if (mode !== shownMode) {
      shownMode = mode;
      if (pauseGlyph) pauseGlyph.textContent = mode === 'paused' ? '▶' : mode === 'half' ? '' : '❚❚';
      const label = mode === 'paused' ? 'Play' : mode === 'half' ? 'Keep it paused' : 'Pause';
      pausePearl.setAttribute('aria-label', label);
      pausePearl.title = mode === 'paused' ? 'Carry on the dive' : mode === 'half' ? 'Keep it paused (it carries on by itself soon)' : 'Pause the dive';
    }
  }

  let visible = true;
  document.addEventListener('visibilitychange', () => { prev = performance.now() / 1000; frameTimes = []; });
  new IntersectionObserver(es => { visible = es[0].isIntersecting; }).observe(canvas);

  // A very slow turn, its way and speed a low, signed noise. Eased in after a start or a touch and
  // towards the end of its depth, but not into the rests: it turns on through them.
  const turnEase = () => smooth(0, 4, turnSteer) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h));
  function turn(dt) { turnT += dt; turnSteer += dt; view.a += turnRate(turnT, turnEase()) * dt; }
  const smooth = (a, b, x) => { const t = Math.min(1, Math.max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t); };
  let prev = performance.now() / 1000;
  function frame() {
    requestAnimationFrame(frame);
    const now = performance.now() / 1000;
    const raw = now - prev, dt = Math.min(raw, 0.1); prev = now;
    if (!cur || !visible || document.hidden) return;   // (the view waits too, so its blend is still good)
    showState();
    adapt(raw, now);   // (raw, uncapped: slow hardware must show as slow)
    if (!cur) return;
    resize();
    if (restHolding && !paused && now > holdUntil) { restHolding = false; onWeGo(); }
    if (!paused && now > holdUntil) {
      // Ease in after a start, a touch or a rest, out into a rest, and out towards the end of its depth.
      steerT += dt; movedT += dt;
      if (settleAt === null && movedT > nextRest && !leaving && fade >= 1 && view.h > minH * 8) settleAt = now;
      let restEase = 1;
      if (settleAt !== null) {
        restEase = smooth(REST_SETTLE, 0, now - settleAt);
        if (now - settleAt >= REST_SETTLE) {
          settleAt = null; holdUntil = now + REST_HOLD; holdLen = REST_HOLD; movedT = 0; nextRest = restIn();
          steerT = 0; easeFor = REST_RESUME; vel = { x: 0, y: 0 }; target = { x: view.x, y: view.y }; aim = { ...target };
          restEase = 0; restHolding = true; say('resting and refining');
        }
      }
      const ease = smooth(0, easeFor, steerT) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h)) * restEase;
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
      turn(dt);
      if (view.h <= minH * 1.2 && !leaving) { leaving = true; fadeDir = -1; }
    } else if (restHolding && !paused) turn(dt);   // (a rest only stops the dive: the refinement's read turned)
    // Fading in only once the blend has a few frames (or the refinement is under way): the very
    // first frames are single noisy samples.
    if (fadeDir < 0 || frames >= READY_FRAMES || refining || now - beganAt > 1) fade = Math.min(1, Math.max(0, fade + fadeDir * dt / FADE));
    if (leaving && fade <= 0) { begin(at + 1); return; }
    const pv = prevView;
    still = pv && pv.x === view.x && pv.y === view.y && pv.h === view.h ? still + 1 : 0;   // (the turn aside: a rest turns on)
    const wantRefine = canRefine && TAA && still > STILL_REFINE && fade >= 1;
    if (wantRefine && !refining) startRefine();
    if (!wantRefine && refining) { if (refTurns && refN >= REF_SEED) bakeRefined(); stopRefine(); }
    if (refining) {
      if (!refineTick(now, raw) && !refTurns) return;   // nothing new: the canvas keeps its picture (unless it turns)
      // Faded in over REF_IN s: switched on in one frame, its sharper picture popped (measured: a
      // frame-to-frame change 4x the settling motion's).
      refMix = Math.min(1, (now - refStartT) / REF_IN);
    } else {
      refMix = Math.max(0, refMix - dt / REF_OUT);
      renderTaa();
    }
    present();
    if (document.body.classList.contains('waiting') && (frames >= READY_FRAMES || now - beganAt > 1)) document.body.classList.remove('waiting');
    if (poster && fade > 0.99 && !document.body.classList.contains('waiting')) poster.classList.add('gone');
  }

  // After the hand: carry on from here, still.
  function touched() {
    holdUntil = performance.now() / 1000 + IDLE_RESUME; holdLen = IDLE_RESUME; settleAt = null; restHolding = false;
    target = { x: view.x, y: view.y }; aim = { ...target }; vel = { x: 0, y: 0 }; steerT = 0; easeFor = 4; turnSteer = 0;
  }
  // The plane under a point on the canvas (client px).
  function planeAt(cx, cy) {
    const r = canvas.getBoundingClientRect();
    const ox = (cx - r.left - r.width / 2) / r.height * view.h, oy = -(cy - r.top - r.height / 2) / r.height * view.h;
    const ca = Math.cos(view.a), sa = Math.sin(view.a);
    return { x: view.x + ca * ox - sa * oy, y: view.y + sa * ox + ca * oy };
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
    const ox = -dx / r.height * view.h, oy = dy / r.height * view.h, ca = Math.cos(view.a), sa = Math.sin(view.a);
    view.x += ca * ox - sa * oy; view.y += sa * ox + ca * oy;
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
    next() { leaving = true; fadeDir = -1; holdUntil = -1e9; settleAt = null; restHolding = false; },
    // Straight to that one (the gallery's full-tab view), from its start.
    show(id) {
      wanted = id;
      if (!order.length) return;   // (still loading: it starts with it)
      const i = order.findIndex(p => p.id === id);
      if (i >= 0 && !(cur && cur.pick.id === id)) { if (starting) queued = i; else begin(i); }
    },
    // Play: off at once (no wait after a touch), up to speed in a second or so.
    togglePause() { paused = !paused; restHolding = false; if (!paused) { steerT = 0; easeFor = 1.2; holdUntil = -1e9; settleAt = null; movedT = 0; } return paused; },
    state: () => ({ fade, leaving, step, scale: steps()[step][0], still, refining, refN, refMix, bands, bandMs, frameInt, refDuty, refScale: refScaleNow(), acc: acc && acc.w + 'x' + acc.h, frames, h: view.h, a: view.a, minH }),
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
    const want = (wanted || new URLSearchParams(location.search).get('pick') || '').toLowerCase();
    const first = want ? order.findIndex(p => p.id.startsWith(want) || p.name.toLowerCase().startsWith(want)) : -1;
    if (first > 0) order.unshift(...order.splice(first, 1));
    showName(order[0]);
    await begin(0);
    requestAnimationFrame(frame);
  })();
})();
