// ============================================================================
// 玄虚幽冥 · 仙侠深渊背景 (Mystic Void — Xianxia Abyss Background)
// ============================================================================
//
// 一个沉浸式的玄幻/仙侠/玄学主题全屏背景：
//   [1] 深渊星空 — 多层噪声星云 + 散落星辰 + 呼吸脉动
//   [2] 灵力气韵 — 3D FBM Domain Warping → 丝绸般的灵力流线
//   [3] 符文光阵 — 极坐标旋转法阵 + 六芒/八卦几何线
//   [4] 灵力粒子 — 向上飘散的灵力光点
//   [5] 边缘神光 — 从四周向中心射入的幽冥光柱
//
// 颜色系统:
//   uColor1: 深渊底色 (深青黑 / 玄色)
//   uColor2: 灵力主色 (灵气青 / 翡翠绿)
//   uColor3: 高光辅色 (鎏金 / 紫光)
//
// Uniforms 布局:
//   [0,1]      vec2  uSize
//   [2]        float uTime
//   [3,4,5]    vec3  uColor1   深渊底色
//   [6,7,8]    vec3  uColor2   灵力主色
//   [9,10,11]  vec3  uColor3   高光辅色
// ============================================================================

#include <flutter/runtime_effect.glsl>

uniform vec2  uSize;
uniform float uTime;
uniform vec3  uColor1;   // 深渊底色
uniform vec3  uColor2;   // 灵力主色
uniform vec3  uColor3;   // 高光辅色

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

