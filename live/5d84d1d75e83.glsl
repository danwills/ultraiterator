const vec2 C0 = vec2(-0.520766942043, -0.017235004566135), R0 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.07142857142857142
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(1.0, 0.0)); d = sqrt(q.x * q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 2.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.0412; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(-0.520766942043, -0.017235004566135), R1 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.21428571428571427
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.0112; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.0412; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-0.520766942043, -0.017235004566135), R2 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 800
#define FORCEOUT false
#define GRADV 0.35714285714285715
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; bool i_first = true; int i_it = 0; float o_sum = 0.0, o_sum2 = 0.0; bool o_first = true; int o_it = 0;
    bool inside = true;
    int numiter = 800;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 800; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 = i_sum; if (!i_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); i_sum += t; } else i_first = false; i_it++; o_sum2 = o_sum; if (!o_first) { float ac = cabs(pixel), az2 = cabs(z - pixel), lb = abs(az2 - ac); float t = (cabs(z) - lb) / (az2 + ac - lb); o_sum += t; } else o_first = false; o_it++;
    }
    float idx;
    if (inside && !FORCEOUT) { { float s = i_sum / float(numiter), s2 = i_sum2 / float(numiter - 1); float f = 4.525182567587084 - 1.4426950408889634 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 60.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float s = o_sum / float(numiter), s2 = o_sum2 / float(numiter - 1); float f = 4.525182567587084 - 1.4426950408889634 * log(abs(log(cabs(z)))); idx = s2 + (s - s2) * (f + 1.0); } float x = idx * 60.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(-0.520766942043, -0.017235004566135), R3 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 820
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_lp = 0.0, i_old = 0.0; float o_lp = 0.0, o_old = 0.0;
    bool inside = true;
    int numiter = 820;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 820; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_old = i_lp; i_lp = prodmul(i_lp, 2.0 * (cabs(z))); o_old = o_lp; o_lp = prodmul(o_lp, 2.0 * (cabs(z)));
    }
    float idx;
    if (inside && !FORCEOUT) { float s = abs(prodlog(i_lp) / float(numiter)), so = abs(prodlog(i_old) / float(numiter - 1)); idx = s; float x = idx * 13.0; x = 2.0 * x * x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    float s = abs(prodlog(o_lp) / float(numiter)), so = abs(prodlog(o_old) / float(numiter - 1)); idx = s; float x = idx * 19.0; x = 2.0 * x * x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(-0.520766942043, -0.017235004566135), R4 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.6428571428571429
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(1.0, 0.0)); d = sqrt(q.x * q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 2.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.0412; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(-0.520766942043, -0.017235004566135), R5 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 900
#define FORCEOUT false
#define GRADV 0.7857142857142857
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 900;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 900; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.0425; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.0825; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(-0.520766942043, -0.017235004566135), R6 = vec2(-0.0024650511282897523, 0.012822039329730542);
#define MAXITER 1000
#define FORCEOUT false
#define GRADV 0.9285714285714286
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    
    z = vec2(0.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 1000;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1000; it++) {
        z = cpow(z, vec2(-1.55555, 0.0)) + pixel;
        if (!(beloweq(mag2(z), 1e+30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += exp(-cabs(z));i_sum2 += exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += exp(-cabs(z));o_sum2 += exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum * 1.0; float x = idx * 0.0212; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum * 1.0; float x = idx * 0.0412; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt6(C6 + cmul(o, R6)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt5(C5 + cmul(o, R5)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = t * b; b4 = b2 + (m - b2) * (0.86 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt4(C4 + cmul(o, R4)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = t * b; b6 = b4 + (m - b4) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt3(C3 + cmul(o, R3)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = abs(t - b); b8 = b6 + (m - b6) * (0.38 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt2(C2 + cmul(o, R2)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = CL(t + b); b10 = b8 + (m - b8) * (0.51 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt1(C1 + cmul(o, R1)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = CL(t + b); b12 = b10 + (m - b10) * (0.56 * clamp(at11, 0.0, 1.0)); }
    vec3 t13 = colourAt0(C0 + cmul(o, R0)); float at13 = gAlpha;
    vec3 b14;
    { vec3 t = clamp(t13, 0.0, 1.0), b = clamp(b12, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b14 = b12 + (m - b12) * (1.0 * clamp(at13, 0.0, 1.0)); }
    return clamp(b14, 0.0, 1.0);
}
