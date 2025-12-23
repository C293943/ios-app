import 'dart:math';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class FireflyParticles extends StatefulWidget {
  final Widget child;
  final bool isConverging; // True when "User is speaking/Thinking"

  const FireflyParticles({
    super.key,
    required this.child,
    this.isConverging = false,
  });

  @override
  State<FireflyParticles> createState() => _FireflyParticlesState();
}

class _FireflyParticlesState extends State<FireflyParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Firefly> _fireflies = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Long loop for continuous updates
      vsync: this,
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _fireflies.add(_createFirefly());
    }

    _controller.addListener(() {
      _updateParticles();
    });
  }

  _Firefly _createFirefly() {
    return _Firefly(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 3 + 1,
      opacity: _random.nextDouble() * 0.5 + 0.2,
      speedX: (_random.nextDouble() - 0.5) * 0.002,
      speedY: (_random.nextDouble() - 0.5) * 0.002,
    );
  }

  void _updateParticles() {
    setState(() {
      for (var f in _fireflies) {
        if (widget.isConverging) {
          // Move towards center (0.5, 0.4 roughly where spirit chest is)
          double dx = 0.5 - f.x;
          double dy = 0.4 - f.y;
          f.x += dx * 0.05;
          f.y += dy * 0.05;
          f.opacity = (1.0 - (dx*dx+dy*dy)).clamp(0.0, 1.0); // Brighter near center
        } else {
          // Ambient float
          f.x += f.speedX;
          f.y += f.speedY;

          // Wrap around
          if (f.x < 0) f.x = 1;
          if (f.x > 1) f.x = 0;
          if (f.y < 0) f.y = 1;
          if (f.y > 1) f.y = 0;
          
          // Random flicker
          if (_random.nextDouble() < 0.05) {
             f.opacity = _random.nextDouble() * 0.5 + 0.3;
          }
        }
      }
    });
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
        widget.child,
        IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(_fireflies),
          ),
        ),
      ],
    );
  }
}

class _Firefly {
  double x, y;
  double size;
  double opacity;
  double speedX, speedY;

  _Firefly({
    required this.x, required this.y, 
    required this.size, required this.opacity,
    required this.speedX, required this.speedY
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Firefly> fireflies;

  _ParticlePainter(this.fireflies);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.moonHalo.withOpacity(0.6);

    for (var f in fireflies) {
      paint.color = AppTheme.spiritJade.withOpacity(f.opacity); // Greenish fireflies
      canvas.drawCircle(
        Offset(f.x * size.width, f.y * size.height),
        f.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
