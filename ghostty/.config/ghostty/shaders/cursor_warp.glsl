vec4 TRAIL_COLOR = iCurrentCursorColor;
const float DURATION = 0.2;
const float TRAIL_SIZE = 0.8;
const float THRESHOLD_MIN_DISTANCE = 1.5;
const float BLUR = 1.0;
const float TRAIL_THICKNESS = 1.0;
const float TRAIL_THICKNESS_X = 0.9;
const float FADE_ENABLED = 0.0;
const float FADE_EXPONENT = 5.0;

const vec2 TL = vec2(-1, 1), TR = vec2(1, 1), BL = vec2(-1, -1), BR = vec2(1, -1);

float ease(float x) { return sqrt(x * (2.0 - x)); }

float sdfBox(vec2 p, vec2 c, vec2 h) {
    vec2 d = abs(p - c) - h;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float segSdf(vec2 p, vec2 a, vec2 b, inout float s, float d) {
    vec2 e = b - a, w = p - a;
    float t = clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    d = min(d, dot(w - e * t, w - e * t));
    bvec3 c = bvec3(p.y >= a.y, p.y < b.y, e.x * w.y < e.y * w.x);
    s *= (all(c) || !any(c)) ? -1.0 : 1.0;
    return d;
}

float sdfQuad(vec2 p, vec2 a, vec2 b, vec2 c, vec2 d) {
    float s = 1.0, dist = dot(p - a, p - a);
    dist = segSdf(p, a, b, s, dist); dist = segSdf(p, b, c, s, dist);
    dist = segSdf(p, c, d, s, dist); dist = segSdf(p, d, a, s, dist);
    return s * sqrt(dist);
}

float dur(float a) {
    float lead = DURATION * (1.0 - TRAIL_SIZE), side = (lead + DURATION) * 0.5;
    return a > 0.5 ? lead : (a > -0.5 ? side : DURATION);
}

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
    #endif

    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec4 cur = vec4((iCurrentCursor.xy * 2.0 - iResolution.xy) / iResolution.y,
                    iCurrentCursor.zw * 2.0 / iResolution.y);
    vec4 prev = vec4((iPreviousCursor.xy * 2.0 - iResolution.xy) / iResolution.y,
                     iPreviousCursor.zw * 2.0 / iResolution.y);

    vec2 curCtr = cur.xy + cur.zw * vec2(0.5, -0.5);
    vec2 prevCtr = prev.xy + prev.zw * vec2(0.5, -0.5);
    float t = iTime - iTimeCursorChange;
    vec4 col = fragColor;

    if (distance(curCtr, prevCtr) > cur.w * THRESHOLD_MIN_DISTANCE && t < DURATION) {
        vec2 thk = vec2(TRAIL_THICKNESS_X, TRAIL_THICKNESS);
        vec2 curH = cur.zw * 0.5 * thk, prevH = prev.zw * 0.5 * thk;
        vec2 dir = sign(curCtr - prevCtr);

        vec4 a = vec4(dot(TL, dir), dot(TR, dir), dot(BL, dir), dot(BR, dir));
        vec4 d = vec4(dur(a.x), dur(a.y), dur(a.z), dur(a.w));
        d.xz = mix(d.xz, vec2(dur((a.x + a.z) * 0.5)), step(0.5, -dir.x));
        d.yw = mix(d.yw, vec2(dur((a.y + a.w) * 0.5)), step(0.5, dir.x));

        vec4 p = clamp(vec4(t) / d, 0.0, 1.0);
        p = sqrt(p * (2.0 - p));

        vec2 tl = mix(prevCtr + prevH * TL, curCtr + curH * TL, p.x);
        vec2 tr = mix(prevCtr + prevH * TR, curCtr + curH * TR, p.y);
        vec2 bl = mix(prevCtr + prevH * BL, curCtr + curH * BL, p.z);
        vec2 br = mix(prevCtr + prevH * BR, curCtr + curH * BR, p.w);

        float sdf = sdfQuad(uv, tl, tr, br, bl);
        float alpha = TRAIL_COLOR.a * (1.0 - smoothstep(0.0, BLUR * 2.0 / iResolution.y, sdf));

        if (FADE_ENABLED > 0.5) {
            vec2 m = curCtr - prevCtr;
            alpha *= pow(clamp(dot(uv - prevCtr, m) / (dot(m, m) + 1e-6), 0.0, 1.0), FADE_EXPONENT);
        }

        col = mix(col, vec4(TRAIL_COLOR.rgb, col.a), alpha);
        col = mix(col, fragColor, step(sdfBox(uv, curCtr, cur.zw * 0.5), 0.0));
    }

    fragColor = col;
}
