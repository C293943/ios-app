import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 玄虚幽冥 · 仙侠深渊背景 (Mystic Void Background)
///
/// 一个沉浸式的玄幻/仙侠/玄学主题全屏 GLSL 背景：
///   - 深渊星空: 多层噪声星云 + 散落星辰 + 闪烁
///   - 灵力气韵: 3D FBM Domain Warping → 丝绸般灵力流线
///   - 符文光阵: 极坐标旋转法阵 + 六芒几何线
///   - 灵力粒子: 向上飘散的灵力光点
///   - 边缘神光: 四角射入的幽冥光柱
///
/// 自动适配深色/浅色主题。
///
/// 用法:
/// ```dart
/// WuxingMysticBackground()  // 放在 Stack 最底层即可
/// ```
class WuxingMysticBackground extends StatefulWidget {
  const WuxingMysticBackground({super.key});

  @override
  State<WuxingMysticBackground> createState() =>
      _WuxingMysticBackgroundState();
}

class _WuxingMysticBackgroundState extends State<WuxingMysticBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static ui.FragmentProgram? _cachedProgram;

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
      _cachedProgram ??= await ui.FragmentProgram.fromAsset(
          'shaders/wuxing_mystic_void.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingMysticBackground] Shader load failed: $e');
    }
  }

  /// 深色/浅色主题色彩矩阵
  ///
  /// 三色组: [深渊底色, 灵力主色, 高光辅色]
  ///
  /// 深色模式: 深邃玄黑 + 冷色灵气 + 鎏金辅光
  /// 浅色模式: 水墨浅灰 + 淡雅青蓝 + 暖金辅色 (降低对比但保留仙侠感)
  List<Color> get _themeColors {
    final isDark = AppTheme.isDark;
    return isDark
        ? const [
            Color(0xFF070F12), // 深渊玄黑 (极暗青黑)
            Color(0xFF22D3EE), // 灵气青 (荧光青)
            Color(0xFFC8AA6E), // 鎏金 (暗金)
          ]
        : const [
            Color(0xFFE8EEF0), // 水墨浅灰 (带微青)
            Color(0xFF0E7490), // 深青 (对比度足够)
            Color(0xFF785C32), // 古铜金 (浅色模式)
          ];
  }

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
      // 优雅降级: 静态深色背景
      return Container(color: AppTheme.voidBackground);
    }

    final colors = _themeColors;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            painter: _MysticPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              color1: colors[0],
              color2: colors[1],
              color3: colors[2],
            ),
            child: const SizedBox.expand(),
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
/// [3,4,5]    vec3  uColor1   深渊底色
/// [6,7,8]    vec3  uColor2   灵力主色
/// [9,10,11]  vec3  uColor3   高光辅色
/// ```
class _MysticPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Color color1;
  final Color color2;
  final Color color3;

  static final Paint _paint = Paint();

  _MysticPainter({
    required this.shader,
    required this.time,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);

    // uColor1 深渊底色
    shader.setFloat(3, color1.red / 255.0);
    shader.setFloat(4, color1.green / 255.0);
    shader.setFloat(5, color1.blue / 255.0);

    // uColor2 灵力主色
    shader.setFloat(6, color2.red / 255.0);
    shader.setFloat(7, color2.green / 255.0);
    shader.setFloat(8, color2.blue / 255.0);

    // uColor3 高光辅色
    shader.setFloat(9, color3.red / 255.0);
    shader.setFloat(10, color3.green / 255.0);
    shader.setFloat(11, color3.blue / 255.0);

    _paint.shader = shader;
    canvas.drawRect(Offset.zero & size, _paint);
  }

  @override
  bool shouldRepaint(_MysticPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.color1 != color1 ||
      oldDelegate.color2 != color2 ||
      oldDelegate.color3 != color3;
}
