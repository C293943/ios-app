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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(CurvedAnimation(
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
        // Base Gradient (Static but deep)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cloudMistWhite,
                AppTheme.celestialCyan,
                Color(0xFFE3F2FD), // Light blue variant
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Animated "Breathing" Overlay
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, 0.2 + _animation.value * 0.1),
                  radius: 1.5 + _animation.value * 0.2,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            );
          },
        ),

        // Deep Void hint at bottom (Grounding)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.deepVoidBlue.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Main Content
        widget.child,
      ],
    );
  }
}
