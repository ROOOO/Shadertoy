#define EARSSIZE 0.25
#define NOSESIZE 0.05
#define MOUSTACHELENGTH 0.3
#define ANTIALIAS 0.01
#define PI 3.141592654

vec2 scale(vec2 v, vec2 s) {
    return mat2(s.x, 0, 0, s.y) * v;
}

vec2 rot(vec2 v, float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * v;
}

vec2 animate(vec2 uv) {
    float tt = mod(iGlobalTime, 1.5) / 1.5;  
    float ss = pow(tt, 0.2) * 0.5 + 0.5;  
    ss = 1.0 + ss*0.5*sin(tt * PI * 2.0 * 3.0 + uv.y*0.5)*exp(-tt*4.0); 
    uv *= vec2(0.5,1.2) + ss * vec2(0.5,-0.2); 
    return uv;
}

vec4 heart(vec2 uv, vec2 center) {
    vec2 p = uv - center;
    float a = atan(p.x, p.y) / PI;
    float r = length(p) / EARSSIZE;
    float h = abs(a);
    float d = (13.0 * h - 22.0 * h * h + 10.0 * h * h * h) / (6.0 - 5.0 * h);
    float t = smoothstep(-ANTIALIAS, ANTIALIAS, r - d);
    return vec4(0.8, 0.3, 0.4, 1.0 - t);
}

vec4 ear(vec2 uv, vec2 center) {
    float d1 = length(uv - center) - EARSSIZE;
    float t1 = smoothstep(0.0, ANTIALIAS, d1);
    float r = 4.5 * EARSSIZE;
    float d2 = length(uv - vec2(center.x, center.y - r)) - 4.0 * EARSSIZE;
    float t2 = smoothstep(0.0, ANTIALIAS, d2);
    return vec4(0.3, 0.3, 0.3, d2 > 0.0 ? (1.0 - t1) : t2);
}

vec4 nose(vec2 uv, vec2 center) {
    float d = length(uv - center);
    float t = smoothstep(NOSESIZE, NOSESIZE + ANTIALIAS, d);
    return vec4(0.0, .0, .0, 1.0 - t);
}

vec4 moustache(vec2 uv, vec2 p) {
    uv.x = abs(uv.x);
    float r = length(uv - p);
    vec2 m = vec2(uv.x, sin(uv.x / MOUSTACHELENGTH * 2.0 * PI - iGlobalTime * 5.) * r);
    m.y /= 5.0;
    float d = length(uv - m);
    float t = smoothstep(0.01, 0.01 + ANTIALIAS, d);
    t = uv.x < p.x || uv.x > p.x + MOUSTACHELENGTH ? 1.0 : t;
    return vec4(1.0, 1.0, 1.0, 1.0 - t);
}

vec4 mulNoise(vec4 col, float f) {
    vec3 c = col.rgb * f;
    return vec4(c, col.a);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (2.0 * fragCoord.xy - iResolution.xy) / min(iResolution.x, iResolution.y);
    uv.y += 0.25;
      
    vec4 bgCol = vec4(0.7, 0.6, 0.5, 1.0);
    
    vec4 nCol = nose(uv, vec2(0.0, 0.0));
    
    vec2 m1UV = rot(uv, 30.0 / 180.0);
    vec4 m1Col = moustache(m1UV, vec2(MOUSTACHELENGTH, 0.0));
    vec2 m2UV = rot(uv, -30.0 / 180.0);
    vec4 m2Col = moustache(m2UV, vec2(MOUSTACHELENGTH, 0.0));
    
    vec2 e1UV = rot(uv, -PI / 5.0);
    e1UV = scale(e1UV, vec2(1.0, 1.1));
    vec2 e2UV = rot(uv, PI / 5.0);
    e2UV = scale(e2UV, vec2(1.0, 1.1));

    e1UV = animate(e1UV);
    e2UV = animate(e2UV);
    
    vec4 e1Col = ear(e1UV, vec2(0.0, 0.8));
    vec4 e1hCol = heart(e1UV, vec2(0.0, 0.93));
    vec4 e2Col = ear(e2UV, vec2(0.0, 0.8));
    vec4 e2hCol = heart(e2UV, vec2(0.0, 0.93));
    
    vec4 col = bgCol;
    col = mix(col, nCol, nCol.a);
    col = mix(col, m1Col, m1Col.a);
    col = mix(col, m2Col, m2Col.a);
    col = mix(col, e1Col, e1Col.a);
    col = mix(col, e1hCol, e1hCol.a);
    col = mix(col, e2Col, e2Col.a);
    col = mix(col, e2hCol, e2hCol.a);

    fragColor = col;
}