const vec2 C0 = vec2(-9.8515146325, 11.499505134), R0 = vec2(6.134553361036669, 0.0);
#define MAXITER 13
#define FORCEOUT false
#define GRADV 0.08333333333333333
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 13;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 13; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(-9.8515146325, 11.499505134), R1 = vec2(6.134553361036669, 0.0);
#define MAXITER 19
#define FORCEOUT false
#define GRADV 0.25
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 19;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 19; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-9.8515146325, 11.499505134), R2 = vec2(6.134553361036669, 0.0);
#define MAXITER 13
#define FORCEOUT false
#define GRADV 0.4166666666666667
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_closest = 1e38, i_closest1 = 1e38, i_d2 = 0.0, i_fiter = 0.0; vec2 i_point = vec2(0.0), i_point1 = vec2(0.0), i_point2 = vec2(0.0), i_point3 = vec2(0.0), i_tc = vec2(-0.011628, -1.279074); int i_i = 0, i_i1 = 0, i_iter = 0; bool i_done = false, i_trapping = false; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 13;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 13; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_iter++;{ vec2 r = vec2(cos((0.36666666666666664 + 0.0 * float(i_iter - 1)) * PI * 0.5), sin((0.36666666666666664 + 0.0 * float(i_iter - 1)) * PI * 0.5)), s = vec2(cos((0.0 + 0.0 * float(i_iter - 1)) * PI * 0.5), sin((0.0 + 0.0 * float(i_iter - 1)) * PI * 0.5)); vec2 z2 = cmul(z - i_tc, r); z2 = vec2(cmul(z2, s).x, z2.y); float d, d2 = i_d2; d = abs(abs(z2.y + sin(z2.x * 1.0) * 4.0 * 0.25) - 1.0); d = d * 1.0; d = d; d = d * 1.0; i_d2 = d2; if (true) { if (d < i_closest) { i_i = i_iter; i_point = z; i_point2 = z2; i_closest = d; } } } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) {  idx = i_closest; float x = idx * 2.0; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(-9.8515146325, 11.499505134), R3 = vec2(6.134553361036669, 0.0);
#define MAXITER 149
#define FORCEOUT false
#define GRADV 0.5833333333333334
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_sum = 0.0, i_sum2 = 0.0; bool i_first = true; int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 149;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 149; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 = i_sum; if (!i_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); i_sum += t; } else i_first = false; i_it++; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { { float s = i_sum / float(numiter), s2 = i_sum2 / float(numiter - 1); float f = 4.525182567587084 - 1.4426950408889634 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 14.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 1.0; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(-9.8515146325, 11.499505134), R4 = vec2(6.134553361036669, 0.0);
#define MAXITER 13
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_closest = 1e38, i_closest1 = 1e38, i_d2 = 0.0, i_fiter = 0.0; vec2 i_point = vec2(0.0), i_point1 = vec2(0.0), i_point2 = vec2(0.0), i_point3 = vec2(0.0), i_tc = vec2(0.72093, -0.854654); int i_i = 0, i_i1 = 0, i_iter = 0; bool i_done = false, i_trapping = false; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 13;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 13; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_iter++;{ vec2 r = vec2(cos((0.36666666666666664 + 0.0 * float(i_iter - 1)) * PI * 0.5), sin((0.36666666666666664 + 0.0 * float(i_iter - 1)) * PI * 0.5)), s = vec2(cos((0.0 + 0.0 * float(i_iter - 1)) * PI * 0.5), sin((0.0 + 0.0 * float(i_iter - 1)) * PI * 0.5)); vec2 z2 = cmul(z - i_tc, r); z2 = vec2(cmul(z2, s).x, z2.y); float d, d2 = i_d2; d = abs(cabs(z2) - 1.0); d = d * 1.0; d = d; d = d * 1.0; i_d2 = d2; if (true) { if (d < i_closest) { i_i = i_iter; i_point = z; i_point2 = z2; i_closest = d; } } } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) {  idx = i_closest; float x = idx * 2.0; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.2; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(-9.8515146325, 11.499505134), R5 = vec2(6.134553361036669, 0.0);
#define MAXITER 149
#define FORCEOUT false
#define GRADV 0.9166666666666666
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    float f_zmod = 0.0, f_old = 0.0;
    z = pixel; f_zmod = mag2(z);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 149;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 149; it++) {
        { vec2 f0, f1, f2; if (cabs(z) > 1.0) { vec2 w = cpow(z, vec2(-3.0, 0.0)); f0 = z - cmul(z, w); f1 = vec2(4.0, 0.0) - w; f2 = 12.0 * cdiv(vec2(1.0, 0.0), z); } else { vec2 zk = cpow(z, vec2(3.0, 0.0)); f0 = cmul(z, zk - vec2(1.0, 0.0)); f1 = 4.0 * zk - vec2(1.0, 0.0); f2 = 12.0 * cpow(z, vec2(2.0, 0.0)); } z = z - cmul(vec2(2.9, 0.0), cdiv(f0, f1 - cdiv(cmul(f2, f0), 2.0 * f1))); f_old = f_zmod; f_zmod = mag2(z); }
        if (!(abs(f_zmod - f_old) >= max(1e-23, 4e-7 * f_zmod))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 1.0; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 1.0; x = 0.5 * sqrt(max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(t)))); b4 = b2 + (m - b2) * (0.61 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt3(C3 + cmul(o, R3)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b6 = b4 + (m - b4) * (0.51 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt2(C2 + cmul(o, R2)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b8 = b6 + (m - b6) * (0.48 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt1(C1 + cmul(o, R1)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(t)))); b10 = b8 + (m - b8) * (0.3 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt0(C0 + cmul(o, R0)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b12 = b10 + (m - b10) * (0.4 * clamp(at11, 0.0, 1.0)); }
    return clamp(b12, 0.0, 1.0);
}
