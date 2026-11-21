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
    grey: 0, jasper: 1, lapis: 2, basalt: 3, sandstone: 4, jade: 5, sky: 6,
    // (a pebble's data-moss: how mossy, 1 usual; data-rocky: 0..1, a rougher, more chipped outline)
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
uniform vec4 uMore[${MAX}];   // the state pearl's x: glow, y: countdown left 0..1 (-1 none; under -1, a rest coming, filled -1 - y), z: its call glow
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
float stoneDist(vec2 rel, vec2 hs, float seed, float rocky, out float r) {
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
    // Rocky: deeper chips, and a fine broken edge.
    wob += rocky * (0.05 * (vnoise(ring * 9.0 + seed * 4.1) - 0.5) + 0.025 * (vnoise(ring * 23.0 + seed) - 0.5));
    float R = 1.0 + (wob - (0.08 + 0.1 * rocky) * chip + 0.07) * mn / dirR;
    r /= R;
    return (r - 1.0) * R * dirR;
}

// Moss on top (as the app's pebbles): patches over the upper part, thicker towards the top edge.
// rp: CSS px from the middle (y down), hs: half size in CSS px.
float mossAt(vec2 rp, vec2 hs, float seed, float amt) {
    // (In from the top edge a few px, ragged: rp.y + hs.y is how far below the top it is.)
    float below = rp.y + hs.y * 0.92 + 3.0 * amt * (vnoise(vec2(rp.x / 6.0, seed)) - 0.5);
    float top = smoothstep(7.0 * amt, 0.0, below);
    // (2D noise for the patches, so they don't run in stripes)
    float patches = smoothstep(0.45 - 0.12 * (amt - 1.0), 0.7 - 0.1 * (amt - 1.0),
        0.65 * vnoise(rp / 11.0 + seed * 9.0) + 0.35 * vnoise(rp.yx / 4.0 + seed));
    return clamp(top * patches * 1.3, 0.0, 1.0);
}
vec3 mossColour(vec2 rp, float seed) {
    return oklch(0.40 + 0.14 * vnoise(rp / 5.0), 0.09 + 0.05 * vnoise(rp / 20.0 + 3.0), 0.36 + 0.07 * vnoise(rp / 25.0 + seed))
         * (0.7 + 0.6 * vnoise(rp / 1.1 + seed));
}

