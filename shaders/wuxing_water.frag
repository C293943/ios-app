// 五行・水 (Water Element) - 流动水波纹理
// 青蓝、浅绿、白色交织的流体渐变，带有水滴涟漪粒子
// 技法：Domain Warping + FBM 噪声 → 模拟水面光影折射

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;  // 青蓝 (Cyan-blue)
uniform vec3 uColor2;  // 浅绿 (Light green)
uniform vec3 uColor3;  // 白色 (White/highlight)

out vec4 fragColor;

// --- 噪声工具函数 ---
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
  float t = uTime * 0.15;
  
  // 呼吸韵律（统一基准：周期 ~6s）
  float breath = sin(t * 1.6) * 0.5 + 0.5;
  
  // === 核心：Domain Warping（域扭曲）===
  // 两层叠入，产生水墨般的流体效果（从三层简化为两层，性能提升约 30%）
  vec2 q = vec2(
    fbm(uv * 3.0 + vec2(t * 0.4, 0.0)),
    fbm(uv * 3.0 + vec2(0.0, t * 0.3))
  );
  
  float f = fbm(uv * 3.0 + 4.0 * q + vec2(1.7, 9.2) + t * 0.12);
  
  // 水面焦散图案（smoothstep 柔化过渡）
  float caustic = smoothstep(0.15, 0.85, f);
  
  // 涟漪波纹
  float ripple = sin(length(uv - 0.5) * 15.0 - t * 3.0) * 0.5 + 0.5;
  ripple *= smoothstep(0.6, 0.0, length(uv - 0.5));
  
  // 第二层涟漪（偏移中心，增加层次）
  vec2 rippleCenter2 = vec2(0.3 + sin(t) * 0.1, 0.6 + cos(t * 0.7) * 0.1);
  float ripple2 = sin(length(uv - rippleCenter2) * 12.0 - t * 2.5) * 0.5 + 0.5;
  ripple2 *= smoothstep(0.5, 0.0, length(uv - rippleCenter2));
  
  // === 色彩混合 ===
  vec3 color = mix(uColor1, uColor2, caustic);
  color = mix(color, uColor3, ripple * 0.25 * breath);
  color = mix(color, (uColor1 + uColor2) * 0.5, ripple2 * 0.15);
  
  // 高光：水面反射
  float hl = smoothstep(0.6, 0.85, f) * breath;
  color += uColor3 * hl * 0.15;
  
  // 微妙色彩漂移（让背景更有生命感）
  color = mix(color, uColor3 * 0.9 + uColor1 * 0.1, sin(t * 0.3) * 0.04);
  
  // 柔和暗角
  float vig = 1.0 - smoothstep(0.3, 0.8, length(uv - 0.5));
  color *= 0.92 + 0.08 * vig;
  
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
