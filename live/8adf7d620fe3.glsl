const vec2 C4 = vec2(0.0048753742354, -2.9267289978), R4 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.45
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = min(q.x, q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 4.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(0.0048753742354, -2.9267289978), R5 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.55
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = min(q.x, q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 4.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(0.0048753742354, -2.9267289978), R6 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.65
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C7 = vec2(0.0048753742354, -2.9267289978), R7 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt7(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 += (33.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C8 = vec2(0.0048753742354, -2.9267289978), R8 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 46
#define FORCEOUT false
#define GRADV 0.85
vec3 colourAt8(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 46;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 46; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 += (22.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = 0.0; float x = idx * 0.05; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C9 = vec2(0.0048753742354, -2.9267289978), R9 = vec2(-0.021476016746238037, -0.006787478260050694);
#define MAXITER 99
#define FORCEOUT false
#define GRADV 0.95
vec3 colourAt9(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 99;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 99; it++) {
        f_zold = z; z = z - cmul(vec2(3.05039, 0.01163), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.04; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt9(C9 + cmul(o, R9)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt8(C8 + cmul(o, R8)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt7(C7 + cmul(o, R7)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt6(C6 + cmul(o, R6)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt5(C5 + cmul(o, R5)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b10 = b8 + (m - b8) * (1.0 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt4(C4 + cmul(o, R4)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = CL(t + b); b12 = b10 + (m - b10) * (1.0 * clamp(at11, 0.0, 1.0)); }
    return clamp(b12, 0.0, 1.0);
}
