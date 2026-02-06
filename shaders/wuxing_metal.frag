// 五行・金 (Metal Element) - 金属质感的线性闪光
// 金黄、纯白、银灰交织的精密光泽
// 技法：各向异性噪声 + 扫光效果 → 模拟金属反射

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;  // 金黄 (Golden)
uniform vec3 uColor2;  // 纯白 (Pure white)
uniform vec3 uColor3;  // 银灰 (Silver gray)

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
  float t = uTime * 0.1;
  
  // 呼吸韵律（统一基准：周期 ~6s）
  float breath = sin(t * 1.6) * 0.5 + 0.5;
  
  // === 各向异性噪声（金属拉丝纹理）===
  // Y方向大幅拉伸 → 产生线性金属纹理
  float metalGrain = fbm(vec2(uv.x * 1.5, uv.y * 12.0) + vec2(t * 0.3, 0.0));
  
  // 线性条纹
  float streaks = sin(uv.y * 40.0 + metalGrain * 8.0 + t) * 0.5 + 0.5;
  streaks = smoothstep(0.3, 0.7, streaks);
  
  // 第二层细纹（更精密的金属质感）
  float fineStreaks = sin(uv.y * 120.0 + metalGrain * 4.0 - t * 0.5) * 0.5 + 0.5;
  fineStreaks = smoothstep(0.4, 0.6, fineStreaks) * 0.3;
  
  // === 扫光效果 ===
  // 缓慢横扫的高光
  float sweep = sin(uv.x * 3.14159 + t * 1.5) * 0.5 + 0.5;
  float sharpFlash = pow(sweep, 6.0);
  
  // 对角线扫光（增加动态感）
  float diagSweep = sin((uv.x + uv.y) * 2.0 + t * 0.8) * 0.5 + 0.5;
  diagSweep = pow(diagSweep, 4.0) * 0.5;
  
  // 金属反射光晕
  float reflection = fbm(uv * 3.0 + vec2(t * 0.15, t * 0.1));
  float sheen = smoothstep(0.5, 0.7, reflection) * breath;
  
  // === 色彩混合 ===
  vec3 color = mix(uColor1, uColor3, smoothstep(0.2, 0.8, streaks * 0.6 + fineStreaks));
  color = mix(color, uColor2, sharpFlash * 0.25 * breath);
  color += uColor2 * pow(sharpFlash, 3.0) * breath * 0.15;
  color = mix(color, uColor2, diagSweep * 0.12 * breath);
  
  // 金属光泽
  color = mix(color, uColor2 * 0.95 + uColor1 * 0.05, sheen * 0.12);
  
  // 微妙的金属颗粒感
  float grain = hash(uv * uSize * 0.5) * 0.015;
  color += grain;
  
  // 微妙色彩漂移（让背景更有生命感）
  color = mix(color, uColor1 * 0.7 + uColor2 * 0.3, sin(t * 0.3) * 0.03);
  
  // 柔和暗角（与其他 shader 保持一致）
  float vig = 1.0 - smoothstep(0.3, 0.8, length(uv - 0.5));
  color *= 0.92 + 0.08 * vig;
  
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
