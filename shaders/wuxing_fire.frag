// 五行・火 (Fire Element) - 向上升腾的虚化光斑
// 朱红、橙黄、淡紫色交织的热浪流体
// 技法：上升噪声 + 浮动光球 → 模拟灵火升腾

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;  // 朱红 (Vermillion)
uniform vec3 uColor2;  // 橙黄 (Orange-yellow)
uniform vec3 uColor3;  // 淡紫 (Light purple)

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
  float t = uTime * 0.2;
  
  // 呼吸韵律（统一基准：周期 ~6s）
  float breath = sin(t * 1.6) * 0.5 + 0.5;
  
  // === 升腾运动 ===
  vec2 rising = uv + vec2(0.0, -t * 0.3);
  
  // 火焰湍流 (Domain Warping)
  vec2 q = vec2(
    fbm(rising * 3.5 + vec2(t * 0.5, 0.0)),
    fbm(rising * 3.5 + vec2(0.0, t * 0.3))
  );
  float turb = fbm(rising * 4.0 + 3.0 * q);
  
  // 火焰形态：底部浓 → 顶部淡
  float flameShape = smoothstep(1.0, 0.15, uv.y);
  float flame = turb * flameShape;
  
  // === 浮动光球（升腾的灵火粒子）===
  float orbs = 0.0;
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    vec2 orbPos = vec2(
      0.12 + 0.76 * hash(vec2(fi * 1.23, 0.45)),
      fract(0.15 * fi - t * 0.06 * (1.0 + 0.3 * fi))
    );
    // 轻微水平漂移
    orbPos.x += sin(t * 1.5 + fi * 2.0) * 0.03;
    float d = length(uv - orbPos);
    float glow = smoothstep(0.1, 0.0, d) * (0.2 + 0.12 * sin(t * 2.5 + fi * 3.0));
    orbs += glow;
  }
  
  // === 色彩混合 ===
  // 基础渐变：底部暖色 → 顶部冷紫
  vec3 color = mix(uColor1, uColor2, uv.y * 0.7 + flame * 0.3);
  color = mix(color, uColor3, smoothstep(0.35, 0.85, uv.y) * 0.35);
  
  // 光球发光
  color += uColor2 * orbs * breath * 0.55;
  
  // 火焰高光
  float flameHL = smoothstep(0.4, 0.65, flame) * (1.0 - uv.y) * breath;
  color += uColor1 * flameHL * 0.1;
  
  // 热浪波动（降低频率，避免摩尔纹；用噪声调制替代硬正弦）
  float hazeNoise = noise(uv * 6.0 + vec2(t * 2.0, t * 1.5));
  float haze = hazeNoise * smoothstep(0.8, 0.3, uv.y) * 0.035;
  color += vec3(haze) * uColor2;
  
  // 微妙色彩漂移（让背景更有生命感）
  color = mix(color, uColor3 * 0.8 + uColor1 * 0.2, sin(t * 0.25) * 0.03);
  
  // 柔和暗角（与其他 shader 保持一致）
  float vig = 1.0 - smoothstep(0.3, 0.8, length(uv - 0.5));
  color *= 0.92 + 0.08 * vig;
  
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
