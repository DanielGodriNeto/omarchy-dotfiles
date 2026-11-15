#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 origin;
    vec2 winSize;
    vec2 cellPx;
    vec2 grid;
    float time;
    float alpha;
    vec4 tint;
    vec4 rip0;
    vec4 rip1;
    vec4 rip2;
    vec4 rip3;
};
layout(binding = 1) uniform sampler2D dataTex;
layout(binding = 2) uniform sampler2D atlasTex;

const float NG = 21.0;

float hh(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vn(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hh(i), hh(i + vec2(1, 0)), f.x), mix(hh(i + vec2(0, 1)), hh(i + vec2(1, 1)), f.x), f.y);
}
float caus(vec2 p) {
    return 1.0 - min(1.0, abs(vn(p / 46.0 + vec2(time * 0.21, -time * 0.13)) - vn(p / 39.0 + vec2(-time * 0.17, time * 0.19) + 7.0)) * 5.5);
}
// straight-alpha "over"
vec4 over(vec4 dst, vec3 c, float a) {
    float oa = a + dst.a * (1.0 - a);
    vec3 rgb = oa > 0.0 ? (c * a + dst.rgb * dst.a * (1.0 - a)) / oa : vec3(0.0);
    return vec4(rgb, oa);
}
float glyphA(float idx, vec2 f) {
    return texture(atlasTex, vec2((idx + f.x) / NG, f.y)).a;
}
// a ring of glyphs: strength and glyph for one ripple at a cell centre
void ring(vec4 r, vec2 cc, inout float s, inout float g) {
    if (r.w < 0.5) return;
    float d = length(cc - r.xy), age = r.z, fade = max(0.0, 1.0 - age / 3.6);
    float r1 = age * 120.0, r2 = r1 * 0.78;
    float a1 = (1.0 - smoothstep(0.0, 9.0, abs(d - r1))) * fade;
    float a2 = (1.0 - smoothstep(0.0, 9.0, abs(d - r2))) * fade * 0.6;
    if (a1 > s) { s = a1; g = 10.0; }
    if (a2 > s) { s = a2; g = 1.0; }
}

void main() {
    vec2 px = qt_TexCoord0 * winSize;
    float rad = 12.0;
    vec2 q = abs(px - winSize * 0.5) - (winSize * 0.5 - rad);
    float mask = clamp(0.5 - (length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - rad), 0.0, 1.0);

    vec2 w = origin + px;
    vec2 cell = floor(w / cellPx);
    vec2 f = fract(w / cellPx);
    vec2 cc = (cell + 0.5) * cellPx;
    float u = (cell.x + 0.5) / grid.x;
    float h3 = grid.y * 3.0;
    vec4 tile = texture(dataTex, vec2(u, (cell.y + 0.5) / h3));
    vec4 gcol = texture(dataTex, vec2(u, (cell.y + grid.y + 0.5) / h3));
    vec4 ctrl = texture(dataTex, vec2(u, (cell.y + 2.0 * grid.y + 0.5) / h3));
    float gi = floor(ctrl.r * 255.0 + 0.5), ga = ctrl.g, ta = ctrl.b;

    vec3 deep = tint.rgb * vec3(0.16, 0.26, 0.3);
    vec4 outc = vec4(deep, 0.74);

    float cs = caus(cc);
    // water: a thin moving net of glyphs where the two noise fields meet
    if (ta < 0.05 && gi < 0.5 && cs > 0.72) {
        float g = cs > 0.9 ? 18.0 : (cs > 0.8 ? 3.0 : 19.0);
        outc = over(outc, tint.rgb, glyphA(g, f) * (cs - 0.72) * 1.2);
    }
    // ripples
    float rs = 0.0, rg = 0.0;
    ring(rip0, cc, rs, rg); ring(rip1, cc, rs, rg); ring(rip2, cc, rs, rg); ring(rip3, cc, rs, rg);
    if (rs > 0.05) outc = over(outc, tint.rgb * 1.3 + 0.1, glyphA(rg, f) * rs);
    // koi: tile, then glyph
    if (ta > 0.003) outc = over(outc, tile.rgb, ta);
    if (gi > 0.5) outc = over(outc, gcol.rgb, glyphA(gi, f) * ga);

    float a = outc.a * alpha * mask;
    fragColor = vec4(outc.rgb * a, a) * qt_Opacity;
}
