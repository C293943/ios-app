import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/widgets/common/wuxing_shader_background.dart';

/// 五行三维气韵漩涡 - 具有 3D 深度感和体积光照的气韵背景
///
/// 在角色背后渲染一个带有透视感的旋转环形气流，具有：
/// - **3.5D 噪声流场**：FBM + 3D noise 在极坐标中产生丝绸般扭动
/// - **体积散射**：多层半透明采样累加，模拟光线穿透气流
/// - **法线扰动照明**：噪声求导计算法线 → Blinn-Phong 光照
/// - **运动模糊**：时间轴 3 帧微偏移加权混合
/// - **底部 3D 涟漪**：透视变形的水平面波纹
///
/// ## Canvas 层叠
/// ```
/// Stack(
///   children: [
///     WuxingShaderBackground(...),  // 底层: 五行弥散
///     Wuxing3dVortex(...),          // 中层: 3D 漩涡 (BlendMode.plus)
///     WuxingAuraRing(...),          // 中层: 气韵环
///     CharacterWidget(...),         // 顶层: 角色
///   ],
/// )
/// ```
class Wuxing3dVortex extends StatefulWidget {
  /// 五行属性
  final WuxingElement element;

  /// 组件宽度 (逻辑像素)
  final double width;

  /// 组件高度 (逻辑像素)
  final double height;

  /// 漩涡中心 (归一化 0~1, 相对于组件)
  final Offset center;

  /// 混合模式 (建议 [BlendMode.plus] 或 [BlendMode.screen])
  final BlendMode blendMode;

  /// 自定义主色
  final Color? colorMain;

  /// 自定义辅色
  final Color? colorAccent;

  /// 呼吸周期
  final Duration breathDuration;

  /// 呼吸缓动曲线
  final Curve breathCurve;

  const Wuxing3dVortex({
    super.key,
    this.element = WuxingElement.water,
    this.width = 320,
    this.height = 400,
    this.center = const Offset(0.5, 0.4),
    this.blendMode = BlendMode.plus,
    this.colorMain,
    this.colorAccent,
    this.breathDuration = const Duration(milliseconds: 5000),
    this.breathCurve = Curves.easeInOut,
  });

  @override
  State<Wuxing3dVortex> createState() => _Wuxing3dVortexState();
}

class _Wuxing3dVortexState extends State<Wuxing3dVortex>
    with TickerProviderStateMixin {
  static ui.FragmentProgram? _cachedProgram;

  ui.FragmentShader? _shader;

  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;
  late final AnimationController _tickController;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    _breathController = AnimationController(
      vsync: this,
      duration: widget.breathDuration,
    )..repeat(reverse: true);
    _breathAnimation = CurvedAnimation(
      parent: _breathController,
      curve: widget.breathCurve,
      reverseCurve: widget.breathCurve,
    );

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadShader();
  }

  @override
  void didUpdateWidget(Wuxing3dVortex oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathDuration != widget.breathDuration) {
      _breathController.duration = widget.breathDuration;
    }
  }

  Future<void> _loadShader() async {
    try {
      _cachedProgram ??=
          await ui.FragmentProgram.fromAsset('shaders/wuxing_3d_vortex.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[Wuxing3dVortex] Shader load failed: $e');
    }
  }

  /// 五行默认色彩对
  ///
  /// 这里使用更鲜明的主色+柔和辅色，专为 3D 体积效果优化：
  /// 主色在内环/高光处发力，辅色在外缘/散射处烘托氛围
  (Color, Color) get _defaultColors => switch (widget.element) {
        WuxingElement.water => (
            const Color(0xFF80DEEA), // 水灵青
            const Color(0xFFB2EBF2), // 浅冰蓝
          ),
        WuxingElement.wood => (
            const Color(0xFFA5D6A7), // 翠叶绿
            const Color(0xFFF1F8E9), // 嫩芽黄
          ),
        WuxingElement.fire => (
            const Color(0xFFFFAB91), // 焰橘红
            const Color(0xFFFFCCBC), // 晕染粉
          ),
        WuxingElement.metal => (
            const Color(0xFFF5F5F5), // 银霜白
            const Color(0xFFFFF176), // 鎏金黄
          ),
        WuxingElement.earth => (
            const Color(0xFFFFECB3), // 琥珀暖
            const Color(0xFFD7CCC8), // 陶土灰
          ),
      };

  double get _elementValue => switch (widget.element) {
        WuxingElement.water => 0.0,
        WuxingElement.wood => 1.0,
        WuxingElement.fire => 2.0,
        WuxingElement.metal => 3.0,
        WuxingElement.earth => 4.0,
      };

  @override
  void dispose() {
    _breathController.dispose();
    _tickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_tickController, _breathAnimation]),
        builder: (context, _) {
          final (defaultMain, defaultAccent) = _defaultColors;
          return CustomPaint(
            painter: _VortexPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              element: _elementValue,
              breath: _breathAnimation.value,
              center: widget.center,
              colorMain: widget.colorMain ?? defaultMain,
              colorAccent: widget.colorAccent ?? defaultAccent,
              blendMode: widget.blendMode,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

/// 漩涡着色器绘制器
///
/// Uniform 布局:
/// ```
/// [0,1]       vec2  uSize        — 画布尺寸 (px)
/// [2]         float uTime        — 动画时间 (秒)
/// [3]         float uElement     — 五行 (0-4)
/// [4]         float uBreath      — 呼吸值 (0-1)
/// [5,6]       vec2  uCenter      — 漩涡中心 (归一化)
/// [7,8,9]     vec3  uColorMain   — 主色 (归一化 RGB)
/// [10,11,12]  vec3  uColorAccent — 辅色 (归一化 RGB)
/// ```
class _VortexPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double element;
  final double breath;
  final Offset center;
  final Color colorMain;
  final Color colorAccent;
  final BlendMode blendMode;

  _VortexPainter({
    required this.shader,
    required this.time,
    required this.element,
    required this.breath,
    required this.center,
    required this.colorMain,
    required this.colorAccent,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, element);
    shader.setFloat(4, breath);
    shader.setFloat(5, center.dx);
    shader.setFloat(6, center.dy);
    shader.setFloat(7, colorMain.red / 255.0);
    shader.setFloat(8, colorMain.green / 255.0);
    shader.setFloat(9, colorMain.blue / 255.0);
    shader.setFloat(10, colorAccent.red / 255.0);
    shader.setFloat(11, colorAccent.green / 255.0);
    shader.setFloat(12, colorAccent.blue / 255.0);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = blendMode,
    );
  }

  @override
  bool shouldRepaint(_VortexPainter oldDelegate) => true;
}
