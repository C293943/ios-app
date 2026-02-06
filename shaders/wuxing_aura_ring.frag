// ============================================================================
// 五行气韵环 (Wuxing Qi Aura Ring)
// ============================================================================
// 基于极坐标 (Polar Coordinates) 的环形气韵效果
// 结合 FBM 噪声产生丝绸/云雾般的有机扭动
//
// 五行视觉逻辑：
//   水(0): 高频振幅 → 细碎波光折射
//   木(1): 低频漂移 → 叶片风摆轨迹
//   火(2): 垂直位移 → Y轴向上热浪升腾
//   金(3): 高光闪烁 → pow(dot,spec) 金属反光
//   土(4): 颗粒度   → 随机微小像素点
// ============================================================================

#include <flutter/runtime_effect.glsl>

// --- Uniforms ---
uniform vec2 uSize;       // [0,1]  画布逻辑像素尺寸
uniform float uTime;      // [2]    动画时间 (秒)
uniform float uElement;   // [3]    五行属性: 0=水, 1=木, 2=火, 3=金, 4=土
uniform float uBreath;    // [4]    呼吸调制: 0.0-1.0 (外部 Curves.easeInOut 驱动)
uniform vec3 uColor1;     // [5,6,7]  主色
uniform vec3 uColor2;     // [8,9,10] 辅色

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

// =============================================
// 噪声工具函数
// =============================================

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f); // Hermite 插值
  return mix(
    mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
    mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
    u.y
  );
}

// FBM (Fractal Brownian Motion) - 4 八度叠加
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

// 高频 FBM - 5 八度 (用于水的细碎波光)
float fbmHQ(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(1.6, 1.2);
    a *= 0.5;
  }
  return v;
}

// =============================================
// 环带函数 - 平滑 Alpha 边缘过渡 (Smoothstep)
// =============================================

// dist: 片元到中心的距离
// center: 环带中心半径
// hw: 环带半宽
float ringBand(float dist, float center, float hw) {
  float edge = hw * 0.35;
  float inner = smoothstep(center - hw - edge, center - hw + edge, dist);
  float outer = 1.0 - smoothstep(center + hw - edge, center + hw + edge, dist);
  return inner * outer;
}

