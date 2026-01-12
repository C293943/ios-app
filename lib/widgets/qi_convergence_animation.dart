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
  late AnimationController _eggPulseController;
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
      duration: const Duration(milliseconds: 3500), // 延长动画时间，让汇聚更丝滑
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _eggPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // 持续脉动
  }

  void _generateParticles() {
    final random = math.Random();
    // 增加粒子数量，让效果更丰富
    for (int i = 0; i < 80; i++) {
      _particles.add(ParticleData(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 200 + random.nextDouble() * 350, // 扩大粒子分布范围
        scale: 0.3 + random.nextDouble() * 1.2,
        speed: 0.3 + random.nextDouble() * 0.7, // 添加速度差异
        color: [
          const Color(0xFF00BCD4), // 青
          const Color(0xFFFFD700), // 金
          const Color(0xFF4CAF50), // 绿
          const Color(0xFF2196F3), // 蓝
          const Color(0xFFD4A574), // 土
        ][i % 5],
        delay: random.nextDouble() * 800, // 增加延迟范围，让粒子分批次进入
        hasTrail: random.nextBool(), // 部分粒子带有尾迹
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
    _eggPulseController.dispose();
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

        // 中心发光和蛋的脉动效果
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
          alignment: Alignment.center,
          children: _particles.map((particle) {
            // 计算每个粒子的进度（考虑延迟和速度）
            final adjustedDelay = particle.delay / 3500;
            final adjustedSpeed = particle.speed;
            final progress = ((_particleController.value * adjustedSpeed) - adjustedDelay)
                .clamp(0.0, 1.0);

            if (progress <= 0) return const SizedBox.shrink();

            // 使用缓动函数让运动更丝滑
            final easedProgress = _easeInOutCubic(progress);

            // 从外向内汇聚到蛋上
            final reverseProgress = 1.0 - easedProgress;
            final distance = particle.distance * reverseProgress;

            // 添加螺旋效果
            final spiralAngle = particle.angle + easedProgress * math.pi * 2;
            final x = math.cos(spiralAngle) * distance;
            final y = math.sin(spiralAngle) * distance;

            // 粒子缩放：靠近中心时变小
            final scale = particle.scale * (0.5 + 0.5 * reverseProgress);

            // 粒子透明度：两头淡，中间亮
            final opacity = math.sin(progress * math.pi) * 0.9;

            return Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(x, y),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildParticleBody(particle),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 缓动函数 - 让运动更丝滑
  double _easeInOutCubic(double x) {
    return x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;
  }

  // 构建粒子主体
  Widget _buildParticleBody(ParticleData particle) {
    if (particle.hasTrail) {
      // 带尾迹的粒子
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              particle.color,
              particle.color.withValues(alpha: 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: particle.color.withValues(alpha: 0.9),
              blurRadius: 20,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: particle.color.withValues(alpha: 0.5),
              blurRadius: 35,
              spreadRadius: 8,
            ),
          ],
        ),
      );
    } else {
      // 普通粒子
      return Container(
        width: 8,
        height: 8,
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
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCenterGlow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 主发光效果
        AnimatedBuilder(
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
        ),

        // 蛋的脉动效果（多层光晕）
        AnimatedBuilder(
          animation: _eggPulseController,
          builder: (context, child) {
            final pulseScale = 0.95 + _eggPulseController.value * 0.1;
            final pulseOpacity = 0.3 + _eggPulseController.value * 0.4;

            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 180,
                height: 216, // 200 * 1.2 蛋形比例
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyan.withValues(alpha: pulseOpacity * 0.3),
                      Colors.amber.withValues(alpha: pulseOpacity * 0.15),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: pulseOpacity * 0.2),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: pulseOpacity * 0.1),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
  final double speed;
  final Color color;
  final double delay;
  final bool hasTrail;

  ParticleData({
    required this.angle,
    required this.distance,
    required this.scale,
    required this.speed,
    required this.color,
    required this.delay,
    required this.hasTrail,
  });
}
