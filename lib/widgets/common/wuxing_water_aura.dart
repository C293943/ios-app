import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 3D 水波气场与涟漪 — 角色脚下动态且具有 3D 纵深感的水波气场
///
/// 核心效果：
///   - 中心环绕水波：极坐标 FBM 扭曲 + 旋转 → 立体环形水波
///   - 底部透视涟漪：UV 非线性映射 → 近大远小的 3D 地面波纹
///   - 流体光影：有限差分法线 + 虚拟光源 → 高光/菲涅尔/反射
///   - 水花飞溅：高频噪点 → 动态边缘碎片
///
/// 位置建议：角色立绘脚下、CTA 按钮下方。
class WuxingWaterAura extends StatefulWidget {
  /// 组件宽度（null 则由父布局决定）
  final double? width;

  /// 组件高度
  final double height;

  /// 水波气场中心点 (归一化 0~1)
  final Offset center;

  /// 混合模式
  final BlendMode blendMode;

  /// 主色 (清澈青蓝色系)
  final Color colorBase;

  /// 辅色/高光色
  final Color colorAccent;

  const WuxingWaterAura({
    super.key,
    this.width,
    this.height = 320,
    this.center = const Offset(0.5, 0.3),
    this.blendMode = BlendMode.plus,
    this.colorBase = const Color(0xFF80DEEA),
    this.colorAccent = const Color(0xFFB2EBF2),
  });

  @override
  State<WuxingWaterAura> createState() => _WuxingWaterAuraState();
}

class _WuxingWaterAuraState extends State<WuxingWaterAura>
    with SingleTickerProviderStateMixin {
  static ui.FragmentProgram? _cachedProgram;

  ui.FragmentShader? _shader;
  late final AnimationController _tickController;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      _cachedProgram ??= await ui.FragmentProgram.fromAsset(
          'shaders/wuxing_water_aura.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingWaterAura] Shader load failed: $e');
    }
  }

  @override
  void dispose() {
    _tickController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _tickController,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaterAuraPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              center: widget.center,
              colorBase: widget.colorBase,
              colorAccent: widget.colorAccent,
              blendMode: widget.blendMode,
            ),
            size: Size(
              widget.width ?? double.infinity,
              widget.height,
            ),
          );
        },
      ),
    );
  }
}

/// Uniform 布局:
/// ```
/// [0,1]      vec2  uSize
/// [2]        float uTime
/// [3,4]      vec2  uCenter
/// [5,6,7]    vec3  uColorBase
/// [8,9,10]   vec3  uColorAccent
/// ```
class _WaterAuraPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Offset center;
  final Color colorBase;
  final Color colorAccent;
  final BlendMode blendMode;

  _WaterAuraPainter({
    required this.shader,
    required this.time,
    required this.center,
    required this.colorBase,
    required this.colorAccent,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // vec2 uSize
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // float uTime
    shader.setFloat(2, time);

    // vec2 uCenter
    shader.setFloat(3, center.dx);
    shader.setFloat(4, center.dy);

    // vec3 uColorBase
    shader.setFloat(5, colorBase.red / 255.0);
    shader.setFloat(6, colorBase.green / 255.0);
    shader.setFloat(7, colorBase.blue / 255.0);

    // vec3 uColorAccent
    shader.setFloat(8, colorAccent.red / 255.0);
    shader.setFloat(9, colorAccent.green / 255.0);
    shader.setFloat(10, colorAccent.blue / 255.0);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = blendMode,
    );
  }

  @override
  bool shouldRepaint(_WaterAuraPainter oldDelegate) => true;
}
