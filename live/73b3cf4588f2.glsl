const vec2 C0 = vec2(-0.09543523104615, 0.18967056435055), R0 = vec2(-0.0007395559362050381, 0.0012584633271723149);
#define MAXITER 170
#define FORCEOUT false
#define GRADV 0.125
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 170;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 170; it++) {
        { int d = f_p / 10; f_p = (f_p - d * 10) * 10 + d; if (false) d = 3 - d; if (d == 1) { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + vec2(0.2184895833, -0.3580729167); f_count = convgoing(z, f_zold, 1e-26) ? 0 : f_count + 1; f_zold = z; } else { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + pixel; f_count = convgoing(z, f_zold2, 1e-26) ? 0 : f_count + 1; f_zold2 = z; } }
        if (!(f_count < 1)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(-0.09543523104615, 0.18967056435055), R1 = vec2(-0.0007395559362050381, 0.0012584633271723149);
#define MAXITER 250
#define FORCEOUT false
#define GRADV 0.375
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 250;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 250; it++) {
        { int d = f_p / 10; f_p = (f_p - d * 10) * 10 + d; if (false) d = 3 - d; if (d == 1) { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + vec2(0.2184895833, -0.3580729167); f_count = convgoing(z, f_zold, 1e-26) ? 0 : f_count + 1; f_zold = z; } else { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + pixel; f_count = convgoing(z, f_zold2, 1e-26) ? 0 : f_count + 1; f_zold2 = z; } }
        if (!(f_count < 1)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-0.09543523104615, 0.18967056435055), R2 = vec2(-0.0007395559362050381, 0.0012584633271723149);
#define MAXITER 80
#define FORCEOUT false
#define GRADV 0.625
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 80;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 80; it++) {
        { int d = f_p / 10; f_p = (f_p - d * 10) * 10 + d; if (false) d = 3 - d; if (d == 1) { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + vec2(0.2184895833, -0.3580729167); f_count = convgoing(z, f_zold, 1e-26) ? 0 : f_count + 1; f_zold = z; } else { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + pixel; f_count = convgoing(z, f_zold2, 1e-26) ? 0 : f_count + 1; f_zold2 = z; } }
        if (!(f_count < 1)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(-0.09543523104615, 0.18967056435055), R3 = vec2(-0.0007395559362050381, 0.0012584633271723149);
#define MAXITER 60
#define FORCEOUT false
#define GRADV 0.875
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 60;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 60; it++) {
        { int d = f_p / 10; f_p = (f_p - d * 10) * 10 + d; if (false) d = 3 - d; if (d == 1) { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + vec2(0.2184895833, -0.3580729167); f_count = convgoing(z, f_zold, 1e-26) ? 0 : f_count + 1; f_zold = z; } else { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + pixel; f_count = convgoing(z, f_zold2, 1e-26) ? 0 : f_count + 1; f_zold2 = z; } }
        if (!(f_count < 1)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt3(C3 + cmul(o, R3)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt2(C2 + cmul(o, R2)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = t * b; b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt1(C1 + cmul(o, R1)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt0(C0 + cmul(o, R0)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b8 = b6 + (m - b6) * (0.41 * clamp(at7, 0.0, 1.0)); }
    return clamp(b8, 0.0, 1.0);
}
