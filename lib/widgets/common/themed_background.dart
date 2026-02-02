import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/theme_service.dart';

/// 响应式主题背景 - 根据 ThemeService 动态切换
class ThemedBackground extends StatefulWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  State<ThemedBackground> createState() => _ThemedBackgroundState();
}

class _ThemedBackgroundState extends State<ThemedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cloudAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _cloudAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final isDark = themeService.isDarkMode;

        return Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.voidGradient,
              ),
            ),

            // Atmospheric Fog
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.fogGradient(
                      center: const Alignment(0.0, -0.2),
                      opacity: isDark ? 0.14 : 0.1,
                      radius: 1.25,
                    ),
                  ),
                ),
              ),
            ),

            // Moonlight/Sunlight Halo
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              height: 500,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      AppTheme.moonHalo.withValues(alpha: isDark ? 0.12 : 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Flowing Clouds/Elements
            AnimatedBuilder(
              animation: _cloudAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: _ElementPainter(
                      offset: _cloudAnimation.value,
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),

            // Vignette
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        isDark
                            ? AppTheme.voidDeeper.withValues(alpha: 0.45)
                            : AppTheme.pureBlack.withValues(alpha: 0.1),
                        isDark
                            ? AppTheme.voidDeeper.withValues(alpha: 0.75)
                            : AppTheme.pureBlack.withValues(alpha: 0.2),
                      ],
                      stops: const [0.0, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            widget.child,
          ],
        );
      },
    );
  }
}

/// Painter for decorative elements (clouds/stars)
class _ElementPainter extends CustomPainter {
  final double offset;
  final bool isDark;

  _ElementPainter({required this.offset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? AppTheme.jadeGreen.withValues(alpha: 0.05)
          : AppTheme.fluorescentCyan.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Draw flowing shapes
    canvas.drawCircle(
      Offset(size.width * 0.2 + (offset * 100), size.height * 0.4),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8 - (offset * 100), size.height * 0.6),
      100,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ElementPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.isDark != isDark;
}