vec3 pebble(int look, vec2 q, vec3 nn, float seed, float hover, vec2 rp, vec2 hs, float mossAmt) {
    float diff = max(dot(nn, L), 0.0);
    // Matte, as beach stones are dry: a broad, faint sheen, a little more when wet (hovered).
    float spec = pow(max(dot(reflect(-L, nn), vec3(0.0, 0.0, 1.0)), 0.0), 10.0 + 20.0 * hover);
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
    } else if (look == 6) {
        // Sky: a weathered blue-grey stone, mottled, with pale lichen-ish flecks.
        base = oklch(0.66 + 0.08 * grain + 0.04 * (speck - 0.5), 0.045, 0.66 + 0.04 * grain);
        base = mix(base, oklch(0.82, 0.02, 0.6), smoothstep(0.66, 0.8, fbm(w * 1.4 + 5.0)) * 0.5);
    } else {
        // Grey beach pebble, speckled.
        base = oklch(0.62 + 0.1 * grain + 0.06 * (speck - 0.5), 0.012, 0.2 + 0.1 * grain);
    }
    // Wet when hovered: darker, more saturated, glossier.
    base *= mix(1.0, 0.82, hover);
    float moss = mossAt(rp, hs, seed, mossAmt);
    base = mix(base, mossColour(rp, seed), moss);
    return base * (0.45 + 0.65 * diff) + env(nn) * 0.15 + spec * (0.08 + 0.3 * hover) * (1.0 - moss) + fres * 0.06 * env(nn);
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
        float marg = 16.0 * uDpr;   // (room for the shadow and the grass)
        if (abs(rel.x) > rc.z + marg || abs(rel.y) > rc.w + marg) continue;
        int kind = int(k.x + 0.5), look = int(k.y + 0.5);
        float seed = k.z, hover = k.w;
        float aa = 1.2 * uDpr;
        float d, sd;
        vec3 nn; vec2 q;
        if (kind == 0) {
            float r, r2;
            d = stoneDist(rel, rc.zw, seed, uMore[i].x, r);
            sd = stoneDist(rel - vec2(2.0, 4.0) * uDpr, rc.zw, seed, uMore[i].x, r2);
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
        if (body > 0.0) col = kind == 0 ? pebble(look, q, nn, seed, hover, rel / uDpr, rc.zw / uDpr, uMore[i].w)
            : look == 19 ? mix(pearl(11, q, nn, seed, hover) * 0.95, pearl(10, q, nn, seed, hover) * 1.3, uMore[i].x)
            : pearl(look, q, nn, seed, hover);
        // Shadow under, then the stone over it.
        vec4 s = vec4(0.0, 0.0, 0.0, shadow * (1.0 - body));
        vec4 b = vec4(col * body, body);
        vec4 item = b + s * (1.0 - b.a);
        if (look == 19) {
            // Half paused: hollow pause bars in a ring that runs down, and the warm call glow
            // growing over the last seconds (js/live.js showState).
            vec4 m = uMore[i];
            float px = 1.0 / min(rc.z, rc.w);   // one px in q
            vec3 warm = vec3(1.0, 0.78, 0.48);
            float call = max(m.z, 0.0), moonWarm = max(-m.z, 0.0);   // (a negative call: the moon out early, warm)
            if (call > 0.0) {
                item.rgb = mix(item.rgb, warm * body, call * 0.6);
                float halo = call * (1.0 - body) * exp(-max(d, 0.0) / (5.0 * uDpr)) * smoothstep(13.0 * uDpr, 6.0 * uDpr, d) * 0.8;   // (gone by the margin)
                item = vec4(warm * halo, halo) + item * (1.0 - halo);
            }
            // Refined: a soft, cool glow round it grows towards the end, so later progress shows too.
            float lit = smoothstep(0.35, 1.0, m.x);
            if (lit > 0.0) {
                float halo = lit * lit * (1.0 - body) * exp(-max(d, 0.0) / (4.5 * uDpr)) * smoothstep(13.0 * uDpr, 6.0 * uDpr, d) * 0.55;
                item = vec4(vec3(0.93, 0.95, 1.0) * halo, halo) + item * (1.0 - halo);
            }
            float moonF = floor(m.w / 1000.0) / 99.0, mw = m.w - floor(m.w / 1000.0) * 1000.0;
            float moonA = floor(mw / 10.0) / 99.0;
            if (moonA > 0.0) {
                // The refining moon: a tiny black pearl orbiting just outside the rim.
                float R = min(rc.z, rc.w), ang = mw - floor(mw / 10.0) * 10.0 - 1.5707963;
                vec2 mp = vec2(cos(ang), sin(ang)) * (R + 5.5 * uDpr);
                float md = length(rel - mp) - 2.8 * uDpr;
                float sh = (1.0 - 0.7 * sqrt(moonF)) * (1.0 - smoothstep(-1.0 * uDpr, 3.0 * uDpr, length(rel - mp - vec2(0.6, 1.2) * uDpr) - 2.8 * uDpr)) * 0.6 * moonA;
                float mo = (1.0 - smoothstep(-0.7 * uDpr, 0.7 * uDpr, md)) * moonA;
                // A tiny pearl, pale while it's busy, darkening to a black pearl (a peacock-green
                // sheen round its rim) as it slows, while the big one brightens; a highlight up left.
                vec2 mq = (rel - mp) / (2.8 * uDpr);
                float mr = clamp(length(mq), 0.0, 1.0);
                vec3 dark = vec3(0.07, 0.075, 0.085) + vec3(0.06, 0.14, 0.12) * pow(mr, 2.0);
                vec3 pale = vec3(1.05, 1.02, 0.98) - vec3(0.12, 0.13, 0.08) * pow(mr, 2.0);
                float fb = sqrt(moonF);   // (pale a while longer than it's fast)
                vec3 mc = mix(dark, pale, fb) + vec3(0.9) * smoothstep(0.55, 0.0, length(mq - vec2(-0.35, -0.4)));
                vec3 glowC = mix(vec3(1.0, 0.97, 0.92), vec3(1.0, 0.7, 0.38), moonWarm);
                mc = mix(mc, mc * vec3(1.0, 0.72, 0.42), moonWarm * 0.85);
                // While it's quick, a little glow round it, so it reads as bright, not grey.
                float mg = fb * moonA * (1.0 - mo) * exp(-max(md, 0.0) / (2.2 * uDpr)) * 0.7;
                item = vec4(glowC * mg, mg) + item * (1.0 - mg);
                item = vec4(0.0, 0.0, 0.0, sh) * (1.0 - item.a) + item;
                item = vec4(mc * mo, mo) + item * (1.0 - mo);
            }
            if (m.y >= 0.0 && body > 0.0) {
                vec3 ink = mix(vec3(1.0), vec3(0.08, 0.07, 0.1), smoothstep(0.45, 0.75, max(m.x, call)));
                float w = 1.6 * px * uDpr;
                // Hollow bars.
                vec2 bq = vec2(abs(abs(q.x) - 0.2), abs(q.y));
                vec2 bd = bq - vec2(0.085, 0.3);
                float box = length(max(bd, 0.0)) + min(max(bd.x, bd.y), 0.0);
                float bars = 1.0 - smoothstep(w * 0.5, w * 0.5 + px * uDpr, abs(box));
                // The ring, running down clockwise from the top.
                float fr = fract(atan(q.x, -q.y) / 6.2831853 + 1.0);
                float ring = (1.0 - smoothstep(w * 0.6, w * 0.6 + px * uDpr, abs(length(q) - 0.74))) * step(fr, m.y);
                float a = max(bars, ring) * body * 0.92;
                item.rgb = mix(item.rgb, ink * item.a, a);
            }
            if (m.y < -1.0 && body > 0.0) {
                // A rest coming: the same ring filling in clockwise from the top (no bars: the
                // pause glyph's still showing), fading in as it starts.
                float fill = -1.0 - m.y, w = 1.6 * px * uDpr;
                float fr = fract(atan(q.x, -q.y) / 6.2831853 + 1.0);
                float ring = (1.0 - smoothstep(w * 0.6, w * 0.6 + px * uDpr, abs(length(q) - 0.74))) * step(fr, fill);
                float a = ring * body * 0.85 * smoothstep(0.0, 0.12, fill);
                item.rgb = mix(item.rgb, vec3(1.0) * item.a, a);
            }
        }
        if (kind == 0) {
            // Grass: short blades standing up from the mossy top edge, in tufts, leaning a little,
            // each its own height and green, darker at the root.
            vec2 rp = rel / uDpr, hs = rc.zw / uDpr;
            float dd = d / uDpr;   // CSS px out from the edge
            float mA = uMore[i].w;
            if (rp.y < -0.35 * hs.y && dd > -1.0 && dd < 11.0) {
                // Two layers of blades (a shorter, darker one behind), each blade placed a little
                // off its slot, leaning with a slow "wind" shared by its neighbours plus its own,
                // and curving over towards its tip, so they don't read as a comb of straight lines.
                float tuft = smoothstep(0.42 - 0.2 * (mA - 1.0), 0.7 - 0.15 * (mA - 1.0), vnoise(vec2(rp.x / 11.0 + seed * 9.0, seed * 3.0)));
                float wind = (vnoise(vec2(rp.x / 17.0 + seed * 5.0, 1.0)) - 0.5) * 1.6;
                for (int Lr = 1; Lr >= 0; Lr--) {
                    float BW = Lr == 0 ? 2.5 : 3.3;   // CSS px a blade slot
                    float xx = rp.x + float(Lr) * 1.37;
                    float ci = floor(xx / BW);
                    float hs1 = hash(vec2(ci, seed + float(Lr) * 17.0));
                    float f = xx / BW - ci - 0.5 - (hash(vec2(ci, seed + 9.0 + float(Lr))) - 0.5) * 0.6;
                    float hgt = (2.0 + 6.5 * hs1) * (Lr == 0 ? 1.0 : 0.7) * (0.75 + 0.25 * mA) * tuft
                              * smoothstep(-0.35, -0.75, rp.y / hs.y);
                    float t = clamp(dd / max(hgt, 1e-3), 0.0, 1.0);
                    float lean = wind + (hash(vec2(ci, seed + 5.0 + float(Lr))) - 0.5) * 1.2;
                    float bend = (hash(vec2(ci, seed + 13.0 + float(Lr))) - 0.5) * 1.6;
                    float half_ = 0.3 * (1.0 - t) + 0.04;
                    float blade = (1.0 - smoothstep(half_ - 0.12, half_ + 0.12, abs(f - lean * t - bend * t * t))) * step(dd, hgt) * step(0.5, hgt);
                    blade *= smoothstep(-1.0, 0.5, dd);
                    vec3 g = oklch((Lr == 0 ? 0.32 : 0.26) + 0.3 * t + 0.08 * hash(vec2(ci, seed + 2.0)), 0.1 + 0.03 * t, 0.36 + 0.07 * hash(vec2(ci, seed + 7.0)));
                    vec4 gr = vec4(g * blade, blade);
                    item = gr + item * (1.0 - gr.a);
                }
            }
        }
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
    return s;
  }
  // Compiled in the background where the browser can (KHR_parallel_shader_compile): asking for
  // its status at once made the page's first frame wait ~0.3 s for it, just as the live hero's
  // fractal was starting too (Dan: sluggish to load). Until it's ready the pebbles show as CSS.
  const prog = gl.createProgram();
  const fs = sh(gl.FRAGMENT_SHADER, FS);
  gl.attachShader(prog, sh(gl.VERTEX_SHADER, VS));
  gl.attachShader(prog, fs);
  gl.bindAttribLocation(prog, 0, 'aPos');
  gl.linkProgram(prog);
  // (The GPU lost, for the live hero's sake or its own: the pebbles and pearls as CSS, not a
  // white page with Chrome's sad face over it.)
  canvas.addEventListener('webglcontextlost', e => { e.preventDefault(); ready = false; canvas.remove(); document.body.classList.remove('gems'); document.body.classList.add('no-gems'); });
  const parallel = gl.getExtension('KHR_parallel_shader_compile');
  let ready = false;
  const U = {};
  function checkReady() {
    if (gl.isContextLost()) return false;
    if (parallel && !gl.getProgramParameter(prog, parallel.COMPLETION_STATUS_KHR)) return false;
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      console.warn(gl.getShaderInfoLog(fs)); document.body.classList.add('no-gems'); canvas.remove(); return false;
    }
    for (const n of ['uRes', 'uTime', 'uDpr', 'uCount', 'uRect', 'uKind', 'uMore']) U[n] = gl.getUniformLocation(prog, n);
    document.body.classList.add('gems');
    return (ready = true);
  }
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
    if (!ready && !checkReady()) { if (canvas.isConnected) requestAnimationFrame(frame); return; }
    requestAnimationFrame(frame);
    const dt = Math.min((now - prev) / 1000, 0.1); prev = now;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    // Sized and placed by the canvas's own box (on Android Chrome 100vh was the height without the
    // address bar while innerHeight was with it, so the drawing stretched and sat low under its text).
    const cr = canvas.getBoundingClientRect();
    const W = Math.round(cr.width * dpr), H = Math.round(cr.height * dpr);
    if (canvas.width !== W || canvas.height !== H) { canvas.width = W; canvas.height = H; }
    let n = 0;
    for (const el of els) {
      if (n >= MAX) break;
      const r = el.getBoundingClientRect();
      if (r.bottom < cr.top - 20 || r.top > cr.bottom + 20 || r.width === 0) continue;
      const kind = el.dataset.gem === 'pearl' ? 1 : 0;
      const look = LOOKS[el.dataset.look] ?? (kind ? 10 : 0);
      const seed = parseFloat(el.dataset.seed || (n * 1.37 + 0.5));
      let h = hover.get(el) || 0;
      h += ((el._over ? 1 : 0) - h) * (1 - Math.exp(-dt * 8));
      hover.set(el, h);
      rects.set([(r.left - cr.left + r.width / 2) * dpr, (r.top - cr.top + r.height / 2) * dpr, r.width / 2 * dpr, r.height / 2 * dpr], n * 4);
      kinds.set([kind, look, seed, h], n * 4);
      // (its glow eases, so steps in progress read as a smooth brightening)
      el._glowShown = (el._glowShown ?? (el._glow || 0)) + ((el._glow || 0) - (el._glowShown ?? 0)) * (1 - Math.exp(-dt * 3));
      el._callShown = (el._callShown || 0) + ((el._call || 0) - (el._callShown || 0)) * (1 - Math.exp(-dt * 6));
      // A pebble's: rockiness, -, -, moss; the state pearl's: glow, countdown, call glow, -.
      // (and the state pearl's w: its orbiting moon, 1000 × its freshness (1 at full speed, 0 stopped)
      // + 10 × its alpha (eased) + its angle)
      const orb = el._orbit;
      el._orbitA = (el._orbitA || 0) + ((orb ? orb.show : 0) - (el._orbitA || 0)) * (1 - Math.exp(-dt * 4));
      if (orb) el._ang = ((el._ang || 0) + orb.speed * dt) % (2 * Math.PI);
      el._freshShown = orb ? (el._freshShown ?? 1) + (orb.fresh - (el._freshShown ?? 1)) * (1 - Math.exp(-dt * 3)) : 1;
      if (kind === 0) more.set([parseFloat(el.dataset.rocky || 0), 0, 0, parseFloat(el.dataset.moss || 1)], n * 4);
      if (kind !== 0) more.set([el._glowShown, el._count ?? -1, el._callShown, Math.floor(el._freshShown * 99) * 1000 + Math.floor(el._orbitA * 99) * 10 + (el._ang || 0)], n * 4);
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
    // Only round each one, as far as FS looks (its rect and `marg`): a full-screen pass, every
    // pixel looping over every gem, cost the whole page's GPU every frame for a few small shapes.
    // (Where boxes overlap, FS works out the same colour twice.)
    gl.enable(gl.SCISSOR_TEST);
    const marg = 16 * dpr + 2;
    for (let i = 0; i < n; i++) {
      const cx = rects[i * 4], cy = rects[i * 4 + 1], hw = rects[i * 4 + 2] + marg, hh = rects[i * 4 + 3] + marg;
      const x0 = Math.max(0, Math.floor(cx - hw)), x1 = Math.min(W, Math.ceil(cx + hw));
      const y0 = Math.max(0, Math.floor(H - (cy + hh))), y1 = Math.min(H, Math.ceil(H - (cy - hh)));
      if (x1 <= x0 || y1 <= y0) continue;
      gl.scissor(x0, y0, x1 - x0, y1 - y0);
      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    }
    gl.disable(gl.SCISSOR_TEST);
  }
  requestAnimationFrame(frame);
})();
