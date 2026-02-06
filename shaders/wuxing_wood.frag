// 五行・木 (Wood Element) - 扩散的叶片影迹
// 翠绿、嫩黄、浅咖交织的有机生长纹理
// 技法：Voronoi 细胞 + 风摆噪声 → 模拟树影婆娑

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;  // 翠绿 (Emerald green)
uniform vec3 uColor2;  // 嫩黄 (Tender yellow)
uniform vec3 uColor3;  // 浅咖 (Light brown)

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

// Voronoi 细胞图案（模拟叶片轮廓）
float cellPattern(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float minDist = 1.0;
  for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
      vec2 n = vec2(float(x), float(y));
      vec2 pt = vec2(
        hash(i + n),
        hash(i + n + vec2(57.0, 113.0))
      );
      float d = length(n + pt - f);
      minDist = min(minDist, d);
    }
  }
  return minDist;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * 0.12;
  
  // 呼吸韵律（统一基准：周期 ~6s）
  float breath = sin(t * 1.6) * 0.5 + 0.5;
  
  // === 风摆效果 ===
  vec2 swayed = uv + vec2(
    sin(uv.y * 3.0 + t * 2.0) * 0.015,
    cos(uv.x * 2.5 + t * 1.5) * 0.01
  );
  
  // 叶影细胞
  float cells = cellPattern(swayed * 5.0 + vec2(t * 0.3, t * 0.2));
  float leafShadow = smoothstep(0.08, 0.45, cells);
  
  // 有机 FBM 纹理（树皮/叶脉质感）— 保留用于年轮计算
  // float organic = fbm(swayed * 2.5 + vec2(t * 0.2, t * 0.15));
  
  // Domain Warping 增加层次
  vec2 warp = vec2(
    fbm(swayed * 2.0 + vec2(t * 0.1, 0.0)),
    fbm(swayed * 2.0 + vec2(0.0, t * 0.1))
  );
  float warped = fbm(swayed * 2.0 + 3.0 * warp);
  
  // 年轮扩散效果
  float rings = sin(length(uv - vec2(0.35, 0.65)) * 12.0 + warped * 4.0 + t) * 0.5 + 0.5;
  
  // === 色彩混合 ===
  vec3 color = mix(uColor1, uColor2, smoothstep(0.2, 0.8, warped));
  color = mix(color, uColor3, leafShadow * 0.3);
  color = mix(color, uColor1 * 1.05, rings * 0.12 * breath);
  
  // 光斑效果（树叶缝隙透光）
  float dapple = smoothstep(0.25, 0.55, cells) * smoothstep(0.75, 0.45, cells);
  color += uColor2 * dapple * breath * 0.08;
  
  // 微妙色彩漂移（让背景更有生命感）
  color = mix(color, uColor2 * 0.8 + uColor1 * 0.2, sin(t * 0.35) * 0.04);
  
  // 柔和暗角
  float vig = 1.0 - smoothstep(0.35, 0.8, length(uv - 0.5));
  color *= 0.93 + 0.07 * vig;
  
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
