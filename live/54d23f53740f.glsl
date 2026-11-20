const vec2 C0 = vec2(0.441244917535, -0.76488209754), R0 = vec2(0.12176443108433382, -0.5678255950684927);
#define MAXITER 50
#define FORCEOUT false
#define GRADV 0.1
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 50;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 50; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
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

const vec2 C1 = vec2(0.441244917535, -0.76488209754), R1 = vec2(0.12176443108433382, -0.5678255950684927);
#define MAXITER 60
#define FORCEOUT false
#define GRADV 0.3
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 60;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 60; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
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

const vec2 C2 = vec2(0.441244917535, -0.76488209754), R2 = vec2(0.12176443108433382, -0.5678255950684927);
#define MAXITER 60
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; bool i_first = true; int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 60;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 60; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 = i_sum; if (!i_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); i_sum += t; } else i_first = false; i_it++; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { { float s = i_sum / float(numiter), s2 = i_sum2 / float(numiter - 1); float f = 4.525182567587084 - 1.4426950408889634 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 112.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.441244917535, -0.76488209754), R3 = vec2(0.12176443108433382, -0.5678255950684927);
#define MAXITER 60
#define FORCEOUT false
#define GRADV 0.7
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 60;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 60; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
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

const vec2 C4 = vec2(0.441244917535, -0.76488209754), R4 = vec2(0.12176443108433382, -0.5678255950684927);
#define MAXITER 30
#define FORCEOUT false
#define GRADV 0.9
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 30;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 30; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
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
    vec3 t1 = colourAt4(C4 + cmul(o, R4)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt3(C3 + cmul(o, R3)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = t * b; b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt2(C2 + cmul(o, R2)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = ucol(mergeHsl(uenc(t), uenc(b), 2)); b6 = b4 + (m - b4) * (0.92 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt1(C1 + cmul(o, R1)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt0(C0 + cmul(o, R0)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b10 = b8 + (m - b8) * (1.0 * clamp(at9, 0.0, 1.0)); }
    return clamp(b10, 0.0, 1.0);
}
