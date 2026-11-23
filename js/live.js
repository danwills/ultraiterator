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
uniform int uLake;         // 1: alpha is how much isn't lake (the steering's looks), else 1
uniform float uIterCap;    // each layer's iterations x this (1: as UF has them; the iterations pearl)
out vec4 frag;
float gInside, gLayers;    // layers inside, of those run, for this sample (counted in at each layer's inside branch)
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
`;
  // As the app's LIVE_GEN_MAIN, but `o` from the view rather than a tile.
  const MAIN = `
void main() {
    vec3 sum = vec3(0.0);
    float px = uView.z / uRes.y, lake = 0.0;
    for (int j = 0; j < uAA; j++) for (int i = 0; i < uAA; i++) {
        vec2 f = gl_FragCoord.xy + uJitter + (vec2(i, j) + 0.5) / float(uAA) - 0.5;
        gInside = 0.0; gLayers = 0.0;
        sum += liveColour(uView.xy + uiTurn(uRot, (f - 0.5 * uRes) * px));
        if (gLayers > 0.0) lake += gInside / gLayers;
    }
    float n = float(uAA * uAA);
    frag = vec4(clamp(sum / n, 0.0, 1.0), uLake == 1 ? 1.0 - lake / n : 1.0);
}`;
  const VS = `#version 300 es
in vec2 aPos;
void main() { gl_Position = vec4(aPos, 0.0, 1.0); }`;
  // The blend: this frame's samples with the history, read back where this pixel was in the
  // last frame's view (Catmull-Rom, so repeated resampling doesn't blur it).
  // The history is at the screen's resolution, finer than the samples (the ladder's scale), and
  // each sample counts where it was really taken, its jittered spot, not its pixel's middle: so
  // the jitter fills in between them over a few frames, and the samples' own grid never shows.
  // (With the history at the samples' size, enlarged to the screen afterwards, it did, whatever
  // the filter: Dan, "still too squarey/griddy when zooming in".)
  const RESOLVE_FS = `#version 300 es
