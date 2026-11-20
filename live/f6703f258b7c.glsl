const vec2 C1 = vec2(-0.076850662905, 0.198254776505), R1 = vec2(0.31442158719863417, 0.12617934869121758);
#define MAXITER 60
#define FORCEOUT false
#define GRADV 0.3
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; bool i_first = true; int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 60;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 60; it++) {
        { int d = f_p / 10; f_p = (f_p - d * 10) * 10 + d; if (false) d = 3 - d; if (d == 1) { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + vec2(0.2184895833, -0.3580729167); f_count = convgoing(z, f_zold, 1e-26) ? 0 : f_count + 1; f_zold = z; } else { z = z - cmul(vec2(2.7, 0.0), cdiv(z - cpow(z, vec2(-2.0, -0.0)), vec2(3.0, 0.0))) + pixel; f_count = convgoing(z, f_zold2, 1e-26) ? 0 : f_count + 1; f_zold2 = z; } }
        if (!(f_count < 1)) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 = i_sum; if (!i_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); i_sum += t; } else i_first = false; i_it++; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { { float s = i_sum / float(numiter), s2 = i_sum2 / float(numiter - 1); float f = 4.525182567587084 - 1.4426950408889634 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-0.076850662905, 0.198254776505), R2 = vec2(0.31442158719863417, 0.12617934869121758);
#define MAXITER 70
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 70;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 70; it++) {
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

const vec2 C3 = vec2(-0.076850662905, 0.198254776505), R3 = vec2(0.31442158719863417, 0.12617934869121758);
#define MAXITER 50
#define FORCEOUT false
#define GRADV 0.7
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 50;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 50; it++) {
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

const vec2 C4 = vec2(-0.076850662905, 0.198254776505), R4 = vec2(0.31442158719863417, 0.12617934869121758);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.9
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_zold2 = vec2(0.0); int f_p = 21, f_count = 0;
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
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
    vec3 t1 = colourAt4(C4 + cmul(o, R4)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt3(C3 + cmul(o, R3)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = t * b; b4 = b2 + (m - b2) * (0.32 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt2(C2 + cmul(o, R2)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt1(C1 + cmul(o, R1)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(t + b); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    return clamp(b8, 0.0, 1.0);
}
