import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/widgets/common/wuxing_shader_background.dart';

/// 五行波纹叠层 - 屏幕底部流动效果
///
/// 根据五行属性在屏幕底部渲染不同风格的波纹/流动效果：
/// - 水：多层正弦波叠加，高频细碎波光，带透视感
/// - 木：低频漂移叶影，风中摆动
/// - 火：垂直向上升腾的热浪
/// - 金：金属拉丝线性闪光 (Linear Glint)
/// - 土：缓慢流动的细沙颗粒
///
/// 支持通过 [center] 参数实时更新波纹中心位置，可接入触摸/拖拽交互。
/// 默认占据屏幕底部 [heightFraction] 比例的区域。
class WuxingWaveOverlay extends StatefulWidget {
  /// 五行属性
  final WuxingElement element;

  /// 波纹中心点（归一化坐标 0~1），默认屏幕中央底部
  final Offset center;

  /// 波纹区域占屏幕高度的比例，默认 0.35（底部 35%）
  final double heightFraction;

  /// 主色（覆盖默认五行配色）
  final Color? color1;

  /// 辅色（覆盖默认五行配色）
  final Color? color2;

  const WuxingWaveOverlay({
    super.key,
    this.element = WuxingElement.water,
    this.center = const Offset(0.5, 0.5),
    this.heightFraction = 0.35,
    this.color1,
    this.color2,
  });

  @override
  State<WuxingWaveOverlay> createState() => _WuxingWaveOverlayState();
}

class _WuxingWaveOverlayState extends State<WuxingWaveOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const String _shaderPath = 'shaders/wuxing_wave.frag';

  /// 着色器程序缓存（跨实例共享）
  static ui.FragmentProgram? _programCache;

  ui.FragmentShader? _shader;
  late final AnimationController _animController;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _loadShader();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _animController.stop();
        _stopwatch.stop();
        break;
      case AppLifecycleState.resumed:
        _stopwatch.start();
        _animController.repeat();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _loadShader() async {
    try {
      ui.FragmentProgram program;
      if (_programCache != null) {
        program = _programCache!;
      } else {
        program = await ui.FragmentProgram.fromAsset(_shaderPath);
        _programCache = program;
      }
      if (mounted) {
        setState(() => _shader = program.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingWave] Failed to load: $_shaderPath — $e');
    }
  }

  /// 五行属性对应的 shader uElement 索引值
  double get _elementIndex => switch (widget.element) {
        WuxingElement.water => 0.0,
        WuxingElement.wood => 1.0,
        WuxingElement.fire => 2.0,
        WuxingElement.metal => 3.0,
        WuxingElement.earth => 4.0,
      };

  /// 获取五行默认配色 [主色, 辅色]
  List<Color> get _defaultColors => switch (widget.element) {
        WuxingElement.water => const [Color(0xFF80DEEA), Color(0xFFB2EBF2)],
        WuxingElement.wood => const [Color(0xFFA5D6A7), Color(0xFFF1F8E9)],
        WuxingElement.fire => const [Color(0xFFFFAB91), Color(0xFFFFCCBC)],
        WuxingElement.metal => const [Color(0xFFF5F5F5), Color(0xFFFFF176)],
        WuxingElement.earth => const [Color(0xFFFFECB3), Color(0xFFD7CCC8)],
      };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const SizedBox.shrink();
    }

    final defaults = _defaultColors;
    final c1 = widget.color1 ?? defaults[0];
    final c2 = widget.color2 ?? defaults[1];

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: widget.heightFraction,
        widthFactor: 1.0,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return CustomPaint(
                painter: _WuxingWavePainter(
                  shader: _shader!,
                  time: _stopwatch.elapsedMilliseconds / 1000.0,
                  elementIndex: _elementIndex,
                  center: widget.center,
                  color1: c1,
                  color2: c2,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 波纹着色器绘制器
///
/// Uniform 布局：
///   0,1  - uSize    (vec2)
///   2    - uTime    (float)
///   3    - uElement (float)
///   4,5  - uCenter  (vec2)
///   6,7,8   - uColor1 (vec3)
///   9,10,11 - uColor2 (vec3)
class _WuxingWavePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double elementIndex;
  final Offset center;
  final Color color1;
  final Color color2;

  static final Paint _shaderPaint = Paint();

  _WuxingWavePainter({
    required this.shader,
    required this.time,
    required this.elementIndex,
    required this.center,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // uniform vec2 uSize
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // uniform float uTime
    shader.setFloat(2, time);

    // uniform float uElement
    shader.setFloat(3, elementIndex);

    // uniform vec2 uCenter
    shader.setFloat(4, center.dx);
    shader.setFloat(5, center.dy);

    // uniform vec3 uColor1
    shader.setFloat(6, color1.red / 255.0);
    shader.setFloat(7, color1.green / 255.0);
    shader.setFloat(8, color1.blue / 255.0);

    // uniform vec3 uColor2
    shader.setFloat(9, color2.red / 255.0);
    shader.setFloat(10, color2.green / 255.0);
    shader.setFloat(11, color2.blue / 255.0);

    _shaderPaint.shader = shader;
    canvas.drawRect(Offset.zero & size, _shaderPaint);
  }

  @override
  bool shouldRepaint(_WuxingWavePainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.elementIndex != elementIndex ||
      oldDelegate.center != center;
}
