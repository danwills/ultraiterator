// Pearls, gems and beach pebbles behind the page's buttons and bullets, as in
// UltraIterator's menu (the app's UiGl MAT_FS: its baroque pearls, root-macro gems
// and STONE pebbles, simplified). One canvas over the page draws them all, at
// each `.gem` element's place, under its text. data-gem: pebble | pearl;
// data-look: the stone or pearl (LOOKS below); data-seed: its shape.
(function () {
  'use strict';
  const MAX = 24;
  const LOOKS = {
    // pebbles
    grey: 0, jasper: 1, lapis: 2, basalt: 3, sandstone: 4, jade: 5,
    // pearls and gems
    nacre: 10, black: 11, ruby: 12, vanilla: 13, agate: 14, moonstone: 15, amethyst: 16, obsidian: 17, opal: 18,
    // a black pearl brightening to white nacre by the element's `_glow` (0..1): the live hero's
    // pause pearl, dim while it plays, brightening as a still view refines (js/live.js)
    state: 19,
  };

  const FS = `#version 300 es
precision highp float;
uniform vec2 uRes;
uniform float uTime;
uniform float uDpr;
uniform int uCount;
uniform vec4 uRect[${MAX}];   // middle and half size, px, y down
uniform vec4 uKind[${MAX}];   // kind (0 pebble, 1 pearl), look, seed, hover 0..1
uniform vec4 uMore[${MAX}];   // x: the state pearl's glow
out vec4 frag;

const vec3 LUMA = vec3(0.299, 0.587, 0.114);
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p), f = p - i;
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + 1.0), f.x), f.y);
}
float fbm(vec2 q) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) { s += a * vnoise(q); q = q * 2.03 + 17.0; a *= 0.5; }
    return s;
}
vec3 srgbFromOklab(vec3 c) {
    float l = c.x + 0.3963377774 * c.y + 0.2158037573 * c.z;
    float m = c.x - 0.1055613458 * c.y - 0.0638541728 * c.z;
    float s = c.x - 0.0894841775 * c.y - 1.2914855480 * c.z;
    l = l * l * l; m = m * m * m; s = s * s * s;
    vec3 lin = vec3(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
                   -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
                   -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s);
    lin = clamp(lin, 0.0, 1.0);
    return mix(lin * 12.92, 1.055 * pow(lin, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, lin));
}
vec3 oklch(float l, float c, float h) { return srgbFromOklab(vec3(l, c * cos(6.28318 * h), c * sin(6.28318 * h))); }
vec3 voro(vec2 x) {
    vec2 i = floor(x), f = x - i;
    float d1 = 8.0, d2 = 8.0, id = 0.0;
    for (int y = -1; y <= 1; y++) for (int xx = -1; xx <= 1; xx++) {
        vec2 g = vec2(float(xx), float(y));
        vec2 r = g + vec2(hash(i + g), hash(i + g + 7.3)) - f;
        float d = dot(r, r);
        if (d < d1) { d2 = d1; d1 = d; id = hash(i + g + 3.1); } else if (d < d2) d2 = d;
    }
    return vec3(sqrt(d1), id, sqrt(d2) - sqrt(d1));
}
// The night sky the page sits under, reflected.
vec3 env(vec3 n) {
    float up = clamp(-n.y * 0.8 + n.z * 0.3, -1.0, 1.0);
    vec3 top = vec3(0.10, 0.12, 0.22), hor = vec3(0.16, 0.13, 0.15), gnd = vec3(0.03, 0.025, 0.03);
    return up > 0.0 ? mix(hor, top, up) : mix(hor, gnd, -up);
}
const vec3 L = normalize(vec3(-0.5, -0.65, 0.75));

// The beach stone's outline (the app's STONE): a superellipse wobbling a little, its own
// posture, chipped. Returns the distance outside it, px; r: how far out from the middle.
float stoneDist(vec2 rel, vec2 hs, float seed, out float r) {
    float q1 = hash(vec2(seed, 21.0)), q2 = hash(vec2(seed, 22.0)), q3 = hash(vec2(seed, 23.0));
    float ta = (q1 - 0.5) * 0.12;
    rel = vec2(cos(ta) * rel.x + sin(ta) * rel.y, -sin(ta) * rel.x + cos(ta) * rel.y);
    float xn = clamp(rel.x / hs.x, -1.2, 1.2);
    rel.y -= (q2 - 0.5) * 0.5 * hs.y * xn * xn;
    rel.y /= 1.0 + (q3 - 0.5) * 0.45 * xn;
    float mn = min(hs.x, hs.y);
    vec2 uv = abs(rel) / hs;
    float ex = 2.4 + 0.5 * hash(vec2(seed, 6.0)) + 0.45 * clamp(hs.x / hs.y - 1.5, 0.0, 2.0);
    r = pow(pow(uv.x, ex) + pow(uv.y, ex), 1.0 / ex);
    float th = atan(rel.y / hs.y, rel.x / hs.x);
    float dirR = length(hs * vec2(cos(th), sin(th)));
    float wob = 0.05 * sin(2.0 * th + 6.0 * hash(vec2(seed, 1.0))) + 0.04 * sin(3.0 * th + 6.0 * hash(vec2(seed, 2.0)))
              + 0.025 * sin(5.0 * th + 6.0 * hash(vec2(seed, 3.0)));
    vec2 ring = vec2(cos(th), sin(th));
    wob += 0.03 * (vnoise(ring * 2.2 + seed * 3.1) - 0.5) + 0.014 * (vnoise(ring * 6.5 + seed * 1.7) - 0.5);
    vec2 edge = rel / max(r, 0.05) / mn;
    float chip = abs(vnoise(edge * 1.3 + seed * 2.3) - 0.5) * 2.0;
    float R = 1.0 + (wob - 0.08 * chip + 0.07) * mn / dirR;
    r /= R;
    return (r - 1.0) * R * dirR;
}

vec3 pebble(int look, vec2 q, vec3 nn, float seed, float hover) {
    float diff = max(dot(nn, L), 0.0);
    float spec = pow(max(dot(reflect(-L, nn), vec3(0.0, 0.0, 1.0)), 0.0), 26.0 + 30.0 * hover);
    float fres = pow(1.0 - nn.z, 3.0);
    vec2 w = q * 3.0 + seed * 7.0;
    float grain = fbm(w * 2.0), speck = vnoise(q * 40.0 + seed);
    vec3 base;
    if (look == 1) {
        // Red jasper: brick red, cloudy, with pale quartz veins.
        float vein = smoothstep(0.035, 0.0, abs(fbm(w * 0.8 + 3.0) - 0.5));
        base = mix(oklch(0.42 + 0.1 * grain, 0.12, 0.08), oklch(0.85, 0.03, 0.15), vein * 0.8);
    } else if (look == 2) {
        // Lapis: deep blue, white calcite clouds, pyrite flecks.
        base = mix(oklch(0.36 + 0.08 * grain, 0.15, 0.73), oklch(0.8, 0.03, 0.7), smoothstep(0.62, 0.8, fbm(w * 1.2 + 9.0)) * 0.6);
        base += vec3(0.9, 0.7, 0.3) * step(0.985, hash(floor(q * 34.0 + seed))) * 0.8;
    } else if (look == 3) {
        // Basalt: near black, fine grain.
        base = oklch(0.22 + 0.06 * grain + 0.04 * speck, 0.008, 0.6);
    } else if (look == 4) {
        // Sandstone: warm, banded.
        float band = sin((q.y + 0.25 * fbm(w)) * 9.0 + seed);
        base = oklch(0.66 + 0.06 * band + 0.06 * grain, 0.06, 0.18);
    } else if (look == 5) {
        // Jade: green, milky, a little see-through.
        base = oklch(0.55 + 0.12 * fbm(w * 0.7), 0.1, 0.42);
    } else {
        // Grey beach pebble, speckled.
        base = oklch(0.62 + 0.1 * grain + 0.06 * (speck - 0.5), 0.012, 0.2 + 0.1 * grain);
    }
    // Wet when hovered: darker, more saturated, glossier.
    base *= mix(1.0, 0.82, hover);
    return base * (0.42 + 0.7 * diff) + env(nn) * 0.25 + spec * (0.35 + 0.6 * hover) + fres * 0.15 * env(nn);
}

vec3 pearl(int look, vec2 q, vec3 nn, float seed, float hover) {
    float diff = max(dot(nn, L), 0.0);
    float spec = pow(max(dot(reflect(-L, nn), vec3(0.0, 0.0, 1.0)), 0.0), 36.0);
    float fres = pow(1.0 - nn.z, 3.0);
    vec3 e = env(nn);
    if (look == 14) {
        // Agate: flowing bands, carnelian, smoky grey and cream.
        vec2 w = q + 0.45 * (vec2(vnoise(q * 1.6 + seed), vnoise(q * 1.6 + seed + 4.0)) - 0.5);
        float rr = length(w * vec2(1.0, 1.3)) - uTime * (0.03 + 0.2 * hover);
        float band = rr * 5.0 + 0.8 * sin(rr * 2.3 + seed) + 0.3 * vnoise(w * 6.0);
        float layer = fract(floor(band) * 0.618 + seed * 0.3);
        vec3 base = layer < 0.45 ? oklch(0.55, 0.11, 0.09) : (layer < 0.75 ? oklch(0.62, 0.02, 0.6) : oklch(0.86, 0.025, 0.2));
        return base * (0.45 + 0.7 * diff) + spec * 0.7 + fres * 0.25 * e;
    }
    if (look == 15) {
        // Moonstone: milky, a blue glow drifting inside.
        vec2 at = vec2(-0.1, -0.15) + 0.3 * vec2(sin(uTime * 0.31 + seed), cos(uTime * 0.23 + seed));
        float glow = exp(-length((q - at) * vec2(1.0, 1.6)) * 2.6) * (0.6 + 0.8 * hover);
        vec3 c = oklch(0.66, 0.012, 0.6) * (0.5 + 0.5 * diff) + oklch(0.78, 0.15, 0.66) * glow;
        return c + spec * 0.6 + fres * 0.35 * e;
    }
    if (look == 16) {
        // Amethyst: big facets, each tilted its own way, sparkling.
        vec3 v = voro(q * 1.5 + seed * 3.0);
        vec2 tilt = vec2(fract(v.y * 13.7), fract(v.y * 29.3)) - 0.5;
        vec3 fn = normalize(nn + vec3(tilt * 0.7, 0.0));
        float fd = max(dot(fn, L), 0.0);
        float sp = pow(max(dot(reflect(-L, fn), vec3(0.0, 0.0, 1.0)), 0.0), 60.0);
        float hue = 0.84 + hover * 0.15 * sin(v.y * 6.28 + uTime * 0.7);
        vec3 c = oklch(0.38 + 0.2 * fd + 0.08 * fract(v.y * 5.1), 0.15, hue);
        c += smoothstep(0.03, 0.0, v.z) * 0.12;
        return c + sp * 1.3 + fres * 0.3 * e;
    }
    if (look == 17) {
        // Obsidian: black glass, a rainbow sheen at its rim, pulsing.
        vec3 c = vec3(0.025) + 0.04 * diff;
        float sheen = q.y * 2.5 + 0.6 * vnoise(q * 2.0 + seed) + uTime * 0.04;
        c += oklch(0.6, 0.12, sheen) * pow(1.0 - nn.z, 1.5) * 0.35;
        c += oklch(0.62, 0.16, 0.75) * fres * (0.25 + 0.25 * sin(uTime * 2.1)) * (0.6 + hover);
        float sharpSpec = pow(max(dot(reflect(-L, nn), vec3(0.0, 0.0, 1.0)), 0.0), 120.0);
        return c + sharpSpec * 1.4 + spec * 0.15 + fres * 0.5 * e;
    }
    if (look == 18) {
        // Opal: milky, with patches of spectral fire.
        vec2 w = q * 2.5 + seed * 5.0;
        w += 0.6 * vec2(vnoise(w * 1.3), vnoise(w * 1.3 + 7.0));
        float fireAt = smoothstep(0.45, 0.75, vnoise(w * 1.4));
        float hue = vnoise(w * 0.9 + 3.0) * 1.6 + 0.9 * dot(nn.xy, vec2(0.7, 0.4)) + hover * 0.6 + uTime * 0.015;
        float flash = 0.6 + 0.4 * smoothstep(0.3, 0.8, vnoise(w * 4.0));
        vec3 c = mix(oklch(0.86, 0.02, 0.25), oklch(0.76, 0.17, hue) * flash, 0.75 * fireAt);
        return c * (0.45 + 0.65 * diff) + spec * 0.8 + fres * 0.25 * e;
    }
    // Nacre: thin-film colour turning with the angle.
    float film = (nn.z * 0.9 + 0.15 * vnoise(q * 3.0 + seed)) * 0.6 + hover * 0.6 + 0.04 * sin(uTime * 0.3 + seed);
    vec3 nacre = oklch(0.78 + 0.1 * diff, 0.05, film + 0.1);
    if (look == 11) nacre = oklch(0.15 + 0.14 * diff, 0.05, 0.5 + 0.35 * film);       // black, peacock sheen
    if (look == 12) {                                                                // ruby, lit from within
        float silk = 0.6 * vnoise(q * 3.0 + seed) + 0.4 * vnoise(q * 7.0 + seed * 2.0);
        vec3 deep = oklch(0.2 + 0.2 * nn.z * nn.z + 0.07 * silk + 0.1 * hover, 0.2 + 0.03 * silk, 0.06 + 0.03 * silk);
        float inner = pow(clamp(dot(nn.xy, -L.xy) * 0.9 + 0.35, 0.0, 1.0), 2.5) * smoothstep(0.0, 0.5, nn.z);
        return deep * (0.4 + 0.5 * diff) + oklch(0.6, 0.23, 0.055) * inner * (0.75 + 0.35 * hover) + spec * 1.4 + fres * 0.3 * e;
    }
    if (look == 13) return oklch(0.93 + 0.04 * vnoise(q * 4.0 + seed), 0.065, 0.24 + 0.015 * film) * (0.62 + 0.42 * diff) + spec * 0.5 + fres * 0.25 * e;
    return nacre * (0.35 + 0.7 * diff) + spec * 0.9 + fres * 0.9 * e;
}

void main() {
    vec2 p = vec2(gl_FragCoord.x, uRes.y - gl_FragCoord.y);
    vec4 acc = vec4(0.0);
    for (int i = 0; i < ${MAX}; i++) {
        if (i >= uCount) break;
        vec4 rc = uRect[i], k = uKind[i];
        vec2 rel = p - rc.xy;
        float marg = 12.0 * uDpr;
        if (abs(rel.x) > rc.z + marg || abs(rel.y) > rc.w + marg) continue;
        int kind = int(k.x + 0.5), look = int(k.y + 0.5);
        float seed = k.z, hover = k.w;
        float aa = 1.2 * uDpr;
        float d, sd;
        vec3 nn; vec2 q;
        if (kind == 0) {
            float r, r2;
            d = stoneDist(rel, rc.zw, seed, r);
            sd = stoneDist(rel - vec2(2.0, 4.0) * uDpr, rc.zw, seed, r2);
            // A worn dome: flat on top, rounding off at the rim.
            float rr = clamp(r, 0.0, 1.0);
            vec2 dir = rel / max(length(rel), 1e-3);
            float slope = pow(rr, 3.0) * 1.4;
            nn = normalize(vec3(dir * slope, 1.0));
            q = rel / min(rc.z, rc.w);
        } else {
            float R = min(rc.z, rc.w);
            float a = atan(rel.y, rel.x);
            // Baroque: never quite round, lumpier while hovered.
            float lump = 1.0 + 0.045 * (vnoise(vec2(a * 1.3 + seed * 7.0, seed * 2.3 + hover * uTime * 0.6)) - 0.5)
                       + 0.012 * sin(a * 2.0 + seed * 4.0) + 0.02 * hover * sin(a * 3.0 + seed * 9.0 + uTime);
            d = length(rel) - R * lump;
            sd = length(rel - vec2(1.5, 3.5) * uDpr) - R * lump;
            q = rel / (R * lump);
            nn = vec3(q, sqrt(max(1.0 - dot(q, q), 0.0)));
        }
        float body = 1.0 - smoothstep(-aa, aa * 0.5, d);
        float shadow = 0.5 * (1.0 - smoothstep(-2.0 * uDpr, 8.0 * uDpr, sd));
        vec3 col = vec3(0.0);
        if (body > 0.0) col = kind == 0 ? pebble(look, q, nn, seed, hover)
            : look == 19 ? mix(pearl(11, q, nn, seed, hover) * 1.15, pearl(10, q, nn, seed, hover) * 1.08, uMore[i].x)
            : pearl(look, q, nn, seed, hover);
        // Shadow under, then the stone over it.
        vec4 s = vec4(0.0, 0.0, 0.0, shadow * (1.0 - body));
        vec4 b = vec4(col * body, body);
        vec4 item = b + s * (1.0 - b.a);
        acc = acc + item * (1.0 - acc.a);
    }
    frag = acc;
}`;
  const VS = `#version 300 es
in vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }`;

  const canvas = document.createElement('canvas');
  canvas.id = 'gems';
  canvas.setAttribute('aria-hidden', 'true');
  document.body.appendChild(canvas);
  const gl = canvas.getContext('webgl2', { premultipliedAlpha: true, alpha: true, antialias: false });
  if (!gl) { document.body.classList.add('no-gems'); canvas.remove(); return; }

  function sh(type, src) {
    const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) console.warn(gl.getShaderInfoLog(s));
    return s;
  }
  const prog = gl.createProgram();
  gl.attachShader(prog, sh(gl.VERTEX_SHADER, VS));
  gl.attachShader(prog, sh(gl.FRAGMENT_SHADER, FS));
  gl.bindAttribLocation(prog, 0, 'aPos');
  gl.linkProgram(prog);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) { document.body.classList.add('no-gems'); canvas.remove(); return; }
  document.body.classList.add('gems');
  const U = {};
  for (const n of ['uRes', 'uTime', 'uDpr', 'uCount', 'uRect', 'uKind', 'uMore']) U[n] = gl.getUniformLocation(prog, n);
  const buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

  const hover = new WeakMap();
  const rects = new Float32Array(MAX * 4), kinds = new Float32Array(MAX * 4), more = new Float32Array(MAX * 4);
  let els = [];
  function collect() { els = [...document.querySelectorAll('.gem')]; }
  collect();
  new MutationObserver(collect).observe(document.body, { childList: true, subtree: true });
  document.addEventListener('pointerover', e => { const g = e.target.closest && e.target.closest('.gem'); if (g) g._over = true; });
  document.addEventListener('pointerout', e => { const g = e.target.closest && e.target.closest('.gem'); if (g && !g.contains(e.relatedTarget)) g._over = false; });
  document.addEventListener('focusin', e => { if (e.target.classList && e.target.classList.contains('gem')) e.target._over = true; });
  document.addEventListener('focusout', e => { if (e.target.classList && e.target.classList.contains('gem')) e.target._over = false; });

  let prev = performance.now();
  function frame(now) {
    requestAnimationFrame(frame);
    const dt = Math.min((now - prev) / 1000, 0.1); prev = now;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const W = Math.round(window.innerWidth * dpr), H = Math.round(window.innerHeight * dpr);
    if (canvas.width !== W || canvas.height !== H) { canvas.width = W; canvas.height = H; }
    let n = 0;
    for (const el of els) {
      if (n >= MAX) break;
      const r = el.getBoundingClientRect();
      if (r.bottom < -20 || r.top > window.innerHeight + 20 || r.width === 0) continue;
      const kind = el.dataset.gem === 'pearl' ? 1 : 0;
      const look = LOOKS[el.dataset.look] ?? (kind ? 10 : 0);
      const seed = parseFloat(el.dataset.seed || (n * 1.37 + 0.5));
      let h = hover.get(el) || 0;
      h += ((el._over ? 1 : 0) - h) * (1 - Math.exp(-dt * 8));
      hover.set(el, h);
      rects.set([(r.left + r.width / 2) * dpr, (r.top + r.height / 2) * dpr, r.width / 2 * dpr, r.height / 2 * dpr], n * 4);
      kinds.set([kind, look, seed, h], n * 4);
      // (its glow eases, so steps in progress read as a smooth brightening)
      el._glowShown = (el._glowShown ?? (el._glow || 0)) + ((el._glow || 0) - (el._glowShown ?? 0)) * (1 - Math.exp(-dt * 3));
      more[n * 4] = el._glowShown;
      n++;
    }
    gl.viewport(0, 0, W, H);
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    if (!n) return;
    gl.useProgram(prog);
    gl.uniform2f(U.uRes, W, H);
    gl.uniform1f(U.uTime, now / 1000);
    gl.uniform1f(U.uDpr, dpr);
    gl.uniform1i(U.uCount, n);
    gl.uniform4fv(U.uRect, rects);
    gl.uniform4fv(U.uKind, kinds);
    gl.uniform4fv(U.uMore, more);
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
  requestAnimationFrame(frame);
})();
