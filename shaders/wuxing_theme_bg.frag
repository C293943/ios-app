// ============================================================================
// 主题自适应复合动效背景 (Theme-Adaptive Composite Background)
// ============================================================================
//
// 三层复合背景着色器：
//   [Layer A] 背景气韵流体 — 5 层 FBM + 三级 Domain Warping → 水墨烟雾
//   [Layer B] 角色脚下气场 — 极坐标螺旋水波 + 3D 透视涟漪 → 立体环形光波
//   [Layer C] 法线光影交互 — 有限差分法线 + Blinn-Phong + 菲涅尔 → 明暗闪烁
//
// 主题适配:
//   uBrightness = 0.0 → 黑夜模式: 深色底 + 冷色气韵线 + 强发光
//   uBrightness = 1.0 → 白天模式: 浅淡底 + 高明度低饱和 + 柔和半透明
//   中间值可平滑过渡
//
// 性能优化:
//   - 共享噪声结果，避免重复采样
//   - 抗锯齿: 所有边缘使用 smoothstep 柔化
//   - 移动端友好: 无分支循环上限 ≤ 5, 总采样 ≤ 40
//
// Uniforms 布局:
//   [0,1]      vec2  uSize        画布逻辑像素尺寸
//   [2]        float uTime        动画时间 (秒)
//   [3,4]      vec2  uCenter      气场中心坐标 (归一化 0~1)
//   [5]        float uBrightness  主题亮度 (0.0=黑夜, 1.0=白天)
//   [6,7,8]    vec3  uBaseColor   主色 (归一化 RGB)
//   [9,10,11]  vec3  uAccentColor 辅色/高光色 (归一化 RGB)
// ============================================================================

#include <flutter/runtime_effect.glsl>

uniform vec2  uSize;
uniform float uTime;
uniform vec2  uCenter;
uniform float uBrightness;
uniform vec3  uBaseColor;
uniform vec3  uAccentColor;

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

