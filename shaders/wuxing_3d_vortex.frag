// ============================================================================
// 五行三维气韵漩涡 (Wuxing 3D Qi Vortex)
// ============================================================================
//
// 一个具有 3D 深度感、体积散射光照和气韵旋转的背景特效。
//
// 核心技术:
//   [1] 3.5D 噪声流场 — FBM + 3D noise 在极坐标中扭动
//   [2] 伪3D透视投影  — 利用 Y 轴模拟俯视视角的环形气流
//   [3] 体积散射     — Volumetric Scattering: 多层半透明采样累加
//   [4] 法线扰动照明 — 噪声求导 → 虚拟光源方向点积 → 高光/暗部
//   [5] 运动模糊     — 时间轴多次采样 + 加权混合
//
// 五行动态逻辑:
//   水(0): 流体动力学 + Specular 水灵反光
//   木(1): 螺旋线条 + 年轮/藤蔓缠绕
//   火(2): Y轴上扰 + 日冕破碎热浪
//   金(3): 精密旋线 + 金属高光 (Blinn-Phong)
//   土(4): 厚重缓流 + 颗粒质感
// ============================================================================

#include <flutter/runtime_effect.glsl>

// --- Uniforms ---
uniform vec2  uSize;        // [0,1]    画布尺寸 (px)
uniform float uTime;        // [2]      动画时间 (秒)
uniform float uElement;     // [3]      五行: 0=水 1=木 2=火 3=金 4=土
uniform float uBreath;      // [4]      呼吸调制 0.0~1.0
uniform vec2  uCenter;      // [5,6]    旋涡中心 (归一化 0~1)
uniform vec3  uColorMain;   // [7,8,9]  主色
uniform vec3  uColorAccent; // [10,11,12] 辅色

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

// =============================================
// § 1  噪声系统 (2D / 3D)
// =============================================

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash3(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// 2D Value Noise
float noise2(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash2(i), hash2(i + vec2(1, 0)), u.x),
    mix(hash2(i + vec2(0, 1)), hash2(i + vec2(1, 1)), u.x),
    u.y
  );
}

// 3D Value Noise — 增加 z 维度以实现 3.5D 效果
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