// =============================================
// 主程序
// =============================================

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;

  // --- 中心化 + 宽高比校正 ---
  vec2 p = uv - 0.5;
  p.x *= uSize.x / uSize.y;

  // --- 极坐标转换 ---
  float r = length(p);
  float theta = atan(p.y, p.x);
  float tNorm = (theta + PI) / TAU; // 归一化角度 [0, 1]

  float t = uTime;
  float breath = uBreath; // 外部缓动驱动的呼吸值

  // =============================================
  // 五行参数矩阵
  // =============================================
  float nFreq;    // 噪声角频率 (水高/木低)
  float nAmp;     // 噪声扭曲振幅
  float rCount;   // 环带数量
  float rWidth;   // 环带半宽度
  float tScale;   // 时间缩放 (动画速度)
  vec2  drift;    // 噪声漂移方向 (火=向上)

  if (uElement < 0.5) {
    // ═══ 水 Water ═══
    // 高频振幅：模拟细碎的波光，多而密的环带
    nFreq = 8.0;  nAmp = 0.028;
    rCount = 6.0; rWidth = 0.014;
    tScale = 0.25; drift = vec2(1.2, 0.3);
  } else if (uElement < 1.5) {
    // ═══ 木 Wood ═══
    // 低频漂移：模拟叶片在风中缓缓摆动
    nFreq = 3.0;  nAmp = 0.05;
    rCount = 4.0; rWidth = 0.024;
    tScale = 0.12; drift = vec2(0.4, 0.6);
  } else if (uElement < 2.5) {
    // ═══ 火 Fire ═══
    // 垂直位移：强制噪声沿 Y 轴向上流动
    nFreq = 6.0;  nAmp = 0.055;
    rCount = 5.0; rWidth = 0.018;
    tScale = 0.35; drift = vec2(0.2, -2.2); // 强烈向上漂移
  } else if (uElement < 3.5) {
    // ═══ 金 Metal ═══
    // 高光闪烁：极精密的薄环，微弱扰动
    nFreq = 5.0;  nAmp = 0.01;
    rCount = 3.0; rWidth = 0.007;
    tScale = 0.08; drift = vec2(0.5, 0.3);
  } else {
    // ═══ 土 Earth ═══
    // 颗粒度：宽环带，沉稳缓慢
    nFreq = 2.5;  nAmp = 0.018;
    rCount = 4.0; rWidth = 0.026;
    tScale = 0.06; drift = vec2(0.2, 0.15);
  }

  // =============================================
  // 呼吸调制 (Breath Modulation)
  // =============================================
  // 环带半径随呼吸微调，产生周期性收缩/扩张
  float bScale = 0.93 + 0.07 * breath;
  float innerR  = 0.13 * bScale;
  float outerR  = 0.42 * bScale;
  float spacing = (outerR - innerR) / max(rCount, 1.0);

  // =============================================
  // 噪声扭曲 (Domain Distortion)
  // =============================================
  // 预计算两层噪声，环间插值使用以增加层次
  vec2 noiseUV = vec2(tNorm * nFreq, r * 6.0) + drift * t * tScale;
  float n1 = fbm(noiseUV) * 2.0 - 1.0;
  float n2 = fbm(noiseUV + vec2(3.7, 8.2)) * 2.0 - 1.0;

  // 火：追加向上偏置扰动 (screen-space y↓, p.y<0 = 上方)
  if (uElement > 1.5 && uElement < 2.5) {
    float upBias = max(0.0, -p.y) * 0.7;
    float fireWarp = fbm(vec2(theta * 4.0, r * 8.0 - t * 1.8)) - 0.5;
    n1 += fireWarp * (0.7 + upBias);
    n2 += upBias * 0.15;
  }

  // =============================================
  // 环带累加 (Ring Accumulation)
  // =============================================
  float rings = 0.0;
  for (int i = 0; i < 7; i++) {
    float fi = float(i);
    if (fi < rCount) {
      float ringR = innerR + spacing * (fi + 0.5);
      float w = rWidth * (1.0 + fi * 0.12);
      float falloff = 1.0 - fi / max(rCount, 1.0) * 0.3;

      // 每环使用两层噪声的不同混合比，避免环间同步
      float localN = mix(n1, n2, fi / max(rCount - 1.0, 1.0));
      float rDist = r + localN * nAmp * (0.8 + 0.2 * breath);

      rings += ringBand(rDist, ringR, w) * falloff;
    }
  }

  // =============================================
  // 环间辉光 (Inter-ring Glow)
  // =============================================
  float glowMask = smoothstep(outerR + 0.06, outerR - 0.04, r) *
                   smoothstep(innerR - 0.04, innerR + 0.04, r);
  float glow = glowMask * 0.12 * (0.7 + 0.3 * breath);

  // =============================================
  // 五行专属视觉效果
  // =============================================

  // --- 水：高频折射微光 ---
  float waterShimmer = 0.0;
  if (uElement < 0.5) {
    float shimmer = noise(vec2(theta * 22.0, r * 35.0 + t * 2.5));
    waterShimmer = shimmer * 0.06 * glowMask;
    // 水波折射：环带亮度沿角度微弱波动
    float refract = sin(theta * 12.0 + fbm(vec2(r * 4.0, t * 0.5)) * 5.0) * 0.5 + 0.5;
    rings *= 0.85 + 0.15 * refract;
  }

  // --- 木：藤蔓疏密脉络 ---
  float woodVine = 1.0;
  if (uElement > 0.5 && uElement < 1.5) {
    float vine = sin(theta * 5.0 + fbm(vec2(r * 3.0, t * 0.2)) * 4.0) * 0.5 + 0.5;
    woodVine = 0.55 + 0.45 * vine;
    // 叶片散落轨迹：极坐标螺旋调制
    float spiral = sin(theta * 3.0 + r * 15.0 - t * 0.5) * 0.5 + 0.5;
    rings += spiral * 0.04 * glowMask * breath;
  }

  // --- 火：破碎火星飞溅 ---
  float fireSparks = 0.0;
  if (uElement > 1.5 && uElement < 2.5) {
    float sparkN = noise(vec2(theta * 14.0, r * 22.0 + t * 4.0));
    fireSparks = smoothstep(0.7, 0.92, sparkN) *
                 smoothstep(outerR + 0.14, outerR - 0.02, r) *
                 (0.4 + max(0.0, -p.y) * 2.0); // 向上加强
    // 边缘破碎效果
    float edgeBreak = noise(vec2(theta * 8.0, t * 2.0));
    rings *= 0.7 + 0.3 * smoothstep(0.3, 0.7, edgeBreak);
  }

  // --- 金：扫光高光 pow(dot(n,l), spec) ---
  float metalSpec = 0.0;
  if (uElement > 2.5 && uElement < 3.5) {
    // 旋转扫光
    float specAngle = mod(t * 0.5, TAU);
    float aDiff = abs(theta - specAngle);
    aDiff = min(aDiff, TAU - aDiff);
    metalSpec = pow(max(0.0, 1.0 - aDiff / 0.5), 32.0) *
                glowMask * 0.7 * (0.5 + 0.5 * breath);
    // 第二扫光 (对角偏移)
    float specAngle2 = mod(t * 0.35 + PI, TAU);
    float aDiff2 = abs(theta - specAngle2);
    aDiff2 = min(aDiff2, TAU - aDiff2);
    metalSpec += pow(max(0.0, 1.0 - aDiff2 / 0.4), 24.0) *
                 glowMask * 0.35;
  }

  // --- 土：随机微粒颗粒 ---
  float earthGrain = 0.0;
  if (uElement > 3.5) {
    // 帧间跳变的细碎颗粒 (模拟沙尘/泥土质感)
    float g = hash(uv * uSize * 0.5 + vec2(floor(t * 6.0)));
    earthGrain = (g - 0.5) * 0.04 * glowMask;
    // 额外的层叠质感
    float sediment = fbm(vec2(tNorm * 3.0, r * 10.0) + vec2(t * 0.03));
    rings *= 0.8 + 0.2 * sediment;
  }

  // =============================================
  // 最终合成 (Final Compositing)
  // =============================================
  float total = clamp(rings * woodVine + glow + waterShimmer + fireSparks + earthGrain, 0.0, 1.0);

  // 径向色彩渐变：内环→主色, 外环→辅色
  float cMix = smoothstep(innerR, outerR, r);
  vec3 color = mix(uColor1, uColor2, cMix);

  // 金属高光叠加 (偏暖白)
  color += metalSpec * vec3(1.0, 0.96, 0.88);

  // Alpha 平滑边缘过渡 (Smoothstep)
  float alpha = total;
  alpha *= smoothstep(outerR + 0.10, outerR - 0.02, r);  // 外缘淡出
  alpha *= smoothstep(innerR - 0.05, innerR + 0.03, r);  // 内缘淡出

  // 预乘 Alpha 输出 (Premultiplied Alpha)
  fragColor = vec4(color * alpha, alpha);
}
