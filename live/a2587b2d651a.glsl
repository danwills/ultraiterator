const vec2 C0 = vec2(-0.061581569715535, -0.233229363165), R0 = vec2(-0.00011966201005147785, -0.0012665996863078682);
#define MAXITER 580
#define FORCEOUT false
#define GRADV 0.1
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 580;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 580; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.1, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.1, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.05246029343628531 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 2.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = exp(prodlog(o_lp) / o_n); float x = idx * 2.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(-0.061581569715535, -0.233229363165), R1 = vec2(-0.00011966201005147785, -0.0012665996863078682);
#define MAXITER 880
#define FORCEOUT false
#define GRADV 0.3
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); 
    bool inside = true;
    int numiter = 880;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 880; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.1, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.1, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.05246029343628531 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; 
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 6.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(-0.061581569715535, -0.233229363165), R2 = vec2(-0.00011966201005147785, -0.0012665996863078682);
#define MAXITER 1580
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 1580;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 1580; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.1, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.1, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.05246029343628531 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = o_dmin; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(-0.061581569715535, -0.233229363165), R3 = vec2(-0.00011966201005147785, -0.0012665996863078682);
#define MAXITER 580
#define FORCEOUT false
#define GRADV 0.7
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 580;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 580; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.1, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.1, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.05246029343628531 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = sqrt(q.x * q.y); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = o_dmin; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(-0.061581569715535, -0.233229363165), R4 = vec2(-0.00011966201005147785, -0.0012665996863078682);
#define MAXITER 580
#define FORCEOUT false
#define GRADV 0.9
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 580;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 580; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.1, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.1, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.05246029343628531 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 5.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 5.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b4 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 b5;
    { vec3 t = clamp(b4, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b5 = b2 + (m - b2) * (1.0); }
    vec3 t6 = colourAt2(C2 + cmul(o, R2)); float at6 = gAlpha;
    vec3 b7;
    { vec3 t = clamp(t6, 0.0, 1.0), b = clamp(b5, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b7 = b5 + (m - b5) * (1.0 * clamp(at6, 0.0, 1.0)); }
    vec3 t8 = colourAt1(C1 + cmul(o, R1)); float at8 = gAlpha;
    vec3 b9;
    { vec3 t = clamp(t8, 0.0, 1.0), b = clamp(b7, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b9 = b7 + (m - b7) * (0.86 * clamp(at8, 0.0, 1.0)); }
    vec3 t10 = colourAt0(C0 + cmul(o, R0)); float at10 = gAlpha;
    vec3 b11;
    { vec3 t = clamp(t10, 0.0, 1.0), b = clamp(b9, 0.0, 1.0); vec3 m = CL(t + b); b11 = b9 + (m - b9) * (1.0 * clamp(at10, 0.0, 1.0)); }
    return clamp(b11, 0.0, 1.0);
}
