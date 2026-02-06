import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 五行属性枚举
enum WuxingElement {
  water, // 水 - 青蓝、浅绿、白色
  fire, // 火 - 朱红、橙黄、淡紫
  wood, // 木 - 翠绿、嫩黄、浅咖
  metal, // 金 - 金黄、纯白、银灰
  earth, // 土 - 琥珀、深黄、浅褐
}

/// 五行着色器背景 - 使用 GLSL Fragment Shader 渲染
///
/// 为每种五行属性提供独特的艺术级渐变背景：
/// - 多种相近色系交织，带有微弱的呼吸感
/// - 低饱和度、高明度，如烟雾或流体般的渐变
/// - 每种五行都有独特的视觉算法（水波、火焰、叶影、金属、地层）
///
/// 技术实现：
/// - 使用 Flutter dart:ui FragmentProgram API 加载编译后的 GLSL 着色器
/// - 通过 Stopwatch 驱动时间 uniform，实现连续动画
/// - 颜色根据深色/浅色模式自动适配
/// - 支持 App 生命周期感知：后台自动暂停，恢复前台继续动画
class WuxingShaderBackground extends StatefulWidget {
  final WuxingElement element;

  const WuxingShaderBackground({
    super.key,
    this.element = WuxingElement.water,
  });

  @override
  State<WuxingShaderBackground> createState() =>
      _WuxingShaderBackgroundState();
}

class _WuxingShaderBackgroundState extends State<WuxingShaderBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// 着色器程序缓存（跨实例共享，避免重复编译）
  static final Map<String, ui.FragmentProgram> _programCache = {};

  ui.FragmentShader? _shader;
  late final AnimationController _animController;
  final Stopwatch _stopwatch = Stopwatch();

  /// 当前已加载的 shader 路径，用于避免重复加载同一 element 的 shader
  String? _loadedShaderPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
    // AnimationController 仅用于驱动每帧重绘，实际时间由 Stopwatch 提供
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _loadShader();
  }

  @override
  void didUpdateWidget(WuxingShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _loadShader();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App 进入后台或不可见时暂停动画，节省 GPU/电池
        _animController.stop();
        _stopwatch.stop();
        break;
      case AppLifecycleState.resumed:
        // App 恢复前台时继续动画
        _stopwatch.start();
        _animController.repeat();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _loadShader() async {
    final path = _shaderPath;
    // 避免对同一 element 重复创建 shader 实例
    if (path == _loadedShaderPath && _shader != null) return;

    try {
      ui.FragmentProgram program;
      if (_programCache.containsKey(path)) {
        program = _programCache[path]!;
      } else {
        program = await ui.FragmentProgram.fromAsset(path);
        _programCache[path] = program;
      }
      if (mounted) {
        _loadedShaderPath = path;
        setState(() => _shader = program.fragmentShader());
      }
    } catch (e) {
      debugPrint('[WuxingShader] Failed to load: $path — $e');
    }
  }

  String get _shaderPath => switch (widget.element) {
        WuxingElement.water => 'shaders/wuxing_water.frag',
        WuxingElement.fire => 'shaders/wuxing_fire.frag',
        WuxingElement.wood => 'shaders/wuxing_wood.frag',
        WuxingElement.metal => 'shaders/wuxing_metal.frag',
        WuxingElement.earth => 'shaders/wuxing_earth.frag',
      };

  /// 获取当前五行属性的色彩组 [主色, 辅色, 点缀色]
  ///
  /// 浅色模式：低饱和度、高明度 — 如宣纸上的淡彩
  /// 深色模式：深沉含蓄、微光暗涌 — 如夜空中的星云
  List<Color> get _elementColors {
    final isDark = AppTheme.isDark;
    return switch (widget.element) {
      // 水：青蓝 → 浅绿 → 白
      WuxingElement.water => isDark
          ? const [Color(0xFF1A3854), Color(0xFF1C4040), Color(0xFF243848)]
          : const [Color(0xFFD0E8F0), Color(0xFFDCF0E4), Color(0xFFF0F8FC)],
      // 火：朱红 → 橙黄 → 淡紫
      WuxingElement.fire => isDark
          ? const [Color(0xFF4C2028), Color(0xFF4C3820), Color(0xFF342040)]
          : const [Color(0xFFF0D0C8), Color(0xFFF0E0C0), Color(0xFFE4D4EC)],
      // 木：翠绿 → 嫩黄 → 浅咖
      WuxingElement.wood => isDark
          ? const [Color(0xFF1C3C1C), Color(0xFF343420), Color(0xFF2C2418)]
          : const [Color(0xFFCCE8CC), Color(0xFFE8E4B8), Color(0xFFDCD0C0)],
      // 金：金黄 → 纯白 → 银灰
      WuxingElement.metal => isDark
          ? const [Color(0xFF3C3418), Color(0xFF2C2C2C), Color(0xFF242430)]
          : const [Color(0xFFE8DCC0), Color(0xFFF8F8F8), Color(0xFFE0E0E8)],
      // 土：琥珀 → 深黄 → 浅褐
      WuxingElement.earth => isDark
          ? const [Color(0xFF3C2C14), Color(0xFF302410), Color(0xFF282018)]
          : const [Color(0xFFE0CCA0), Color(0xFFD8BC88), Color(0xFFD0C0A8)],
    };
  }

  /// 预计算归一化 RGB 值列表（避免每帧重复 / 255.0 运算）
  /// 返回 9 个 double：[r1, g1, b1, r2, g2, b2, r3, g3, b3]
  List<double> _normalizedColors(List<Color> colors) {
    return [
      for (final c in colors) ...[
        c.red / 255.0,
        c.green / 255.0,
        c.blue / 255.0,
      ],
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
      // 着色器加载中的优雅降级：显示五行主色调的静态渐变
      final colors = _elementColors;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      );
    }

    final colors = _elementColors;
    final normalizedColors = _normalizedColors(colors);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            painter: _WuxingShaderPainter(
              shader: _shader!,
              time: _stopwatch.elapsedMilliseconds / 1000.0,
              normalizedColors: normalizedColors,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

/// 着色器绘制器
///
/// 每帧设置 uniform 并绘制全屏四边形：
/// - uSize (vec2): 画布逻辑像素尺寸
/// - uTime (float): 动画时间（秒）
/// - uColor1/2/3 (vec3): 五行三色组（归一化 RGB）
class _WuxingShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final List<double> normalizedColors;

  /// 复用 Paint 对象，避免每帧分配
  static final Paint _shaderPaint = Paint();

  _WuxingShaderPainter({
    required this.shader,
    required this.time,
    required this.normalizedColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // uniform vec2 uSize (indices 0, 1)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // uniform float uTime (index 2)
    shader.setFloat(2, time);

    // uniform vec3 uColor1 (indices 3, 4, 5)
    // uniform vec3 uColor2 (indices 6, 7, 8)
    // uniform vec3 uColor3 (indices 9, 10, 11)
    for (int i = 0; i < 9; i++) {
      shader.setFloat(3 + i, normalizedColors[i]);
    }

    _shaderPaint.shader = shader;
    canvas.drawRect(Offset.zero & size, _shaderPaint);
  }

  @override
  bool shouldRepaint(_WuxingShaderPainter oldDelegate) =>
      oldDelegate.time != time;
}
