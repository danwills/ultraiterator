// Live fractals in the page: a few of UltraIterator Demo's ported Ultra Fractal
// parameters (uprLib's uprPort/liveexport.py, the app's assets/live/), drawn by the
// browser's GPU as they are on the phone, diving slowly towards detail.
// No pictures are downloaded for it: each is a shader and its gradients.
(function () {
  'use strict';

  const HEAD = `#version 300 es
precision highp float;
uniform sampler2D uGrad;   // its gradients' 400 colours, a row a layer (UF's rows only)
uniform int uAA;           // samples a side
uniform vec3 uView;        // the view's middle (x, y) and height (z), in the picture's units (its 2k's height = 1)
uniform vec2 uRes;
uniform float uFade;
out vec4 frag;
`;
  // As the app's LIVE_GEN_MAIN, but `o` from the view rather than a tile.
  const MAIN = `
void main() {
    vec3 sum = vec3(0.0);
    float px = uView.z / uRes.y;
    for (int j = 0; j < uAA; j++) for (int i = 0; i < uAA; i++) {
        vec2 f = gl_FragCoord.xy + (vec2(i, j) + 0.5) / float(uAA) - 0.5;
        sum += liveColour(uView.xy + (f - 0.5 * uRes) * px);
    }
    vec3 c = clamp(sum / float(uAA * uAA), 0.0, 1.0);
    frag = vec4(c * uFade, 1.0);
}`;
  const VS = `#version 300 es
in vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }`;

  const ZOOM_RATE = 0.16;      // octaves a second
  const RETARGET = 3.5;        // seconds between looks for detail
  const PROBE = 40;            // the look's size, px square
  const IDLE_RESUME = 9;       // seconds after a touch before it steers itself again
  const FADE = 1.2;            // seconds to fade between fractals

  const canvas = document.getElementById('live');
  const info = document.getElementById('live-name');
  const poster = document.getElementById('live-poster');
  if (!canvas) return;
  const gl = canvas.getContext('webgl2', { antialias: false, alpha: false, preserveDrawingBuffer: false });
  if (!gl) { document.body.classList.add('no-live'); return; }

  let common = '';
  let picks = [];
  let order = [];
  let cur = null;          // { pick, prog, tex, uni }
  let at = 0;              // place in `order`
  let view = { x: 0, y: 0, h: 1 };
  let target = { x: 0, y: 0 };
  let startH = 1, minH = 1e-3, born = 0, lastLook = 0, lastTouch = -1e9;
  let fade = 0, fadeDir = 1, paused = false, leaving = false;
  let scale = Math.min(window.devicePixelRatio || 1, 1.5) * 0.6;   // render scale, adapted to keep it smooth
  let frameTimes = [];

  const quad = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
  const probeTex = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, probeTex);
  gl.texStorage2D(gl.TEXTURE_2D, 1, gl.RGBA8, PROBE, PROBE);
  const probeFb = gl.createFramebuffer();
  gl.bindFramebuffer(gl.FRAMEBUFFER, probeFb);
  gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, probeTex, 0);
  gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  const probePx = new Uint8Array(PROBE * PROBE * 4);

  function shader(type, src) {
    const s = gl.createShader(type);
    gl.shaderSource(s, src); gl.compileShader(s);
    return s;
  }
  // Compiles without waiting where the browser can (KHR_parallel_shader_compile).
  const parallel = gl.getExtension('KHR_parallel_shader_compile');
  function program(fs) {
    const p = gl.createProgram();
    const v = shader(gl.VERTEX_SHADER, VS), f = shader(gl.FRAGMENT_SHADER, fs);
    gl.attachShader(p, v); gl.attachShader(p, f);
    gl.bindAttribLocation(p, 0, 'aPos');
    gl.linkProgram(p);
    return new Promise((resolve, reject) => {
      const check = () => {
        if (parallel && !gl.getProgramParameter(p, parallel.COMPLETION_STATUS_KHR)) { setTimeout(check, 30); return; }
        if (!gl.getProgramParameter(p, gl.LINK_STATUS)) reject(new Error(gl.getShaderInfoLog(f) || gl.getProgramInfoLog(p)));
        else resolve(p);
      };
      check();
    });
  }

  // Its gradients: the PNG's top half, UF's rows (the bottom half is the same in linear light).
  async function gradient(id) {
    const blob = await (await fetch('live/' + id + '.png')).blob();
    const bmp = await createImageBitmap(blob, { colorSpaceConversion: 'none', premultiplyAlpha: 'none' });
    const rows = Math.max(1, bmp.height >> 1);
    const c = document.createElement('canvas');
    c.width = bmp.width; c.height = rows;
    const g = c.getContext('2d', { colorSpace: 'srgb' });
    g.drawImage(bmp, 0, 0);
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
        const uni = {};
        for (const n of ['uGrad', 'uAA', 'uView', 'uRes', 'uFade']) uni[n] = gl.getUniformLocation(prog, n);
        return { pick, prog, tex, uni };
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
    minH = startH / Math.min(pick.depth * 2048 / Math.max(canvas.height, 1), 4096);
    view = { x: 0, y: 0, h: startH };
    target = { x: 0, y: 0 };
    born = performance.now() / 1000; lastLook = born - RETARGET + 1.0;
    fade = 0; fadeDir = 1; leaving = false;
    load(order[(at + 1) % order.length]).catch(() => {});   // the next one compiles meanwhile
  }

  function draw(u, w, h, v, f) {
    gl.useProgram(cur.prog);
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, cur.tex);
    gl.uniform1i(u.uGrad, 0);
    gl.uniform1i(u.uAA, cur.pick.aa);
    gl.uniform3f(u.uView, v.x, v.y, v.h);
    gl.uniform2f(u.uRes, w, h);
    gl.uniform1f(u.uFade, f);
    gl.viewport(0, 0, w, h);
    gl.bindBuffer(gl.ARRAY_BUFFER, quad);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }

  // Where's the detail? A small render of a view a little wider than the screen, and the cell
  // with the most contrast among its neighbours, leaning towards the middle so it doesn't wander.
  function look() {
    const wide = { x: view.x, y: view.y, h: view.h * 0.9 };
    gl.bindFramebuffer(gl.FRAMEBUFFER, probeFb);
    draw(cur.uni, PROBE, PROBE, wide, 1);
    gl.readPixels(0, 0, PROBE, PROBE, gl.RGBA, gl.UNSIGNED_BYTE, probePx);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    const L = (x, y) => { const k = (y * PROBE + x) * 4; return 0.3 * probePx[k] + 0.59 * probePx[k + 1] + 0.11 * probePx[k + 2]; };
    let best = -1, bx = PROBE / 2, by = PROBE / 2;
    for (let y = 3; y < PROBE - 3; y += 2) for (let x = 3; x < PROBE - 3; x += 2) {
      let s = 0, s2 = 0;
      for (let j = -2; j <= 2; j++) for (let i = -2; i <= 2; i++) { const l = L(x + i, y + j); s += l; s2 += l * l; }
      const varc = s2 / 25 - (s / 25) * (s / 25);
      const dx = x / PROBE - 0.5, dy = y / PROBE - 0.5;
      const score = Math.sqrt(Math.max(varc, 0)) * (1 - 1.6 * (dx * dx + dy * dy)) + Math.random() * 6;
      if (score > best) { best = score; bx = x; by = y; }
    }
    // (The probe's square, wide.h each way, so only the middle of a wide screen is looked at.)
    target = { x: view.x + (bx / PROBE - 0.5) * wide.h, y: view.y + (by / PROBE - 0.5) * wide.h };
  }

  function resize() {
    const r = canvas.getBoundingClientRect();
    const w = Math.max(16, Math.round(r.width * scale)), h = Math.max(16, Math.round(r.height * scale));
    if (canvas.width !== w || canvas.height !== h) { canvas.width = w; canvas.height = h; }
  }

  // Keep it smooth: a lower render scale when frames are slow, higher when there's room.
  function adapt(dt) {
    frameTimes.push(dt);
    if (frameTimes.length < 20) return;
    frameTimes.sort((a, b) => a - b);
    const med = frameTimes[10];
    frameTimes = [];
    const maxScale = Math.min(window.devicePixelRatio || 1, 1.5);
    if (med > 0.045 && scale > 0.45) scale *= 0.85;   // (not below ~half a CSS px: chunkier looked worse than slower)
    else if (med < 0.022 && scale < maxScale) scale = Math.min(maxScale, scale * 1.12);
  }

  let visible = true;
  new IntersectionObserver(es => { visible = es[0].isIntersecting; }).observe(canvas);

  let prev = performance.now() / 1000;
  function frame() {
    requestAnimationFrame(frame);
    const now = performance.now() / 1000;
    const dt = Math.min(now - prev, 0.1); prev = now;
    if (!cur || !visible || document.hidden) return;
    adapt(dt);
    resize();
    const steering = now - lastTouch > IDLE_RESUME;
    if (!paused && steering) {
      view.h *= Math.pow(2, -ZOOM_RATE * dt);
      if (now - lastLook > RETARGET) { lastLook = now; look(); }
      const k = 1 - Math.exp(-dt * 0.5);
      view.x += (target.x - view.x) * k;
      view.y += (target.y - view.y) * k;
      if (view.h <= minH && !leaving) { leaving = true; fadeDir = -1; }
    }
    fade = Math.min(1, Math.max(0, fade + fadeDir * dt / FADE));
    if (leaving && fade <= 0) { begin(at + 1); return; }
    draw(cur.uni, canvas.width, canvas.height, view, fade);
    if (poster && fade > 0.99) poster.classList.add('gone');
  }

  // Touch: drag to move, pinch or Ctrl+wheel to zoom; it steers itself again after a while. On a
  // touch screen the canvas is touch-action: pan-y, so a vertical swipe still scrolls the page
  // (the browser takes it, and cancels the pointer) and a sideways one moves the fractal.
  const pointers = new Map();
  let pinch = 0;
  canvas.addEventListener('pointerdown', e => { canvas.setPointerCapture(e.pointerId); pointers.set(e.pointerId, { x: e.clientX, y: e.clientY }); lastTouch = performance.now() / 1000; });
  canvas.addEventListener('pointerup', e => { pointers.delete(e.pointerId); pinch = 0; });
  canvas.addEventListener('pointercancel', e => { pointers.delete(e.pointerId); pinch = 0; });
  canvas.addEventListener('pointermove', e => {
    const p = pointers.get(e.pointerId);
    if (!p) return;
    const r = canvas.getBoundingClientRect();
    lastTouch = performance.now() / 1000;
    if (pointers.size === 1) {
      view.x -= (e.clientX - p.x) / r.height * view.h;
      view.y += (e.clientY - p.y) / r.height * view.h;
    } else if (pointers.size === 2) {
      p.x = e.clientX; p.y = e.clientY;
      const [a, b] = [...pointers.values()];
      const d = Math.hypot(a.x - b.x, a.y - b.y);
      if (pinch) zoomBy(pinch / d);
      pinch = d;
      return;
    }
    p.x = e.clientX; p.y = e.clientY;
    target = { x: view.x, y: view.y };
  });
  function zoomBy(f) { view.h = Math.min(startH * 2, Math.max(minH, view.h * f)); target = { x: view.x, y: view.y }; }
  // Only Ctrl+wheel zooms (a trackpad's pinch sends that too); a plain wheel scrolls the page.
  canvas.addEventListener('wheel', e => {
    if (!e.ctrlKey) return;
    e.preventDefault(); lastTouch = performance.now() / 1000; zoomBy(Math.pow(2, e.deltaY * 0.01));
  }, { passive: false });

  window.UILive = {
    next() { leaving = true; fadeDir = -1; },
    togglePause() { paused = !paused; return paused; },
  };

  canvas.addEventListener('webglcontextlost', e => { e.preventDefault(); cur = null; });

  (async () => {
    [common, picks] = await Promise.all([
      fetch('live/common.glsl').then(r => r.text()),
      fetch('live/picks.json').then(r => r.json()),
    ]);
    order = picks.slice();
    for (let i = order.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [order[i], order[j]] = [order[j], order[i]]; }
    showName(order[0]);
    await begin(0);
    requestAnimationFrame(frame);
  })();
})();
