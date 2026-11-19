const vec2 C0 = vec2(0.0, 0.0), R0 = vec2(44078.076582868125, -17775.86505739424);
#define MAXITER 33
#define FORCEOUT false
#define GRADV 0.1
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zn = pixel, f_dz = vec2(0.0); const vec2 f_r1 = vec2(3.0, 0.0), f_r2 = vec2(1.0, 0.0); int f_n = 0;
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 33;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 33; it++) {
        { f_n = 1 - f_n; vec2 fp = cpow(f_zn, vec2(4.0, 0.0)), ff = cmul(f_zn, fp) - vec2(-3.0, 7.0); vec2 fpp = cmul(cpow(f_zn, vec2(3.0, 0.0)), vec2(20.0, 0.0)); fp = cmul(vec2(5.0, 0.0), fp); f_dz = -cmul(f_r1, cpow(cdiv(ff, fp), f_r2)); f_zn += f_dz; z = f_zn; }
        if (!(mag2(f_dz) > 1e-06)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 6 == 0) {i_sum += (444.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 3.0 + 0.0) + 0.5) * 0.5);i_sum2 += (444.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 3.0 + 0.0) + 0.5) * 0.5);} i_it++; i_zold = z; o_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.01; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.0, 0.0), R1 = vec2(44078.076582868125, -17775.86505739424);
#define MAXITER 33
#define FORCEOUT false
#define GRADV 0.3
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zn = pixel, f_dz = vec2(0.0); const vec2 f_r1 = vec2(3.0, 0.0), f_r2 = vec2(1.0, 0.0); int f_n = 0;
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 33;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 33; it++) {
        { f_n = 1 - f_n; vec2 fp = cpow(f_zn, vec2(4.0, 0.0)), ff = cmul(f_zn, fp) - vec2(-3.0, 7.0); vec2 fpp = cmul(cpow(f_zn, vec2(3.0, 0.0)), vec2(20.0, 0.0)); fp = cmul(vec2(5.0, 0.0), fp); f_dz = -cmul(f_r1, cpow(cdiv(ff, fp), f_r2)); f_zn += f_dz; z = f_zn; }
        if (!(mag2(f_dz) > 1e-06)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = 0.0; float x = idx * 0.01; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.0, 0.0), R2 = vec2(44078.076582868125, -17775.86505739424);
#define MAXITER 63
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zn = pixel, f_dz = vec2(0.0); const vec2 f_r1 = vec2(3.0, 0.0), f_r2 = vec2(1.0, 0.0); int f_n = 0;
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 63;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 63; it++) {
        { f_n = 1 - f_n; vec2 fp = cpow(f_zn, vec2(4.0, 0.0)), ff = cmul(f_zn, fp) - vec2(-3.0, 7.0); vec2 fpp = cmul(cpow(f_zn, vec2(3.0, 0.0)), vec2(20.0, 0.0)); fp = cmul(vec2(5.0, 0.0), fp); f_dz = -cmul(f_r1, cpow(cdiv(ff, fp), f_r2)); f_zn += f_dz; z = f_zn; }
        if (!(mag2(f_dz) > 1e-06)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 7) % 3 == 0) {i_sum += (444.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);i_sum2 += (444.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 0.0 + 0.0) + 0.0) * 1.0);} i_it++; i_zold = z; o_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.01; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.0, 0.0), R3 = vec2(44078.076582868125, -17775.86505739424);
#define MAXITER 33
#define FORCEOUT false
#define GRADV 0.7
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zn = pixel, f_dz = vec2(0.0); const vec2 f_r1 = vec2(3.0, 0.0), f_r2 = vec2(1.0, 0.0); int f_n = 0;
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 33;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 33; it++) {
        { f_n = 1 - f_n; vec2 fp = cpow(f_zn, vec2(4.0, 0.0)), ff = cmul(f_zn, fp) - vec2(-3.0, 7.0); vec2 fpp = cmul(cpow(f_zn, vec2(3.0, 0.0)), vec2(20.0, 0.0)); fp = cmul(vec2(5.0, 0.0), fp); f_dz = -cmul(f_r1, cpow(cdiv(ff, fp), f_r2)); f_zn += f_dz; z = f_zn; }
        if (!(mag2(f_dz) > 1e-06)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        if ((i_it + 0) % 6 == 0) {i_sum += (444.0 / float(MAXITER)) * exp(-cabs(z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 8.0 + 0.5) + 0.5) * 0.5);i_sum2 += (444.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z)) * ((cos(float(i_it) / float(MAXITER) * 6.2831853 * 8.0 + 0.5) + 0.5) * 0.5);} i_it++; i_zold = z; o_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 0.01; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.0, 0.0), R4 = vec2(44078.076582868125, -17775.86505739424);
#define MAXITER 33
#define FORCEOUT false
#define GRADV 0.9
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zn = pixel, f_dz = vec2(0.0); const vec2 f_r1 = vec2(3.0, 0.0), f_r2 = vec2(1.0, 0.0); int f_n = 0;
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 33;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 33; it++) {
        { f_n = 1 - f_n; vec2 fp = cpow(f_zn, vec2(4.0, 0.0)), ff = cmul(f_zn, fp) - vec2(-3.0, 7.0); vec2 fpp = cmul(cpow(f_zn, vec2(3.0, 0.0)), vec2(20.0, 0.0)); fp = cmul(vec2(5.0, 0.0), fp); f_dz = -cmul(f_r1, cpow(cdiv(ff, fp), f_r2)); f_zn += f_dz; z = f_zn; }
        if (!(mag2(f_dz) > 1e-06)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum2 += (1000.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = 0.0; float x = idx * 0.01; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt4(C4 + cmul(o, R4)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt3(C3 + cmul(o, R3)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = t * b; b4 = b2 + (m - b2) * (0.66 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt2(C2 + cmul(o, R2)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt1(C1 + cmul(o, R1)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt0(C0 + cmul(o, R0)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b10 = b8 + (m - b8) * (1.0 * clamp(at9, 0.0, 1.0)); }
    return clamp(b10, 0.0, 1.0);
}
