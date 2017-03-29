// Prewitt
const int PGx[9] = int[](-1, -1, -1, 0, 0, 0, 1, 1, 1);
const int PGy[9] = int[](-1, 0, 1, -1, 0, 1, -1, 0, 1);
// Sobel
const int SGx[9] = int[](-1, -2, -1, 0, 0, 0, 1, 2, 1);
const int SGy[9] = int[](-1, 0, 1, -2, 0, 2, -1, 0, 1);
const vec2 vUV[9] = vec2[](
    vec2(-1.0, -1.0), vec2(0.0, -1.0), vec2(1.0, -1.0),
    vec2(-1.0, 0.0), vec2(0.0, 0.0), vec2(1.0, 0.0),
    vec2(-1.0, 1.0), vec2(0.0, 1.0), vec2(1.0, 1.0));
float x;

vec4 line(vec2 uv) {
    float d = abs(uv.x - x / iResolution.x);
    return vec4(0.0, 0.0, 0.0, d < 0.003 ? 1.0 : 0.0);
}

float luminance(vec4 color) {
    return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
}

float sobel(vec2 fragCoord, sampler2D mainTex) {
    float texColor = 0.0;
    float edgeX = 0.0;
    float edgeY = 0.0;
    for (int i = 0; i < 9; ++i) {
        texColor = luminance(texture(mainTex, (fragCoord + vUV[i]) / iResolution.xy));
        if (fragCoord.x < iMouse.x) {
            edgeX += float(PGx[i]) * texColor;
            edgeY += float(PGy[i]) * texColor;        
        } else {
            edgeX += float(SGx[i]) * texColor;
            edgeY += float(SGy[i]) * texColor;                
        }
    }
    return 1.0 - abs(edgeX) - abs(edgeY);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 edgeCol = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 bgCol = vec4(0.3, 0.3, 0.3, 1.0);
    x = iMouse.z > 0.0 ? iMouse.x : iResolution.x / 2.0; 
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    float edge = sobel(fragCoord, iChannel0);
    vec4 withEdgeCol = mix(edgeCol, texture(iChannel0, uv), edge);
    vec4 onlyEdgeCol = mix(edgeCol, bgCol, edge);
    fragColor = mix(withEdgeCol, onlyEdgeCol, 0.5);
    
    vec4 l = line(uv);
    fragColor = mix(fragColor, l, l.a);
}