const vec2 C0 = vec2(0.015369148360745, -0.6753256298145), R0 = vec2(-0.0010828102245738363, -0.015804371623832702);
#define MAXITER 280
#define FORCEOUT false
#define GRADV 0.1
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); 
    bool inside = true;
    int numiter = 280;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 280; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.2, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.2, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.027424074738735392 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; 
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.015369148360745, -0.6753256298145), R1 = vec2(-0.0010828102245738363, -0.015804371623832702);
#define MAXITER 250
#define FORCEOUT false
#define GRADV 0.3
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); 
    bool inside = true;
    int numiter = 250;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 250; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.2, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.2, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.027424074738735392 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; 
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 4.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.015369148360745, -0.6753256298145), R2 = vec2(-0.0010828102245738363, -0.015804371623832702);
#define MAXITER 380
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; 
    bool inside = true;
    int numiter = 380;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 380; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.2, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.2, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.027424074738735392 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(-0.002907, 0.005814)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } 
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 9.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.015369148360745, -0.6753256298145), R3 = vec2(-0.0010828102245738363, -0.015804371623832702);
#define MAXITER 280
#define FORCEOUT false
#define GRADV 0.7
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; 
    bool inside = true;
    int numiter = 280;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 280; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.2, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.2, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.027424074738735392 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } 
    }
    float idx;
    if (inside && !FORCEOUT) { idx = i_dmin; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.015369148360745, -0.6753256298145), R4 = vec2(-0.0010828102245738363, -0.015804371623832702);
#define MAXITER 280
#define FORCEOUT false
#define GRADV 0.9
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_z1 = vec2(0.0), f_d = vec2(0.0); float f_dk = 0.0, f_modz = 0.0;
    f_z1 = vec2(0.0, 0.0); z = f_z1;
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); 
    bool inside = true;
    int numiter = 280;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 280; it++) {
        { vec2 zp = cpow(f_z1, vec2(-1.2, 0.0)); vec2 dz = dot(f_z1, f_z1) == 0.0 ? vec2(0.0) : cmul(vec2(-1.2, 0.0), cdiv(zp, f_z1)); f_d = cmul(dz, f_d) + vec2(exp2(-f_dk), 0.0); if (cabs(f_d) > 1e12) { f_d *= exp2(-40.0); f_dk += 40.0; } f_z1 = zp + pixel; f_modz = mag2(f_z1); if (!(f_modz <= 1e+20) || it == MAXITER - 1) { vec2 F = cdiv(f_d, f_z1); float L = log(cabs(f_z1)); vec2 g = -0.027424074738735392 * vec2(F.x, -F.y) / L; vec3 n; if (f_dk > 60.0 || isinf(g.x) || isinf(g.y)) n = vec3(normalize(g), 0.0); else { g *= exp2(f_dk); n = normalize(vec3(g, -1.0)); } z = (isnan(n.x) || isnan(n.y)) ? vec2(0.0) : n.xy; } else z = f_z1; }
        if (!(!(f_modz > 1e+20))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; 
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 3.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    { float vz = -sqrt(max(1.0 - mag2(z), 0.0)); float l = -0.8660254037844387 * z.x + 1.0605752387249069e-16 * z.y + -0.49999999999999994 * vz; if (l < 0.0) l = 0.0; idx = l * 0.99; } float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt2(C2 + cmul(o, R2)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b6 = b4 + (m - b4) * (0.52 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt1(C1 + cmul(o, R1)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(b - t); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt0(C0 + cmul(o, R0)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = CL(t + b); b10 = b8 + (m - b8) * (1.0 * clamp(at9, 0.0, 1.0)); }
    return clamp(b10, 0.0, 1.0);
}
