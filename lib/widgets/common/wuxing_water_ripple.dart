import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/wuxing_shader_background.dart';

/// 五行海浪层叠地面 - 角色脚下绕 Y 轴旋转的立体层叠水波
///
/// 不同于同心扩散波纹：这是**海浪**——多层波浪面绕中心旋转，
/// 前后遮挡产生层叠效果，带有透视压缩和水面折射高光。
///
/// 支持五行元素切换（水/木/火/金/土）和深色/浅色主题自动适配。
///
/// 位置建议：角色脚下、CTA 按钮下方。
class WuxingWaterRipple extends StatefulWidget {
  /// 五行属性（影响波浪形态、颜色、速度）
  final WuxingElement element;

  /// 组件宽度（null 则由父布局决定）
  final double? width;

  /// 组件高度
  final double height;

  /// 海浪中心点 (归一化 0~1)
  final Offset center;

  /// 混合模式
  final BlendMode blendMode;

  /// 自定义主色（覆盖五行/主题默认值）
  final Color? color1;

  /// 自定义辅色（覆盖五行/主题默认值）
  final Color? color2;

  /// 呼吸周期
  final Duration breathDuration;

  /// 呼吸曲线
  final Curve breathCurve;

  const WuxingWaterRipple({
    super.key,
    this.element = WuxingElement.water,
    this.width,
    this.height = 260,
    this.center = const Offset(0.5, 0.22),
    this.blendMode = BlendMode.plus,
    this.color1,
    this.color2,
    this.breathDuration = const Duration(milliseconds: 4500),
    this.breathCurve = Curves.easeInOut,
  });

  @override
  State<WuxingWaterRipple> createState() => _WuxingWaterRippleState();
}

class _WuxingWaterRippleState extends State<WuxingWaterRipple>
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
  void didUpdateWidget(WuxingWaterRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathDuration != widget.breathDuration) {
      _breathController.duration = widget.breathDuration;
    }
  }

  Future<void> _loadShader() async {
    try {
      _cachedProgram ??= await ui.FragmentProgram.fromAsset(
          'shaders/wuxing_water_ripple.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingWaterRipple] Shader load failed: $e');
    }
  }

  /// 五行 × 深浅主题 色彩矩阵
  ///
  /// 深色模式：鲜艳发光的效果
  /// 浅色模式：需要足够深的颜色保证对比度
  (Color, Color) get _themeColors {
    final isDark = AppTheme.isDark;
    return switch (widget.element) {
      // 水: 青蓝水波
      WuxingElement.water => isDark
          ? (const Color(0xFF33CCFF), const Color(0xFF1A6699)) // 深色：亮青蓝 + 深海蓝
          : (const Color(0xFF0099CC), const Color(0xFF006699)), // 浅色：深青蓝 + 海蓝 (增强对比)
      // 木: 翠绿藤浪
      WuxingElement.wood => isDark
          ? (const Color(0xFF4CAF50), const Color(0xFF1B5E20)) // 深色：翠绿 + 深绿
          : (const Color(0xFF2E7D32), const Color(0xFF1B5E20)), // 浅色：深绿 (增强对比)
      // 火: 焰橘热浪
      WuxingElement.fire => isDark
          ? (const Color(0xFFFF6B35), const Color(0xFF8B2500)) // 深色：烈焰橙 + 深红
          : (const Color(0xFFE65100), const Color(0xFFBF360C)), // 浅色：深橙 + 深红 (增强对比)
      // 金: 银霜波纹
      WuxingElement.metal => isDark
          ? (const Color(0xFFE0E0E0), const Color(0xFF757575)) // 深色：银白 + 银灰
          : (const Color(0xFF9E9E9E), const Color(0xFF616161)), // 浅色：灰色 (增强对比)
      // 土: 琥珀沙浪
      WuxingElement.earth => isDark
          ? (const Color(0xFFD4A574), const Color(0xFF6D4C2A)) // 深色：琥珀 + 深褐
          : (const Color(0xFF8D6E63), const Color(0xFF5D4037)), // 浅色：深褐 (增强对比)
    };
  }

  /// 五行枚举 → 着色器 uElement 值
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
          final (defaultC1, defaultC2) = _themeColors;
          return CustomPaint(
            painter: _RipplePainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              element: _elementValue,
              breath: _breathAnimation.value,
              center: widget.center,
              color1: widget.color1 ?? defaultC1,
              color2: widget.color2 ?? defaultC2,
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
/// [3]        float uElement   ← 新增: 五行切换
/// [4]        float uBreath
/// [5,6]      vec2  uCenter
/// [7,8,9]    vec3  uColor1
/// [10,11,12] vec3  uColor2
/// ```
class _RipplePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double element;
  final double breath;
  final Offset center;
  final Color color1;
  final Color color2;
  final BlendMode blendMode;

  _RipplePainter({
    required this.shader,
    required this.time,
    required this.element,
    required this.breath,
    required this.center,
    required this.color1,
    required this.color2,
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
    shader.setFloat(7, color1.red / 255.0);
    shader.setFloat(8, color1.green / 255.0);
    shader.setFloat(9, color1.blue / 255.0);
    shader.setFloat(10, color2.red / 255.0);
    shader.setFloat(11, color2.green / 255.0);
    shader.setFloat(12, color2.blue / 255.0);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = blendMode,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => true;
}
