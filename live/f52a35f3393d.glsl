const vec2 C0 = vec2(-0.1740420175425, -0.2212659434565), R0 = vec2(-0.011357637623310523, -0.017486154614973413);
#define MAXITER 4951
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 4951;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 4951; it++) {
        f_zold = z; z = z - cmul(vec2(3.73696, 2.67182), cdiv(z - cpowcap(z, vec2(-4.0, -0.0)), vec2(5.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-34))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum2 += (4951.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum2 += (4951.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = 0.0; float x = idx * 33.0; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = 0.0; float x = idx * 33.0; x = pow(max(x, 0.0), 1.0 / 3.0) * 0.3303; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt0(C0 + cmul(o, R0)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    return clamp(b2, 0.0, 1.0);
}
