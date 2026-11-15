#version 440
// Rasterises the koi into one data image, one pixel per character cell, three bands stacked:
// band 0 tile colour, band 1 glyph colour, band 2 control (glyph index, glyph alpha, tile alpha).
// The anatomy and lighting follow pursurer/ascii-koi (MIT), ported to the GPU.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 cellPx;
    vec2 grid;
    float time;
    float nFish;
    vec4 accent;
};
layout(binding = 1) uniform sampler2D fishTex;

const int N = 12;
const float TW = 40.0;
const float TH = 32.0;

float sstep(float a, float b, float x) { float k = clamp((x - a) / (b - a), 0.0, 1.0); return k * k * (3.0 - 2.0 * k); }
uint ihash(uint a, uint b) {
    uint x = (a * 0x27d4eb2du) ^ (b * 0x165667b1u);
    x = (x ^ (x >> 15)) * 0x85ebca6bu;
    x ^= x >> 13; x *= 0xc2b2ae35u; x ^= x >> 16;
    return x;
}
float h2(float a, float b) { return float(ihash(uint(int(a)), uint(int(b)))) / 4294967296.0; }
float vnoise(float x, float y, float seed) {
    float xi = floor(x), yi = floor(y), u = sstep(0.0, 1.0, x - xi), v = sstep(0.0, 1.0, y - yi);
    float a = h2(xi + seed * 131.0, yi), b = h2(xi + 1.0 + seed * 131.0, yi);
    float c = h2(xi + seed * 131.0, yi + 1.0), d = h2(xi + 1.0 + seed * 131.0, yi + 1.0);
    return mix(mix(a, b, u), mix(c, d, u), v);
}
float caus(vec2 p) {
    return 1.0 - min(1.0, abs(vnoise(p.x / 46.0 + time * 0.21, p.y / 46.0 - time * 0.13, 7.0) - vnoise(p.x / 39.0 - time * 0.17, p.y / 52.0 + time * 0.19, 11.0)) * 5.5);
}

float rd(int col, int row) {
    vec4 t = texture(fishTex, vec2((float(col) + 0.5) / TW, (float(row) + 0.5) / TH));
    return (t.r * 255.0 * 256.0 + t.g * 255.0) / 16.0 - 512.0;
}

vec2 sp[12];
float arcv[12];
float arcTotal;
float D, S, V, TX, TY;
int SEG;
int hk;
float hAcross, hRs, hRa;

float halfW(float s) {
    return s < 0.1 ? 0.118 * pow(sin(s / 0.1 * 1.5707963), 0.6)
         : s < 0.3 ? 0.118 + 0.02 * sstep(0.1, 0.3, s)
         : 0.03 + 0.108 * (1.0 - sstep(0.3, 0.76, s));
}
float tailW(float s) { return 0.028 + 0.165 * pow(sstep(0.72, 1.0, s), 0.85); }
bool finHit(float s, float a, float rootS, float angle, float reach, float width) {
    float ra = halfW(rootS) * 0.85, ca = cos(angle), sa = sin(angle);
    float ds = s - rootS, da = a - ra;
    float along = ds * ca + da * sa - reach, perp = -ds * sa + da * ca;
    if ((along / reach) * (along / reach) + (perp / width) * (perp / width) > 1.0) return false;
    hk = 2; hRs = ds; hRa = da;
    return true;
}
bool classify(float s, float a, float past, float flare, float ahead, float lateral) {
    hk = 0; hAcross = 1.0; hRs = 1.0; hRa = 0.0;
    if (ahead > 0.0) {
        if (ahead < 0.05 && abs(lateral - (0.042 + ahead * 0.75)) < 0.015) { hk = 5; return true; }
        return false;
    }
    float w = halfW(s);
    if (s <= 0.76 && a <= w) {
        hAcross = a / w;
        hk = (s > 0.056 && s < 0.084 && hAcross > 0.5 && hAcross < 0.78) ? 3 : ((s > 0.3 && s < 0.6 && hAcross < 0.13) ? 4 : 1);
        return true;
    }
    if (s > 0.7 && past <= 0.0) {
        float tw = tailW(s) * flare;
        if (a <= tw && s <= 0.88 + 0.12 * (a / tw)) { hk = 2; hRs = 1.0; hRa = (a / tw) * 0.8; return true; }
    }
    return finHit(s, a, 0.2, 0.9 + 0.45 * (flare - 1.0), 0.07 * flare, 0.038) || finHit(s, a, 0.47, 0.75, 0.038, 0.019);
}

