// ============================================================================
// 3D 水波气场与涟漪 (3D Water Aura & Perspective Ripples)
// ============================================================================
//
// 角色脚下动态且具有 3D 纵深感的水波气场。
//
// 核心效果:
//   [1] 中心环绕水波 — 极坐标 FBM 扭曲 + 旋转 → 立体环形水波
//   [2] 底部透视涟漪 — UV 非线性映射 → 近大远小的 3D 地面波纹
//   [3] 流体光影     — 有限差分法线 + 虚拟光源 → 高光/菲涅尔/反射
//   [4] 水花飞溅     — 高频噪点阈值 → 动态边缘碎片
//
// Uniforms 布局:
//   [0,1]      vec2  uSize        画布逻辑像素尺寸
//   [2]        float uTime        动画时间 (秒)
//   [3,4]      vec2  uCenter      水波中心 (归一化 0~1)
//   [5,6,7]    vec3  uColorBase   主色 (归一化 RGB)
//   [8,9,10]   vec3  uColorAccent 辅色/高光色 (归一化 RGB)
// ============================================================================

#include <flutter/runtime_effect.glsl>

uniform vec2  uSize;
uniform float uTime;
uniform vec2  uCenter;
uniform vec3  uColorBase;
uniform vec3  uColorAccent;

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