precision highp float;
uniform sampler2D uCur, uHist;
uniform vec2 uRes;         // the history's size
uniform vec2 uCurRes;      // the samples'
uniform float uCurH;       // the samples' view's height (it reaches a little further out than the history's)
uniform vec2 uJitter;      // this frame's samples' sub-pixel offset
uniform vec3 uView, uPrev;
uniform vec2 uRot, uPrevRot;   // their turns, (cos, sin)
uniform float uKeep;       // the history's weight (0: start afresh)
uniform float uClip;       // how far (in the neighbourhood's spreads) history may stray from this frame
out vec4 frag;
vec2 uiTurn(vec2 r, vec2 p) { return vec2(r.x * p.x - r.y * p.y, r.y * p.x + r.x * p.y); }   // p turned by r = (cos, sin)
// (All nine taps: the usual five-tap shortcut, corners dropped, left an axis-aligned grid that
// built up where the history's kept longest, round the zoom's centre; measured ~2x the 9-tap's.)
vec3 catmullRom(vec2 p) {
    vec2 tc = floor(p - 0.5) + 0.5, f = p - tc;
    vec2 w0 = f * (-0.5 + f * (1.0 - 0.5 * f)), w1 = 1.0 + f * f * (-2.5 + 1.5 * f);
    vec2 w2 = f * (0.5 + f * (2.0 - 1.5 * f)), w3 = f * f * (-0.5 + 0.5 * f);
    vec2 w12 = w1 + w2, t12 = (tc + w2 / w12) / uRes, t0 = (tc - 1.0) / uRes, t3 = (tc + 2.0) / uRes;
    vec3 c = vec3(0.0);
    vec2 tx[3] = vec2[3](vec2(t0.x, w0.x), vec2(t12.x, w12.x), vec2(t3.x, w3.x));
    vec2 ty[3] = vec2[3](vec2(t0.y, w0.y), vec2(t12.y, w12.y), vec2(t3.y, w3.y));
    for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) c += texture(uHist, vec2(tx[i].x, ty[j].x)).rgb * tx[i].y * ty[j].y;
    return c;
}
// A sample's weight by its distance in sample pixels: a Gaussian about as wide as the refinement's.
const float SIGMA = 0.45;
void main() {
    vec2 f = gl_FragCoord.xy;
    // Where this pixel is among the samples, and this frame's estimate there: the 3x3 nearest
    // samples, weighted by how far each one's spot is from it. cover says how near they came.
    float k = (uView.z / uRes.y) * (uCurRes.y / uCurH);   // sample pixels a history pixel
    vec2 q = (f - 0.5 * uRes) * k + 0.5 * uCurRes - uJitter;
    ivec2 b = ivec2(floor(q)), hi = ivec2(uCurRes) - 1;
    vec3 c = vec3(0.0), m1 = vec3(0.0), m2 = vec3(0.0);
    float cover = 0.0;
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) {
        ivec2 t = clamp(b + ivec2(i, j), ivec2(0), hi);
        vec3 s = texelFetch(uCur, t, 0).rgb;
        vec2 d = q - (vec2(b + ivec2(i, j)) + 0.5);
        float w = exp(-dot(d, d) / (2.0 * SIGMA * SIGMA));
        c += s * w; cover += w;
        m1 += s; m2 += s * s;
    }
    c /= cover;
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
        m1 /= 9.0; m2 /= 9.0;
        vec3 sd = sqrt(max(m2 - m1 * m1, 0.0));
        // Moving fast, the history counts for less and is clipped closer (it smeared into
        // streaks on quick pans and zooms), and pixels that came in past the edge only borrow
        // the edge's history when they're within a pixel or two of it.
        // (Both in sample pixels, as they were tuned before the history was finer.)
        float speed = length(pf - f) * k;   // this pixel's travel since last frame
        float outside = length(pf - clamp(pf, vec2(1.5), uRes - 1.5)) * k;
        float clip = uClip / (1.0 + 0.12 * speed);
        h = clamp(h, m1 - clip * sd, m1 + clip * sd);
        // A pixel between this frame's samples takes less of them, the rest from its history.
        float keep = uKeep * exp(-outside / 2.5) / (1.0 + 0.08 * speed);
        c = mix(h, c, (1.0 - keep) * min(cover, 1.0));
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
// The blend, enlarged to the screen by a Mitchell-Netravali cubic (B = C = 1/3, 16 taps): bilinear
// showed its pixel grid at the lower render scales, and so did Catmull-Rom wherever the scale's
// not a whole number (measured at 0.4: axis-aligned energy 48x the diagonal's; Mitchell 4.5x).
float mitchell(float x) {
    x = abs(x);
    return x < 1.0 ? (7.0 * x * x * x - 12.0 * x * x + 16.0 / 3.0) / 6.0
         : x < 2.0 ? (-7.0 / 3.0 * x * x * x + 12.0 * x * x - 20.0 * x + 32.0 / 3.0) / 6.0 : 0.0;
}
vec3 blendAt(vec2 uv) {
    if (uHistRes.y >= uRes.y) return texture(uTex, uv).rgb;
    vec2 p = uv * uHistRes - 0.5, b = floor(p), f = p - b;
    vec3 c = vec3(0.0); float ws = 0.0;
    for (int j = -1; j <= 2; j++) for (int i = -1; i <= 2; i++) {
        float w = mitchell(float(i) - f.x) * mitchell(float(j) - f.y);
        c += texelFetch(uTex, clamp(ivec2(b) + ivec2(i, j), ivec2(0), ivec2(uHistRes) - 1), 0).rgb * w; ws += w;
    }
    return max(c / ws, 0.0);
}
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
    vec2 hu = vec2(hq.x * uHistRes.y / uHistRes.x, hq.y) + 0.5;
    vec3 c = blendAt(hu);
    // Past the blend's edge (it waits while the view turns on in a rest, and runs out at the rim
    // within a second or so) it's only its edge pixels stretched: streaks (Dan). There the
    // refinement's own picture alone, once it has a sample.
    bool off = any(lessThan(hu, vec2(0.0))) || any(greaterThan(hu, vec2(1.0)));
    if (uRefMix > 0.0) {
        vec2 pf = uiTurn(uRefRot * vec2(1.0, -1.0), o - uRefView.xy) * (uAccRes.y / uRefView.z) + 0.5 * uAccRes;
        if (all(greaterThanEqual(pf, vec2(0.0))) && all(lessThan(pf, uAccRes))) {
            vec4 a = accAt(pf);
            // From the first sample on: the moving view's picture, worth uSeed samples, and the
            // refinement's, so it improves at once and smoothly takes over.
            c = off && a.a > 0.0 ? a.rgb / a.a : mix(c, (c * uSeed + a.rgb) / (uSeed + a.a), uRefMix);
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

  // Its randomness is seeded from the world's clock (UTC), so every copy of the page open at once
  // shows the same (Dan: "all instances in the world will get the same seed at the same time"):
  // the order's shuffled once a UTC day, it starts on the one for this SLOT of the day and goes on
  // in that order, and each fractal's dive (its steering's picks, rests and turn) is seeded by the
  // day and the fractal. They drift apart from there with each machine's speed (its rests last as
  // long as it takes to refine), but each fractal's dive begins the same everywhere.
  const FIRST_GLSL_MAX = 10000;   // bytes: the page's first fractal's shader at most (17 of 63)
  const SLOT = 120;            // seconds of the day a fractal, for where it starts
  const DAY = Math.floor(Date.now() / 864e5);
  function seeded(n) {   // mulberry32
    let a = n >>> 0;
    return () => { a = (a + 0x6D2B79F5) >>> 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
  }
  const hashStr = str => { let h = 2166136261; for (let i = 0; i < str.length; i++) h = Math.imul(h ^ str.charCodeAt(i), 16777619); return h >>> 0; };
  let rand = seeded(DAY);
  const ZOOM_RATE = 0.6;       // octaves a second (quicker since the rests show it sharp; was 0.085, 0.13, 0.2, 0.3)
  const TURN_MAX = 0.035;      // the most it turns, radians a second (~2°; ~1.4° a second on average; was 0.015, 0.025)
  let turnT = 0, turnPh = 0, turnSteer = 0;   // (turnSteer: s since a start or a touch)
  // Its rate, radians a second, at turn time t: a low, signed noise (two slow sines).
  const turnRate = (t, ease) => TURN_MAX * ease * (0.6 * Math.sin(0.043 * t + turnPh) + 0.4 * Math.sin(0.0187 * t + 2.1 * turnPh));
  const DRIFT_MAX = 0.09;      // the most it drifts sideways, in screen heights a second (was 0.045, 0.07)
  const RETARGET = 3;          // seconds between looks for detail (was 4.5)
  const PROBE = 40;            // the look's size, px square
  // Looking ahead: the best LOOK_K spots in the look (and straight on) are each drawn small,
  // LOOK_DEEP times deeper, and it heads for the one that stays detailed all over down there.
  const LOOK_K = 6, LOOK_DEEP = [4, 12], LOOK_PX = 24;
  const STEER_OLD = new URLSearchParams(location.search).get('steer') === 'old';   // (?steer=old: the old way, to compare)
  const IDLE_RESUME = 9;       // seconds after a touch before it steers itself again
  // Rests: the dive eases to a stop now and then (after REST_EVERY s of moving) and holds still for
  // REST_HOLD s, so the refinement gets to show; the pause pearl counts it down as after a touch.
  const REST_EVERY = [7.5, 15],   // (halved, Dan, 2026-11-21: was 15-30)
        REST_HOLD = 11, REST_SETTLE = 3, REST_RESUME = 3;
  // ...or, where it refines, for as long as the picture's still settling (Dan): about once a second
  // the middle of the refinement is read back, and once it changes by under REST_STILL (of 255)
  // a second it holds REST_AFTER s more. Never under REST_MIN s or over REST_MAX; and it ends
  // early rather than turn past what it refined (REST_TURN_FOR s of turn's worth, see startRefine).
  // (Dan: rested too long; all halved, 2026-11-21: they were 8, 40, 5, 25, with REST_HOLD 22.)
  // ...and then (Dan: "wait until refinement is done, then a few more seconds of rotate drift"):
  // done at REST_SAMPLES samples a pixel (END_MIN_N at the depth's end), as the settling read
  // seldom came under REST_STILL (busy fractals keep changing a little), so rests ran to their
  // caps; then REST_AFTER s more, turning, and on.
  const REST_MIN = 4, REST_MAX = 20, REST_AFTER = 3, REST_STILL = 1, REST_TURN_FOR = 9, REST_SAMPLES = 16;   // (REST_TURN_FOR 9 since it turns faster in a rest)
  // No rest till it's moved REST_MOVE_FIRST s since a start or a touch (Dan: after looking around
  // by hand it went straight into a rest: the time since the last rest had kept counting).
  const REST_MOVE_FIRST = 4;
  const SETTLE_PX = 48;
  let restWhy = '', restRate = 0, restWaiting = false, restAt = 0, settleRead = null, settleReadAt = 0, settleReadN = 0, settleReads = 0, rateKnown = false, refFirstAt = 0, refAng = 0, refAngGo = 0;
  const settlePx = new Float32Array(SETTLE_PX * SETTLE_PX * 4);
  // The end of its depth always gets a rest (Dan: "heaps of zooms seem to end and go to the next
  // fractal instead of rendering a nice deep-zoom"): it settles there, at END_REST_AT x its least
  // height, refines as any rest does, then fades to the next fractal still holding the refined view.
  const END_REST_AT = 1.5;
  // ...and that last rest is meant to end sharp (Dan: "zooms in for ages and doesn't reward with
  // a high-res"): it refines at the screen's full resolution whatever the refinement had stepped
  // down to (watchFps), doesn't turn (so needs no margin and never runs out of it), and holds till
  // END_MIN_N samples a pixel and settled, or END_MAX s.
  const END_MIN_N = 32, END_MAX = 20;   // (were 64, 60; Dan: the longest rest 20 s)
  // (The depth's end counts its END_MAX from the refinement's first sample, so a slow start doesn't
  // cut it short of finishing, Dan; END_HARD at the most however it goes.)
  const END_HARD = 45;
  const REST_LEAD = 5;         // seconds of moving the pause pearl shows a rest coming (and then its settling)
  // A word under the pause pearl as a rest begins and ends.
  const sayEl = document.getElementById('live-say'), SAY_FOR = 3.5;
  let sayTimer = 0, restHolding = false, endRest = false, ended = false;   // (endRest: this rest's the depth's end; ended: done, fading out still)
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
  const restIn = () => REST_EVERY[0] + rand() * (REST_EVERY[1] - REST_EVERY[0]);
  const FADE = 1.5;            // seconds to fade between fractals
  const KEEP_MAX = 0.9;        // the history's most weight: about the last ten frames
  const KEEP_DEEP = 0.75;      // ...and at the end of its depth
  const CLIP = 2.0;            // variance clipping's reach (RESOLVE_FS) while it moves
  const CLIP_DEEP = 1.25;      // ...and at the end of its depth
  // Still (paused, or left alone after a touch) for STILL_REFINE frames, it refines: each frame
  // adds one sample a pixel to a running sum, at a fresh sub-pixel spot (Halton, so they never
  // repeat), spread as a Gaussian of REF_SIGMA px, so after N frames it's as if rendered at √N×
  // and downsampled with a soft filter: 2× by 4, 8× by 64, 32× by REF_MAX. On a desktop (a mouse
  // to hover with) it refines at the screen's full resolution; a phone at a CSS pixel, for its
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
  const REF_SEED = 6;          // the moving view's picture's worth, in samples, as refinement begins (SHOW_FS)...
  const REF_SEED_GO = 8;       // ...shrinking by e each this many samples (Dan: at a steady 6 its lumpy low-res
                               // still showed through the refined one: 17% at 30 samples; now 5% at 16, 1% at 24)
  const REF_IN = 1.5;          // seconds the refinement takes to fade in
  let refStartT = 0;
  const REF_OUT = 0.5;         // seconds to fade back out once the view moves
  // Without float blending: a plain running average in the moving view's blend instead, this long.
  const STILL_FRAMES = 128;
  // How deep: no further than where a screen pixel spans PRECISION_ULPS of fp32's steps in c, at
  // the worst place the view can be. (Was 2, from the 2k's middle only: precision blocks crept in at
  // the end of some dives, Dan.) Each layer maps the view's o to c = C + R o, both in fp32 on the
  // GPU, so its step is c's own (ulp at |c|, which grows away from the middle) plus o's, by |R|.
  // 16 (was 8, from 2 before that): precision trouble was still seen at the end of a dive
  // (Dan, 2026-11-21: "extra careful"). Median ~16x past the 2k over the 63, the least 3.3x.
  // (Measuring it directly, as the view drawn twice with c rounded two ways, didn't work: past
  // the limit both collapse to the same flat colour, and chaotic ones differ at any depth.)
  const PRECISION_ULPS = 16;
  const ulp32 = x => 2 ** (Math.floor(Math.log2(Math.max(Math.abs(x), 1e-30))) - 23);
  const mapsOf = src => { const off = slopeOffsets(src); return [...src.matchAll(/const vec2 C(\d+) = vec2\(([^,]+), ([^)]+)\), R\d+ = vec2\(([^,]+), ([^)]+)\)/g)]
    .map(m => ({ cx: +m[2], cy: +m[3], r: Math.hypot(+m[4], +m[5]), off: off[m[1]] || 0 })); };
  // A slope layer lit from three orbits a fixed offset apart in c (sdc-slope-blend's, uprPort):
  // with a pixel under the offset its light is a slope across pixels, blurred, and blocky as the
  // offset nears fp32's steps. So its pixel stays at least the offset. (Its normal's last term
  // is -offset. None on the site yet, 20 in the app; SlopeMandel's is exact, from dz/dc, and its
  // grain looks right at the general limit, smeared only at a quarter of it.)
  const slopeOffsets = src => {
    const out = {};
    for (const part of src.split(/(?=vec3 colourAt\d+\()/)) {
      const k = /^vec3 colourAt(\d+)\(/.exec(part), m = /normalize\(vec3\([^,]+ \* \(f_e2 - f_e1\), [^,]+ \* \(f_e3 - f_e1\), (-?[0-9.e+-]+)\)\)/.exec(part);
      if (k && m) out[k[1]] = Math.abs(+m[1]);
    }
    return out;
  };
  // The least height for a view reaching rho (picture heights) from the 2k's middle.
  // (picks.json's floor: a pick that goes soft before that, stopped that many times shallower:
  // 6bd31d1593eb, 4, from Dan's phone.)
  function floorH(maps, rho, screenPx) {
    let need = 0;
    for (const m of maps) if (m.r > 0) {
      need = Math.max(need, (ulp32(Math.max(Math.abs(m.cx), Math.abs(m.cy)) + m.r * rho) / m.r + ulp32(rho)) * PRECISION_ULPS);
      if (m.off) need = Math.max(need, m.off / m.r);   // (a slope layer's pixel, at least its offset)
    }
    return need * screenPx;
  }
  const TAA = new URLSearchParams(location.search).get('taa') !== '0';   // ?taa=0: no blending, to compare
  const PIN_STEP = new URLSearchParams(location.search).has('step') ? +new URLSearchParams(location.search).get('step') : null;   // ?step=n: hold the ladder there, to compare
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
  let startH = 1, minH = 1e-3, floorPx = 1, picRho = 1, lastLook = 0, steerT = 0, easeFor = 4;   // (easeFor: s to reach full speed)
  // Held still till holdUntil (a touch, or a rest), holdLen s in all; moving for movedT s since the
  // last rest, the next after nextRest; settleAt: when a rest began easing to a stop (or null).
  let holdUntil = -1e9, holdLen = IDLE_RESUME, movedT = 0, nextRest = restIn(), settleAt = null;
  let fade = 0, fadeDir = 1, paused = false, leaving = false;
  let frames = 0, jitterI = 0, still = 0;
  const READY_FRAMES = 8;   // frames blended before it fades in
  let refining = false, refN = 0, refMix = 0, refView = null, acc = null, refTurns = false;
  let refSync = null, refSyncA = null, refBegan = 0, refSubmit = 0, refRest = 0, band = 0, bands = 1;
  // (Never more bands than half its rows: past that they're empty draws, each still waited on.)
  const maxBands = () => 2 ** Math.floor(Math.log2(Math.max(1, Math.min(1024, (acc ? acc.h : 2) >> 1))));

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
  const ahead = target2d((LOOK_K + 1) * LOOK_PX, LOOK_DEEP.length * LOOK_PX, gl.RGBA8);
  const aheadPx = new Uint8Array(ahead.w * ahead.h * 4);
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
        if (!gl.getProgramParameter(p, gl.LINK_STATUS)) reject(Object.assign(new Error(gl.getShaderInfoLog(f) || gl.getProgramInfoLog(p)), { compile: true }));
        else resolve(p);
      };
      check();
    });
  }
  function uniforms(p, names) { const u = {}; for (const n of names) u[n] = gl.getUniformLocation(p, n); return u; }
  const resolve = link(RESOLVE_FS).p, show = link(SHOW_FS).p, bake = link(BAKE_FS).p;
  const BU = uniforms(bake, ['uAcc', 'uRes', 'uAccRes', 'uView', 'uRefView', 'uRot', 'uRefRot']);
  const RU = uniforms(resolve, ['uCur', 'uHist', 'uRes', 'uCurRes', 'uCurH', 'uJitter', 'uView', 'uPrev', 'uKeep', 'uClip', 'uRot', 'uPrevRot']);
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

  // A port's source as drawn here. Each layer's inside branch counts it, for the steering's lakes
  // (see look). And its iterations are capped by uIterCap, the iterations pearl (a variable bound
  // measured no slower at 1), with its inside colouring scaled to match (Dan: "so we end up in a
  // similar bit of the gradient"): a point still going at the cap has done cap of its iterations,
  // so whatever its colouring adds up each iteration (i_sum, i_sum2; prodlog(i_lp), a sum of logs,
  // where it's over numiter) is scaled by full / capped, as if the rest had added the same again.
  // Minimums (i_dmin, i_closest) and averages over their own count (i_lp / i_n) need nothing, and
  // a point that bails, as it would have anyway, is unchanged. Measured over the 63 at half the
  // iterations: the median change 62 of 255 unscaled, 24 scaled. Tried and worse (2026-11-21):
  // summing exp(-1/|step|)'s tail from the step's shrinking ratio (the orbits at the cap mostly
  // wander rather than converge, so the ratio's noise), and letting converging points out early.
  // (Each layer's loop is matched with the inside branch after it: one each in all 63. opts.pad
  // false leaves the scaling out, for tests.)
  function capSource(src, opts = {}) {
    let out = '', i = 0;
    const loop = /for \(int it = 0; it < (\d+); it\+\+\)/g;
    let m;
    while ((m = loop.exec(src))) {
      const n = m[1], eff = 'max(1, int(float(' + n + ') * uIterCap))';
      const head = 'if (inside && !FORCEOUT) {', at = src.indexOf(head, m.index);
      if (at < 0) break;
      let d = 1, j = at + head.length;
      while (j < src.length && d) { if (src[j] === '{') d++; else if (src[j] === '}') d--; j++; }
      let branch = src.slice(at + head.length, j - 1);
      if (opts.pad !== false) branch = ' float iPad_ = float(' + n + ') / float(' + eff + ');' + branch
        .replace(/\bi_sum2\b/g, '(i_sum2 * iPad_)').replace(/\bi_sum\b/g, '(i_sum * iPad_)')
        .replace(/prodlog\((i_lp|i_old)\) \/ float\(numiter/g, 'prodlog($1) * iPad_ / float(numiter');
      out += src.slice(i, m.index) + 'for (int it = 0; it < ' + eff + '; it++)' + src.slice(m.index + m[0].length, at) +
        'gLayers += 1.0; gInside += float(inside); ' + head + branch + '}';
      i = j; loop.lastIndex = j;
    }
    return out + src.slice(i);
  }
  const SLOW = +(new URLSearchParams(location.search).get('slow') || 0);
  // A pixel drawn with a new program as soon as it's linked: a phone's driver (Dan's S22) finished
  // compiling only at its first draw, whatever KHR_parallel_shader_compile said, so the fade-in
  // stalled 1.5-2 s. Now that's here, at the rest it's loaded in (the view still), instead.
  const warmT = target2d(1, 1, gl.RGBA8);
  function warm(prog) {
    if (gl.isContextLost()) return;
    const fb = gl.getParameter(gl.FRAMEBUFFER_BINDING), vp = gl.getParameter(gl.VIEWPORT), was = gl.getParameter(gl.CURRENT_PROGRAM);
    gl.bindFramebuffer(gl.FRAMEBUFFER, warmT.fb);
    gl.useProgram(prog);
    quadDraw(1, 1);
    gl.useProgram(was); gl.bindFramebuffer(gl.FRAMEBUFFER, fb); gl.viewport(vp[0], vp[1], vp[2], vp[3]);
  }
  const loaded = new Map();
  function load(pick) {
    if (!loaded.has(pick.id)) {
      loaded.set(pick.id, (async () => {
        const src = capSource(await (await fetch('live/' + pick.id + '.glsl')).text());
        if (SLOW) await new Promise(r => setTimeout(r, SLOW));   // (?slow=ms: a slow compile, to test the wait)
        const [prog, tex] = await Promise.all([program(HEAD + common + src + MAIN), gradient(pick.id)]);
        warm(prog);
        return { pick, prog, tex, maps: mapsOf(src), uni: uniforms(prog, ['uGrad', 'uAA', 'uView', 'uRes', 'uJitter', 'uRot', 'uLake', 'uIterCap']) };
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
  let starting = false, beganAt = 0, fullAt = 0, queued = null, begun = false;   // (fullAt: when it had faded in)
  // The next fractal's compiled while this one rests (or is paused), the view still: a compile
  // takes 0.2-4 s, and the browser's GPU stalls meanwhile (frames of up to half a second here),
  // so compiling as each one began made its start sluggish (Dan). (One not ready by the end is
  // waited for, its render showing.)
  const loadNext = () => { if (order.length) load(order[nextFitting(at)]).catch(() => {}); };
  const WAIT_SHOW = 0.4;   // s of waiting before the render's shown   // (queued: a show() that came while starting)
  // A fractal that didn't load (Dan: clicking one, it cycled through them all, a frame each): it
  // had been dropped and the next begun at once, so with the network down (each fetch failing at
  // once) the list emptied in seconds, and a failed load stayed failed. Now its render shows and
  // the same one's tried again (LOAD_RETRY s, longer each time); a shader that won't compile is
  // dropped as before, but COMPILE_GIVE_UP of them running means something's wrong here, and with
  // the GPU lost it stops at once: either way, the render (giveUp).
  const LOAD_RETRY = 3, COMPILE_GIVE_UP = 3;
  let loadFails = 0, compileFails = 0, retryT = 0;
  function loadFailed(pick, e) {
    loaded.delete(pick.id);
    cur = null;   // (the one before stops, or its fade's end would begin another each frame)
    if (gl.isContextLost()) { giveUp(); return; }
    if (e && e.compile) {
      console.warn('live: ' + pick.id + ' did not compile', e);
      order.splice(at, 1);
      if (++compileFails >= COMPILE_GIVE_UP || !order.length) { if (poster) poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)'; giveUp(); return; }
      begin(at);
      return;
    }
    console.warn('live: ' + pick.id + ' did not load; again in ' + LOAD_RETRY * (loadFails + 1) + ' s', e);
    if (poster) { poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)'; poster.classList.remove('gone'); }
    document.body.classList.add('waiting');
    clearTimeout(retryT);
    retryT = setTimeout(() => { if (!cur && !starting) begin(at); }, LOAD_RETRY * 1000 * Math.min(++loadFails, 10));
  }
  async function begin(i) {
    clearTimeout(retryT);
    if (starting) return;
    starting = true;
    at = (i + order.length) % order.length;
    const pick = order[at];
    rand = seeded(hashStr(DAY + ':' + pick.id)); turnPh = rand() * 6.283; turnT = 0;   // (this dive's own, the same everywhere)
    // A slow compile (a shader not ready yet, ~10 s for some): its 2k render shows meanwhile, not
    // black, and the live one cross-fades in over it once it's ready.
    const first = !begun; begun = true;   // (the page's very first: its render shows straight away, the GPU's busiest then)
    const waitT = setTimeout(() => {
      if (!starting) return;
      if (poster) { poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)'; poster.classList.remove('gone'); }
      document.body.classList.add('waiting');
    }, first ? 0 : WAIT_SHOW * 1000);
    let next;
    try { next = await load(pick); }
    catch (e) { starting = false; clearTimeout(waitT); loadFailed(pick, e); return; }
    loadFails = 0; compileFails = 0;
    starting = false;
    clearTimeout(waitT);
    if (queued !== null) { const q = queued; queued = null; begin(q); return; }
    cur = next; beganAt = performance.now() / 1000; fullAt = 0; looking = false; refCap = 1e9; proved = false; cheapNext = false;
    if (PIN_STEP === null) { step = startStep(pick); ceiling = 99; frameTimes = []; }
    showName(pick);
    // The whole 2k to start with, then in until fp32 runs out (its depth past the 2k).
    startH = 1.0;
    // Its depth is how far past its 2k fp32 holds: a pixel no finer than 1/(2048 depth) of the
    // picture's height. Taken at the screen's own pixels (not the render's, which can be coarser
    // for a while), with a margin, since the sub-pixel samples go finer still.
    const screenPx = canvas.getBoundingClientRect().height * Math.min(window.devicePixelRatio || 1, 2);
    // (The view stays near the picture, so its half-diagonal and a little more; look() raises it if
    // the view wanders further.)
    floorPx = screenPx; picRho = 0.6 * Math.hypot(pick.aspect || 1, 1);
    minH = Math.max(startH / 4096, floorH(next.maps, picRho, screenPx) * (pick.floor || 1));
    view = { x: 0, y: 0, h: startH, a: 0 };
    target = { x: 0, y: 0 }; aim = { x: 0, y: 0 }; vel = { x: 0, y: 0 };
    lastLook = performance.now() / 1000 - RETARGET + 1.0; steerT = 0; easeFor = 4; turnSteer = 0;
    // (the first rest a quarter of the usual way in, as if it had joined a cycle partway through)
    holdUntil = -1e9; movedT = 0; nextRest = restIn() / 4; settleAt = null; restHolding = false; restWaiting = false; endRest = false; ended = false;
    fade = 0; fadeDir = 1; leaving = false; frames = 0; still = 0; prevView = null; stopRefine(); refMix = 0;
    if (document.body.classList.contains('waiting')) fade = 1;   // (the canvas's own opacity does the cross-fade)
    // (The next one compiles at this one's first rest: loadNext.)
  }

  function quadDraw(w, h) {
    gl.viewport(0, 0, w, h);
    gl.bindBuffer(gl.ARRAY_BUFFER, quad);
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
  function drawFractal(w, h, v, aa, jx, jy, lake) {
    const u = cur.uni;
    gl.useProgram(cur.prog);
    gl.uniform1i(u.uLake, lake ? 1 : 0);
    gl.uniform1f(u.uIterCap, iterCap);
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

  // Where's the detail? A small render of the view, and the cells with the most contrast among
  // their neighbours, leaning towards the middle and towards the way it's already drifting, so
  // its course bends gently rather than doubling back. Contrast alone liked the edge of a big
  // flat region, or a lone line in a blank space (Dan), and only saw this depth, so the best few
  // (and straight on) are each looked at deeper (lookAhead) before it picks.
  // Read back without waiting: into a pixel buffer, picked up once a fence says the GPU's done
  // (pollReads, each frame). readPixels straight into memory had stalled the page 150-250 ms at
  // every look on Dan's phone (every 3 s), waiting for the draws before it. A read whose fractal
  // has changed meanwhile is dropped.
  const reads = [];
  function readAsync(fb, w, h, dst, done) {
    const buf = gl.createBuffer();
    gl.bindBuffer(gl.PIXEL_PACK_BUFFER, buf);
    gl.bufferData(gl.PIXEL_PACK_BUFFER, dst.byteLength, gl.STREAM_READ);
    gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
    gl.readPixels(0, 0, w, h, gl.RGBA, gl.UNSIGNED_BYTE, 0);
    gl.bindBuffer(gl.PIXEL_PACK_BUFFER, null);
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    reads.push({ buf, dst, done, of: cur, sync: gl.fenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0) });
    gl.flush();
  }
  function pollReads() {
    for (let i = 0; i < reads.length; i++) {
      const r = reads[i];
      if (gl.clientWaitSync(r.sync, 0, 0) === gl.TIMEOUT_EXPIRED) continue;
      reads.splice(i--, 1);
      gl.deleteSync(r.sync);
      if (r.of === cur && cur) {
        gl.bindBuffer(gl.PIXEL_PACK_BUFFER, r.buf);
        gl.getBufferSubData(gl.PIXEL_PACK_BUFFER, 0, r.dst);
        gl.bindBuffer(gl.PIXEL_PACK_BUFFER, null);
      }
      gl.deleteBuffer(r.buf);
      if (r.of === cur && cur) r.done();
    }
  }
  let looking = false;
  function look() {
    if (looking) return;
    const rho = Math.hypot(view.x, view.y) + view.h;
    if (rho > picRho) { picRho = rho; minH = Math.max(minH, floorH(cur.maps, rho, floorPx) * (cur.pick.floor || 1)); }   // (wandered off the picture: c's step may be coarser there)
    gl.bindFramebuffer(gl.FRAMEBUFFER, probe.fb);
    const v = { ...view };   // (the view it looked from: it's moved on by the time the pixels are back)
    drawFractal(PROBE, PROBE, v, 1, 0, 0, true);
    looking = true;
    readAsync(probe.fb, PROBE, PROBE, probePx, () => looked(v));
  }
  function looked(view) {
    const L = (x, y) => { const k = (y * PROBE + x) * 4; return 0.3 * probePx[k] + 0.59 * probePx[k + 1] + 0.11 * probePx[k + 2]; };
    const sp = Math.hypot(vel.x, vel.y), ca = Math.cos(view.a), sa = Math.sin(view.a);
    const sv = { x: ca * vel.x + sa * vel.y, y: -sa * vel.x + ca * vel.y };   // (its drift on screen)
    const cells = [];
    for (let y = 4; y < PROBE - 4; y += 2) for (let x = 4; x < PROBE - 4; x += 2) {
      let s = 0, s2 = 0, land = 0;
      for (let j = -2; j <= 2; j++) for (let i = -2; i <= 2; i++) { const l = L(x + i, y + j); s += l; s2 += l * l; land += probePx[((y + j) * PROBE + x + i) * 4 + 3]; }
      // (A cell that's mostly lake scores less: its grain read as detail. Shores count fully.)
      const sd = Math.sqrt(Math.max(s2 / 25 - (s / 25) * (s / 25), 0)) * shore(land / 25 / 255);
      const dx = x / PROBE - 0.5, dy = y / PROBE - 0.5, r = Math.hypot(dx, dy);
      const along = sp > 1e-4 && r > 1e-3 ? (dx * sv.x + dy * sv.y) / (r * sp) : 0;
      cells.push({ x, y, r, along, score: sd * (1 - 1.2 * r * r) * (1 + 0.5 * along) + rand() * 4 });
    }
    cells.sort((p, q) => q.score - p.score);
    // (The probe's square, view.h each way, so only the middle of a wide screen is looked at.)
    const reach = STEER_OLD ? 0.7 : 0.7;   // (0.55 till Dan wanted where it zooms to vary more)
    const at = c => {
      const ox = (c.x / PROBE - 0.5) * view.h * reach, oy = (c.y / PROBE - 0.5) * view.h * reach;
      return { x: view.x + ca * ox - sa * oy, y: view.y + sa * ox + ca * oy };
    };
    if (STEER_OLD) { target = at(cells[0]); looking = false; return; }
    // The best few, far enough apart to be different places, and straight on.
    const picks = [{ x: PROBE / 2, y: PROBE / 2, r: 0, along: 0, straight: true }];
    for (const c of cells) {
      if (picks.length > LOOK_K) break;
      if (picks.every(p => Math.hypot(p.x - c.x, p.y - c.y) >= 6)) picks.push(c);
    }
    lookAhead(picks.map(at), view, deep => {
      let best = -1, pick = picks[0];
      picks.forEach((c, i) => {
        // (Wider since Dan: "if the zoom-in location could vary a bit more": the middle and straight
        // on were favoured more, 1.2 r² and 1.15, with 0.85-1.15 at random.)
        const score = deep[i] * (1 - 0.6 * c.r * c.r) * (1 + 0.3 * c.along) * (0.7 + 0.6 * rand());
        if (score > best) { best = score; pick = c; }
      });
      target = at(pick);
      looking = false;
    });
  }
  // Each spot drawn LOOK_PX square at each of LOOK_DEEP, all into one small target (each tile's
  // view shifted by its offset, so the port's shader needn't know), and read back at once. Its
  // score is how much of it has detail at both depths (the geometric mean), times how strong.
  // Lakes (Dan: "avoid the lakes, not all the interesting bits"): inside the set, every pixel runs
  // to its most iterations, the slowest to draw and refine (one dive rested in one at a sample a
  // pixel in 10 s), and some insides' colourings are a fine grain the contrast took for detail.
  // The ports' inside flags say where they are (uLake): a look counts lake pixels as no detail,
  // and one mostly lake (over LAKE_OK of it) is let down gently to nothing at all lake.
  const LAKE_OK = 0.5;
  const shore = land => Math.min(1, land / (1 - LAKE_OK));
  function lookAhead(spots, view, then) {
    const D = LOOK_PX, ca = Math.cos(view.a), sa = Math.sin(view.a);
    gl.bindFramebuffer(gl.FRAMEBUFFER, ahead.fb);
    const u = cur.uni;
    gl.useProgram(cur.prog);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, cur.tex);
    gl.uniform1i(u.uGrad, 0); gl.uniform1i(u.uAA, 1); gl.uniform1i(u.uLake, 1); gl.uniform1f(u.uIterCap, iterCap);
    gl.uniform2f(u.uRes, D, D); gl.uniform2f(u.uJitter, 0, 0); gl.uniform2f(u.uRot, ca, sa);
    gl.bindBuffer(gl.ARRAY_BUFFER, quad); gl.enableVertexAttribArray(0); gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
    spots.forEach((p, i) => LOOK_DEEP.forEach((k, j) => {
      const h = view.h / k, px = h / D, ox = i * D * px, oy = j * D * px;
      gl.viewport(i * D, j * D, D, D);
      gl.uniform3f(u.uView, p.x - (ca * ox - sa * oy), p.y - (sa * ox + ca * oy), h);
      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    }));
    readAsync(ahead.fb, ahead.w, ahead.h, aheadPx, () => then(scoreAhead(spots)));
  }
  function scoreAhead(spots) {
    const D = LOOK_PX;
    const W = ahead.w, L = (x, y) => { const k = (y * W + x) * 4; return 0.3 * aheadPx[k] + 0.59 * aheadPx[k + 1] + 0.11 * aheadPx[k + 2]; };
    return spots.map((p, i) => {
      let g = 1;
      LOOK_DEEP.forEach((k, j) => {
        let busy = 0, n = 0, sum = 0, land = 0;
        for (let y = 1; y < D - 1; y++) for (let x = 1; x < D - 1; x++) {
          const k = ((j * D + y) * W + i * D + x) * 4 + 3, dry = aheadPx[k] / 255;
          land += dry; n++;
          if (dry < 0.5) continue;   // (a lake pixel: its grain isn't detail)
          let s = 0, s2 = 0;
          for (let b = -1; b <= 1; b++) for (let a = -1; a <= 1; a++) { const l = L(i * D + x + a, j * D + y + b); s += l; s2 += l * l; }
          const sd = Math.sqrt(Math.max(s2 / 9 - (s / 9) * (s / 9), 0));
          if (sd > 6) busy++;
          sum += Math.min(sd, 40);
        }
        g *= (busy / n) * (0.4 + sum / n / 40) * shore(land / n) + 1e-3;
      });
      return Math.sqrt(g);
    });
  }

  // Quality: a step on LADDER, moved by how long frames take. A step that proved too slow is
  // kept off for a while (longer each time), so it doesn't see-saw.
  // Down a step under ~12 fps (Dan: a sharper moving view is worth a slower one, on a slow GPU),
  // and up one only where the next (~1.5x the pixels) would still be over it.
  const MOVE_SLOW = 1 / 12, MOVE_UP = 1 / 20;
  const maxScale = () => Math.min(window.devicePixelRatio || 1, 1.5);
  const steps = () => LADDER.filter(s => s[0] <= maxScale() + 1e-6);
  let step = PIN_STEP ?? 1, ceiling = 99, ceilingUntil = 0, ceilingFor = 15, frameTimes = [];
  // Each fractal starts on the step this machine can draw it at (Dan: sluggish at the start, fine
  // once it's going: it started at step 4 whatever the fractal and took seconds of 0.3-0.8 s frames
  // to come down; and a heavy fractal after a light one began where the light one had got to).
  // gpuRate is what this machine's done: work a second, work being samples x 32 / the fractal's
  // rows (picks.json: rows of a tile a frame, timed against Alan's 32, so 1/rows is its cost), kept
  // in this browser between visits. Unknown, it's a slow GPU's (GPU_RATE_GUESS).
  const GPU_KEY = 'ultraiterator-gpu-rate', GPU_RATE_GUESS = 4e6, START_FPS = 40;   // (40: a dive's start is usually its cheapest view, so it aims high)
  let gpuRate = GPU_RATE_GUESS;
  try { const v = parseFloat(localStorage.getItem(GPU_KEY)); if (v > 0) gpuRate = v; } catch (e) {}
  const workOf = (px, aa, pick) => px * aa * aa * 32 / Math.max(1, (pick && pick.rows) || 8);
  function startStep(pick) {
    const r = canvas.getBoundingClientRect(), all = steps();
    for (let i = all.length - 1; i > 0; i--) {
      const [sc, aa] = all[i];
      if (workOf(r.width * r.height * sc * sc * 1.1, aa, pick) * START_FPS <= gpuRate) return i;
    }
    return 0;
  }
  // The iterations pearl (for now, to try it: Dan, "in some cases it could still look good"):
  // each layer's iterations x iterCap. The colourings mostly sum over every iteration, so nearly
  // all of them change colour, some a lot (measured: 3 of 63 look the same at half).
  const ITER_STEPS = [1, 0.7, 0.5, 0.35, 0.25, 0.17, 0.12, 0.08, 0.05], ITER_MIN = 1 / 128;
  // Its gestures (Dan): a click a step fewer, Shift or a right click a step more, a double click
  // halves it, a long press puts it back to full. A click waits out the double click's time, so
  // a double's two clicks aren't two steps as well; and a touch's long press, which browsers also
  // count as a right click, is the long press only.
  const LONG_PRESS = 0.5, DOUBLE_CLICK = 0.28;
  function itersGestures(el) {
    let pressT = null, longDone = false, clickT = null, touch = false;
    const act = d => window.UILive && UILive.iters(d);
    el.addEventListener('pointerdown', e => {
      touch = e.pointerType !== 'mouse'; longDone = false;
      if (e.button !== 0) return;
      clearTimeout(pressT);
      pressT = setTimeout(() => { longDone = true; act('full'); }, LONG_PRESS * 1000);
    });
    const unpress = () => clearTimeout(pressT);
    el.addEventListener('pointerup', unpress); el.addEventListener('pointerleave', unpress); el.addEventListener('pointercancel', unpress);
    el.addEventListener('click', e => {
      if (longDone) { longDone = false; return; }
      if (e.shiftKey) { act(1); return; }
      if (clickT) { clearTimeout(clickT); clickT = null; act('half'); return; }
      clickT = setTimeout(() => { clickT = null; act(-1); }, DOUBLE_CLICK * 1000);
    });
    el.addEventListener('contextmenu', e => { e.preventDefault(); if (!touch) act(1); });
  }
  let iterCap = 1;
  // Fractals too heavy for this machine are passed over (Dan: "rather that than it being insanely
  // slow on lesser computers or phones"). Seen, not predicted: one that's at the ladder's lowest
  // step and still under FIT_FPS in its first FIT_WINDOW s (near its 2k, where picks.json's cost
  // was timed) is noted as too heavy here, kept in this browser, and it moves on; from then on that
  // one and any as heavy (by picks.json's rows) go by. (Predicting from gpuRate, measured by frame
  // times, had a desktop passing over 51 of 63.) Never one picked from the gallery, and not while
  // the iterations pearl's capping them. So a slow phone's order skips some of everyone else's.
  const FIT_FPS = 12, FIT_WINDOW = 15, HEAVY_KEY = 'ultraiterator-too-heavy-2';
  let heavyCost = Infinity, chosen = false;   // (the lightest cost seen too heavy; chosen: from the gallery)
  const costOf = pick => workOf(1, pick.aa || 1, pick);
  // (-2: picks.json's rows timed again, 2026-11-23, from this page's own shaders at their 2k on a
  // GTX 960, the median kept: the app's figures had a3e32773b725 among the cheapest, ~25x off.)
  // And it works up to the heavy ones (Dan, 2026-11-22: a phone got "a bit slow" on a heavy one,
  // and should start on cheaper ones, and try a cheap one before giving up). The costs go from 1.2
  // to 64 (picks.json's rows), the cheapest third at most CHEAP_COST. A new browser's first is one
  // of those, and the order then takes only ones up to PROVE_GROW times the heaviest that's gone
  // well here (FIT_WINDOW s without being at the ladder's lowest step), kept in this browser.
  // Too slow even at the lowest step, it moves to a cheap one, and only gives up on a cheap one.
  const CHEAP_COST = 3.5, PROVE_GROW = 4, PROVEN_KEY = 'ultraiterator-proven-2';
  let provenCost = CHEAP_COST, proved = false, cheapNext = false;
  try { const v = parseFloat(localStorage.getItem(PROVEN_KEY)); if (v > 0) provenCost = Math.max(CHEAP_COST, v); } catch (e) {}
  // The cheap ones always fit: one of them too heavy gives up instead (a phone's heavy mark had
  // come down to the cheapest, so none fit and it went round them all, too heavy, for good).
  const HEAVY_MIN = CHEAP_COST * 1.0001;
  try { const v = parseFloat(localStorage.getItem(HEAVY_KEY)); if (v > 0) heavyCost = Math.max(HEAVY_MIN, v); } catch (e) {}
  const isCheap = pick => costOf(pick) <= CHEAP_COST;
  const fits = pick => iterCap < 1 || (costOf(pick) < heavyCost && costOf(pick) <= provenCost * PROVE_GROW && (!cheapNext || isCheap(pick)));
  // And one that's settled coarser than SHARP_MIN samples a CSS pixel here (Dan's phone drew the
  // heaviest at 0.4-0.65, blocky at any depth) is noted like a too-heavy one, for next time: it
  // carries on, but from then on it and any as heavy go by, so a phone keeps to ones it draws sharp.
  const SHARP_MIN = 0.65;
  function prove(now) {
    if (proved || !cur || iterCap < 1 || now - fullAt < FIT_WINDOW) return;
    if (!chosen && !isCheap(cur.pick) && steps()[step][0] < SHARP_MIN - 1e-6) {
      proved = true;
      heavyCost = Math.max(HEAVY_MIN, Math.min(heavyCost, costOf(cur.pick)));
      try { localStorage.setItem(HEAVY_KEY, String(heavyCost)); } catch (e) {}
      console.info('live: ' + cur.pick.id + ' only ' + steps()[step][0] + ' samples a pixel here; passing over ' + order.filter(p => !fits(p)).length + ' of ' + order.length + ' from now on');
      return;
    }
    if (step === 0) return;
    proved = true;
    if (costOf(cur.pick) <= provenCost) return;
    provenCost = costOf(cur.pick);
    try { localStorage.setItem(PROVEN_KEY, String(provenCost)); } catch (e) {}
  }
  // Too slow at the lowest step, past FIT_WINDOW (deeper in, where its iterations have grown):
  // a cheap one next, if this isn't one already (and wasn't picked from the gallery).
  function swapToCheap() {
    if (!cur || chosen || isCheap(cur.pick) || !order.some(isCheap)) return false;
    heavyCost = Math.min(heavyCost, costOf(cur.pick)); provenCost = CHEAP_COST; cheapNext = true;
    try { localStorage.setItem(HEAVY_KEY, String(heavyCost)); localStorage.setItem(PROVEN_KEY, String(provenCost)); } catch (e) {}
    console.info('live: ' + cur.pick.id + ' too slow here; on to a cheap one');
    return true;
  }
  function tooHeavy(med, now) {
    if (!cur || chosen || iterCap < 1 || step !== 0 || med <= 1 / FIT_FPS || now - fullAt > FIT_WINDOW) return false;
    heavyCost = Math.max(HEAVY_MIN, Math.min(heavyCost, costOf(cur.pick)));
    try { localStorage.setItem(HEAVY_KEY, String(heavyCost)); } catch (e) {}
    console.info('live: ' + cur.pick.id + ' too heavy here (' + Math.round(1 / med) + ' fps at the lowest step); passing over ' + order.filter(p => !fits(p)).length + ' of ' + order.length);
    return true;
  }
  // The next one along from i that fits (or just the next, if none does).
  function nextFitting(i) {
    for (let k = 1; k <= order.length; k++) { const j = (i + k) % order.length; if (fits(order[j])) return j; }
    return (i + 1) % order.length;
  }
  function noteRate(med) {
    if (!sampled || !cur || iterCap < 1) return;   // (capped, it'd look faster than it is)
    const rate = workOf(sampled.w * sampled.h, steps()[step][1], cur.pick) / med;
    // (Frames held to the display's rate say only that it's at least this fast.)
    gpuRate = med < 0.022 ? Math.max(gpuRate, rate) : gpuRate * 0.7 + rate * 0.3;
    try { localStorage.setItem(GPU_KEY, String(Math.round(gpuRate))); } catch (e) {}
  }
  function adapt(dt, now) {
    if (refining || leaving || fade < 1) { frameTimes = []; return; }   // (nor fading in: its first frames carry the compile's end, Dan's phone)
    if (!fullAt) fullAt = now;   // (slow frames are fine while still; and on the way out, it's going anyway)
    frameTimes.push(dt);
    // Every 30 frames, or every second once there are a few (slow hardware shouldn't wait long).
    const span = frameTimes.reduce((a, b) => a + b, 0);
    if (frameTimes.length < 30 && !(span > 1 && frameTimes.length >= 5) && !(span > 3 && frameTimes.length >= 3)) return;
    frameTimes.sort((a, b) => a - b);
    const med = frameTimes[frameTimes.length >> 1];
    baseFrame = med;   // (refinement's frame-rate watch compares against this)
    noteRate(med);
    frameTimes = [];
    if (tooHeavy(med, now)) { if (isCheap(cur.pick)) giveUp(); else { cheapNext = true; UILive.next(); } return; }
    if (med > TOO_SLOW && step === 0) { if (swapToCheap()) UILive.next(); else giveUp(); return; }
    prove(now);
    if (med > TOO_SLOW * 2) { step = 0; ceiling = 0; ceilingUntil = now + 600; return; }   // hopeless: straight to the bottom
    if (med > 0.15 && step > 1) step--;   // very slow: a step more
    const top = steps().length - 1;
    if (now > ceilingUntil) ceiling = 99;
    if (med > MOVE_SLOW && step > 0) { ceiling = step - 1; ceilingUntil = now + ceilingFor; ceilingFor = Math.min(ceilingFor * 2, 240); step--; }
    else if (med < MOVE_UP && step < Math.min(top, ceiling)) step++;
    step = Math.min(step, top);
    if (PIN_STEP !== null) step = Math.min(PIN_STEP, top);
  }

  // The moving view's buffers: its samples at the ladder's scale, and its blend (the history) at
  // the screen's (at most UP_MAX times the samples'), each with HIST_MARGIN of the height more all
  // round: a blend's edge pixels have the least history (things come in there, reprojected from
  // nowhere) and sparkled, so they're drawn but kept just off the screen. ov(v): v as the samples
  // see it; histOver, the blend's own margin.
  const HIST_MARGIN = 0.05, UP_MAX = 4;   // (was 0.03: streaks came in at the edges, Dan)
  let histOver = 1, curOver = 1;
  const ov = v => ({ ...v, h: v.h * curOver });
  function resize() {
    const r = canvas.getBoundingClientRect();
    const margined = s => {
      const hi = Math.max(16, Math.round(r.height * s)), m = Math.ceil(hi * HIST_MARGIN) + 2;
      return { w: Math.max(16, Math.round(r.width * s)) + 2 * m, h: hi + 2 * m, over: (hi + 2 * m) / hi };
    };
    const s = steps()[step][0], lo = margined(s), up = margined(Math.max(s, Math.min(refScaleNow(), s * UP_MAX)));
    if (!sampled || sampled.w !== lo.w || sampled.h !== lo.h) {
      if (sampled) sampled.free();
      sampled = target2d(lo.w, lo.h, gl.RGBA8);
      curOver = lo.over;
    }
    // (A new ladder step alone keeps the blend as it is: it's at the screen's size either way.)
    const w = up.w, h = up.h;
    if (hist[0] && hist[0].w === w && hist[0].h === h) return;
    histOver = up.over;
    const old = hist[histAt] || null;
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
    const jx = halton(jitterI, 2) - 0.5, jy = halton(jitterI, 3) - 0.5;
    drawFractal(w, h, ov(view), steps()[step][1], jx, jy);
    const src = hist[histAt], dst = hist[1 - histAt];
    gl.bindFramebuffer(gl.FRAMEBUFFER, dst.fb);
    gl.useProgram(resolve);
    gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, sampled.tex);
    gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, src.tex);
    gl.uniform1i(RU.uCur, 0); gl.uniform1i(RU.uHist, 1);
    gl.uniform2f(RU.uRes, dst.w, dst.h);
    gl.uniform2f(RU.uCurRes, w, h);
    gl.uniform1f(RU.uCurH, view.h * curOver);
    gl.uniform2f(RU.uJitter, jx, jy);
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
    quadDraw(dst.w, dst.h);
    histAt = 1 - histAt;
    prevView = { ...view };
    frames++;
  }

  let refDuty = REF_DUTY, refFps = [], refFpsAt = 0;
  let refScale = null;   // CSS px a pixel it refines at (null: the most for this screen)
  try { const v = parseFloat(localStorage.getItem(REF_SCALE_KEY)); if (v > 0) refScale = v; } catch (e) {}
  // (A phone's at a CSS pixel at most, not its screen's own: its samples' grid, enlarged by the
  // browser, showed as much as a desktop's did.)
  const refScaleMax = () => HI_OK ? Math.min(window.devicePixelRatio || 1, 2) : Math.max(steps()[step][0], Math.min(window.devicePixelRatio || 1, 1));
  const endHeld = () => endRest && (restHolding || ended);
  // A heavy fractal's refinement at the screen's scale took seconds a pass (measured: 8.5 s for
  // its first sample, the rests ending with 0 or 1, all spent on the blurry moving view): if the
  // first pass is on course for much over REF_PASS_S, this fractal's refining is at the scale that
  // takes about that (refCap, till the next fractal; still sharper than the moving view's).
  const REF_PASS_S = 0.75;
  let refCap = 1e9;
  const refScaleNow = () => Math.max(steps()[step][0], Math.min(endHeld() ? refScaleMax() : Math.min(refScaleMax(), refScale || 1e9), refCap));
  function capRefine(now) {
    if (!refining || refN > 0 || band === 0 || now - refStartT < 1) return;
    const pass = (now - refStartT) * bands / band;   // (bands can double mid-pass; band with it)
    if (pass < REF_PASS_S * 1.5) return;
    const s = refScaleNow(), to = Math.max(steps()[step][0], s * Math.sqrt(REF_PASS_S / pass));
    if (to > s * 0.95) return;
    refCap = to;
    stopRefine(); startRefine();
  }
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
      if (refComfort > REF_UP_AFTER && now > refUpAt && s < refScaleMax() - 1e-6 && !endHeld()) {
        refWentUp = true;
        return rescale(Math.min(refScaleMax(), s / REF_SCALE_STEP));
      }
      return false;
    }
    refComfort = 0;
    if (refDuty > REF_DUTY_MIN + 1e-6) { refDuty = Math.max(REF_DUTY_MIN, refDuty * 0.7); return false; }
    if (s <= steps()[step][0] + 1e-6 || endHeld()) return false;   // as low as the moving view's already (or the end's rest, kept sharp)
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

  // (For tests: frames where a corner read past the buffer it reads, by which.)
  const edgeMiss = { show: 0, blend: 0, bake: 0 };
  // Is the rect (half sizes hw, hh, in plane units, about view v) inside buffer view bv (height bh, aspect asp)?
  function covers(v, hw, hh, bv, bh, asp) {
    const ca = Math.cos(v.a), sa = Math.sin(v.a), cb = Math.cos(bv.a), sb = Math.sin(bv.a);
    for (const [ex, ey] of [[-1, -1], [1, -1], [-1, 1], [1, 1]]) {
      const ox = v.x + ca * ex * hw - sa * ey * hh - bv.x, oy = v.y + sa * ex * hw + ca * ey * hh - bv.y;
      const qx = (cb * ox + sb * oy) / bh, qy = (-sb * ox + cb * oy) / bh;
      if (Math.abs(qx) > asp / 2 + 1e-6 || Math.abs(qy) > 0.5 + 1e-6) return false;
    }
    return true;
  }
  function bakeRefined() {
    const t = hist[histAt];
    if (!covers(view, view.h * histOver * t.w / t.h / 2, view.h * histOver / 2, refView, refView.h, acc.w / acc.h)) edgeMiss.bake++;
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
    const hs = Math.max(16, Math.round(r.height * s));
    // Out past the screen as far as the moving view's buffer goes (HIST_MARGIN, and a little
    // more), so baking it into that (bakeRefined) never reads past its edge: that smeared the
    // edge's pixels into the margin, and they streaked in as the view moved on (Dan).
    const pad = 1 + 2 * (HIST_MARGIN + 0.01);
    let w = Math.ceil(Math.max(16, Math.round(r.width * s)) * pad), h = Math.ceil(hs * pad);
    // In a rest the view keeps turning, so it refines a little more all round: enough for the turn
    // the rest of the hold will make (worked out ahead, the noise being known), and the screen just
    // reads it turned. ~14° at the most, about half as many pixels again for a wide screen. It
    // covers the furthest the turn gets on the way (it can swing back), through the REST_AFTER
    // seconds it turns on after the refinement's done (past it, the edges streaked: Dan); refAngGo,
    // the turn the refinement's done at.
    let ang = 0, go = 0;
    if (restHolding && !paused && !endRest) {
      const now = performance.now() / 1000;
      const Tgo = restWaiting ? Math.max(0, restAt + REST_TURN_FOR - now) : Math.max(0, holdUntil - now);
      const T = Tgo + (restWaiting ? REST_AFTER : 0) + 0.5;
      let a = 0;
      for (let t = 0; t < T; t += 0.1) {
        a += turnRate(turnT + t, smooth(0, 4, turnSteer + t) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h))) * REST_TURN_MUL * 0.1;
        ang = Math.max(ang, Math.abs(a));
        if (t < Tgo) go = ang;
      }
      ang = Math.min(0.5, ang * 1.15 + 0.004); go = Math.min(go * 1.15 + 0.002, ang * 0.75);
    }
    refTurns = ang > 0; refAng = ang; refAngGo = go;
    const c = Math.cos(ang), sn = Math.sin(ang);
    [w, h] = [Math.ceil(w * c + h * sn), Math.ceil(w * sn + h * c)];
    if (!acc || acc.w !== w || acc.h !== h) { if (acc) acc.free(); acc = target2d(w, h, gl.RGBA32F); }
    gl.bindFramebuffer(gl.FRAMEBUFFER, acc.fb);
    gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
    settleRead = null; settleReads = 0; rateKnown = false; refFirstAt = 0;
    refN = 0; refView = { ...view, h: view.h * h / hs }; refining = true; refStartT = performance.now() / 1000; band = 0; refRest = 0; bandMs = 0;
    // The first pass in bands already, sized from the moving view's frames scaled by the pixels:
    // as one band, a heavy fractal's first sample at a phone's whole CSS-pixel size held its GPU
    // for seconds (no timer there to learn from first), and the page went black and wouldn't
    // scroll (Dan). It's an overestimate (a frame's more than its fractal), and the bands are
    // halved from there once they're measured.
    const guess = sampled ? baseFrame * 1000 * (w * h) / (sampled.w * sampled.h) : 0;
    bands = Math.min(maxBands(), 2 ** Math.ceil(Math.log2(Math.max(1, guess / REF_BAND_MAX_MS))));
    refFps = []; refFpsAt = performance.now() / 1000;
  }
  function stopRefine() {
    refining = false;
    if (refSync) { gl.deleteSync(refSync); refSync = null; }
    if (refSyncA) { gl.deleteSync(refSyncA); refSyncA = null; }
    for (const { q } of refQueue) gl.deleteQuery(q);
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
      while (refQueue.length && gl.getQueryParameter(refQueue[0].q, gl.QUERY_RESULT_AVAILABLE)) {
        const { q, n } = refQueue.shift();
        const ms = gl.getQueryParameter(q, gl.QUERY_RESULT) / 1e6 / n;
        if (!gl.getParameter(timer.GPU_DISJOINT_EXT)) bandMs = bandMs ? bandMs * 0.7 + ms * 0.3 : ms;
        gl.deleteQuery(q); done = true;
      }
    } else if (refSync) {
      // Its own time: from a fence just before it (the frames queued ahead of it on the GPU done)
      // to the one after, each seen at the frame it's found done. Timed from its submission
      // instead, it counted those frames too (~200 ms on Dan's phone), and its bands doubled up
      // to 1024, mostly empty, each waited on, with a rest after each: minutes to a sample.
      let same = false;
      if (refSyncA && gl.clientWaitSync(refSyncA, 0, 0) !== gl.TIMEOUT_EXPIRED) { gl.deleteSync(refSyncA); refSyncA = null; refBegan = now; same = true; }
      if (gl.clientWaitSync(refSync, 0, 0) === gl.TIMEOUT_EXPIRED) return false;
      gl.deleteSync(refSync); refSync = null; done = true;
      if (refSyncA) { gl.deleteSync(refSyncA); refSyncA = null; refBegan = now; same = true; }
      const busy = same ? 0.5 * frameInt : now - refBegan;   // (both done between two frames: under one)
      bandMs = busy * 1000;
      // A band that held the GPU for frames: the rest of this pass in halves at once, not from
      // the next pass (a heavy view's whole first pass, each band seconds long, risked the GPU's
      // reset). (band is the next one's: in twice as many, it's at 2 band.)
      if (busy > 2.5 * frameInt && bands < maxBands()) { band *= 2; bands *= 2; }
      refRest = now + busy * (1 / refDuty - 1);
    }
    if (refQueue.length || refSync || refN >= REF_MAX || now < refRest) return done;
    // (A frame's bands timed together: the timer reads ~2 ms over for each query, measured against
    // whole passes read back, so timing each band alone had it fitting one or two a frame, a
    // fifth of its share; and more bands then looked like more work, so it cut them finer still.)
    let spent = 0, n = 0;
    const q = timer ? gl.createQuery() : null;
    if (q) gl.beginQuery(timer.TIME_ELAPSED_EXT, q);
    do { sendBand(budget); spent += bandMs || budget; n++; }
    while (timer && refN < REF_MAX && spent + (bandMs || budget) <= budget);
    if (q) { gl.endQuery(timer.TIME_ELAPSED_EXT); refQueue.push({ q, n }); gl.flush(); }
    // Over its share (a band bigger than a frame's): rest until the average is back to it.
    if (timer && spent > budget) refRest = now + spent / 1000 / refDuty - frameInt;
    return done;
  }
  function sendBand(budget) {
    const n = refN + 1;
    const rad = REF_SIGMA * Math.sqrt(-2 * Math.log(halton(n, 2))), th = 2 * Math.PI * halton(n, 3);
    const y0 = Math.floor(acc.h * band / bands), y1 = Math.floor(acc.h * (band + 1) / bands);
    if (!timer) refSyncA = gl.fenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0);
    gl.bindFramebuffer(gl.FRAMEBUFFER, acc.fb);
    gl.enable(gl.SCISSOR_TEST); gl.scissor(0, y0, acc.w, y1 - y0);
    gl.enable(gl.BLEND); gl.blendFunc(gl.ONE, gl.ONE);
    drawFractal(acc.w, acc.h, refView, 1, rad * Math.cos(th), rad * Math.sin(th));
    gl.disable(gl.BLEND); gl.disable(gl.SCISSOR_TEST);
    if (!timer) { refSync = gl.fenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0); gl.flush(); refSubmit = performance.now() / 1000; }
    if (++band < bands) return;
    // A pass done: one more sample a pixel. Size the bands for the next, so one fits a frame's share
    // (without the timer, a band known only to the frame: more bands if it took over two).
    band = 0; refN++;
    if (refN === 1) refFirstAt = performance.now() / 1000;
    if (!bandMs) return;
    const pass = bandMs * bands;
    const want = timer ? Math.min(maxBands(), 2 ** Math.ceil(Math.log2(Math.max(1, pass / Math.min(budget, REF_BAND_MAX_MS)))))
      : bandMs > 2.5 * frameInt * 1000 ? Math.min(maxBands(), bands * 2) : bandMs < 1.5 * frameInt * 1000 && bands > 1 ? bands / 2 : bands;
    if (want !== bands) { bandMs *= bands / want; bands = want; }
  }

  // Too slow even at its lowest: show the fractal's own render, sharp, instead.
  function giveUp() {
    cur = null;
    document.body.classList.add('no-live');
    // (the one it's on now: after a lost GPU every pick came here, and the poster stayed on the
    // first one's render whichever was picked, Dan)
    if (poster && order[at]) poster.style.backgroundImage = 'url(live/' + order[at].id + '.webp)';
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
    gl.uniform1f(SU.uSeed, REF_SEED * Math.exp(-refN / REF_SEED_GO));   // (refN kept while it fades back out)
    gl.uniform2f(SU.uRes, w, h);
    gl.uniform2f(SU.uAccRes, acc ? acc.w : 1, acc ? acc.h : 1);
    gl.uniform3f(SU.uView, view.x, view.y, view.h);
    const rv = refView || view;
    gl.uniform3f(SU.uRefView, rv.x, rv.y, rv.h);
    gl.uniform2f(SU.uRot, Math.cos(view.a), Math.sin(view.a));
    gl.uniform2f(SU.uRefRot, Math.cos(rv.a), Math.sin(rv.a));
    const hv = prevView || view;   // (the blend's view: renderTaa's last)
    { const hw = view.h * w / h / 2, hh = view.h / 2;
      if (acc && refMix > 0 && refining && !covers(view, hw, hh, rv, rv.h, acc.w / acc.h)) edgeMiss.show++;
      if (!(acc && refMix > 0 && refN > 0) && !covers(view, hw, hh, hv, hv.h * histOver, hist[histAt].w / hist[histAt].h)) edgeMiss.blend++; }
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
  const ORBIT_RATE_FULL = 12;   // the moon at full speed while the picture changes this fast (of 255 a second)
  const MOON_SHOW = 0.65;       // and dim, so the pearl's own brightening says the most
  let moonFresh = 0;
  const pauseGlyph = pausePearl && pausePearl.querySelector('.glyph');
  let shownMode = '';
  function showState() {
    if (!pausePearl) return;
    const n = refining ? refN : !canRefine && still > 0 ? Math.min(still, STILL_FRAMES) * 2 : 0;
    const prog = Math.min(1, Math.log2(1 + n) / Math.log2(1 + GLOW_FULL_AT));
    pausePearl._glow = GLOW_PLAY + (1 - GLOW_PLAY) * prog;
    // While it refines, a tiny dim moon circles the pearl, as fast as the picture is still changing
    // (restRate): brisk while it visibly sharpens, slowing to a stop as it settles, and hardly
    // moving at all for a view that was sharp already. (Dan: a steady spin read as the page having
    // to compute before it could zoom on; it's only polishing the view it's on.) Till the first
    // reading (a second or two), slowly. Without refinement, by its still frames' averaging.
    // (js/pearls.js integrates its angle.)
    const working = refining || (!canRefine && still > 0 && still < STILL_FRAMES);
    const fresh = refining ? (rateKnown ? smooth(REST_STILL * 0.5, ORBIT_RATE_FULL, restRate) : 0.2) : 1 / (1 + Math.pow(n / ORBIT_HALF, 2.5));
    moonFresh += (fresh - moonFresh) * 0.05;
    pausePearl._orbit = working ? { speed: ORBIT_SPEED * moonFresh, fresh: moonFresh, show: MOON_SHOW * (1 - smooth(0.85, 1, prog)) } : null;
    const left = holdUntil - performance.now() / 1000;
    const half = !paused && left > 0;
    pausePearl._count = half ? (restWaiting ? 1 : left / holdLen) : -1;
    pausePearl._call = half ? smooth(CALL_LEAD, 0, left) : 0;
    // A rest on its way: the ring fills in over its last REST_LEAD s of moving and its settling, so
    // it's full as the rest begins and runs down from there (sent as -1 - fill).
    if (!paused && !half && !leaving && fade >= 1 && (view.h > minH * 8 || !endRest || settleAt !== null)) {
      // (The depth's end: the zoom's time to END_REST_AT, roughly, as it eases down towards it.)
      const easeAt = h => 0.25 + 0.75 * smooth(minH, minH * 6, h);
      const toEnd = endRest ? 1e9 : Math.log2(view.h / (minH * END_REST_AT)) / (ZOOM_RATE * 0.5 * (easeAt(view.h) + easeAt(minH * END_REST_AT)));
      const tLeft = settleAt === null ? Math.min(view.h > minH * 8 ? nextRest - movedT : 1e9, toEnd) + REST_SETTLE : REST_SETTLE - (performance.now() / 1000 - settleAt);
      const fill = 1 - tLeft / (REST_LEAD + REST_SETTLE);
      if (fill > 0) pausePearl._count = -1 - Math.min(1, fill);
    }
    // (No moon before the refinement starts: out early, it looked like the dive waiting on a computation.)
    const mode = paused ? 'paused' : half ? (restHolding ? 'rest' : 'half') : 'playing';
    if (mode !== shownMode) {
      shownMode = mode;
      if (pauseGlyph) { pauseGlyph.textContent = mode === 'paused' ? '▶' : ''; pauseGlyph.classList.toggle('bars', mode === 'playing'); }   // (bars: home.css)
      const label = mode === 'paused' ? 'Play' : mode === 'half' || mode === 'rest' ? 'Keep it paused' : 'Pause';
      pausePearl.setAttribute('aria-label', label);
      pausePearl.title = mode === 'paused' ? 'Carry on the dive' : mode === 'rest' ? 'Sharpening this view (the dive carries on by itself; click to keep it paused)'
        : mode === 'half' ? 'Keep it paused (it carries on by itself soon)' : 'Pause the dive';
    }
  }

  let visible = true;
  document.addEventListener('visibilitychange', () => { prev = performance.now() / 1000; frameTimes = []; });
  new IntersectionObserver(es => { visible = es[0].isIntersecting; }).observe(canvas);

  // A very slow turn, its way and speed a low, signed noise. Eased in after a start or a touch and
  // towards the end of its depth, but not into the rests: it turns on through them.
  const turnEase = () => smooth(0, 4, turnSteer) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h));
  // In a rest it turns REST_TURN_MUL x as fast, eased in and out over a second or so (Dan: the
  // turn didn't read while it refined).
  const REST_TURN_MUL = 2;
  let turnMul = 1, turnHold = 1;
  function turn(dt) {
    turnMul += ((restHolding && !endRest ? REST_TURN_MUL : 1) - turnMul) * (1 - Math.exp(-dt));
    turnT += dt; turnSteer += dt;
    // Till the refinement's first sample the turn waits (eased): the blend waits meanwhile, and
    // turned on past it the edges streaked (Dan). (Drawing the moving view on till then instead
    // took the GPU from the first pass: 10 s to it on Dan's phone, 1 s without.)
    turnHold += ((refining && refN === 0 ? 0 : 1) - turnHold) * (1 - Math.exp(-dt * 4));
    let da = turnRate(turnT, turnEase()) * turnMul * turnHold * dt;
    // Never past what the rest's refinement covers: it eases to a stop at its edge, if it ever gets there.
    if (refining && refTurns) {
      const off = view.a - refView.a;
      if (da * off > 0) da *= smooth(0, 0.03, refAng - 0.005 - Math.abs(off));
    }
    view.a += da;
  }
  const smooth = (a, b, x) => { const t = Math.min(1, Math.max(0, (x - a) / (b - a))); return t * t * (3 - 2 * t); };
  // Black till the next one begins (begin sets cur again): the canvas cleared, its poster hidden.
  function blackOut() {
    cur = null;
    if (poster) poster.classList.add('gone');
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.viewport(0, 0, canvas.width, canvas.height);
    gl.clearColor(0, 0, 0, 1); gl.clear(gl.COLOR_BUFFER_BIT);
  }
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
    if (restHolding && !paused && now > holdUntil) { restHolding = false; if (endRest) { ended = true; leaving = true; fadeDir = -1; } else onWeGo(); }
    if (!paused && now > holdUntil && !ended) {
      // Ease in after a start, a touch or a rest, out into a rest, and out towards the end of its depth.
      steerT += dt; movedT += dt;
      if (settleAt === null && !leaving && fade >= 1) {
        if (movedT < REST_MOVE_FIRST) {}
        else if (!endRest && view.h <= minH * END_REST_AT) { settleAt = now; endRest = true; }
        else if (movedT > nextRest && view.h > minH * 8) settleAt = now;
      }
      let restEase = 1;
      if (settleAt !== null) {
        restEase = smooth(REST_SETTLE, 0, now - settleAt);
        if (now - settleAt >= REST_SETTLE) {
          restWaiting = canRefine && TAA; restAt = now; settleRead = null; settleReads = 0;
          settleAt = null; holdUntil = now + (restWaiting ? (endRest ? END_HARD : REST_MAX) : REST_HOLD); holdLen = restWaiting ? (endRest ? END_HARD : REST_MAX) : REST_HOLD; movedT = 0; nextRest = restIn();
          steerT = 0; easeFor = REST_RESUME; vel = { x: 0, y: 0 }; target = { x: view.x, y: view.y }; aim = { ...target };
          restEase = 0; restHolding = true; say('sharpening this view'); loadNext();
          for (const r of reads) r.of = null; looking = false;   // (a look still out would steer from where it was)
        }
      }
      const ease = smooth(0, easeFor, steerT) * (0.25 + 0.75 * smooth(minH, minH * 6, view.h)) * restEase;
      view.h = view.h < minH ? Math.min(minH, view.h * Math.pow(2, ZOOM_RATE * dt))   // (back out, if look() raised the floor)
        : Math.max(minH, view.h * Math.pow(2, -ZOOM_RATE * ease * dt));
      pollReads();
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
      if (view.h <= minH * 1.2 && !leaving && !endRest) { leaving = true; fadeDir = -1; }
    } else if (restHolding && !paused && !endRest) turn(dt);   // (a rest only stops the dive: the refinement's read turned)
    // Fading in only once the blend has a few frames (or the refinement is under way): the very
    // first frames are single noisy samples.
    if (fadeDir < 0 || frames >= READY_FRAMES || refining || now - beganAt > 1) fade = Math.min(1, Math.max(0, fade + fadeDir * dt / FADE));
    if (leaving && fade <= 0) { chosen = false; begin(nextFitting(at)); return; }
    const pv = prevView;
    still = pv && pv.x === view.x && pv.y === view.y && pv.h === view.h ? still + 1 : 0;   // (the turn aside: a rest turns on)
    // (and on through a fade out from a still view, the depth's end: stopped as it began fading,
    // its sharp picture went back to the moving view's softer one as it left, Dan: "teasing")
    const wantRefine = canRefine && TAA && still > STILL_REFINE && (fade >= 1 || (leaving && refining));
    if (wantRefine && !refining) startRefine();
    if (!wantRefine && refining) { if (refTurns && refN >= REF_SEED) bakeRefined(); stopRefine(); }
    if (refining) {
      readChange(now);
      if (restWaiting && restHolding && !paused) watchSettle(now);
      const got = refineTick(now, raw);
      capRefine(now);
      if (!got && !refTurns) return;   // nothing new: the canvas keeps its picture (unless it turns)
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

  // A rest's refinement settling (REST_STILL): when it has, or has turned as far as it refined, the
  // rest's end is set, and the pause pearl's ring (full till then) runs down to it.
  // How fast the refinement's picture is still changing (restRate, of 255 a second), read once a
  // second at the middle whenever it refines: the rest's settling, and the pause pearl's moon.
  function readChange(now) {
    if (now - settleReadAt >= 1 && refN > 0) {
      const x = Math.max(0, (acc.w - SETTLE_PX) >> 1), y = Math.max(0, (acc.h - SETTLE_PX) >> 1);
      const w = Math.min(SETTLE_PX, acc.w), h = Math.min(SETTLE_PX, acc.h);
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, acc.fb);
      gl.readPixels(x, y, w, h, gl.RGBA, gl.FLOAT, settlePx);
      gl.bindFramebuffer(gl.READ_FRAMEBUFFER, null);
      const n = w * h, mean = new Float32Array(n * 3);
      for (let i = 0; i < n; i++) { const c = settlePx[i * 4 + 3] || 1; for (let k = 0; k < 3; k++) mean[i * 3 + k] = settlePx[i * 4 + k] / c; }
      if (settleRead && refN > settleReadN) {
        let d = 0;
        for (let i = 0; i < n * 3; i++) d += Math.abs(mean[i] - settleRead[i]);
        const rate = d / (n * 3) * 255 / (now - settleReadAt);   // (of 255, a second)
        settleReads = rate < REST_STILL ? settleReads + 1 : 0;
        restRate = rate; rateKnown = true;
      }
      if (!settleRead || refN < settleReadN) { settleReads = 0; rateKnown = false; }   // (begun again, smaller: watchFps)
      settleRead = mean; settleReadAt = now; settleReadN = refN;
    }
  }
  function watchSettle(now) {
    let done = refN >= REF_MAX || refTurns && Math.abs(view.a - refView.a) > refAngGo;
    if (done) restWhy = refN >= REF_MAX ? 'max samples' : 'turned ' + Math.abs(view.a - refView.a).toFixed(3) + ' of ' + refAngGo.toFixed(3);
    if (!done && refN >= (endRest ? END_MIN_N : REST_SAMPLES)) { done = true; restWhy = refN + ' samples'; }
    if (!done && settleReads >= 2 && (!endRest || refN >= END_MIN_N)) { done = true; restWhy = 'settled ' + restRate.toFixed(2); }
    if (endRest ? now - restAt > END_HARD || (refFirstAt && now - refFirstAt > END_MAX) : now - restAt > REST_MAX) { done = true; restWhy = 'max time'; }
    if (!done) return;
    restWaiting = false;
    holdUntil = Math.max(now + REST_AFTER, restAt + REST_MIN); holdLen = holdUntil - now;
  }

  // After the hand: carry on from here, still.
  function touched() {
    holdUntil = performance.now() / 1000 + IDLE_RESUME; holdLen = IDLE_RESUME; settleAt = null; restHolding = false; restWaiting = false;
    movedT = 0; nextRest = restIn();
    // (At the depth's end: a touch keeps it here, and it rests there again before it moves on.)
    if (ended) { ended = false; leaving = false; fadeDir = 1; }
    endRest = false;
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
  // one finger moving sideways first moves it, and moving up or down first scrolls the page
  // (in the full-tab view, any way moves it).
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
      tmode = document.body.classList.contains('theatre') || Math.abs(dx) > Math.abs(dy) ? 'pan' : 'scroll';   // (full-tab: no page to scroll)
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
    next() { leaving = true; fadeDir = -1; holdUntil = -1e9; settleAt = null; restHolding = false; restWaiting = false; },
    // Straight to that one (the gallery's full-tab view), from its start.
    show(id) {
      wanted = id;
      // The GPU back after a loss (webglcontextrestored): everything made on it is gone, so the
      // page starts again, straight into this one (js/theatre.js opens #live-<id>).
      if (glRestored) { history.replaceState(null, '', location.pathname + location.search + '#live-' + id); location.reload(); return; }
      if (!order.length) return;   // (still loading: it starts with it)
      const i = order.findIndex(p => p.id === id);
      if (i >= 0 && !(cur && cur.pick.id === id)) {
        // Black at once, not the one before while this one compiles (Dan); it fades in from there.
        if (cur) blackOut();
        chosen = true;
        if (starting) queued = i; else begin(i);
      }
    },
    // Play: off at once (no wait after a touch), up to speed in a second or so.
    current: () => (cur ? cur.pick.id : order[at] ? order[at].id : null),   // (the fullscreen pearl's: js/theatre.js)
    capSource,   // (for tests)
    // (For tests: ms a frame drawing this one at v, w x h, the GPU waited for; tools' cost timing.)
    timeView(v, w, h, n = 3) {
      if (!cur) return null;
      const t = target2d(w, h, gl.RGBA8);
      gl.bindFramebuffer(gl.FRAMEBUFFER, t.fb);
      const px = new Uint8Array(4), done = () => gl.readPixels(0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, px);   // (finish alone may not wait)
      drawFractal(w, h, v, 1, 0, 0, false); done();
      const t0 = performance.now();
      for (let i = 0; i < n; i++) drawFractal(w, h, v, 1, 0, 0, false);
      done();
      const ms = (performance.now() - t0) / n;
      gl.bindFramebuffer(gl.FRAMEBUFFER, null); t.free();
      return ms;
    },
    // (For tests: the view put there, paused. h in picture heights, or in floors with floors: n.)
    place(v) { if (v.floors) v = { ...v, h: minH * v.floors }; Object.assign(view, v); paused = true; restHolding = false; restWaiting = false; frames = 0; still = 0; prevView = null; stopRefine(); refMix = 0; return { ...view, minH }; },
    // The iterations pearl: down a step (up, with Shift or a right click), round again past the
    // ends; 'half' halves it (to ITER_MIN at the least), 'full' puts it back. (From a halving, off
    // the steps, a step goes to the next one along.)
    iters(dir) {
      if (dir === 'full') iterCap = 1;
      else if (dir === 'half') iterCap = Math.max(ITER_MIN, iterCap / 2);
      else if (dir < 0) iterCap = ITER_STEPS.find(v => v < iterCap - 1e-9) ?? ITER_STEPS[0];   // (the list runs most to fewest)
      else iterCap = [...ITER_STEPS].reverse().find(v => v > iterCap + 1e-9) ?? ITER_STEPS[ITER_STEPS.length - 1];
      // (Begun again from here: no history or refinement from the old count.)
      frames = 0; still = 0; prevView = null; stopRefine(); refMix = 0;
      const pct = (iterCap >= 0.1 ? Math.round(iterCap * 100) : +(iterCap * 100).toFixed(1)) + '%';
      const el = document.getElementById('iters-pearl');
      if (el) { el.querySelector('.glyph').textContent = pct; el.title = el.title.replace(/^Iterations: [^ ]+/, 'Iterations: ' + pct); }
      say('iterations ' + pct);
      return iterCap;
    },
    togglePause() { paused = !paused; if (paused) loadNext(); restHolding = false; restWaiting = false; endRest = false; if (ended) { ended = false; leaving = false; fadeDir = 1; } if (!paused) { steerT = 0; easeFor = 1.2; holdUntil = -1e9; settleAt = null; movedT = 0; } return paused; },
    state: () => ({ iterCap, heavyCost, gpuRate, fitting: order.filter(fits).length, of: order.length, endRest, ended, restWhy, restRate, rest: restHolding ? (restWaiting ? 'settling' : 'ending') : '', restFor: restHolding ? +(performance.now() / 1000 - restAt).toFixed(1) : 0, fade, leaving, step, scale: steps()[step][0], still, refining, refN, refMix, bands, bandMs, frameInt, refDuty, refScale: refScaleNow(), acc: acc && acc.w + "x" + acc.h, frames, h: view.h, a: view.a, x: view.x, y: view.y, looking, minH, refAng, refAngGo, refCap, refA: refView ? refView.a : null, picRho, edgeMiss: { ...edgeMiss }, moonFresh, rateKnown }),
  };

  // The GPU lost (a draw that ran too long gets the GPU reset, Chrome showing a white canvas with a
  // sad face; Dan saw it): the fractal's own render instead, as giveUp, and the one it was drawing
  // is noted as too heavy here (tooHeavy), so it and any as heavy are passed over next time.
  { const el = document.getElementById('iters-pearl'); if (el) itersGestures(el); }
  let glRestored = false;
  canvas.addEventListener('webglcontextrestored', () => {
    glRestored = true;
    // (In the full-tab view the fractal is the page: back to it now. Otherwise at the next pick.)
    if (document.body.classList.contains('theatre') && /^#live-[0-9a-f]+$/.test(location.hash)) location.reload();
  });
  canvas.addEventListener('webglcontextlost', e => {
    e.preventDefault();
    const pick = cur ? cur.pick : order[at];
    console.warn('live: the GPU context was lost' + (pick ? ' drawing ' + pick.id : ''));
    if (pick) {
      heavyCost = Math.min(heavyCost, costOf(pick));
      try { localStorage.setItem(HEAVY_KEY, String(heavyCost)); } catch (err) {}
      if (poster) poster.style.backgroundImage = 'url(live/' + pick.id + '.webp)';
    }
    giveUp();
  });

  (async () => {
    let picks;
    [common, picks] = await Promise.all([
      fetch('live/common.glsl').then(r => r.text()),
      fetch('live/picks.json').then(r => r.json()),
    ]);
    order = picks.slice().sort((a, b) => a.id < b.id ? -1 : 1);   // (the same start everywhere, whatever picks.json's order)
    for (let i = order.length - 1; i > 0; i--) { const j = Math.floor(rand() * (i + 1)); [order[i], order[j]] = [order[j], order[i]]; }
    const slot = Math.floor((Date.now() % 864e5) / 1000 / SLOT) % order.length;
    order = order.slice(slot).concat(order.slice(0, slot));
    // ...starting on the first from there with a small shader: the page's first compile stalls
    // its GPU (0.2-4 s, by the shader's size), as the page itself is loading. (Picked from the
    // shared order, so everyone opening it at once still starts on the same one.)
    // (And a cheap one to draw, CHEAP_COST, unless this browser's shown it can do more.)
    let light = order.findIndex(p => (p.glsl || 0) < FIRST_GLSL_MAX && costOf(p) <= provenCost);
    if (light < 0) light = order.findIndex(p => (p.glsl || 0) < FIRST_GLSL_MAX);
    if (light > 0) order = order.slice(light).concat(order.slice(0, light));
    // ?pick=<id or the start of its name>: start with that one.
    const want = (wanted || new URLSearchParams(location.search).get('pick') || '').toLowerCase();
    const first = want ? order.findIndex(p => p.id.startsWith(want) || p.name.toLowerCase().startsWith(want)) : -1;
    if (first > 0) order.unshift(...order.splice(first, 1));
    showName(order[0]);
    await begin(0);
    requestAnimationFrame(frame);
  })();
})();
