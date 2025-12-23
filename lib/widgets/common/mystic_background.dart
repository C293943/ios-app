import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class MysticBackground extends StatefulWidget {
  final Widget child;

  const MysticBackground({super.key, required this.child});

  @override
  State<MysticBackground> createState() => _MysticBackgroundState();
}

class _MysticBackgroundState extends State<MysticBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Animation for cloud movement
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
    return Stack(
      children: [
        // 1. Deep "Dai" Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.daiDeep,
                AppTheme.crowCyan,
                AppTheme.daiDeep, // darker at bottom again for grounding
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        
        // 2. Moonlight Halo (Top Center)
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
                  AppTheme.moonHalo.withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        
        // 3. Flowing Clouds (Animated opacity/position)
        AnimatedBuilder(
          animation: _cloudAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: CloudPainter(offset: _cloudAnimation.value),
              ),
            );
          },
        ),

        // 4. Far Mountains (Silhouettes at bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: CustomPaint(
            painter: MountainPainter(),
          ),
        ),

        // 5. Main Content with subtle noise/grain if needed (optional)
        widget.child,
      ],
    );
  }
}

// Painter for Mountain Silhouettes 
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Layer 1: Farthest, lightest (Foggy)
    paint.color = AppTheme.mountainMist.withOpacity(0.3);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.cubicTo(size.width * 0.3, size.height * 0.5, size.width * 0.6, size.height * 0.7, size.width, size.height * 0.55);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Layer 2: Middle
    paint.color = AppTheme.mountainMist.withOpacity(0.6);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.cubicTo(size.width * 0.2, size.height * 0.65, size.width * 0.7, size.height * 0.85, size.width, size.height * 0.7);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
    
    // Layer 3: Closest, Darkest
    paint.color = AppTheme.daiDeep; // Merges with bottom
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.cubicTo(size.width * 0.1, size.height * 0.9, size.width * 0.4, size.height * 0.95, size.width * 0.6, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for Abstract Clouds (Wisps)
class CloudPainter extends CustomPainter {
  final double offset;
  
  CloudPainter({required this.offset});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.moonHalo.withOpacity(0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20); // Soften edges

    // Draw some flowing shapes
    canvas.drawCircle(Offset(size.width * 0.2 + (offset * 100), size.height * 0.4), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.8 - (offset * 100), size.height * 0.6), 100, paint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => oldDelegate.offset != offset;
}
