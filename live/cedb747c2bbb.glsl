const vec2 C0 = vec2(0.54136116131, 1.7088604442), R0 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 70
#define FORCEOUT false
#define GRADV 0.05
vec3 colourAt0(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; 
    bool inside = true;
    int numiter = 70;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 70; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } 
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = (float(numiter) - (log(logmag2(z) / 46.051701859880914) / 0.6931471805599453)) / 100.0; float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C1 = vec2(0.54136116131, 1.7088604442), R1 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 32
#define FORCEOUT false
#define GRADV 0.15
vec3 colourAt1(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
     
    bool inside = true;
    int numiter = 32;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 32; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
         
    }
    float idx;
    if (inside && !FORCEOUT) { idx = (float(numiter) - ((logmag2(z) / 46.051701859880914 - 1.0) / 1.0)) / 100.0; float x = idx * 12.0; x = 2.0 * x * x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = (float(numiter) - (log(logmag2(z) / 46.051701859880914) / 0.6931471805599453)) / 100.0; float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C2 = vec2(0.54136116131, 1.7088604442), R2 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 70
#define FORCEOUT false
#define GRADV 0.25
vec3 colourAt2(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
     
    bool inside = true;
    int numiter = 70;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 70; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
         
    }
    float idx;
    if (inside && !FORCEOUT) { idx = (float(numiter) - ((logmag2(z) / 46.051701859880914 - 1.0) / 1.0)) / 100.0; float x = idx * 11.0; x = 2.0 * x * x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = (float(numiter) - (log(logmag2(z) / 46.051701859880914) / 0.6931471805599453)) / 100.0; float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C3 = vec2(0.54136116131, 1.7088604442), R3 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 48
#define FORCEOUT false
#define GRADV 0.35
vec3 colourAt3(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
     
    bool inside = true;
    int numiter = 48;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 48; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
         
    }
    float idx;
    if (inside && !FORCEOUT) { idx = (float(numiter) - ((logmag2(z) / 46.051701859880914 - 1.0) / 1.0)) / 100.0; float x = idx * 8.0; x = 2.0 * x * x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = (float(numiter) - (log(logmag2(z) / 46.051701859880914) / 0.6931471805599453)) / 100.0; float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C4 = vec2(0.54136116131, 1.7088604442), R4 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 38
#define FORCEOUT false
#define GRADV 0.45
vec3 colourAt4(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 38;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 38; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = exp(prodlog(o_lp) / o_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C5 = vec2(0.54136116131, 1.7088604442), R5 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 39
#define FORCEOUT false
#define GRADV 0.55
vec3 colourAt5(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 39;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 39; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = exp(prodlog(o_lp) / o_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C6 = vec2(0.54136116131, 1.7088604442), R6 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 26
#define FORCEOUT false
#define GRADV 0.65
vec3 colourAt6(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 26;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 26; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = exp(prodlog(o_lp) / o_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C7 = vec2(0.54136116131, 1.7088604442), R7 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 27
#define FORCEOUT false
#define GRADV 0.75
vec3 colourAt7(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; float o_d = 0.0, o_first = 0.0, o_dmin = 1e20, o_dmax = 0.0, o_dsum = 0.0, o_lp = 0.0, o_n = 0.0;
    bool inside = true;
    int numiter = 27;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 27; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); o_n += 1.0; if (o_n == 1.0) o_first = d; o_dmin = min(o_dmin, d); o_dmax = max(o_dmax, d); o_dsum += d; o_lp = prodmul(o_lp, d); o_d = d; }
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = exp(prodlog(o_lp) / o_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C8 = vec2(0.54136116131, 1.7088604442), R8 = vec2(-0.022228052424096322, -0.01826131696576977);
#define MAXITER 200
#define FORCEOUT false
#define GRADV 0.85
vec3 colourAt8(vec2 pixel) {
    gAlpha = 1.0;
    vec2 z;
    vec2 f_zold = vec2(0.0);
    z = vec2(1.0, 0.0);
    float i_d = 0.0, i_first = 0.0, i_dmin = 1e20, i_dmax = 0.0, i_dsum = 0.0, i_lp = 0.0, i_n = 0.0; 
    bool inside = true;
    int numiter = 200;   // UF's #numiter: the iterations done, not counting the one that bailed out (cl_sck_*)
    for (int it = 0; it < 200; it++) {
        f_zold = z; z = z - cmul(vec2(3.0, 0.0), cdiv(z - cpowcap(z, vec2(-1.0, -0.0)), vec2(2.0, 0.0))) + pixel;
        if (!(convgoing(z, f_zold, 1e-30))) { inside = false; numiter = it; break; }
        // UF runs the colouring's loop only while still inside the bailout, so on the last
        // iteration zold stays the z before (ExponentialSmoothing's convergence test needs it).
        { float d; vec2 q = abs(z - vec2(0.0, 0.0)); d = pow(pow(q.x, 2.0) + pow(q.y, 2.0), 0.5); i_n += 1.0; if (i_n == 1.0) i_first = d; i_dmin = min(i_dmin, d); i_dmax = max(i_dmax, d); i_dsum += d; i_lp = prodmul(i_lp, d); i_d = d; } 
    }
    float idx;
    if (inside && !FORCEOUT) { idx = exp(prodlog(i_lp) / i_n); float x = idx * 1.0; x = log(1.0 + max(x, 0.0)); if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb; }
    idx = (float(numiter) - (log(logmag2(z) / 46.051701859880914) / 0.6931471805599453)) / 100.0; float x = idx * 1.0; x = x; if (isinf(x) || isnan(x)) x = 0.0; return texture(uGrad, vec2(fract(x) + 0.5 / 400.0, GRADV)).rgb;
}
#undef MAXITER
#undef FORCEOUT
#undef GRADV

const vec2 C9 = vec2(0.54136116131, 1.7088604442), R9 = vec2(-0.022228052424096322, -0.01826131696576977);
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
    { vec3 t = clamp(t3, 0.0, 1.0), b = clamp(b2, 0.0, 1.0); vec3 m = CL(t + b); b4 = b2 + (m - b2) * (1.0 * clamp(at3, 0.0, 1.0)); }
    vec3 t5 = colourAt7(C7 + cmul(o, R7)); float at5 = gAlpha;
    vec3 b6;
    { vec3 t = clamp(t5, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b6 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at5, 0.0, 1.0)); }
    vec3 t7 = colourAt6(C6 + cmul(o, R6)); float at7 = gAlpha;
    vec3 b8;
    { vec3 t = clamp(t7, 0.0, 1.0), b = clamp(b6, 0.0, 1.0); vec3 m = CL(b - t); b8 = b6 + (m - b6) * (1.0 * clamp(at7, 0.0, 1.0)); }
    vec3 b9;
    { vec3 t = clamp(b8, 0.0, 1.0), b = clamp(b4, 0.0, 1.0); vec3 m = CL(t + b); b9 = b4 + (m - b4) * (1.0); }
    vec3 t10 = colourAt5(C5 + cmul(o, R5)); float at10 = gAlpha;
    vec3 b11;
    { vec3 t = clamp(t10, 0.0, 1.0), b = clamp(vec3(0.0), 0.0, 1.0); vec3 m = t; b11 = vec3(0.0) + (m - vec3(0.0)) * (1.0 * clamp(at10, 0.0, 1.0)); }
    vec3 t12 = colourAt4(C4 + cmul(o, R4)); float at12 = gAlpha;
    vec3 b13;
    { vec3 t = clamp(t12, 0.0, 1.0), b = clamp(b11, 0.0, 1.0); vec3 m = CL(b - t); b13 = b11 + (m - b11) * (1.0 * clamp(at12, 0.0, 1.0)); }
    vec3 b14;
    { vec3 t = clamp(b13, 0.0, 1.0), b = clamp(b9, 0.0, 1.0); vec3 m = CL(t + b); b14 = b9 + (m - b9) * (1.0); }
    vec3 t15 = colourAt3(C3 + cmul(o, R3)); float at15 = gAlpha;
    vec3 b16;
    { vec3 t = clamp(t15, 0.0, 1.0), b = clamp(b14, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b16 = b14 + (m - b14) * (0.34 * clamp(at15, 0.0, 1.0)); }
    vec3 t17 = colourAt2(C2 + cmul(o, R2)); float at17 = gAlpha;
    vec3 b18;
    { vec3 t = clamp(t17, 0.0, 1.0), b = clamp(b16, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b18 = b16 + (m - b16) * (0.23 * clamp(at17, 0.0, 1.0)); }
    vec3 t19 = colourAt1(C1 + cmul(o, R1)); float at19 = gAlpha;
    vec3 b20;
    { vec3 t = clamp(t19, 0.0, 1.0), b = clamp(b18, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b20 = b18 + (m - b18) * (0.23 * clamp(at19, 0.0, 1.0)); }
    vec3 t21 = colourAt0(C0 + cmul(o, R0)); float at21 = gAlpha;
    vec3 b22;
    { vec3 t = clamp(t21, 0.0, 1.0), b = clamp(b20, 0.0, 1.0); vec3 m = ucol(mix(2.0 * uenc(t) * uenc(b), 1.0 - 2.0 * (1.0 - uenc(t)) * (1.0 - uenc(b)), step(0.5, uenc(b)))); b22 = b20 + (m - b20) * (0.58 * clamp(at21, 0.0, 1.0)); }
    return clamp(b22, 0.0, 1.0);
}
