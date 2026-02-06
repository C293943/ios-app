import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/widgets/common/wuxing_shader_background.dart';

/// 五行气韵环 - GLSL Fragment Shader 驱动的角色光环
///
/// 基于极坐标的环形气韵效果，结合噪声产生丝绸/云雾般的有机扭动。
/// 设计为放置在角色背后，通过 [BlendMode.plus] 或 [BlendMode.screen]
/// 实现发光的半透明叠加效果。
///
/// ## Canvas 层叠建议 (由外到内)
/// ```
/// Stack(
///   children: [
///     WuxingShaderBackground(...),    // 底层：五行弥散背景
///     WuxingAuraRing(...),            // 中层：气韵环 (BlendMode.plus)
///     CharacterWidget(...),           // 顶层：角色 Spine/PNG
///   ],
/// )
/// ```
///
/// ## 呼吸动画
/// 内部使用 [CurvedAnimation] + [Curves.easeInOut] 驱动 `uBreath` uniform，
/// 让波纹产生周期性的收缩与扩张，而非恒定速度增长。
class WuxingAuraRing extends StatefulWidget {
  /// 五行属性（决定颜色、噪声参数、特殊效果）
  final WuxingElement element;

  /// 气韵环尺寸（逻辑像素，宽高相同）
  final double size;

  /// 混合模式（建议 [BlendMode.plus] 或 [BlendMode.screen]）
  final BlendMode blendMode;

  /// 自定义主色（覆盖五行默认值）
  final Color? color1;

  /// 自定义辅色（覆盖五行默认值）
  final Color? color2;

  /// 呼吸周期时长
  final Duration breathDuration;

  /// 呼吸缓动曲线
  final Curve breathCurve;

  const WuxingAuraRing({
    super.key,
    this.element = WuxingElement.water,
    this.size = 260,
    this.blendMode = BlendMode.plus,
    this.color1,
    this.color2,
    this.breathDuration = const Duration(milliseconds: 4000),
    this.breathCurve = Curves.easeInOut,
  });

  @override
  State<WuxingAuraRing> createState() => _WuxingAuraRingState();
}

class _WuxingAuraRingState extends State<WuxingAuraRing>
    with TickerProviderStateMixin {
  /// 着色器程序缓存（单例）
  static ui.FragmentProgram? _cachedProgram;

  ui.FragmentShader? _shader;

  /// 呼吸控制器：[0→1→0] 循环, 配合缓动曲线
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  /// 帧驱动器：仅用于触发每帧重绘
  late final AnimationController _tickController;

  /// 精确时间源（替代 AnimationController.value 避免精度损失）
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    // 呼吸动画：用 CurvedAnimation 实现缓入缓出的收缩/扩张
    _breathController = AnimationController(
      vsync: this,
      duration: widget.breathDuration,
    )..repeat(reverse: true);
    _breathAnimation = CurvedAnimation(
      parent: _breathController,
      curve: widget.breathCurve,
      reverseCurve: widget.breathCurve,
    );

    // 帧驱动
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadShader();
  }

  @override
  void didUpdateWidget(WuxingAuraRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathDuration != widget.breathDuration) {
      _breathController.duration = widget.breathDuration;
    }
  }

  Future<void> _loadShader() async {
    try {
      _cachedProgram ??=
          await ui.FragmentProgram.fromAsset('shaders/wuxing_aura_ring.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingAuraRing] Shader load failed: $e');
    }
  }

  /// 五行默认色彩对 (主色, 辅色)
  ///
  /// 色彩说明:
  /// | 五行 | 主色     | 辅色     | 视觉逻辑                     |
  /// |------|----------|----------|------------------------------|
  /// | 水   | #80DEEA  | #B2EBF2  | 高频振幅，细碎波光           |
  /// | 木   | #A5D6A7  | #F1F8E9  | 低频漂移，叶片风摆           |
  /// | 火   | #FFAB91  | #FFCCBC  | 垂直位移，Y轴向上流动        |
  /// | 金   | #F5F5F5  | #FFF176  | 高光闪烁，金属反光           |
  /// | 土   | #FFECB3  | #D7CCC8  | 颗粒度，随机微小像素点       |
  (Color, Color) get _defaultColors => switch (widget.element) {
        WuxingElement.water => (
            const Color(0xFF80DEEA),
            const Color(0xFFB2EBF2)
          ),
        WuxingElement.wood => (
            const Color(0xFFA5D6A7),
            const Color(0xFFF1F8E9)
          ),
        WuxingElement.fire => (
            const Color(0xFFFFAB91),
            const Color(0xFFFFCCBC)
          ),
        WuxingElement.metal => (
            const Color(0xFFF5F5F5),
            const Color(0xFFFFF176)
          ),
        WuxingElement.earth => (
            const Color(0xFFFFECB3),
            const Color(0xFFD7CCC8)
          ),
      };

  /// 五行枚举 → 着色器 uElement 数值
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
      // 着色器加载中：显示透明占位
      return SizedBox(width: widget.size, height: widget.size);
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_tickController, _breathAnimation]),
        builder: (context, _) {
          final (defaultC1, defaultC2) = _defaultColors;
          return CustomPaint(
            painter: _AuraRingPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              element: _elementValue,
              breath: _breathAnimation.value,
              color1: widget.color1 ?? defaultC1,
              color2: widget.color2 ?? defaultC2,
              blendMode: widget.blendMode,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

/// 气韵环着色器绘制器
///
/// Uniform 布局:
/// ```
/// [0,1]     vec2  uSize    — 画布尺寸
/// [2]       float uTime    — 动画时间 (秒)
/// [3]       float uElement — 五行属性 (0-4)
/// [4]       float uBreath  — 呼吸值 (0-1, eased)
/// [5,6,7]   vec3  uColor1  — 主色 (归一化 RGB)
/// [8,9,10]  vec3  uColor2  — 辅色 (归一化 RGB)
/// ```
class _AuraRingPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double element;
  final double breath;
  final Color color1;
  final Color color2;
  final BlendMode blendMode;

  _AuraRingPainter({
    required this.shader,
    required this.time,
    required this.element,
    required this.breath,
    required this.color1,
    required this.color2,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- 设置 Uniforms ---
    shader.setFloat(0, size.width); // uSize.x
    shader.setFloat(1, size.height); // uSize.y
    shader.setFloat(2, time); // uTime
    shader.setFloat(3, element); // uElement
    shader.setFloat(4, breath); // uBreath
    shader.setFloat(5, color1.red / 255.0); // uColor1.r
    shader.setFloat(6, color1.green / 255.0); // uColor1.g
    shader.setFloat(7, color1.blue / 255.0); // uColor1.b
    shader.setFloat(8, color2.red / 255.0); // uColor2.r
    shader.setFloat(9, color2.green / 255.0); // uColor2.g
    shader.setFloat(10, color2.blue / 255.0); // uColor2.b

    // --- 绘制 ---
    // 使用指定的 BlendMode (建议 BlendMode.plus 或 BlendMode.screen)
    // 使气韵效果呈现出"发光"的半透明感
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..blendMode = blendMode,
    );
  }

  @override
  bool shouldRepaint(_AuraRingPainter oldDelegate) => true;
}
