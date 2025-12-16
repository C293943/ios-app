import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class LiquidAvatar extends StatefulWidget {
  final bool isTalking;

  const LiquidAvatar({super.key, this.isTalking = false});

  @override
  State<LiquidAvatar> createState() => _LiquidAvatarState();
}

class _LiquidAvatarState extends State<LiquidAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 5), // 4-6秒呼吸循环
        vsync: this
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    ));
  }
  
  @override
  void didUpdateWidget(LiquidAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTalking != oldWidget.isTalking) {
      if (widget.isTalking) {
        _controller.duration = const Duration(seconds: 1); // Talk fast pulse
        _controller.repeat(reverse: true);
      } else {
        _controller.duration = const Duration(seconds: 5); // Calm breath
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.jadeGreen.withOpacity(0.2), // 疗愈绿
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
              // Inner Core (Spirit)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      AppTheme.celestialCyan.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.fluidGold.withOpacity(widget.isTalking ? 0.6 : 0.0), // Divine spark when talking
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