bool samplePt(vec2 p, float L, float flareL, float flareR, int from, int to) {
    float best = 1e20, bs = 0.0, sgn = 1.0, past = 0.0, ahead = 0.0, lateral = 0.0;
    for (int n = 0; n < N - 1; n++) {
        if (n < from || n > to) continue;
        vec2 a = sp[n], sv = sp[n + 1] - a;
        float len2 = dot(sv, sv);
        if (len2 < 1e-6) len2 = 1.0;
        float raw = dot(p - a, sv) / len2, u = clamp(raw, 0.0, 1.0);
        vec2 q = p - a - sv * u;
        float d2 = dot(q, q);
        if (d2 < best) {
            float len = sqrt(len2), cross = sv.x * (p.y - a.y) - sv.y * (p.x - a.x);
            best = d2; bs = (arcv[n] + u * len) / arcTotal; sgn = cross >= 0.0 ? 1.0 : -1.0;
            past = n == N - 2 ? max(0.0, raw - 1.0) * len : 0.0;
            ahead = n == 0 ? max(0.0, -raw) * len : 0.0;
            lateral = abs(cross) / len; TX = sv.x / len; TY = sv.y / len; SEG = n;
        }
    }
    D = sqrt(best); S = bs; V = D * sgn;
    return classify(bs, D / L, past / L, sgn > 0.0 ? flareL : flareR, ahead / L, lateral / L);
}

bool inPatch(float ms, float mv, float rs, float rv, float s, float vn, float wob) {
    float a = (s - ms) / rs, b = (vn - mv) / rv;
    return a * a + b * b < 1.0 + wob;
}
// 0 white, 1 red, 2 black. variety: 0 kohaku, 1 sanke, 2 tancho, 3 ogon (one solid colour)
int skin(float seed, int variety, float s, float vn, float across) {
    if (across > 0.9 || s > 0.74) return 0;
    float wob = (vnoise(s * 13.0 + seed, vn * 28.0, seed) - 0.5) * 0.65;
    if (variety == 1) {
        int nb = 4 + int(floor(h2(seed, 50.0) * 3.0));
        for (int k = 0; k < 6; k++) {
            if (k >= nb) break;
            float ms = 0.25 + h2(seed, 60.0 + float(k)) * 0.42, mv = (h2(seed, 70.0 + float(k)) - 0.5) * 0.15;
            if (inPatch(ms, mv, 0.021, 0.025, s, vn, wob)) return 2;
        }
    }
    if (variety == 3) return 0;
    if (variety == 2) return inPatch(0.1, 0.0, 0.052, 0.06, s, vn, wob) ? 1 : 0;
    if (h2(seed, 1.0) < 0.85 && inPatch(0.09, (h2(seed, 2.0) - 0.5) * 0.03, 0.05 + h2(seed, 3.0) * 0.03, 0.1, s, vn, wob)) return 1;
    int n = h2(seed, 4.0) < 0.25 ? 3 : 2;
    float w0 = 0.5 + h2(seed, 30.0), w1 = 0.5 + h2(seed, 31.0), w2 = n == 3 ? 0.5 + h2(seed, 32.0) : 0.0;
    float unit = (0.45 - 0.05 * float(n - 1)) / (w0 + w1 + w2), at = 0.23;
    for (int j = 0; j < 3; j++) {
        if (j >= n) break;
        float wj = j == 0 ? w0 : (j == 1 ? w1 : w2);
        float rs = unit * wj / 2.0;
        float mv = (mod(float(j), 2.0) > 0.5 ? 1.0 : -1.0) * (0.022 + h2(seed, 20.0 + float(j)) * 0.018);
        float rv = 0.065 + rs * 0.3 + h2(seed, 40.0 + float(j)) * 0.02;
        if (inPatch(at + rs, mv, rs * 0.95, rv, s, vn, wob)) return 1;
        at += rs * 2.0 + 0.05;
    }
    return 0;
}

