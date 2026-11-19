// Colour parameters (a start colour, a solid colour) go through ucol: as they are (sRGB values,
// as UF does its colour maths), or decoded for UltraIterator's linear-light mode (uLinear, which
// also binds a decoding gradient and encodes the result once at the end). Unset here: 0, UF's way.
uniform bool uLinear;
vec3 ucol(vec3 c) { return uLinear ? mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c)) : c; }
vec4 ucol(vec4 c) { return vec4(ucol(c.rgb), c.a); }
// And back, for the merge modes that only mean something on encoded values (merge_glsl).
vec3 uenc(vec3 c) { c = clamp(c, 0.0, 1.0); return uLinear ? mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c)) : c; }
vec2 cmul(vec2 a, vec2 b) { return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x); }
// Scaled by b's larger part first: |b|^2 under ~1e-38 flushes to 0 in fp32 (0/0, NaN), and over
// ~1e19 overflows, where UF's doubles have room (njs2's z^-7 for |z| ~ 1e-3 went NaN).
vec2 cdiv(vec2 a, vec2 b) {
    float m = max(abs(b.x), abs(b.y));
    if (m > 0.0 && !isinf(m)) { a /= m; b /= m; }
    return vec2(a.x * b.x + a.y * b.y, a.y * b.x - a.x * b.y) / dot(b, b);
}
vec2 cexp(vec2 a) { return exp(a.x) * vec2(cos(a.y), sin(a.y)); }
vec2 clog(vec2 a) { return vec2(log(length(a)), atan(a.y, a.x)); }
// Whole powers by multiplying: the GPU's exp/log are a few ulps out, and near a root z^n - 1
// cancels down to that error (NovaMandel's layers went to noise; numpy's multiplying matched UF).
vec2 cpowi(vec2 a, int n) {
    // 0 to a negative power is 0, as UF has it (as cpow's other branch already did): Mandelbrot at
    // power -2 from z = 0 had gone NaN at once. 23 better, none worse, misses 19 -> 6 of the 512
    // entries with one (batch, 2026-11-11).
    if (n < 0 && dot(a, a) == 0.0) return vec2(0.0);
    // A negative power as the reciprocal's power: 1/(z^k) overflowed fp32 at |z| > (3e38)^(1/k)
    // (z^-7 past |z| ~ 3e5), 1/inf going NaN, where (1/z)^k just heads for 0 (njs2's Nova).
    vec2 r = vec2(1.0, 0.0), b = n < 0 ? cdiv(vec2(1.0, 0.0), a) : a; int k = abs(n);
    while (k > 0) { if ((k & 1) == 1) r = cmul(r, b); b = cmul(b, b); k >>= 1; }
    return r;
}
vec2 cpow(vec2 a, vec2 p) {
    if (p.y == 0.0 && p.x == floor(p.x) && abs(p.x) <= 64.0) return cpowi(a, int(p.x));
    return dot(a, a) == 0.0 ? vec2(0.0) : cexp(cmul(p, clog(a)));
}
// |z| without squaring past fp32's range (bailouts of 1e20 square to 1e40; UF's doubles don't mind).
float cabs(vec2 a) { float m = max(abs(a.x), abs(a.y)); return m == 0.0 ? 0.0 : m * length(a / m); }
float logmag2(vec2 a) { return 2.0 * log(cabs(a)); }   // log of UF's |z|
// a^p with its size capped at e^84 (~3e36), its angle kept: where UF's doubles take a Nova orbit out
// to ~1e37 (z^(1-p) of a tiny z) and halve it back, fp32 went inf, then NaN (njs2: z^-7, |z| < 4e-6).
vec2 cpowcap(vec2 a, vec2 p) {
    if (cabs(a) > 1e-3) return cpow(a, p);
    if (dot(a, a) == 0.0 && a == vec2(0.0)) return p.x < 0.0 ? vec2(1e36, 0.0) : vec2(0.0);
    vec2 e = cmul(p, clog(a));
    return exp(min(e.x, 84.0)) * vec2(cos(e.y), sin(e.y));
}
// A product kept as its log, going to 0 or inf (and staying there) where UF's doubles would.
const float PROD_ZERO = -1e30, PROD_INF = 1e30;
float prodmul(float lp, float v) {
    if (lp <= PROD_ZERO || lp >= PROD_INF) return lp;
    if (v == 0.0) return PROD_ZERO;
    lp += log(abs(v));
    return lp < -745.13 ? PROD_ZERO : lp > 709.78 ? PROD_INF : lp;
}
float prodlog(float lp) { return lp <= PROD_ZERO ? -1.0 / 0.0 : lp >= PROD_INF ? 1.0 / 0.0 : lp; }
float mag2(vec2 a) { return dot(a, a); }      // UF's |z|
vec3 clamp01(vec3 v) { return clamp(v, 0.0, 1.0); }
// |z| < b for a divergent bailout, false for inf and NaN: the plain comparison, negated in the loop,
// was compiled as >= and kept a NaN orbit going (Ducky's, sin of a huge z).
bool below(float m, float b) { return !(isinf(m) || isnan(m)) && m < b; }
bool beloweq(float m, float b) { return !(isinf(m) || isnan(m)) && m <= b; }
// Convergent bailouts below fp32's resolution: stop once z only moves by rounding.
const float CONV_EPS = 1e-12;
const float PI = 3.14159265358979;
// Still going by a convergent bailout (UF's |z - zold| > b). A distance that overflows fp32 is
// still going: compared as inf > inf, it had counted as converged.
float gAlpha;   // the layer's alpha here: 1 but for direct colourings
bool convgoing(vec2 z, vec2 zold, float b) {
    float d = mag2(z - zold);
    return isinf(d) || isnan(d) || d > max(b, CONV_EPS * mag2(z));
}
#define CL(v) clamp(v, 0.0, 1.0)
vec3 rgb2hsl(vec3 c) {
    float mx = max(c.r, max(c.g, c.b)), mn = min(c.r, min(c.g, c.b)), l = (mx + mn) / 2.0, d = mx - mn;
    if (d == 0.0) return vec3(0.0, 0.0, l);
    float s = d / max(1e-9, 1.0 - abs(2.0 * l - 1.0)), h;
    if (mx == c.r) h = mod((c.g - c.b) / d, 6.0); else if (mx == c.g) h = (c.b - c.r) / d + 2.0; else h = (c.r - c.g) / d + 4.0;
    return vec3(h / 6.0, s, l);
}
vec3 hsl2rgb(vec3 x) {
    vec3 k = mod(vec3(0.0, 8.0, 4.0) + x.x * 12.0, 12.0);
    float a = x.y * min(x.z, 1.0 - x.z);
    return x.z - a * clamp(min(k - 3.0, 9.0 - k), -1.0, 1.0);
}
vec3 mergeHsl(vec3 t, vec3 b, int mode) {
    vec3 ht = rgb2hsl(t), hb = rgb2hsl(b);
    if (mode == 0) return hsl2rgb(vec3(ht.x, hb.y, hb.z));      // hue
    if (mode == 1) return hsl2rgb(vec3(hb.x, ht.y, hb.z));      // saturation
    if (mode == 2) return hsl2rgb(vec3(ht.x, ht.y, hb.z));      // color
    if (mode == 3) return hsl2rgb(vec3(hb.x, hb.y, ht.z));      // luminance
    return hsl2rgb(vec3(mod(ht.x + hb.x, 1.0), clamp(ht.y + hb.y, 0.0, 1.0), clamp(ht.z + hb.z - 0.5, 0.0, 1.0)));   // hsladd
}
