const vec2 C0 = vec2(0.136842772559, 2.4451584648), R0 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.05
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.136842772559, 2.4451584648), R1 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 66
#define FORCEOUT false
#define GRADV 0.15
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 66;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 66; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.136842772559, 2.4451584648), R2 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 44
#define FORCEOUT false
#define GRADV 0.25
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 44;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 44; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.1; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.136842772559, 2.4451584648), R3 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 32
#define FORCEOUT false
#define GRADV 0.35
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 32;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 32; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.136842772559, 2.4451584648), R4 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 30
#define FORCEOUT false
#define GRADV 0.45
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 30;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 30; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(0.136842772559, 2.4451584648), R5 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 28
#define FORCEOUT false
#define GRADV 0.55
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 28;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 28; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(0.136842772559, 2.4451584648), R6 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 26
#define FORCEOUT false
#define GRADV 0.65
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 26;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 26; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C7 = vec2(0.136842772559, 2.4451584648), R7 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 24
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt7(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 24;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 24; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C8 = vec2(0.136842772559, 2.4451584648), R8 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 22
#define FORCEOUT false
#define GRADV 0.85
vec3 colourAt8(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 22;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 22; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C9 = vec2(0.136842772559, 2.4451584648), R9 = vec2(-0.17476124837691911, -0.14357400680254526);
#define MAXITER 24
#define FORCEOUT false
#define GRADV 0.95
vec3 colourAt9(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = pixel;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 24;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 24; it++) {
        
        if (!(false)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.3; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b4 = b2 + (m - b2) * (0.26 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt7(C7 + cmul(o, R7)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (0.26 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt6(C6 + cmul(o, R6)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (0.2 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt5(C5 + cmul(o, R5)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = CL(t + b); b10 = b8 + (m - b8) * (0.15 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt4(C4 + cmul(o, R4)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = CL(t + b); b12 = b10 + (m - b10) * (0.1 * clamp(at11, 0.0, 1.0)); }
    vec3 t13 = colourAt3(C3 + cmul(o, R3)); float at13 = gAlpha;
    vec3 b14;
    { vec3 t = clamp(t13, 0.0, 1.0), b = clamp(b12, 0.0, 1.0); vec3 m = CL(t + b); b14 = b12 + (m - b12) * (0.06 * clamp(at13, 0.0, 1.0)); }
    vec3 t15 = colourAt2(C2 + cmul(o, R2)); float at15 = gAlpha;
    vec3 b16;
    { vec3 t = clamp(t15, 0.0, 1.0), b = clamp(b14, 0.0, 1.0); vec3 m = abs(t - b); b16 = b14 + (m - b14) * (0.89 * clamp(at15, 0.0, 1.0)); }
    vec3 t17 = colourAt1(C1 + cmul(o, R1)); float at17 = gAlpha;
    vec3 b18;
    { vec3 t = clamp(t17, 0.0, 1.0), b = clamp(b16, 0.0, 1.0); vec3 m = CL(t + b); b18 = b16 + (m - b16) * (0.93 * clamp(at17, 0.0, 1.0)); }
    vec3 t19 = colourAt0(C0 + cmul(o, R0)); float at19 = gAlpha;
    vec3 b20;
    { vec3 t = clamp(t19, 0.0, 1.0), b = clamp(b18, 0.0, 1.0); vec3 m = CL(t + b); b20 = b18 + (m - b18) * (0.93 * clamp(at19, 0.0, 1.0)); }
    return clamp(b20, 0.0, 1.0);
}
