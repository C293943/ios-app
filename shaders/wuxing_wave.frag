// 五行・波纹叠层 (Wuxing Wave Overlay)
// 屏幕底部的波纹/流动效果，根据五行属性切换视觉模式：
//   0 = 水：多层正弦波叠加，高频细碎波光，带透视感
//   1 = 木：低频漂移叶影，风中摆动
//   2 = 火：垂直向上升腾的热浪
//   3 = 金：金属拉丝线性闪光 (Linear Glint)
//   4 = 土：缓慢流动的细沙颗粒
//
// Uniforms:
//   uSize    (vec2)  - 画布逻辑像素尺寸
//   uTime    (float) - 动画时间（秒）
//   uElement (float) - 五行类型 (0~4)
//   uCenter  (vec2)  - 交互中心点（归一化坐标 0~1）
//   uColor1  (vec3)  - 主色（归一化 RGB）
//   uColor2  (vec3)  - 辅色（归一化 RGB）

#include <flutter/runtime_effect.glsl>

uniform vec2  uSize;
uniform float uTime;
uniform float uElement;
uniform vec2  uCenter;
uniform vec3  uColor1;
uniform vec3  uColor2;

out vec4 fragColor;

// --- 工具函数 ---
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

// ============================================================
//  水 (Water) — 多层正弦波叠加 + 透视近大远小
// ============================================================
vec4 waterWave(vec2 uv, float t) {
  // 透视变换：底部（y=1）的波纹大，顶部（y=0）的波纹小且密
  float perspective = smoothstep(0.0, 1.0, uv.y);
  float scale = mix(0.3, 1.0, perspective);
  
  // 交互：波纹受 uCenter 影响产生偏移
  float centerInfluence = (uv.x - uCenter.x) * 0.15;
  
  // 多层正弦波叠加（高频细碎波光）
  float wave = 0.0;
  wave += sin(uv.x * 12.0 * scale + t * 2.5 + centerInfluence) * 0.25;
  wave += sin(uv.x * 18.0 * scale - t * 1.8 + 1.3) * 0.18;
  wave += sin(uv.x * 30.0 * scale + t * 3.2 + 2.7) * 0.12;
  wave += sin(uv.x * 7.0  * scale - t * 1.2 + centerInfluence * 2.0) * 0.3;
  
  // 随机偏移模拟流动（噪声调制）
  float drift = noise(vec2(uv.x * 4.0, t * 0.5)) * 0.15;
  wave += drift;
  
  // 波峰白光（水面反射）
  float crest = smoothstep(0.35, 0.65, wave * 0.5 + 0.5);
  float shimmer = pow(crest, 3.0) * perspective;
  
  // 基底色混合
  vec3 color = mix(uColor1, uColor2, uv.y * 0.6 + wave * 0.2);
  // 波光白色叠加
  color += vec3(1.0) * shimmer * 0.35;
  
  // 底部浓、顶部透明（用于叠层效果）
  float alpha = smoothstep(0.0, 0.6, uv.y) * 0.85;
  
  return vec4(color, alpha);
}

// ============================================================
//  木 (Wood) — 低频漂移叶影
// ============================================================
vec4 woodWave(vec2 uv, float t) {
  float perspective = smoothstep(0.0, 1.0, uv.y);
  
  // 低频大幅摆动
  float sway = sin(uv.x * 3.0 + t * 0.8 + (uv.x - uCenter.x) * 0.3) * 0.4;
  sway += sin(uv.x * 5.5 - t * 0.5 + 1.8) * 0.25;
  sway += sin(uv.x * 2.0 + t * 1.2) * 0.35;
  
  // 叶影噪声纹理
  float leafNoise = noise(vec2(uv.x * 6.0 + t * 0.3, uv.y * 3.0 + sway));
  float leaf = smoothstep(0.3, 0.7, leafNoise) * perspective;
  
  vec3 color = mix(uColor1, uColor2, sway * 0.3 + 0.5);
  // 叶片光斑
  color += uColor2 * leaf * 0.2;
  
  float alpha = smoothstep(0.0, 0.5, uv.y) * 0.75;
  
  return vec4(color, alpha);
}

// ============================================================
//  火 (Fire) — 垂直向上升腾的热浪
// ============================================================
vec4 fireWave(vec2 uv, float t) {
  float perspective = smoothstep(0.0, 1.0, uv.y);
  
  // 强制沿 Y 轴向上流动
  vec2 rising = vec2(uv.x, uv.y + t * 0.4);
  float centerPull = (uv.x - uCenter.x) * 0.2;
  
  // 多层升腾波纹
  float flame = 0.0;
  flame += sin(rising.y * 8.0 + uv.x * 4.0 + centerPull + t * 2.0) * 0.3;
  flame += sin(rising.y * 14.0 - uv.x * 6.0 + t * 3.5) * 0.2;
  flame += sin(rising.y * 20.0 + uv.x * 10.0 - t * 1.5) * 0.12;
  
  // 噪声湍流
  float turb = noise(vec2(uv.x * 5.0 + t, rising.y * 3.0)) * 0.25;
  flame += turb;
  
  // 火焰明暗
  float intensity = smoothstep(0.2, 0.7, flame * 0.5 + 0.5) * perspective;
  
  vec3 color = mix(uColor1, uColor2, intensity);
  // 火焰高光
  color += uColor1 * pow(intensity, 2.5) * 0.3;
  
  float alpha = smoothstep(0.0, 0.55, uv.y) * 0.8;
  
  return vec4(color, alpha);
}

