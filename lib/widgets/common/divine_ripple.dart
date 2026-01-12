import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 金色神圣风格水波动效组件
/// 用于营造蛋或元神在上方飘着的效果
class DivineRipple extends StatefulWidget {
  final double width;
  final double height;
  final Color? baseColor;

  const DivineRipple({
    super.key,
    this.width = 300,
    this.height = 100,
    this.baseColor,
  });

  @override
  State<DivineRipple> createState() => _DivineRippleState();
}

class _DivineRippleState extends State<DivineRipple>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();

    // 水波扩散动画
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // 闪烁粒子动画
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? const Color(0xFFFFD700); // 金色

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 多层水波纹
          ...List.generate(4, (index) {
            return AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                final delay = index * 0.25;
                final animationValue = ((_rippleController.value + delay) % 1.0);

                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _RipplePainter(
                    progress: animationValue,
                    color: baseColor.withValues(alpha: 0.3 - index * 0.05),
                    waveCount: 3 + index,
                    amplitude: 10.0 + index * 2,
                ),
                );
              },
            );
          }),

          // 闪烁粒子
          ...List.generate(8, (index) {
            return AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                final delay = index * 0.125;
                final animationValue = ((_sparkleController.value + delay) % 1.0);

                final angle = (index / 8) * 2 * math.pi;
                final distance = 30.0 + 50.0 * animationValue;
                final opacity = (1.0 - animationValue) * 0.8;

                final x = widget.width / 2 + math.cos(angle) * distance;
                final y = widget.height / 2 + math.sin(angle) * distance * 0.5;

                return Positioned(
                  left: x - 3,
                  top: y - 3,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseColor,
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.8),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 中心光晕
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              final pulse = 0.8 + 0.2 * math.sin(_rippleController.value * 2 * math.pi);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        baseColor.withValues(alpha: 0.4),
                        baseColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 水波纹绘制器
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int waveCount;
  final double amplitude;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.waveCount,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制椭圆波纹
    final radiusX = size.width * 0.3 * progress;
    final radiusY = size.height * 0.3 * progress;

    path.addOval(Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: radiusX * 2,
      height: radiusY * 2,
    ));

    canvas.drawPath(path, paint);

    // 绘制波浪线
    final wavePath = Path();
    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (progress + i / waveCount) % 1.0;
      final waveRadiusX = size.width * 0.4 * waveProgress;
      final waveRadiusY = size.height * 0.3 * waveProgress;

      final rect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: waveRadiusX * 2,
        height: waveRadiusY * 2,
      );

      // 绘制波浪椭圆
      wavePath.addOval(rect);
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
