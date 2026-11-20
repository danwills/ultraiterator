const vec2 C0 = vec2(0.2204921376, -3.17549490965), R0 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 79
#define FORCEOUT false
#define GRADV 0.0625
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 79;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 79; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 1 == 0) {i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 3.01 + 0.0) + 0.0) * 1.0);i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 3.01 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.05; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.2204921376, -3.17549490965), R1 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 79
#define FORCEOUT false
#define GRADV 0.1875
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 79;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 79; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 11) % 19 == 0) {i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.2204921376, -3.17549490965), R2 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 95
#define FORCEOUT false
#define GRADV 0.3125
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 95;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 95; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
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

const vec2 C3 = vec2(0.2204921376, -3.17549490965), R3 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 95
#define FORCEOUT false
#define GRADV 0.4375
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 95;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 95; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 7 == 0) {i_sum += (22.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);i_sum2 += (22.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.333; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.2204921376, -3.17549490965), R4 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 55
#define FORCEOUT false
#define GRADV 0.5625
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 55;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 55; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 7 == 0) {i_sum += (22.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);i_sum2 += (22.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.333; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(0.2204921376, -3.17549490965), R5 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 99
#define FORCEOUT false
#define GRADV 0.6875
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 99;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 99; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 1 == 0) {i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 5.0 + 2.0) + 0.0) * 1.0);i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 5.0 + 2.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.02; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(0.2204921376, -3.17549490965), R6 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 79
#define FORCEOUT false
#define GRADV 0.8125
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 79;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 79; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 3 == 0) {i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.4 + 0.0) + 0.0) * 1.0);i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.4 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C7 = vec2(0.2204921376, -3.17549490965), R7 = vec2(-0.03762257745281788, -0.0907603787377312);
#define MAXITER 99
#define FORCEOUT false
#define GRADV 0.9375
vec3 colourAt7(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 99;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 99; it++) {
        f_zold = z; z = z - cmul(vec2(3.309111, 0.22093), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 6) % 8 == 0) {i_sum += (66.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.4 + 0.0) + 0.0) * 1.0);i_sum2 += (66.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.4 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt7(C7 + cmul(o, R7)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt6(C6 + cmul(o, R6)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt5(C5 + cmul(o, R5)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = t * b; b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt4(C4 + cmul(o, R4)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b8 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt3(C3 + cmul(o, R3)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mergeHsl(uenc(t), uenc(b), 4)); b10 = b8 + (m - b8) * (0.56 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt2(C2 + cmul(o, R2)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = CL(t + b); b12 = b10 + (m - b10) * (1.0 * clamp(at11, 0.0, 1.0)); }
    vec3 b13;
    { vec3 t = clamp(b12, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b13 = b6 + (m - b6) * (1.0); }
    vec3 t14 = colourAt1(C1 + cmul(o, R1)); float at14 = gAlpha;
    vec3 b15;
    { vec3 t = clamp(t14, 0.0, 1.0), b = clamp(b13, 0.0, 1.0); vec3 m = t * b; b15 = b13 + (m - b13) * (1.0 * clamp(at14, 0.0, 1.0)); }
    vec3 t16 = colourAt0(C0 + cmul(o, R0)); float at16 = gAlpha;
    vec3 b17;
    { vec3 t = clamp(t16, 0.0, 1.0), b = clamp(b15, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b17 = b15 + (m - b15) * (1.0 * clamp(at16, 0.0, 1.0)); }
    return clamp(b17, 0.0, 1.0);
}
