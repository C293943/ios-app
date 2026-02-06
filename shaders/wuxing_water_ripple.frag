// ============================================================================
// 2.5D 旋转水波特效 — 清晰的斜切面波纹绕中心旋转
// ============================================================================

#include <flutter/runtime_effect.glsl>

uniform vec2  uSize;
uniform float uTime;
uniform float uElement;
uniform float uBreath;
uniform vec2  uCenter;
uniform vec3  uColor1;   // 主色
uniform vec3  uColor2;   // 辅色

out vec4 fragColor;

const float PI  = 3.14159265;
const float TAU = 6.28318530;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  float t = uTime;
  float breath = uBreath;
  float aspect = uSize.x / uSize.y;

  // =============================================
  // 2.5D 斜切面坐标 (俯视椭圆)
  // =============================================
  vec2 p = uv - uCenter;
  p.x *= aspect;
  
  // Y 压缩形成椭圆透视
  float yCompress = 3.0;
  vec2 xz = vec2(p.x, p.y * yCompress);
  
  float dist = length(xz);
  float angle = atan(xz.y, xz.x);

  // =============================================
  // 整体绕中心旋转
  // =============================================
  float rotSpeed = 0.5;
  float rotation = t * rotSpeed;
  float rotatedAngle = angle - rotation;

  // =============================================
  // 清晰的同心椭圆环 (旋转而非扩散)
  // =============================================
  vec3 color = vec3(0.0);
  float totalGlow = 0.0;
  
  // 6 层清晰的椭圆环
  for (int i = 0; i < 6; i++) {
    float fi = float(i);
    float progress = fi / 5.0;
    
    // 固定的环半径
    float ringRadius = 0.1 + fi * 0.1;
    
    // 呼吸脉动
    ringRadius *= 1.0 + (breath - 0.5) * 0.1;
    
    // 沿角度的波动 (让环有起伏，产生3D感)
    float wavePhase = rotatedAngle * 3.0 + fi * 1.2;
    float wave = sin(wavePhase) * 0.02 * (1.0 + progress);
    ringRadius += wave;
    
    // 到环的距离
    float ringDist = abs(dist - ringRadius);
    
    // 清晰的环线 (窄而亮)
    float ringWidth = 0.012;
    float ring = smoothstep(ringWidth, ringWidth * 0.3, ringDist);
    
    // 环的发光边缘
    float glow = exp(-ringDist * 25.0) * 0.6;
    
    // 颜色：内环深，外环亮
    vec3 ringColor = mix(uColor2, uColor1, progress);
    
    // 3D 明暗：根据角度模拟光照
    // 前方(下方)亮，后方(上方)暗
    float lighting = 0.5 + 0.5 * sin(rotatedAngle + PI * 0.5);
    ringColor *= 0.6 + 0.4 * lighting;
    
    // 外环更亮
    float intensity = 0.5 + progress * 0.5;
    
    color += ringColor * (ring + glow) * intensity;
    totalGlow += (ring + glow * 0.5) * intensity;
  }

  // =============================================
  // 中心光点
  // =============================================
  float centerDot = exp(-dist * 12.0) * 0.4;
  color += mix(uColor2, uColor1, 0.5) * centerDot;
  totalGlow += centerDot;

  // =============================================
  // 旋转的光线/射线 (增强旋转感)
  // =============================================
  float rays = sin(rotatedAngle * 8.0) * 0.5 + 0.5;
  rays = pow(rays, 4.0) * 0.15;
  rays *= smoothstep(0.6, 0.2, dist); // 只在中心区域
  color += uColor1 * rays * totalGlow;

  // =============================================
  // 椭圆形遮罩
  // =============================================
  float edgeFade = smoothstep(0.65, 0.15, dist);
  
  float alpha = totalGlow * edgeFade;
  alpha *= 0.85 + 0.15 * breath;
  alpha = clamp(alpha, 0.0, 1.0);

  fragColor = vec4(color, alpha);
}
