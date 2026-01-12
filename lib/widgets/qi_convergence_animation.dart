import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:primordial_spirit/config/app_theme.dart';

/// 灵气汇聚过渡动画 - 生辰信息提交后显示
class QiConvergenceAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isTriggered;

  const QiConvergenceAnimation({
    super.key,
    required this.onComplete,
    required this.isTriggered,
  });

  @override
  State<QiConvergenceAnimation> createState() => _QiConvergenceAnimationState();
}

class _QiConvergenceAnimationState extends State<QiConvergenceAnimation>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _textController;
  final List<ParticleData> _particles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateParticles();
    // 如果初始状态就是 triggered，立即开始动画
    if (widget.isTriggered) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(ParticleData(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 150 + random.nextDouble() * 250,
        scale: 0.5 + random.nextDouble() * 1.5,
        color: [
          const Color(0xFF00BCD4), // 青
          const Color(0xFFFFD700), // 金
          const Color(0xFF4CAF50), // 绿
          const Color(0xFF2196F3), // 蓝
          const Color(0xFFD4A574), // 土
        ][i % 5],
        delay: random.nextDouble() * 500,
      ));
    }
  }

  @override
  void didUpdateWidget(QiConvergenceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('[QiConvergenceAnimation] didUpdateWidget: isTriggered=${widget.isTriggered}, oldWidget.isTriggered=${oldWidget.isTriggered}');
    if (widget.isTriggered && !oldWidget.isTriggered) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    debugPrint('[QiConvergenceAnimation] 动画开始');
    _particleController.forward();
    _glowController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    debugPrint('[QiConvergenceAnimation] 等待粒子动画完成');
    await Future.delayed(const Duration(milliseconds: 2500));
    debugPrint('[QiConvergenceAnimation] 调用 onComplete 回调');
    widget.onComplete();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTriggered) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        // 背景遮罩
        Container(
          color: Colors.black.withValues(alpha: 0.4),
        ),

        // 粒子汇聚效果
        _buildParticles(),

        // 中心发光
        _buildCenterGlow(),

        // 文字提示
        _buildText(),
      ],
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = (_particleController.value - particle.delay / 2500)
                .clamp(0.0, 1.0);

            if (progress <= 0) return const SizedBox.shrink();

            // 反向汇聚：从外向内
            final reverseProgress = 1.0 - progress;
            final x = math.cos(particle.angle) * particle.distance * reverseProgress;
            final y = math.sin(particle.angle) * particle.distance * reverseProgress;
            final scale = math.sin(progress * math.pi) * particle.scale;
            final opacity = progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;

            return Positioned(
              left: 0,
              top: 0,
              child: Transform.translate(
                offset: Offset(x, y),
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              particle.color,
                              particle.color.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withValues(alpha: 0.8),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCenterGlow() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final scale = 0.5 + _glowController.value * 1.5;
        final opacity = math.sin(_glowController.value * math.pi);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.cyan.withValues(alpha: opacity * 0.6),
                  Colors.amber.withValues(alpha: opacity * 0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: opacity * 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final opacity = _textController.value;
        final scale = 0.8 + _textController.value * 0.2;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '灵气汇聚',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.cyan, Colors.amber],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '五行之力融汇贯通',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ParticleData {
  final double angle;
  final double distance;
  final double scale;
  final Color color;
  final double delay;

  ParticleData({
    required this.angle,
    required this.distance,
    required this.scale,
    required this.color,
    required this.delay,
  });
}
