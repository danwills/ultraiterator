const vec2 C0 = vec2(0.4499053957375, 0.778398513845), R0 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.08333333333333333
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.4499053957375, 0.778398513845), R1 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 20
#define FORCEOUT false
#define GRADV 0.25
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 20;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 20; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.4499053957375, 0.778398513845), R2 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 100
#define FORCEOUT false
#define GRADV 0.4166666666666667
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 100;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 100; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.4499053957375, 0.778398513845), R3 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 70
#define FORCEOUT false
#define GRADV 0.5833333333333334
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 70;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 70; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.4499053957375, 0.778398513845), R4 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 50
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 50;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 50; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(0.4499053957375, 0.778398513845), R5 = vec2(5.684355165265884e-17, -0.9283256477252958);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.9166666666666666
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.0, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-24))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 6.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt5(C5 + cmul(o, R5)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt4(C4 + cmul(o, R4)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt3(C3 + cmul(o, R3)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = abs(t - b); b6 = b4 + (m - b4) * (0.48 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt2(C2 + cmul(o, R2)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt1(C1 + cmul(o, R1)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b10 = b8 + (m - b8) * (1.0 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt0(C0 + cmul(o, R0)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b12 = b10 + (m - b10) * (1.0 * clamp(at11, 0.0, 1.0)); }
    return clamp(b12, 0.0, 1.0);
}