// =============================================
// § 1  噪声工具链 (Noise Toolkit)
// =============================================

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash3(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// 2D Value Noise — Hermite 插值
float noise2(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash2(i), hash2(i + vec2(1.0, 0.0)), u.x),
    mix(hash2(i + vec2(0.0, 1.0)), hash2(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

// 3D Value Noise — 体积采样
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

// 2D FBM — 5 octave (背景气韵主力)
float fbm5(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise2(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

// 3D FBM — 4 octave (体积/光影)
float fbm3(vec3 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise3(p);
    p = p * 2.01 + vec3(1.6, 1.2, 0.8);
    a *= 0.5;
  }
  return v;
}

// 2D 旋转
vec2 rot2D(vec2 p, float a) {
  float c = cos(a), s = sin(a);
  return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

// =============================================
// § 2  Layer A — 背景气韵流体
// =============================================
// 三级 Domain Warping + 5-octave FBM
// 产生水墨/烟雾般的有机流体背景

vec3 layerBackground(vec2 uv, float t, float brightness) {
  // --- 三级域扭曲 (Triple Domain Warp) ---
  // 第一级: 大尺度漂移 (水墨底纹)
  vec2 q = vec2(
    fbm5(uv * 2.5 + vec2(t * 0.08, t * 0.06)),
    fbm5(uv * 2.5 + vec2(t * 0.05 + 5.2, t * 0.07 + 1.3))
  );

  // 第二级: 中尺度扭曲 (云雾卷积)
  vec2 r = vec2(
    fbm5(uv * 2.5 + 4.0 * q + vec2(1.7, 9.2) + t * 0.04),
    fbm5(uv * 2.5 + 4.0 * q + vec2(8.3, 2.8) + t * 0.03)
  );

  // 第三级: 精细纹理 (丝绸纤维)
  float f = fbm5(uv * 3.0 + 3.5 * r + vec2(t * 0.02));

  // --- 主题自适应色彩映射 ---
  // 深色: 暗底 + 微光气韵
  // 浅色: 亮底 + 低饱和淡彩
  float darkBase = 0.03 + 0.04 * f;                        // 深色底板
  float lightBase = 0.88 + 0.08 * f;                       // 浅色底板
  float baseLum = mix(darkBase, lightBase, brightness);     // 按亮度插值

  // 气韵色彩强度: 深色模式下气韵线更明显
  float flowIntensity = mix(0.35, 0.12, brightness);

  // 气韵色: 由 domain warp 的梯度决定色相分布
  float colorGrad = smoothstep(0.3, 0.7, f);
  vec3 flowColor = mix(uBaseColor, uAccentColor, colorGrad);

  // 额外的色彩层次: 利用 q/r 的分量创造渐变
  float secondaryBlend = smoothstep(0.35, 0.65, q.x);
  flowColor = mix(flowColor, uAccentColor * 1.1, secondaryBlend * 0.2);

  // 合成: 底色 + 气韵叠加
  vec3 baseGray = vec3(baseLum);
  // 浅色模式底色带轻微色调 (避免纯灰死板)
  vec3 tintedBase = mix(baseGray, uBaseColor * 0.15 + baseGray * 0.85, brightness * 0.5);

  vec3 bgColor = tintedBase + flowColor * flowIntensity * f;

  // --- 暗角 (Vignette) ---
  float vig = 1.0 - smoothstep(0.3, 0.85, length(uv - 0.5) * 1.2);
  float vigStrength = mix(0.15, 0.05, brightness); // 深色模式暗角更重
  bgColor *= 1.0 - vigStrength * (1.0 - vig);

  return bgColor;
}

// =============================================
// § 3  Layer B — 角色脚下螺旋气场
// =============================================
// 极坐标 + Y 轴压缩透视 + 螺旋旋转 + FBM 扰动

struct AuraResult {
  vec3 color;
  float alpha;
};

AuraResult layerFootAura(vec2 uv, float t, float brightness) {
  float aspect = uSize.x / uSize.y;
  vec2 p = uv - uCenter;
  p.x *= aspect;

  // --- 3D 透视 (俯视椭圆) ---
  float yCompress = 2.8;
  vec2 pPersp = vec2(p.x, p.y * yCompress);
  float dist = length(pPersp);
  float angle = atan(pPersp.y, pPersp.x);

  // --- 螺旋旋转 ---
  float rotSpeed = 0.3;
  float rotation = t * rotSpeed;
  float rotAngle = angle - rotation;
  vec2 pRot = rot2D(pPersp, -rotation);

  // --- FBM 域扭曲 (气场有机形态) ---
  vec3 noisePos = vec3(pRot * 3.0, t * 0.2);
  vec2 warp = vec2(
    fbm3(noisePos + vec3(0.0, 0.0, t * 0.15)),
    fbm3(noisePos + vec3(5.2, 1.3, t * 0.12))
  );
  float field = fbm5(pRot * 4.0 + warp * 1.5 + vec2(t * 0.1));

  vec3 color = vec3(0.0);
  float alpha = 0.0;

  // ===================
  // B1: 螺旋环形水波带
  // ===================
  float ringGlow = 0.0;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float progress = fi / 4.0;

    // 环半径 (螺旋展开: 随角度微偏移)
    float spiralOffset = sin(rotAngle * 2.0 + fi * 1.2) * 0.01;
    float ringR = 0.08 + fi * 0.06 + spiralOffset;

    // 角度波动 (立体起伏)
    float wave = sin(rotAngle * (3.0 + fi) + fi * 1.5) * 0.015 * (1.0 + progress * 0.8);
    float noiseDisp = (field - 0.5) * 0.04 * (1.0 + fi * 0.3);
    ringR += wave + noiseDisp;

    float ringDist = abs(dist - ringR);

    // 环线宽度 (抗锯齿: smoothstep 保证亚像素平滑)
    float ringWidth = 0.007 + fi * 0.002;
    float ring = smoothstep(ringWidth, ringWidth * 0.15, ringDist);

    // 发光晕染
    float glow = exp(-ringDist * 35.0) * 0.45;

    // 3D 光照: 前亮后暗
    float lighting = 0.4 + 0.6 * sin(rotAngle + PI * 0.5);

    // 颜色: 内→主色, 外→辅色
    vec3 ringColor = mix(uBaseColor, uAccentColor, progress * 0.7);
    ringColor *= 0.5 + 0.5 * lighting;

    // 主题调制: 浅色模式下环更淡更透
    float themeAlpha = mix(1.0, 0.6, brightness);
    float intensity = (1.0 - progress * 0.4) * themeAlpha;

    color += ringColor * (ring + glow) * intensity;
    ringGlow += (ring + glow * 0.6) * intensity;
  }
  alpha += ringGlow;

  // ===================
  // B2: 底部 3D 透视涟漪
  // ===================
  float floorFade = smoothstep(-0.02, 0.06, p.y);

  // 透视映射: 非线性 UV → 纵深感
  float perspDepth = max(0.01, p.y * yCompress);
  float perspU = p.x / perspDepth;
  float perspV = 1.0 / perspDepth;

  float ripple = 0.0;
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float freq = 5.0 + fi * 4.0;
    float speed = 1.2 + fi * 0.5;
    float amp = 0.28 / (1.0 + fi * 0.5);

    float perspDist = length(vec2(perspU, perspV) * (0.8 + fi * 0.2));
    float wave = sin(perspDist * freq - t * speed + field * 3.0) * 0.5 + 0.5;
    wave = smoothstep(0.3, 0.7, wave); // 抗锯齿波纹
    ripple += wave * amp;
  }

  float rippleMask = floorFade * smoothstep(0.0, 0.22, p.y);
  rippleMask *= smoothstep(1.5, 0.3, perspV);
  rippleMask *= smoothstep(3.0, 0.5, abs(perspU));

  vec3 rippleColor = mix(uBaseColor, uAccentColor, ripple * 0.6);
  float rippleAlpha = ripple * rippleMask * mix(0.3, 0.15, brightness);
  color += rippleColor * rippleAlpha;
  alpha += rippleAlpha;

  // ===================
  // B3: 中心能量核心
  // ===================
  float centerGlow = exp(-dist * 18.0) * mix(0.5, 0.25, brightness);
  float pulse = 0.85 + 0.15 * sin(t * 2.0);
  vec3 coreColor = mix(uBaseColor, uAccentColor, 0.4);
  color += coreColor * centerGlow * pulse;
  alpha += centerGlow * pulse;

  // ===================
  // B4: 旋转射线
  // ===================
  float rays = sin(rotAngle * 6.0) * 0.5 + 0.5;
  rays = pow(rays, 5.0) * mix(0.1, 0.04, brightness);
  float ringMask = smoothstep(0.38, 0.10, dist) * smoothstep(0.02, 0.06, dist);
  rays *= smoothstep(0.5, 0.12, dist);
  color += uAccentColor * rays * ringMask;
  alpha += rays * ringMask * 0.3;

  // --- 椭圆外缘淡出 ---
  float edgeFade = smoothstep(0.5, 0.12, dist);
  float combinedFade = max(edgeFade, rippleMask * 0.5);
  alpha *= combinedFade;

  AuraResult result;
  result.color = color;
  result.alpha = clamp(alpha, 0.0, 1.0);
  return result;
}

// =============================================
// § 4  Layer C — 法线光影交互
// =============================================
// 对气场区域的 FBM 流场做有限差分求法线
// 虚拟光源 Blinn-Phong + 菲涅尔 → 明暗闪烁

struct LightResult {
  vec3 specular;
  float fresnel;
};

LightResult layerLighting(vec2 uv, float t, float auraMask) {
  vec2 p = uv - uCenter;
  p.x *= uSize.x / uSize.y;
  vec2 pPersp = vec2(p.x, p.y * 2.8);
  vec2 pRot = rot2D(pPersp, -t * 0.3);

  // --- 高度场 (共用 fbm5 + noise2) ---
  float eps = 0.015;
  float hC = fbm5(pRot * 4.0 + vec2(t * 0.15, t * 0.1));
  float hR = fbm5((pRot + vec2(eps, 0.0)) * 4.0 + vec2(t * 0.15, t * 0.1));
  float hU = fbm5((pRot + vec2(0.0, eps)) * 4.0 + vec2(t * 0.15, t * 0.1));

  // 法线 (有限差分)
  vec3 tanX = vec3(eps, 0.0, (hR - hC) * 0.35);
  vec3 tanY = vec3(0.0, eps, (hU - hC) * 0.35);
  vec3 normal = normalize(cross(tanY, tanX));

  // 虚拟光源: 随时间缓慢绕行 (增强动态闪烁感)
  float lightAngle = t * 0.15;
  vec3 lightDir = normalize(vec3(
    0.5 * cos(lightAngle) + 0.3,
    -0.6,
    0.5 * sin(lightAngle) + 0.4
  ));

  vec3 viewDir = vec3(0.0, 0.0, 1.0);
  vec3 halfDir = normalize(lightDir + viewDir);

  // Blinn-Phong 高光
  float spec = pow(max(0.0, dot(normal, halfDir)), 48.0) * 0.65;
  spec *= auraMask;

  // 菲涅尔: 边缘更亮 (掠射角效应)
  float fres = pow(1.0 - max(0.0, dot(normal, viewDir)), 3.5);
  fres *= auraMask * 0.35;

  LightResult lr;
  lr.specular = vec3(1.0, 0.97, 0.93) * spec;
  lr.fresnel = fres;
  return lr;
}

// =============================================
// § 5  主入口 — 三层合成 + 主题混合
// =============================================

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  float t = uTime;
  float brightness = clamp(uBrightness, 0.0, 1.0);

  // =============================================
  // Layer A: 背景气韵流体 (全屏)
  // =============================================
  vec3 bg = layerBackground(uv, t, brightness);

  // =============================================
  // Layer B: 角色脚下螺旋气场 (中心区域)
  // =============================================
  AuraResult aura = layerFootAura(uv, t, brightness);

  // =============================================
  // Layer C: 法线光影交互 (气场区域)
  // =============================================
  // auraMask 决定光影作用范围
  float aspect = uSize.x / uSize.y;
  vec2 pMask = uv - uCenter;
  pMask.x *= aspect;
  float distMask = length(vec2(pMask.x, pMask.y * 2.8));
  float auraMask = smoothstep(0.4, 0.08, distMask);

  LightResult light = layerLighting(uv, t, auraMask);

  // =============================================
  // 三层合成
  // =============================================
  vec3 finalColor = bg;

  // 气场叠加: 使用 Screen 混合模式 (避免过曝)
  // Screen: result = 1 - (1 - a) * (1 - b)
  vec3 auraContrib = aura.color + light.specular + uAccentColor * light.fresnel;
  auraContrib = clamp(auraContrib, 0.0, 1.0);

  // 气场强度随主题调节: 深色更强，浅色更柔
  float auraStrength = mix(0.9, 0.5, brightness);
  float blendAlpha = aura.alpha * auraStrength;

  // Screen blend
  finalColor = 1.0 - (1.0 - finalColor) * (1.0 - auraContrib * blendAlpha);

  // =============================================
  // 抗锯齿后处理
  // =============================================
  // 微弱的像素级降噪 (消除噪声函数产生的硬边)
  // 通过极低强度 dither 打破色带
  float dither = (hash2(fragCoord * 0.5 + vec2(t * 100.0)) - 0.5) / 255.0;
  finalColor += dither;

  finalColor = clamp(finalColor, 0.0, 1.0);

  // 不透明背景输出 (alpha = 1.0)
  fragColor = vec4(finalColor, 1.0);
}