// =============================================
// § 噪声系统
// =============================================

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash3(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float noise2(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

float noise3(vec3 p) {
  vec3 i = floor(p);
  vec3 f = fract(p);
  vec3 u = f * f * (3.0 - 2.0 * f);
  float n000 = hash3(i);
  float n100 = hash3(i + vec3(1, 0, 0));
  float n010 = hash3(i + vec3(0, 1, 0));
  float n110 = hash3(i + vec3(1, 1, 0));
  float n001 = hash3(i + vec3(0, 0, 1));
  float n101 = hash3(i + vec3(1, 0, 1));
  float n011 = hash3(i + vec3(0, 1, 1));
  float n111 = hash3(i + vec3(1, 1, 1));
  return mix(
    mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
    mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
    u.z
  );
}

float fbm2(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise2(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

float fbm3(vec3 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise3(p);
    p = p * 2.01 + vec3(1.6, 1.2, 0.8);
    a *= 0.5;
  }
  return v;
}

vec2 rot(vec2 p, float a) {
  float c = cos(a), s = sin(a);
  return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

// =============================================
// § 1  深渊星空 (Abyss Starfield)
// =============================================
// 多层噪声星云 + 散落星辰 → 玄虚深邃

vec3 abyssStarfield(vec2 uv, float t) {
  // --- 深渊底色: 从中心到边缘的径向暗色渐变 ---
  float vignette = length(uv - 0.5) * 1.4;
  float depthGrad = smoothstep(0.0, 1.0, uv.y * 0.6 + 0.2);

  // 底色: 深不见底的玄色
  vec3 abyss = uColor1 * (0.6 + 0.4 * depthGrad);
  abyss *= 1.0 - vignette * 0.5;  // 边缘更暗

  // --- 星云 (Nebula) ---
  // 两级 domain warp 产生深空星云纹理
  vec2 nUV = uv * 2.5;
  vec2 q = vec2(
    fbm2(nUV + vec2(t * 0.04, 0.0)),
    fbm2(nUV + vec2(0.0, t * 0.03) + 5.2)
  );
  float nebula = fbm2(nUV + 3.5 * q + vec2(t * 0.02));

  // 星云颜色: 灵力色 + 辅色 交织
  vec3 nebColor = mix(uColor2 * 0.3, uColor3 * 0.25, smoothstep(0.35, 0.65, nebula));
  // 星云强度: 中远处密集，中心留空给角色
  float nebulaIntensity = smoothstep(0.15, 0.55, vignette) * 0.5;
  abyss += nebColor * nebula * nebulaIntensity;

  // --- 散落星辰 (无马赛克: 用连续距离场代替 floor 网格) ---
  // Layer 1: 细碎远星 — 在连续噪声空间中提取亮点
  float starField1 = noise2(uv * 120.0);       // 高频噪声
  float starField1b = noise2(uv * 120.0 + 7.3); // 第二层偏移
  float starMask1 = starField1 * starField1b;    // 相乘→只有双层都亮才出星
  float star1 = smoothstep(0.75, 0.82, starMask1);
  // 闪烁: 用连续坐标做相位
  float twinkle1 = sin(t * 2.0 + starField1 * TAU * 3.0) * 0.5 + 0.5;
  star1 *= 0.5 + 0.5 * twinkle1;
  abyss += vec3(star1) * 0.5;

  // Layer 2: 稀疏亮星 (更大、带柔和光晕)
  float starField2 = noise2(uv * 45.0 + 33.3);
  float starField2b = noise2(uv * 45.0 + 88.8);
  float starMask2 = starField2 * starField2b;
  float star2 = smoothstep(0.78, 0.85, starMask2);
  // 柔和光晕: 用 pow 扩展亮区
  star2 = pow(star2, 0.6) * 0.8;
  float twinkle2 = sin(t * 1.2 + starField2 * TAU * 2.0) * 0.5 + 0.5;
  star2 *= 0.6 + 0.4 * twinkle2;
  // 亮星带灵力色
  vec3 brightStarColor = mix(uColor2, uColor3, starField2);
  abyss += brightStarColor * star2 * 0.6;

  return abyss;
}

// =============================================
// § 2  灵力气韵 (Spirit Qi Flow)
// =============================================
// 3D FBM Domain Warping → 丝绸般的灵力流线
// 从屏幕四周流向中心，呼吸脉动

vec3 spiritQiFlow(vec2 uv, float t) {
  // 中心化
  vec2 p = uv - 0.5;
  float aspect = uSize.x / uSize.y;
  p.x *= aspect;
  float r = length(p);
  float theta = atan(p.y, p.x);

  // 3D 空间映射
  vec3 sp = vec3(
    theta / TAU * 4.0,
    r * 3.0,
    t * 0.15
  );

  // 三级 domain warp (丝绸质感)
  vec3 w1 = vec3(
    fbm3(sp + vec3(t * 0.1, 0.0, 0.0)),
    fbm3(sp + vec3(0.0, t * 0.08, 3.7)),
    fbm3(sp + vec3(5.2, 0.0, t * 0.06))
  );
  vec3 w2 = vec3(
    fbm3(sp + 2.5 * w1 + vec3(1.7, 9.2, 0.0)),
    fbm3(sp + 2.5 * w1 + vec3(8.3, 2.8, 4.1)),
    fbm3(sp + 2.5 * w1 + vec3(0.0, 3.4, 7.7))
  );
  float flow = fbm3(sp + 2.0 * w2);

  // 灵力流线: 提取高亮区域形成「脉络」
  float vein = smoothstep(0.42, 0.58, flow);
  float veinHL = smoothstep(0.55, 0.68, flow);

  // 颜色: 灵力主色为底，高光处偏辅色
  vec3 qiColor = mix(uColor2 * 0.5, uColor3 * 0.6, veinHL);

  // 强度: 中心弱(留给角色) + 边缘强
  float qiMask = smoothstep(0.05, 0.3, r) * smoothstep(0.85, 0.45, r);
  // 呼吸脉动
  float breath = sin(t * 0.6) * 0.5 + 0.5;
  qiMask *= 0.6 + 0.4 * breath;

  return qiColor * vein * qiMask * 0.6;
}

// =============================================
// § 3  符文光阵 (Rune Array)
// =============================================
// 极坐标旋转法阵 + 多边形几何线 → 玄学仪式感

float runeArray(vec2 uv, float t) {
  vec2 p = uv - 0.5;
  float aspect = uSize.x / uSize.y;
  p.x *= aspect;
  float r = length(p);
  float theta = atan(p.y, p.x);

  // 慢速旋转
  float rotation = t * 0.08;
  float rotTheta = theta - rotation;

  // 屏幕空间自适应线宽 (px → UV 空间)
  // 保证在任何分辨率下线条都是 ~1.5px 宽，不会产生锯齿
  float px = 1.5 / min(uSize.x, uSize.y);

  float rune = 0.0;

  // --- 外层法阵环 (八卦) ---
  float outerR = 0.42;
  float outerDist = abs(r - outerR);
  float outerRing = smoothstep(px * 2.0, px * 0.3, outerDist);
  // 呼吸脉动
  float pulse = 0.6 + 0.4 * sin(t * 0.5);
  outerRing *= pulse;

  // 八等分刻度线
  float ticks = abs(sin(rotTheta * 4.0));
  ticks = smoothstep(0.96, 1.0, ticks);
  float tickLine = ticks * smoothstep(outerR + 0.04, outerR, r) * smoothstep(outerR - 0.06, outerR, r);

  rune += outerRing * 0.35 + tickLine * 0.2;

  // --- 内层法阵环 ---
  float innerR = 0.28;
  float innerDist = abs(r - innerR);
  float innerRing = smoothstep(px * 1.8, px * 0.3, innerDist) * pulse * 0.6;
  rune += innerRing * 0.3;

  // --- 六芒星 (Hexagram / 六爻) ---
  float hex1 = 0.0;
  float hex2 = 0.0;
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float a1 = rotTheta + fi * TAU / 3.0;
    float a2 = rotTheta + fi * TAU / 3.0 + PI / 3.0;

    // 每条边: 距离线段的距离 (使用自适应线宽)
    float line1 = abs(sin(a1) * p.x - cos(a1) * p.y);
    hex1 += smoothstep(px * 2.0, px * 0.2, line1) * smoothstep(innerR + 0.02, innerR - 0.08, r);

    float line2 = abs(sin(a2) * p.x - cos(a2) * p.y);
    hex2 += smoothstep(px * 2.0, px * 0.2, line2) * smoothstep(innerR + 0.02, innerR - 0.08, r);
  }
  rune += (hex1 + hex2) * 0.15 * pulse;

  // --- 中心小圆 ---
  float centerDot = smoothstep(0.03, 0.02, r);
  rune += centerDot * 0.3 * pulse;

  // 整体范围限制 + 淡入淡出
  rune *= smoothstep(0.55, 0.45, r);

  return rune;
}

// =============================================
// § 4  灵力粒子 (Spirit Particles)
// =============================================
// 向上飘散的灵力光点

float spiritParticles(vec2 uv, float t) {
  float particles = 0.0;
  // 宽高比校正: 让粒子光晕为圆形
  float aspect = uSize.x / uSize.y;

  for (int i = 0; i < 12; i++) {
    float fi = float(i);
    float seed = hash(vec2(fi * 1.23, fi * 0.87 + 3.14));

    // 位置: 随机分布 + 缓慢上升
    vec2 pPos = vec2(
      0.08 + 0.84 * hash(vec2(fi * 2.34, 0.56)),
      fract(seed - t * 0.03 * (0.8 + seed * 0.4))  // 循环上升
    );

    // 水平微漂移
    pPos.x += sin(t * 0.8 + fi * 2.1) * 0.02;

    // 宽高比校正的距离
    vec2 delta = uv - pPos;
    delta.x *= aspect;
    float d = length(delta);

    // 纯高斯衰减 (无硬边, 无马赛克)
    float coreGlow = exp(-d * d * 8000.0);   // 紧凑核心
    float softGlow = exp(-d * 50.0) * 0.35;  // 柔和外晕

    // 闪烁
    float flicker = sin(t * 2.5 + fi * 3.7) * 0.5 + 0.5;
    particles += (coreGlow + softGlow) * (0.5 + 0.5 * flicker);
  }

  return particles;
}

// =============================================
// § 5  边缘神光 (Edge Divine Light)
// =============================================
// 从屏幕四角射入的幽冥光柱

vec3 edgeDivineLight(vec2 uv, float t) {
  vec2 p = uv - 0.5;
  float aspect = uSize.x / uSize.y;
  p.x *= aspect;
  float r = length(p);
  float theta = atan(p.y, p.x);

  vec3 divineLight = vec3(0.0);

  // 4 条对角光柱
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float beamAngle = fi * PI * 0.5 + PI * 0.25; // 四角: 45°, 135°, 225°, 315°
    // 缓慢摆动
    beamAngle += sin(t * 0.2 + fi * 1.5) * 0.08;

    float aDiff = abs(theta - beamAngle);
    aDiff = min(aDiff, TAU - aDiff);

    // 光柱宽度 + 衰减
    float beam = exp(-aDiff * aDiff * 80.0);
    beam *= smoothstep(0.2, 0.5, r); // 中心处不可见
    beam *= 0.12;

    // 光柱颜色: 交替灵力色和辅色
    vec3 beamColor = (mod(fi, 2.0) < 0.5) ? uColor2 : uColor3;
    divineLight += beamColor * beam;
  }

  return divineLight;
}

// =============================================
// § 主入口
// =============================================

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  float t = uTime;

  // =============================================
  // 合成所有图层
  // =============================================

  // Layer 1: 深渊星空
  vec3 color = abyssStarfield(uv, t);

  // Layer 2: 灵力气韵流线
  color += spiritQiFlow(uv, t);

  // Layer 3: 符文光阵
  float rune = runeArray(uv, t);
  // 符文颜色: 灵力主色为主，高光处偏辅色
  vec3 runeColor = mix(uColor2 * 0.7, uColor3 * 0.5, rune);
  color += runeColor * rune;

  // Layer 4: 灵力粒子
  float particles = spiritParticles(uv, t);
  vec3 particleColor = mix(uColor2, uColor3, 0.3);
  color += particleColor * particles * 0.5;

  // Layer 5: 边缘神光
  color += edgeDivineLight(uv, t);

  // =============================================
  // 后处理
  // =============================================

  // 整体暗角加深 (强化深邃感)
  float vig = 1.0 - smoothstep(0.2, 0.9, length(uv - 0.5) * 1.5);
  color *= 0.75 + 0.25 * vig;

  // 色彩氛围: 全局微弱的冷色偏移 (增强神秘感)
  color = mix(color, color * vec3(0.85, 0.95, 1.1), 0.15);

  // Dither 消除色带 (加强: 1.5 bit 随机扰动)
  float dither = (hash(fragCoord + vec2(fract(t * 60.0) * 100.0)) - 0.5) * (1.5 / 255.0);
  color += dither;

  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
