const vec2 C0 = vec2(-0.04508600891285, 1.02659810004), R0 = vec2(0.035544964735840484, 0.0);
#define MAXITER 133
#define FORCEOUT false
#define GRADV 0.08333333333333333
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 133;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 133; it++) {
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.5; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.5; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(-0.04508600891285, 1.02659810004), R1 = vec2(0.035544964735840484, 0.0);
#define MAXITER 115
#define FORCEOUT false
#define GRADV 0.25
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 115;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 115; it++) {
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-0.04508600891285, 1.02659810004), R2 = vec2(0.035544964735840484, 0.0);
#define MAXITER 130
#define FORCEOUT false
#define GRADV 0.4166666666666667
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; bool i_first = true; int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; bool o_first = true; int o_it = 0;
    bool inside = true;
    int numiter = 130;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 130; it++) {
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 = i_sum; if (!i_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); i_sum += t; } else i_first = false; i_it++; o_sum2 = o_sum; if (!o_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); o_sum += t; } else o_first = false; o_it++;
    }
    float idx;
    if (inside && !FORCEOUT) { { float s = i_sum / float(numiter), s2 = i_sum2 / float(numiter - 1); float f = 2.262591283793542 - 0.7213475204444817 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float s = o_sum / float(numiter), s2 = o_sum2 / float(numiter - 1); float f = 2.262591283793542 - 0.7213475204444817 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(-0.04508600891285, 1.02659810004), R3 = vec2(0.035544964735840484, 0.0);
#define MAXITER 200
#define FORCEOUT false
#define GRADV 0.5833333333333334
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 200;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 200; it++) {
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.1; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(-0.04508600891285, 1.02659810004), R4 = vec2(0.035544964735840484, 0.0);
#define MAXITER 100
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 100;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 100; it++) {
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 2.0; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 2.0; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(-0.04508600891285, 1.02659810004), R5 = vec2(0.035544964735840484, 0.0);
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
        f_y = f_zold; f_zold = z; z = z - cdiv(cmul(cmul(vec2(1.0, 0.0), z) + cmul(vec2(-3.0, 0.0), cpow(z, vec2(-1.0, 0.0))) - cpow(z, vec2(-3.0, 0.0)), vec2(3.8, 0.0)), cmul(vec2(1.0, 0.0), vec2(4.0, 0.0)) + cmul(cmul(vec2(-3.0, 0.0), vec2(2.0, 0.0)), cpow(z, vec2(-2.0, 0.0)))) + pixel + cmul(vec2(-0.5, 0.0), f_y);
        if (!(convgoing(z, f_zold, 1e-20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.05; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(b - t); b4 = b2 + (m - b2) * (0.46 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt3(C3 + cmul(o, R3)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (0.25 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt2(C2 + cmul(o, R2)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b8 = b6 + (m - b6) * (0.48 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt1(C1 + cmul(o, R1)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = CL(b - t); b10 = b8 + (m - b8) * (0.14 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt0(C0 + cmul(o, R0)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b12 = b10 + (m - b10) * (0.34 * clamp(at11, 0.0, 1.0)); }
    return clamp(b12, 0.0, 1.0);
}
