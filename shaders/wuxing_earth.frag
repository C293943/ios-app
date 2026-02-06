// 五行・土 (Earth Element) - 沉稳的块状渐变层
// 琥珀、深黄、浅褐交织的大地质感
// 技法：水平层叠 + 量化渐变 → 模拟地层沉积

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;  // 琥珀 (Amber)
uniform vec3 uColor2;  // 深黄 (Deep yellow)
uniform vec3 uColor3;  // 浅褐 (Light brown)

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * 0.08;  // 极缓慢 — 沉稳如山
  
  // 呼吸韵律（统一基准：周期 ~6s）
  float breath = sin(t * 1.6) * 0.5 + 0.5;
  
  // === 水平地层 ===
  // X方向拉伸，Y方向压缩 → 水平层叠效果
  float layers = fbm(vec2(uv.x * 2.0, uv.y * 5.0) + vec2(t * 0.1, 0.0));
  
  // 量化为块状渐变（模拟地层断面）
  float blocks = floor(layers * 6.0) / 6.0;
  blocks = mix(blocks, layers, 0.25);  // 略微柔化边缘
  
  // 沉积纹理（更水平的细节）
  float sediment = fbm(vec2(uv.x * 8.0, uv.y * 2.5) + vec2(0.0, t * 0.05));
  
  // Domain Warping 增加自然感
  vec2 warp = vec2(
    fbm(uv * 1.5 + vec2(t * 0.05, 0.0)),
    fbm(uv * 1.5 + vec2(0.0, t * 0.03))
  );
  float earthFlow = fbm(uv * 2.0 + 2.0 * warp);
  
  // 纵深渐变
  float depth = smoothstep(0.0, 1.0, uv.y);
  
  // === 色彩混合 ===
  vec3 color = mix(uColor1, uColor2, smoothstep(0.2, 0.8, blocks));
  color = mix(color, uColor3, depth * 0.35);
  
  // 沉积物纹理叠加
  color += (sediment - 0.5) * 0.04;
  
  // 自然流动混合
  color = mix(color, (uColor1 + uColor2) * 0.5, earthFlow * 0.15);
  
  // 呼吸微光
  float glow = smoothstep(0.35, 0.6, blocks) * breath;
  color = mix(color, uColor1 * 1.03, glow * 0.06);
  
  // 大地颗粒质感
  float grain = hash(uv * uSize * 0.3) * 0.012;
  color += grain;
  
  // 微妙色彩漂移（让背景更有生命感）
  color = mix(color, uColor2 * 0.7 + uColor3 * 0.3, sin(t * 0.3) * 0.03);
  
  // 柔和暗角
  float vig = 1.0 - smoothstep(0.35, 0.85, length(uv - 0.5));
  color *= 0.94 + 0.06 * vig;
  
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