// 2D FBM
float fbm2(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise2(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

// 3D FBM — 丝绸般的三维纹理
float fbm3(vec3 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise3(p);
    p = p * 2.01 + vec3(1.6, 1.2, 0.8);
    a *= 0.5;
  }
  return v;
}

// =============================================
// § 2  法线求导 (Gradient → Normal)
// =============================================
// 通过有限差分对噪声函数求偏导，计算表面法线
// 用于虚拟光源的 Blinn-Phong 着色

vec3 calcNormal(vec3 pos, float eps) {
  float c  = fbm3(pos);
  float dx = fbm3(pos + vec3(eps, 0.0, 0.0)) - c;
  float dy = fbm3(pos + vec3(0.0, eps, 0.0)) - c;
  float dz = fbm3(pos + vec3(0.0, 0.0, eps)) - c;
  return normalize(vec3(-dx, -dy, -dz));
}

// =============================================
// § 3  主渲染管线
// =============================================

// 单帧采样 (timeOffset 用于运动模糊)
vec4 sampleVortex(vec2 uv, float t, float breath) {
  // --- 中心化 + 宽高比校正 ---
  vec2 center = uCenter;
  vec2 p = uv - center;
  p.x *= uSize.x / uSize.y;

  float r = length(p);
  float theta = atan(p.y, p.x);

  // =============================================
  // 3.5D 极坐标 → 空间坐标映射
  // =============================================
  // 将2D极坐标提升到3D: (angle, radius, time) → xyz
  // 模拟从上方俯视一个旋转环形气流
  float depth = 1.0 / (1.0 + r * 2.8); // 透视缩放因子
  vec3 spacePos = vec3(
    theta / TAU * 6.0,          // X: 角度展开
    r * 4.0 * depth,            // Y: 径向 (带透视)
    t * 0.3 + r * 2.0           // Z: 时间+径向混合 → 层叠感
  );

  // 旋转驱动: 角度随时间偏移
  float rotSpeed = 0.35;
  float rotAngle = t * rotSpeed;

  // =============================================
  // 五行参数矩阵
  // =============================================
  float nScale;     // 噪声空间缩放
  float nAmp;       // 流场扭曲振幅
  float specPow;    // 高光指数
  float specInt;    // 高光强度
  vec2  flowBias;   // 额外流向偏置

  if (uElement < 0.5) {
    // ═══ 水 Water ═══  流体动力学 + Specular
    nScale = 1.8; nAmp = 0.35;
    specPow = 64.0; specInt = 0.6;
    flowBias = vec2(0.3, 0.1);
    rotSpeed = 0.28;
  } else if (uElement < 1.5) {
    // ═══ 木 Wood ═══  螺旋年轮 + 藤蔓缠绕
    nScale = 1.2; nAmp = 0.25;
    specPow = 16.0; specInt = 0.15;
    flowBias = vec2(0.15, 0.3);
    rotSpeed = 0.15;
  } else if (uElement < 2.5) {
    // ═══ 火 Fire ═══  Y轴上扰 + 日冕
    nScale = 2.2; nAmp = 0.55;
    specPow = 32.0; specInt = 0.35;
    flowBias = vec2(0.1, -1.5);
    rotSpeed = 0.45;
  } else if (uElement < 3.5) {
    // ═══ 金 Metal ═══  精密旋线 + Blinn-Phong
    nScale = 1.0; nAmp = 0.12;
    specPow = 128.0; specInt = 0.85;
    flowBias = vec2(0.2, 0.1);
    rotSpeed = 0.2;
  } else {
    // ═══ 土 Earth ═══  厚重缓流 + 颗粒
    nScale = 0.8; nAmp = 0.18;
    specPow = 8.0; specInt = 0.08;
    flowBias = vec2(0.05, 0.08);
    rotSpeed = 0.08;
  }

  // =============================================
  // 3D 噪声流场 (Domain Warping in 3D)
  // =============================================
  vec3 noiseP = spacePos * nScale;
  noiseP.x += rotAngle * 2.0; // 旋转注入

  // 第一层: 大尺度扭曲
  vec3 warp1 = vec3(
    fbm3(noiseP + vec3(t * flowBias.x, 0.0, 0.0)),
    fbm3(noiseP + vec3(0.0, t * flowBias.y, 3.7)),
    fbm3(noiseP + vec3(5.2, 0.0, t * 0.15))
  );

  // 第二层: 精细纹理
  vec3 warp2 = vec3(
    fbm3(noiseP + nAmp * 4.0 * warp1 + vec3(1.7, 9.2, 0.0)),
    fbm3(noiseP + nAmp * 4.0 * warp1 + vec3(8.3, 2.8, 4.1)),
    fbm3(noiseP + nAmp * 4.0 * warp1 + vec3(0.0, 3.4, 7.7))
  );

  float field = fbm3(noiseP + nAmp * 3.0 * warp2);

  // =============================================
  // § 体积散射 (Volumetric Scattering)
  // =============================================
  // 模拟光线穿过多层半透明气流的明暗渐变
  float volDensity = 0.0;
  float volStep = 0.08;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float depthSample = fi * volStep;
    vec3 volP = noiseP + vec3(0.0, 0.0, depthSample);
    float d = fbm3(volP + nAmp * 2.0 * warp1);
    volDensity += d * (1.0 - fi * 0.18); // 远层衰减
  }
  volDensity *= 0.22;

  // 虚拟光源方向 (从右上前方照射)
  vec3 lightDir = normalize(vec3(0.6, -0.7, 0.35));

  // =============================================
  // § 法线扰动照明 (Normal Perturbation Lighting)
  // =============================================
  vec3 normal = calcNormal(noiseP + nAmp * 2.0 * warp2, 0.02);

  // Blinn-Phong 光照
  vec3 viewDir = vec3(0.0, 0.0, 1.0);
  vec3 halfDir = normalize(lightDir + viewDir);
  float diffuse = max(0.0, dot(normal, lightDir)) * 0.6 + 0.4;
  float specular = pow(max(0.0, dot(normal, halfDir)), specPow) * specInt;

  // 背光散射 (增加体积感)
  float backScatter = pow(max(0.0, dot(normal, -lightDir)), 3.0) * 0.15;

  // =============================================
  // § 环形结构与透视
  // =============================================
  // 主环带 (带透视椭圆压缩)
  float ringCenter = 0.22 + 0.03 * breath;
  float ringWidth  = 0.12 + 0.02 * breath;
  float ringEdge   = ringWidth * 0.4;
  float ringMask   = smoothstep(ringCenter - ringWidth - ringEdge, ringCenter - ringWidth + ringEdge, r)
                   * (1.0 - smoothstep(ringCenter + ringWidth - ringEdge, ringCenter + ringWidth + ringEdge, r));

  // 底部3D涟漪 (俯视透视)
  // p.y > 0 → 画面下半部; 模拟水平面涟漪
  float floorY = p.y * 3.0;
  float perspR = length(vec2(p.x, floorY)); // 拉伸 Y → 透视变形
  float ripple = sin(perspR * 18.0 - t * 2.5 + field * 5.0) * 0.5 + 0.5;
  ripple *= smoothstep(0.45, 0.15, perspR);
  float floorMask = smoothstep(-0.02, 0.08, p.y); // 仅底部
  float floorEffect = ripple * floorMask * 0.2 * (0.7 + 0.3 * breath);

  // =============================================
  // § 五行专属效果
  // =============================================

  float elemFX = 0.0;

  if (uElement < 0.5) {
    // ═══ 水: 焦散反光 ═══
    float caustic = noise2(vec2(theta * 8.0, r * 15.0 + t * 1.5));
    caustic = pow(caustic, 2.0) * 0.35 * ringMask;
    elemFX = caustic;
    // 水面涟漪增强
    floorEffect *= 1.8;
  }
  else if (uElement < 1.5) {
    // ═══ 木: 螺旋藤蔓 ═══
    float spiral = sin(theta * 5.0 + r * 20.0 - t * 0.6 + field * 3.0);
    spiral = smoothstep(0.6, 0.9, spiral) * 0.3 * ringMask;
    // 年轮纹
    float rings = sin(r * 35.0 + field * 6.0) * 0.5 + 0.5;
    rings = smoothstep(0.4, 0.6, rings) * 0.08 * ringMask;
    elemFX = spiral + rings;
  }
  else if (uElement < 2.5) {
    // ═══ 火: 日冕热浪 ═══
    float upWarp = max(0.0, -p.y) * 2.5;
    float corona = fbm2(vec2(theta * 6.0, r * 10.0 - t * 3.0));
    corona = pow(corona, 1.5) * (0.5 + upWarp);
    // 边缘破碎 (高频噪声)
    float shatter = noise2(vec2(theta * 20.0, r * 30.0 + t * 5.0));
    shatter = smoothstep(0.65, 0.95, shatter) * 0.4;
    float fireMask = smoothstep(ringCenter + ringWidth + 0.1, ringCenter + ringWidth - 0.02, r);
    elemFX = (corona * 0.3 + shatter * fireMask) * (0.6 + 0.4 * breath);
  }
  else if (uElement < 3.5) {
    // ═══ 金: 旋转扫光 ═══
    float sweepAngle = mod(t * 0.6, TAU);
    float aDiff = abs(theta - sweepAngle);
    aDiff = min(aDiff, TAU - aDiff);
    float sweep = pow(max(0.0, 1.0 - aDiff / 0.35), 48.0);
    elemFX = sweep * ringMask * 0.5;
  }
  else {
    // ═══ 土: 颗粒沉积 ═══
    float grain = hash2(uv * uSize * 0.5 + vec2(floor(t * 4.0)));
    elemFX = (grain - 0.5) * 0.06 * ringMask;
    float sediment = fbm2(vec2(theta * 2.0, r * 6.0) + t * 0.03);
    field *= 0.8 + 0.2 * sediment;
  }

  // =============================================
  // § 色彩合成
  // =============================================
  // 径向渐变: 内→主色, 外→辅色
  float colorMix = smoothstep(ringCenter - ringWidth, ringCenter + ringWidth, r);
  vec3 color = mix(uColorMain, uColorAccent, colorMix);

  // 光照调制
  color *= diffuse;
  color += specular * vec3(1.0, 0.97, 0.92); // 暖白高光
  color += backScatter * uColorMain;           // 背光散射

  // 体积散射色彩 (为深层气流着色)
  vec3 volColor = mix(uColorMain * 0.8, uColorAccent * 0.6, volDensity);

  // =============================================
  // § Alpha 合成
  // =============================================
  float alpha = 0.0;
  alpha += ringMask * (field * 0.7 + volDensity * 0.3); // 主环
  alpha += floorEffect;                                  // 底部涟漪
  alpha += elemFX;                                       // 五行特效

  // 全局呼吸调制
  alpha *= 0.65 + 0.35 * breath;

  // Smoothstep 内外缘淡出
  alpha *= smoothstep(0.50, 0.35, r); // 外缘淡出
  alpha *= smoothstep(0.02, 0.08, r); // 内缘淡出

  alpha = clamp(alpha, 0.0, 1.0);

  // 最终颜色混合
  vec3 finalColor = color + volColor * 0.3;
  finalColor = clamp(finalColor, 0.0, 1.0);

  // 预乘 Alpha (Premultiplied Alpha)
  return vec4(finalColor * alpha, alpha);
}

// =============================================
// § 4  运动模糊 (Motion Blur via Temporal Sampling)
// =============================================
// 在时间轴上取 3 帧微偏移采样，加权混合
// 产生自然的运动模糊感

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime;
  float breath = uBreath;

  // 运动模糊: 3 次时间偏移采样 (前中后)
  float blur = 0.012; // 模糊半径 (秒)
  vec4 s0 = sampleVortex(uv, t - blur, breath);
  vec4 s1 = sampleVortex(uv, t,        breath);
  vec4 s2 = sampleVortex(uv, t + blur, breath);

  // 加权混合: 中间帧权重最高
  fragColor = s0 * 0.25 + s1 * 0.50 + s2 * 0.25;
}