// 12 colour schemes: red patch, white body, black spot. 0 follows the painting's accent; 4 to 7 are the koi
// variants of Ascii-Animals-extension (MIT); the rest are our own, more fanciful ones.
const vec3 KR[12] = vec3[12](vec3(0.0), vec3(214, 58, 36) / 255.0, vec3(230, 164, 52) / 255.0, vec3(238, 132, 128) / 255.0,
    vec3(214, 48, 36) / 255.0, vec3(250, 150, 30) / 255.0, vec3(255, 172, 72) / 255.0, vec3(176, 186, 202) / 255.0,
    vec3(90, 150, 230) / 255.0, vec3(170, 110, 220) / 255.0, vec3(70, 190, 140) / 255.0, vec3(235, 80, 140) / 255.0);
const vec3 KW[12] = vec3[12](vec3(238, 232, 220) / 255.0, vec3(246, 242, 234) / 255.0, vec3(222, 228, 232) / 255.0, vec3(250, 240, 228) / 255.0,
    vec3(236, 232, 226) / 255.0, vec3(244, 196, 44) / 255.0, vec3(240, 118, 38) / 255.0, vec3(214, 220, 228) / 255.0,
    vec3(200, 225, 245) / 255.0, vec3(235, 225, 245) / 255.0, vec3(225, 245, 235) / 255.0, vec3(250, 228, 238) / 255.0);
const vec3 KB[12] = vec3[12](vec3(40, 36, 38) / 255.0, vec3(24, 22, 20) / 255.0, vec3(98, 74, 42) / 255.0, vec3(66, 60, 70) / 255.0,
    vec3(30, 30, 34) / 255.0, vec3(120, 80, 20) / 255.0, vec3(150, 60, 20) / 255.0, vec3(100, 108, 122) / 255.0,
    vec3(30, 50, 110) / 255.0, vec3(40, 30, 80) / 255.0, vec3(20, 70, 60) / 255.0, vec3(70, 20, 50) / 255.0);
void scheme(int c, out vec3 red, out vec3 white, out vec3 black, out vec3 fin) {
    red = c == 0 ? mix(accent.rgb, vec3(232.0, 92.0, 52.0) / 255.0, 0.5) : KR[c];
    white = KW[c]; black = KB[c];
    fin = mix(white, vec3(0.78, 0.84, 0.86), 0.45);
}
float lineGlyph(vec2 d) {
    float l = length(d); if (l < 1e-6) l = 1.0;
    return abs(d.y) < 0.38 * l ? 3.0 : (abs(d.x) < 0.38 * l ? 17.0 : (d.x * d.y > 0.0 ? 16.0 : 15.0));
}