// ============================================================
//  金 (Metal) — 金属拉丝闪光 (Linear Glint)
// ============================================================
vec4 metalWave(vec2 uv, float t) {
  float perspective = smoothstep(0.0, 1.0, uv.y);
  
  // 拉丝纹理：强 Y 方向拉伸
  float grain = noise(vec2(uv.x * 2.0, uv.y * 25.0 + t * 0.3));
  
  // 线性条纹
  float streaks = sin(uv.y * 60.0 + grain * 6.0 + t * 0.5) * 0.5 + 0.5;
  streaks = smoothstep(0.3, 0.7, streaks);
  
  // 扫光高光 — 模拟金属反光 pow(dot(n,l), spec)
  float lightAngle = uv.x * 3.14159 + t * 1.2 + (uv.x - uCenter.x) * 0.5;
  float nDotL = sin(lightAngle) * 0.5 + 0.5;
  float specular = pow(nDotL, 16.0);
  
  // 对角闪光
  float diagGlint = sin((uv.x + uv.y * 0.5) * 10.0 + t * 2.0) * 0.5 + 0.5;
  diagGlint = pow(diagGlint, 8.0) * 0.4;
  
  vec3 color = mix(uColor1, uColor2, streaks * 0.5);
  // 高光闪烁
  color += vec3(1.0) * specular * perspective * 0.5;
  color += uColor2 * diagGlint * perspective * 0.3;
  
  float alpha = smoothstep(0.0, 0.5, uv.y) * 0.7;
  
  return vec4(color, alpha);
}

// ============================================================
//  土 (Earth) — 缓慢流动的细沙颗粒
// ============================================================
vec4 earthWave(vec2 uv, float t) {
  float perspective = smoothstep(0.0, 1.0, uv.y);
  
  // 慢速水平漂移
  float drift = t * 0.15 + (uv.x - uCenter.x) * 0.1;
  
  // 沙纹波浪（低频宽幅）
  float sandWave = 0.0;
  sandWave += sin(uv.x * 6.0 + drift + uv.y * 2.0) * 0.35;
  sandWave += sin(uv.x * 10.0 - drift * 0.7 + 2.1) * 0.2;
  sandWave += sin(uv.x * 3.5 + drift * 1.3) * 0.3;
  
  float sandBase = smoothstep(0.3, 0.7, sandWave * 0.5 + 0.5);
  
  // 颗粒感：高频随机微小像素点
  float grainFine = hash(floor(uv * uSize * 0.4 + vec2(t * 0.5, 0.0)));
  float grainCoarse = hash(floor(uv * uSize * 0.15 + vec2(0.0, t * 0.3)));
  float grain = grainFine * 0.6 + grainCoarse * 0.4;
  // 颗粒强度随透视和位置变化
  float grainStrength = perspective * 0.08;
  
  vec3 color = mix(uColor1, uColor2, sandBase * 0.6 + uv.y * 0.3);
  // 沙粒点缀
  color += (grain - 0.5) * grainStrength;
  // 沙丘高光
  float duneHL = pow(sandBase, 2.0) * perspective * 0.12;
  color += vec3(duneHL);
  
  float alpha = smoothstep(0.0, 0.6, uv.y) * 0.75;
  
  return vec4(color, alpha);
}

// ============================================================
//  主入口：根据 uElement 分发
// ============================================================
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  // 翻转 Y 轴：让 uv.y=0 在顶部（远处），uv.y=1 在底部（近处）
  uv.y = 1.0 - uv.y;
  
  float t = uTime;
  
  // 根据五行类型选择波纹算法
  // 使用 step 而非 if/else 以保持 GPU 友好
  int elem = int(uElement + 0.5);
  
  vec4 result;
  if (elem == 1) {
    result = woodWave(uv, t);
  } else if (elem == 2) {
    result = fireWave(uv, t);
  } else if (elem == 3) {
    result = metalWave(uv, t);
  } else if (elem == 4) {
    result = earthWave(uv, t);
  } else {
    result = waterWave(uv, t);  // 默认：水
  }
  
  // 柔和暗角（从边缘向中心渐隐）
  float vig = 1.0 - smoothstep(0.4, 0.9, abs(uv.x - 0.5) * 1.5);
  result.rgb *= 0.9 + 0.1 * vig;
  
  fragColor = vec4(clamp(result.rgb, 0.0, 1.0), clamp(result.a, 0.0, 1.0));
}
