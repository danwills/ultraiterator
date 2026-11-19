const vec2 C0 = vec2(1.68279523565, 2.844207332), R0 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 240
#define FORCEOUT false
#define GRADV 0.029411764705882353
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 240;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 240; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(1.68279523565, 2.844207332), R1 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 90
#define FORCEOUT false
#define GRADV 0.08823529411764706
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 90;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 90; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(1.68279523565, 2.844207332), R2 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 40
#define FORCEOUT false
#define GRADV 0.14705882352941177
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 40;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 40; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(1.68279523565, 2.844207332), R3 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 25
#define FORCEOUT false
#define GRADV 0.20588235294117646
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 25;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 25; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(1.68279523565, 2.844207332), R4 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 24
#define FORCEOUT false
#define GRADV 0.2647058823529412
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 24;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 24; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(1.68279523565, 2.844207332), R5 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 23
#define FORCEOUT false
#define GRADV 0.3235294117647059
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 23;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 23; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(1.68279523565, 2.844207332), R6 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 22
#define FORCEOUT false
#define GRADV 0.38235294117647056
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 22;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 22; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C7 = vec2(1.68279523565, 2.844207332), R7 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 21
#define FORCEOUT false
#define GRADV 0.4411764705882353
vec3 colourAt7(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 21;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 21; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C8 = vec2(1.68279523565, 2.844207332), R8 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 20
#define FORCEOUT false
#define GRADV 0.5
vec3 colourAt8(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 20;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 20; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C9 = vec2(1.68279523565, 2.844207332), R9 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 17
#define FORCEOUT false
#define GRADV 0.5588235294117647
vec3 colourAt9(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 17;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 17; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C10 = vec2(1.68279523565, 2.844207332), R10 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 15
#define FORCEOUT false
#define GRADV 0.6176470588235294
vec3 colourAt10(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 15;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 15; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C11 = vec2(1.68279523565, 2.844207332), R11 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 16
#define FORCEOUT false
#define GRADV 0.6764705882352942
vec3 colourAt11(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 16;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 16; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C12 = vec2(1.68279523565, 2.844207332), R12 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 14
#define FORCEOUT false
#define GRADV 0.7352941176470589
vec3 colourAt12(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 14;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 14; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C13 = vec2(1.68279523565, 2.844207332), R13 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 13
#define FORCEOUT false
#define GRADV 0.7941176470588235
vec3 colourAt13(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 13;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 13; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C14 = vec2(1.68279523565, 2.844207332), R14 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 12
#define FORCEOUT false
#define GRADV 0.8529411764705882
vec3 colourAt14(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 12;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 12; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C15 = vec2(1.68279523565, 2.844207332), R15 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 11
#define FORCEOUT false
#define GRADV 0.9117647058823529
vec3 colourAt15(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 11;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 11; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C16 = vec2(1.68279523565, 2.844207332), R16 = vec2(-0.002039015913167725, -0.04899896787250649);
#define MAXITER 10
#define FORCEOUT false
#define GRADV 0.9705882352941176
vec3 colourAt16(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0), f_y = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_sum = 0.0, i_sum2 = 0.0; vec2 i_zold = vec2(0.0); float o_sum = 0.0, o_sum2 = 0.0; vec2 o_zold = vec2(0.0);
    bool inside = true;
    int numiter = 10;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 10; it++) {
        f_y = f_zold; f_zold = z; { vec2 D; { vec2 a = vec2(12.0, 0.0), b = vec2(6.0, 0.0), t = cmul(cmul(vec2(6.0, 0.0), z), vec2(3.11395, 0.0)); if (cabs(z) > 1.0) { vec2 r = cpow(z, vec2(-3.0, -0.0)); D = cdiv(cmul(t, vec2(1.0, 0.0) - r), a + cmul(b, r)); } else { vec2 zt = cpow(z, vec2(3.0, 0.0)); D = cdiv(cmul(t, zt - vec2(1.0, 0.0)), cmul(a, zt) + b); } } z = z - D + pixel; }
        if (!(convgoing(z, f_zold, 1e-23))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        i_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));i_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(i_zold - z));i_zold = z; o_sum += (1.0 / float(MAXITER)) * exp(-cabs(z));o_sum2 += (1.0 / float(MAXITER)) * exp(-1.0 / cabs(o_zold - z));o_zold = z;
    }
    float idx;
    if (inside && !FORCEOUT) { if (mag2(z - i_zold) < 0.5) idx = i_sum2; else idx = i_sum; float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    if (mag2(z - o_zold) < 0.5) idx = o_sum2; else idx = o_sum; float x = idx * 2.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

vec3 liveColour(vec2 o) {
    vec3 t1 = colourAt16(C16 + cmul(o, R16)); float at1 = gAlpha;
    vec3 b2;
    { vec3 t = clamp(t1, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b2 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at1, 0.0, 1.0)); }
    vec3 t3 = colourAt15(C15 + cmul(o, R15)); float at3 = gAlpha;
    vec3 b4;
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = abs(t - b); b4 = b2 + (m - b2) * (0.23 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt14(C14 + cmul(o, R14)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = abs(t - b); b6 = b4 + (m - b4) * (0.23 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt13(C13 + cmul(o, R13)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = abs(t - b); b8 = b6 + (m - b6) * (0.23 * clamp(at7, 0.0, 1.0)); }
    vec3 t9 = colourAt12(C12 + cmul(o, R12)); float at9 = gAlpha;
    vec3 b10;
    { vec3 t = clamp(t9, 0.0, 1.0), b = clamp(b8, 0.0, 1.0); vec3 m = abs(t - b); b10 = b8 + (m - b8) * (0.23 * clamp(at9, 0.0, 1.0)); }
    vec3 t11 = colourAt11(C11 + cmul(o, R11)); float at11 = gAlpha;
    vec3 b12;
    { vec3 t = clamp(t11, 0.0, 1.0), b = clamp(b10, 0.0, 1.0); vec3 m = abs(t - b); b12 = b10 + (m - b10) * (0.23 * clamp(at11, 0.0, 1.0)); }
    vec3 t13 = colourAt10(C10 + cmul(o, R10)); float at13 = gAlpha;
    vec3 b14;
    { vec3 t = clamp(t13, 0.0, 1.0), b = clamp(b12, 0.0, 1.0); vec3 m = abs(t - b); b14 = b12 + (m - b12) * (0.23 * clamp(at13, 0.0, 1.0)); }
    vec3 t15 = colourAt9(C9 + cmul(o, R9)); float at15 = gAlpha;
    vec3 b16;
    { vec3 t = clamp(t15, 0.0, 1.0), b = clamp(b14, 0.0, 1.0); vec3 m = abs(t - b); b16 = b14 + (m - b14) * (0.23 * clamp(at15, 0.0, 1.0)); }
    vec3 t17 = colourAt8(C8 + cmul(o, R8)); float at17 = gAlpha;
    vec3 b18;
    { vec3 t = clamp(t17, 0.0, 1.0), b = clamp(b16, 0.0, 1.0); vec3 m = abs(t - b); b18 = b16 + (m - b16) * (0.23 * clamp(at17, 0.0, 1.0)); }
    vec3 t19 = colourAt7(C7 + cmul(o, R7)); float at19 = gAlpha;
    vec3 b20;
    { vec3 t = clamp(t19, 0.0, 1.0), b = clamp(b18, 0.0, 1.0); vec3 m = abs(t - b); b20 = b18 + (m - b18) * (0.23 * clamp(at19, 0.0, 1.0)); }
    vec3 t21 = colourAt6(C6 + cmul(o, R6)); float at21 = gAlpha;
    vec3 b22;
    { vec3 t = clamp(t21, 0.0, 1.0), b = clamp(b20, 0.0, 1.0); vec3 m = abs(t - b); b22 = b20 + (m - b20) * (0.23 * clamp(at21, 0.0, 1.0)); }
    vec3 t23 = colourAt5(C5 + cmul(o, R5)); float at23 = gAlpha;
    vec3 b24;
    { vec3 t = clamp(t23, 0.0, 1.0), b = clamp(b22, 0.0, 1.0); vec3 m = abs(t - b); b24 = b22 + (m - b22) * (0.23 * clamp(at23, 0.0, 1.0)); }
    vec3 t25 = colourAt4(C4 + cmul(o, R4)); float at25 = gAlpha;
    vec3 b26;
    { vec3 t = clamp(t25, 0.0, 1.0), b = clamp(b24, 0.0, 1.0); vec3 m = abs(t - b); b26 = b24 + (m - b24) * (0.23 * clamp(at25, 0.0, 1.0)); }
    vec3 t27 = colourAt3(C3 + cmul(o, R3)); float at27 = gAlpha;
    vec3 b28;
    { vec3 t = clamp(t27, 0.0, 1.0), b = clamp(b26, 0.0, 1.0); vec3 m = abs(t - b); b28 = b26 + (m - b26) * (0.23 * clamp(at27, 0.0, 1.0)); }
    vec3 t29 = colourAt2(C2 + cmul(o, R2)); float at29 = gAlpha;
    vec3 b30;
    { vec3 t = clamp(t29, 0.0, 1.0), b = clamp(b28, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b30 = b28 + (m - b28) * (1.0 * clamp(at29, 0.0, 1.0)); }
    vec3 t31 = colourAt1(C1 + cmul(o, R1)); float at31 = gAlpha;
    vec3 b32;
    { vec3 t = clamp(t31, 0.0, 1.0), b = clamp(b30, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b32 = b30 + (m - b30) * (1.0 * clamp(at31, 0.0, 1.0)); }
    vec3 t33 = colourAt0(C0 + cmul(o, R0)); float at33 = gAlpha;
    vec3 b34;
    { vec3 t = clamp(t33, 0.0, 1.0), b = clamp(b32, 0.0, 1.0); vec3 m = 1.0 - (1.0 - t) * (1.0 - b); b34 = b32 + (m - b32) * (1.0 * clamp(at33, 0.0, 1.0)); }
    return clamp(b34, 0.0, 1.0);
}
