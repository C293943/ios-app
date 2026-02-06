import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/wuxing_shader_background.dart';

/// 主题自适应复合动效背景 (Theme-Adaptive Composite Background)
///
/// 三层复合着色器背景：
///   - Layer A: 背景气韵流体 — 5 层 FBM + 三级 Domain Warping → 水墨烟雾
///   - Layer B: 角色脚下气场 — 极坐标螺旋水波 + 3D 透视涟漪 → 立体环形光波
///   - Layer C: 法线光影交互 — 有限差分法线 + Blinn-Phong + 菲涅尔 → 明暗闪烁
///
/// 自动适配深色/浅色主题，颜色跟随五行属性切换。
///
/// 用法示例:
/// ```dart
/// WuxingThemeBackground(
///   element: WuxingElement.water,
///   center: const Offset(0.5, 0.45),
/// )
/// ```
class WuxingThemeBackground extends StatefulWidget {
  /// 五行属性 (影响色彩、动效风格)
  final WuxingElement element;

  /// 气场中心坐标 (归一化 0~1)
  final Offset center;

  /// 自定义主色 (覆盖五行/主题默认值)
  final Color? colorBase;

  /// 自定义辅色 (覆盖五行/主题默认值)
  final Color? colorAccent;

  /// 自定义亮度 (覆盖主题自动检测, 0.0~1.0)
  final double? brightness;

  const WuxingThemeBackground({
    super.key,
    this.element = WuxingElement.water,
    this.center = const Offset(0.5, 0.45),
    this.colorBase,
    this.colorAccent,
    this.brightness,
  });

  @override
  State<WuxingThemeBackground> createState() => _WuxingThemeBackgroundState();
}

class _WuxingThemeBackgroundState extends State<WuxingThemeBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// 着色器程序缓存 (跨实例共享)
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
          'shaders/wuxing_theme_bg.frag');
      if (mounted) {
        setState(() => _shader = _cachedProgram!.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingThemeBackground] Shader load failed: $e');
    }
  }

  // =========================================================================
  //  五行 × 深浅主题 色彩矩阵
  // =========================================================================
  //
  //  | 模式  | 水 (Water)               | 火 (Fire)                |
  //  |-------|--------------------------|--------------------------|
  //  | 白天  | Base: #E0F7FA 0.9        | Base: #FFF3E0 0.85       |
  //  |       | Accent: #80DEEA          | Accent: #FFCCBC          |
  //  | 黑夜  | Base: #001F24 0.2        | Base: #210B00 0.15       |
  //  |       | Accent: #006064          | Accent: #BF360C          |
  //
  // =========================================================================

  /// 返回 (baseColor, accentColor, brightness)
  (Color, Color, double) get _themeParams {
    final isDark = AppTheme.isDark;
    final b = widget.brightness; // 用户自定义亮度

    return switch (widget.element) {
      // ═══ 水 Water ═══
      WuxingElement.water => isDark
          ? (const Color(0xFF001F24), const Color(0xFF006064), b ?? 0.2)
          : (const Color(0xFFE0F7FA), const Color(0xFF80DEEA), b ?? 0.9),

      // ═══ 木 Wood ═══
      WuxingElement.wood => isDark
          ? (const Color(0xFF0D1F0D), const Color(0xFF2E7D32), b ?? 0.18)
          : (const Color(0xFFE8F5E9), const Color(0xFFA5D6A7), b ?? 0.88),

      // ═══ 火 Fire ═══
      WuxingElement.fire => isDark
          ? (const Color(0xFF210B00), const Color(0xFFBF360C), b ?? 0.15)
          : (const Color(0xFFFFF3E0), const Color(0xFFFFCCBC), b ?? 0.85),

      // ═══ 金 Metal ═══
      WuxingElement.metal => isDark
          ? (const Color(0xFF1A1A20), const Color(0xFF757575), b ?? 0.18)
          : (const Color(0xFFF5F5F5), const Color(0xFFE0E0E0), b ?? 0.92),

      // ═══ 土 Earth ═══
      WuxingElement.earth => isDark
          ? (const Color(0xFF1A1008), const Color(0xFF6D4C2A), b ?? 0.16)
          : (const Color(0xFFFFF8E1), const Color(0xFFD4A574), b ?? 0.86),
    };
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
      // 着色器加载中: 优雅降级为静态渐变
      final (baseColor, accentColor, _) = _themeParams;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [baseColor, accentColor.withValues(alpha: 0.3)],
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final (defaultBase, defaultAccent, themeBrightness) = _themeParams;
          return CustomPaint(
            painter: _ThemeBgPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              center: widget.center,
              brightness: themeBrightness,
              colorBase: widget.colorBase ?? defaultBase,
              colorAccent: widget.colorAccent ?? defaultAccent,
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
/// [3,4]      vec2  uCenter
/// [5]        float uBrightness
/// [6,7,8]    vec3  uBaseColor
/// [9,10,11]  vec3  uAccentColor
/// ```
class _ThemeBgPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Offset center;
  final double brightness;
  final Color colorBase;
  final Color colorAccent;

  /// 复用 Paint 对象
  static final Paint _paint = Paint();

  _ThemeBgPainter({
    required this.shader,
    required this.time,
    required this.center,
    required this.brightness,
    required this.colorBase,
    required this.colorAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // [0,1] vec2 uSize
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // [2] float uTime
    shader.setFloat(2, time);

    // [3,4] vec2 uCenter
    shader.setFloat(3, center.dx);
    shader.setFloat(4, center.dy);

    // [5] float uBrightness
    shader.setFloat(5, brightness);

    // [6,7,8] vec3 uBaseColor
    shader.setFloat(6, colorBase.red / 255.0);
    shader.setFloat(7, colorBase.green / 255.0);
    shader.setFloat(8, colorBase.blue / 255.0);

    // [9,10,11] vec3 uAccentColor
    shader.setFloat(9, colorAccent.red / 255.0);
    shader.setFloat(10, colorAccent.green / 255.0);
    shader.setFloat(11, colorAccent.blue / 255.0);

    _paint.shader = shader;
    canvas.drawRect(Offset.zero & size, _paint);
  }

  @override
  bool shouldRepaint(_ThemeBgPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.brightness != brightness ||
      oldDelegate.colorBase != colorBase ||
      oldDelegate.colorAccent != colorAccent;
}