// =============================================
// § 1  噪声系统
// =============================================

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash3(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// 2D Value Noise (Hermite 平滑插值)
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

// 3D Value Noise
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

// 2D FBM — 5 八度
float fbm2(vec2 p) {
  float v = 0.0, a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise2(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

// 3D FBM — 4 八度 (用于体积感)
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
// § 2  2D 旋转矩阵
// =============================================

vec2 rotate2D(vec2 p, float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

// =============================================
// § 3  水面高度场 (Height Field)
// =============================================
// 通过多层噪声生成一个连续的水面高度值
// 用于法线计算和高光渲染

float waterHeight(vec2 pos, float t) {
  // 第一层: 大尺度起伏
  float h = fbm2(pos * 2.0 + vec2(t * 0.3, t * 0.2)) * 0.5;
  // 第二层: 中频波浪
  h += noise2(pos * 5.0 + vec2(t * 0.6, -t * 0.4)) * 0.25;
  // 第三层: 高频细节
  h += noise2(pos * 12.0 + vec2(-t * 0.8, t * 0.5)) * 0.12;
  // 第四层: 极高频水花
  h += noise2(pos * 25.0 + vec2(t * 1.2, t * 0.9)) * 0.06;
  return h;
}

// =============================================
// § 4  法线计算 (有限差分)
// =============================================

vec3 waterNormal(vec2 pos, float t, float eps) {
  float hC = waterHeight(pos, t);
  float hR = waterHeight(pos + vec2(eps, 0.0), t);
  float hU = waterHeight(pos + vec2(0.0, eps), t);
  // 从高度差推导法线
  vec3 tangentX = vec3(eps, 0.0, (hR - hC) * 0.3);
  vec3 tangentY = vec3(0.0, eps, (hU - hC) * 0.3);
  return normalize(cross(tangentY, tangentX));
}

// =============================================
// § 5  环形水波带
// =============================================

float ringWave(float dist, float center, float width, float softness) {
  float inner = smoothstep(center - width - softness, center - width + softness, dist);
  float outer = 1.0 - smoothstep(center + width - softness, center + width + softness, dist);
  return inner * outer;
}

// =============================================
// § 6  主渲染管线
// =============================================

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  float t = uTime;
  float aspect = uSize.x / uSize.y;

  // --- 中心化 + 宽高比校正 ---
  vec2 p = uv - uCenter;
  p.x *= aspect;

  // =============================================
  // A. 3D 透视变形 — 俯视椭圆
  // =============================================
  // Y 轴压缩，模拟从上方俯视角色脚下的水面
  float yCompress = 2.8;
  vec2 pPersp = vec2(p.x, p.y * yCompress);

  float dist = length(pPersp);
  float angle = atan(pPersp.y, pPersp.x);

  // =============================================
  // B. 缓慢旋转
  // =============================================
  float rotSpeed = 0.25;
  float rotation = t * rotSpeed;
  float rotAngle = angle - rotation;

  // 旋转后的坐标 (用于噪声采样)
  vec2 pRot = rotate2D(pPersp, -rotation);

  // =============================================
  // C. 中心环绕水波 (Central Ring of Water)
  // =============================================
  vec3 color = vec3(0.0);
  float totalAlpha = 0.0;

  // --- C1: FBM 域扭曲生成有机水波形态 ---
  vec3 noisePos = vec3(pRot * 3.0, t * 0.2);
  vec2 warp = vec2(
    fbm3(noisePos + vec3(0.0, 0.0, t * 0.15)),
    fbm3(noisePos + vec3(5.2, 1.3, t * 0.12))
  );
  float field = fbm2(pRot * 4.0 + warp * 1.5 + vec2(t * 0.1));

  // --- C2: 多层环形水波带 ---
  float ringGlow = 0.0;
  for (int i = 0; i < 5; i++) {
    float fi = float(i);
    float progress = fi / 4.0;

    // 环半径: 内到外递增
    float ringR = 0.08 + fi * 0.065;

    // 角度方向的波动 (产生 3D 立体感)
    float wavePhase = rotAngle * (3.0 + fi) + fi * 1.5;
    float wave = sin(wavePhase) * 0.015 * (1.0 + progress * 0.8);
    // FBM 扰动让每个环不规则
    float noiseDisp = (field - 0.5) * 0.04 * (1.0 + fi * 0.3);
    ringR += wave + noiseDisp;

    // 环带距离
    float ringDist = abs(dist - ringR);

    // 清晰的环线
    float ringWidth = 0.008 + fi * 0.002;
    float ring = smoothstep(ringWidth, ringWidth * 0.2, ringDist);

    // 发光晕染
    float glow = exp(-ringDist * 30.0) * 0.5;

    // 3D 明暗: 模拟光照 (前方亮，后方暗)
    float lighting = 0.45 + 0.55 * sin(rotAngle + PI * 0.5);

    // 颜色渐变: 内环主色 → 外环辅色
    vec3 ringColor = mix(uColorBase, uColorAccent, progress * 0.7);
    ringColor *= 0.55 + 0.45 * lighting;

    // 外环更透明
    float intensity = 1.0 - progress * 0.4;

    color += ringColor * (ring + glow) * intensity;
    ringGlow += (ring + glow * 0.6) * intensity;
  }

  totalAlpha += ringGlow;

  // --- C3: 环形区域的水面高度场着色 ---
  float ringMask = smoothstep(0.38, 0.10, dist) * smoothstep(0.02, 0.06, dist);
  float hField = waterHeight(pRot * 2.5, t);
  vec3 ringWaterColor = mix(uColorBase, uColorAccent, hField);
  color += ringWaterColor * hField * ringMask * 0.3;
  totalAlpha += hField * ringMask * 0.25;

  // --- C4: 水面法线 → 高光 + 菲涅尔 ---
  vec3 normal = waterNormal(pRot * 2.5, t, 0.02);

  // 虚拟光源 (右上前方)
  vec3 lightDir = normalize(vec3(0.5, -0.6, 0.6));
  vec3 viewDir = vec3(0.0, 0.0, 1.0);
  vec3 halfDir = normalize(lightDir + viewDir);

  // Blinn-Phong 高光
  float specular = pow(max(0.0, dot(normal, halfDir)), 64.0) * 0.7;
  specular *= ringMask;

  // 菲涅尔效应: 掠射角更亮
  float fresnel = pow(1.0 - max(0.0, dot(normal, viewDir)), 3.0);
  fresnel *= ringMask * 0.4;

  // 应用高光和菲涅尔
  color += vec3(1.0, 0.98, 0.95) * specular;
  color += uColorAccent * fresnel;
  totalAlpha += specular * 0.6 + fresnel * 0.5;

  // --- C5: 水花飞溅 (边缘噪点) ---
  float splashNoise = noise2(vec2(angle * 10.0, dist * 40.0 + t * 3.0));
  float splash = smoothstep(0.72, 0.92, splashNoise);
  // 只在环带边缘附近
  float splashZone = ringWave(dist, 0.32, 0.08, 0.06);
  splash *= splashZone * 0.5;
  color += uColorAccent * splash;
  totalAlpha += splash * 0.4;

  // =============================================
  // D. 底部透视涟漪 (Perspective Ripples at Base)
  // =============================================
  // p.y > 0 → 画面下半部 (角色脚下延伸到远处)
  float floorFade = smoothstep(-0.02, 0.05, p.y);

  // 透视映射: 越远(p.y越小) → UV 越密集
  // 使用非线性映射创建纵深感
  float perspDepth = max(0.01, p.y * yCompress);
  float perspU = p.x / perspDepth; // 横向随深度展开
  float perspV = 1.0 / perspDepth; // 纵向近大远小

  // 涟漪波纹 (多层叠加)
  float ripple = 0.0;
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    float freq = 6.0 + fi * 4.0;
    float speed = 1.5 + fi * 0.5;
    float amp = 0.3 / (1.0 + fi * 0.5);

    // 同心圆涟漪 (透视变形后)
    float perspDist = length(vec2(perspU, perspV) * (0.8 + fi * 0.2));
    float wave = sin(perspDist * freq - t * speed + field * 3.0) * 0.5 + 0.5;
    wave = smoothstep(0.35, 0.65, wave);
    ripple += wave * amp;
  }

  // 涟漪区域遮罩: 只在底部区域渐显，远处衰减
  float rippleMask = floorFade * smoothstep(0.0, 0.25, p.y);
  rippleMask *= smoothstep(1.5, 0.3, perspV); // 极远处淡出
  rippleMask *= smoothstep(3.0, 0.5, abs(perspU)); // 两侧淡出

  // 涟漪的法线和高光
  float rippleH = ripple * 0.15;
  float rippleHL = noise2(vec2(perspU * 3.0, perspV * 2.0 + t * 0.5));
  rippleHL = pow(rippleHL, 3.0) * 0.4;

  // 涟漪颜色
  vec3 rippleColor = mix(uColorBase, uColorAccent, ripple * 0.6);
  rippleColor += vec3(1.0, 0.98, 0.95) * rippleHL * rippleMask;

  // 距离衰减: 远处更暗更蓝
  float depthDarken = smoothstep(0.0, 0.8, p.y);
  rippleColor *= 0.5 + 0.5 * depthDarken;

  float rippleAlpha = ripple * rippleMask * 0.35;
  color += rippleColor * rippleAlpha;
  totalAlpha += rippleAlpha;

  // =============================================
  // E. 中心光点 (Energy Core)
  // =============================================
  float centerGlow = exp(-dist * 16.0) * 0.5;
  vec3 coreColor = mix(uColorBase, uColorAccent, 0.4);
  // 脉动
  float pulse = 0.85 + 0.15 * sin(t * 2.0);
  color += coreColor * centerGlow * pulse;
  totalAlpha += centerGlow * pulse;

  // =============================================
  // F. 旋转光线 (Rotating Rays)
  // =============================================
  float rays = sin(rotAngle * 6.0) * 0.5 + 0.5;
  rays = pow(rays, 5.0) * 0.12;
  rays *= smoothstep(0.5, 0.15, dist);
  color += uColorAccent * rays * ringMask;
  totalAlpha += rays * ringMask * 0.3;

  // =============================================
  // G. 全局合成
  // =============================================

  // 椭圆形外缘淡出
  float edgeFade = smoothstep(0.55, 0.15, dist);
  // 底部涟漪区域不受椭圆遮罩约束 (它有自己的遮罩)
  float combinedFade = max(edgeFade, rippleMask * 0.6);

  totalAlpha *= combinedFade;
  totalAlpha = clamp(totalAlpha, 0.0, 1.0);

  color = clamp(color, 0.0, 1.0);

  // 预乘 Alpha (Premultiplied Alpha)
  fragColor = vec4(color * totalAlpha, totalAlpha);
}