void main() {
    vec2 g = floor(qt_TexCoord0 * vec2(grid.x, grid.y * 3.0));
    int band = int(floor(g.y / grid.y));
    vec2 cell = vec2(g.x, g.y - float(band) * grid.y);
    vec2 cp = cell * cellPx, cen = cp + cellPx * 0.5;
    float diag = length(cellPx);

    vec3 tileC = vec3(0.0), glyC = vec3(0.0);
    float gi = 0.0, ga = 0.0, ta = 0.0;
    const vec2 SUB[4] = vec2[4](vec2(0.25, 0.25), vec2(0.75, 0.25), vec2(0.25, 0.75), vec2(0.75, 0.75));

    for (int f = 0; f < 32; f++) {
        if (float(f) >= nFish) break;
        // bounding circle first: most koi are nowhere near this cell
        if (distance(cen, vec2(rd(2 * N + 6, f), rd(2 * N + 7, f))) > rd(2 * N + 8, f) + diag) continue;
        float flareL = rd(2 * N, f) - 0.0, flareR = rd(2 * N + 1, f);
        // scalars are stored as value + 512 scaled by 16, so decode back
        flareL = flareL / 100.0 + 0.0; flareR = flareR / 100.0 + 0.0;
        float depth = rd(2 * N + 2, f) / 100.0;
        int colour = int(floor(rd(2 * N + 3, f) + 0.5));
        float seed = floor(rd(2 * N + 4, f) + 0.5);
        int variety = int(floor(rd(2 * N + 5, f) + 0.5));
        float mn = 1e20;
        for (int n = 0; n < N; n++) { sp[n] = vec2(rd(n, f), rd(N + n, f)); mn = min(mn, distance(sp[n], cen)); }
        arcv[0] = 0.0;
        for (int m = 1; m < N; m++) arcv[m] = arcv[m - 1] + distance(sp[m], sp[m - 1]);
        arcTotal = max(arcv[N - 1], 1.0);
        float L = arcTotal;
        if (mn > L * 0.3 + diag) continue;
        vec3 kr, kw, kb, kf; scheme(colour, kr, kw, kb, kf);
        float alphaBase = 0.9 * (0.55 + 0.45 * depth);

        bool got = samplePt(cen, L, flareL, flareR, 0, N - 2);
        if (!got && D > L * ((S > 0.4 && S < 0.62) ? 0.15 : 0.26) + diag) continue;
        int kind = hk; float across = hAcross, rs = hRs, ra = hRa, s2 = S, v = V, tx2 = TX, ty2 = TY;
        int seg = SEG, from = max(0, seg - 2), to = min(N - 2, seg + 2);
        int hits = got ? 1 : 0;
        bool deep = got && kind == 1 && s2 > 0.05 && s2 < 0.7 && halfW(s2) * L - D > diag * 0.4;
        if (deep) hits = 5;
        else {
            for (int q = 0; q < 4; q++) {
                if (!samplePt(cp + SUB[q] * cellPx, L, flareL, flareR, from, to)) continue;
                if (hits == 0) { kind = hk; across = hAcross; rs = hRs; ra = hRa; s2 = S; v = V; tx2 = TX; ty2 = TY; }
                hits++;
            }
        }
        if (hits == 0) continue;
        float cover = float(hits) / 5.0, side = v >= 0.0 ? 1.0 : -1.0;
        vec3 tile = vec3(0.0), gC = vec3(0.0);
        float tA = 0.0, gI = 0.0, gA = 0.0;
        bool hasTile = false, hasGlyph = false;
        if (kind == 5) {
            gI = lineGlyph(vec2(tx2, ty2)); gC = kf; gA = 0.7 * alphaBase; hasGlyph = true;
        } else if (kind == 2) {
            vec2 nn = vec2(-ty2 * side, tx2 * side);
            gI = lineGlyph(vec2(rs * tx2 + ra * nn.x, rs * ty2 + ra * nn.y));
            tile = kf; tA = 0.26 * cover * alphaBase; gC = kf * 1.1; gA = 0.55 * alphaBase; hasTile = true; hasGlyph = true;
        } else {
            float nz = sqrt(max(0.0, 1.0 - across * across));
            vec2 ns = vec2(-ty2 * side * across, tx2 * side * across);
            float gl = sstep(0.62, 0.96, caus(cen)) * nz;
            float lit = clamp(0.76 + 0.26 * nz + 0.2 * (ns.x * -0.6 + ns.y * -0.8) + 0.3 * gl, 0.62, 1.34);
            int sk = kind == 3 ? 0 : skin(seed, variety, s2, v / L, across);
            vec3 base = kind == 3 ? mix(kb, vec3(0.06), 0.5) : (sk == 1 ? kr : (sk == 2 ? kb : kw));
            tile = base * lit; tA = (cover >= 0.6 ? 1.0 : cover * 1.4) * alphaBase * (kind == 3 ? 0.72 : 1.0); hasTile = true;
            if (kind == 3) { gI = 1.0; gC = kw; gA = 0.7 * alphaBase; hasGlyph = true; }
            else {
                gI = clamp(1.0 + floor((1.08 - lit) / 0.46 * 6.0 + 0.5) + (kind == 4 ? 2.0 : 0.0), 1.0, 9.0);
                gC = base * (sk == 0 ? 0.55 : 1.35); gA = 0.62 * alphaBase; hasGlyph = true;
                if (gl > 0.5 && kind != 4) { gI = 6.0; gC = mix(base, vec3(1.0), 0.75); gA = (0.45 + 0.4 * gl) * alphaBase; }
            }
        }
        tileC = hasTile ? clamp(tile, 0.0, 1.0) : vec3(0.0); ta = hasTile ? clamp(tA, 0.0, 1.0) : 0.0;
        glyC = hasGlyph ? clamp(gC, 0.0, 1.0) : vec3(0.0); gi = hasGlyph ? gI : 0.0; ga = hasGlyph ? clamp(gA, 0.0, 1.0) : 0.0;
    }

    if (band == 0) fragColor = vec4(tileC, 1.0);
    else if (band == 1) fragColor = vec4(glyC, 1.0);
    else fragColor = vec4(gi / 255.0, ga, ta, 1.0);
}
