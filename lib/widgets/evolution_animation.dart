import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 觉醒动画组件 - 灵石进化为元神
///
/// 阶段:
/// - idle: 空闲状态
/// - glowing: 灵石开始发光
/// - cracking: 灵石出现裂纹
/// - burst: 灵石爆发
/// - emerge: 元神出现
/// - complete: 完成
class EvolutionAnimation extends StatefulWidget {
  final bool isTriggered;
  final VoidCallback onComplete;
  final String? spiritStoneAsset;
  final String? avatarSpiritAsset;

  const EvolutionAnimation({
    super.key,
    required this.isTriggered,
    required this.onComplete,
    this.spiritStoneAsset,
    this.avatarSpiritAsset,
  });

  @override
  State<EvolutionAnimation> createState() => EvolutionAnimationState();
}

class EvolutionAnimationState extends State<EvolutionAnimation>
    with TickerProviderStateMixin {
  AnimationStage _currentStage = AnimationStage.idle;

  // 动画控制器
  late AnimationController _glowController;
  late AnimationController _crackController;
  late AnimationController _burstController;
  late AnimationController _emergeController;
  late AnimationController _particleController;
  late AnimationController _overlayController;

  // 动画对象
  late Animation<double> _glowAnimation;
  late Animation<double> _crackAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _emergeAnimation;
  late Animation<double> _overlayAnimation;

  // 粒子数据
  final List<ParticleData> _particles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateParticles();
    if (widget.isTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryStartEvolution();
      });
    }
  }

  void _setupAnimations() {
    // 发光动画 - 1.5秒循环
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 裂纹动画 - 1秒
    _crackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _crackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _crackController, curve: Curves.easeInOut),
    );

    // 爆发动画 - 1秒
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOut),
    );

    // 元神出现动画 - 1.5秒
    _emergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _emergeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emergeController, curve: Curves.easeOut),
    );

    // 粒子动画 - 2秒
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 遮罩动画
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayAnimation = Tween<double>(begin: 0.7, end: 0.9).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
    );
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(ParticleData(
        angle: random.nextDouble() * 2 * math.pi,
        distance: 100 + random.nextDouble() * 300,
        scale: random.nextDouble() * 1.5,
        color: i % 2 == 0 ? const Color(0xFF00BCD4) : const Color(0xFFFFD700), // 青色和金色
        delay: random.nextDouble() * 300,
      ));
    }
  }

  @override
  void didUpdateWidget(EvolutionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTriggered && !oldWidget.isTriggered) {
      _tryStartEvolution();
    }
  }

  void _tryStartEvolution() {
    if (!mounted) return;
    if (!widget.isTriggered) return;
    if (_currentStage != AnimationStage.idle) return;
    _startEvolution();
  }

  void _startEvolution() async {
    // 阶段1: 发光 (0-1.5秒)
    setState(() => _currentStage = AnimationStage.glowing);
    _glowController.repeat();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 阶段2: 裂纹 (1.5-3秒)
    setState(() => _currentStage = AnimationStage.cracking);
    _crackController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 阶段3: 爆发 (3-4秒)
    setState(() => _currentStage = AnimationStage.burst);
    _glowController.stop();
    _burstController.forward();
    _particleController.forward();
    _overlayController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // 阶段4: 元神出现 (4-6秒)
    setState(() => _currentStage = AnimationStage.emerge);
    _emergeController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // 完成
    setState(() => _currentStage = AnimationStage.complete);
    widget.onComplete();

    // 重置动画控制器状态，允许下次触发
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _resetAnimationControllers();
    }
  }

  /// 重置所有动画控制器
  void _resetAnimationControllers() {
    _glowController.reset();
    _crackController.reset();
    _burstController.reset();
    _emergeController.reset();
    _particleController.reset();
    _overlayController.reset();
    setState(() => _currentStage = AnimationStage.idle);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _crackController.dispose();
    _burstController.dispose();
    _emergeController.dispose();
    _particleController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTriggered || _currentStage == AnimationStage.idle) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景遮罩（半透明黑色，增强对比度）
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                final opacity = _currentStage == AnimationStage.burst ||
                    _currentStage == AnimationStage.emerge
                    ? 0.9
                    : 0.7;
                return Container(
                  color: Colors.black.withValues(alpha: opacity),
                );
              },
            ),
          ),

          // 粒子爆发效果（中间层）
          if (_currentStage == AnimationStage.burst ||
              _currentStage == AnimationStage.emerge)
            _buildParticles(),

          // 能量环（中间层）
          if (_currentStage == AnimationStage.burst)
            _buildEnergyRings(),

          // 主体内容（上层，确保在最前面显示）
          Center(
            child: _buildMainContent(),
          ),

          // 文字提示（最上层）
          if (_currentStage == AnimationStage.emerge)
            _buildAnnouncement(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentStage) {
      case AnimationStage.glowing:
      case AnimationStage.cracking:
        return _buildStone();
      case AnimationStage.burst:
        return _buildFlash();
      case AnimationStage.emerge:
      case AnimationStage.complete:
        return _buildSpirit();
      default:
        return const SizedBox.shrink();
    }
  }

  // 灵石显示
  Widget _buildStone() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        // 震动效果 (裂纹阶段)
        final shake = _currentStage == AnimationStage.cracking
            ? math.sin(_crackAnimation.value * math.pi * 10) * 5
            : 0.0;

        return Transform.translate(
          offset: Offset(shake, shake),
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 发光背景
                _buildGlowEffect(),

                // 灵石图片（不做任何处理，直接显示）
                Image.asset(
                  widget.spiritStoneAsset ?? 'assets/images/spirit-stone-egg.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),

                // 裂纹覆盖层（完全透明的 SVG 线条，叠加在蛋上）
                if (_currentStage == AnimationStage.cracking) ...[
                  // 裂纹线条
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: _buildCrackOverlay(),
                  ),
                  // 从裂纹处透出的光芒
                  _buildCrackGlow(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // 发光效果
  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final scale = 1.0 + _glowController.value * 0.3;
        final opacity = 0.5 + _glowController.value * 0.5;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.cyan.withValues(alpha: opacity * 0.6),
                  Colors.amber.withValues(alpha: opacity * 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 裂纹覆盖层
  Widget _buildCrackOverlay() {
    return AnimatedBuilder(
      animation: _crackAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _crackAnimation.value.clamp(0.0, 1.0), // 确保完全可见
          child: CustomPaint(
            size: const Size(160, 160),
            painter: CrackPainter(),
          ),
        );
      },
    );
  }

  // 从裂纹处透出的光芒
  Widget _buildCrackGlow() {
    return AnimatedBuilder(
      animation: _crackController,
      builder: (context, child) {
        final glowIntensity = (math.sin(_crackController.value * math.pi * 2) * 0.5 + 0.5)
            .clamp(0.4, 1.0);

        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5,
              colors: [
                const Color(0xFFFFB84D).withValues(alpha: glowIntensity * 0.7), // 金色光芒 hsl(43 100% 70%)
                const Color(0xFFFFB84D).withValues(alpha: glowIntensity * 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        );
      },
    );
  }

  // 爆发闪光
  Widget _buildFlash() {
    return AnimatedBuilder(
      animation: _burstAnimation,
      builder: (context, child) {
        final scale = 0.5 + _burstAnimation.value * 2.5;
        final opacity = math.sin(_burstAnimation.value * math.pi);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: opacity),
                  Colors.amber.withValues(alpha: opacity * 0.7),
                  Colors.cyan.withValues(alpha: opacity * 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 能量环
  Widget _buildEnergyRings() {
    return AnimatedBuilder(
      animation: _burstAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_burstAnimation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + progress * 3.5;
            final opacity = (0.8 - progress * 0.8).clamp(0.0, 0.8);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index % 2 == 0
                        ? Colors.cyan.withValues(alpha: opacity)
                        : Colors.amber.withValues(alpha: opacity),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (index % 2 == 0 ? Colors.cyan : Colors.amber)
                          .withValues(alpha: opacity * 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // 粒子效果
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = (_particleController.value - particle.delay / 2000)
                .clamp(0.0, 1.0);

            if (progress <= 0) return const SizedBox.shrink();

            final x = math.cos(particle.angle) * particle.distance * progress;
            final y = math.sin(particle.angle) * particle.distance * progress;
            final scale = math.sin(progress * math.pi) * particle.scale;
            final opacity = (1.0 - progress).clamp(0.0, 1.0);

            return Positioned(
              left: 0,
              top: 0,
              child: Transform.translate(
                offset: Offset(x, y),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 12,
                      height: 12,
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
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
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

  // 元神显示
  Widget _buildSpirit() {
    return AnimatedBuilder(
      animation: _emergeAnimation,
      builder: (context, child) {
        final opacity = _emergeAnimation.value;
        final scale = 0.3 + _emergeAnimation.value * 0.7;
        final yOffset = 50 * (1 - _emergeAnimation.value);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: 192,
                height: 192,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 灵气光环
                    _buildSpiritGlow(),

                    // 元神图片
                    Image.asset(
                      widget.avatarSpiritAsset ?? 'assets/images/back-1.png',
                      width: 192,
                      height: 192,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 元神灵气光环
  Widget _buildSpiritGlow() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final scale = 1.0 + math.sin(value * math.pi * 2) * 0.1;
        final opacity = 0.6 + math.sin(value * math.pi * 2) * 0.2;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 480,
            height: 480,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.cyan.withValues(alpha: opacity * 0.4),
                  Colors.amber.withValues(alpha: opacity * 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // 循环动画
        if (mounted && _currentStage == AnimationStage.emerge) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() {}); // 触发重建
            }
          });
        }
      },
    );
  }

  // 觉醒公告文字
  Widget _buildAnnouncement() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Column(
                children: [
                  Text(
                    '元神觉醒',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.amber, Colors.cyan],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '灵石破壳，神识初成',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 动画阶段枚举
enum AnimationStage {
  idle,
  glowing,
  cracking,
  burst,
  emerge,
  complete,
}

// 粒子数据
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

// 裂纹绘制器
class CrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 第一条裂纹（金色 hsl(43 100% 70%)）- 主裂纹
    final paint1 = Paint()
      ..color = const Color(0xFFFFB84D) // HSL(43, 100%, 70%) = 金色
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

    final path1 = Path();
    path1.moveTo(center.dx, center.dy - 35);
    path1.lineTo(center.dx + 6, center.dy - 18);
    path1.lineTo(center.dx - 3, center.dy);
    path1.lineTo(center.dx + 3, center.dy + 18);
    path1.lineTo(center.dx - 6, center.dy + 35);
    canvas.drawPath(path1, paint1);

    // 第二条裂纹（青色 hsl(187 100% 70%)）- 横向裂纹
    final paint2 = Paint()
      ..color = const Color(0xFF00F0FF) // HSL(187, 100%, 70%) = 青色
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

    final path2 = Path();
    path2.moveTo(center.dx - 25, center.dy - 12);
    path2.lineTo(center.dx - 6, center.dy - 6);
    path2.lineTo(center.dx, center.dy);
    path2.lineTo(center.dx + 6, center.dy + 6);
    path2.lineTo(center.dx + 25, center.dy + 12);
    canvas.drawPath(path2, paint2);

    // 第三条裂纹（金色 hsl(43 100% 70%)）- 对角裂纹
    final paint3 = Paint()
      ..color = const Color(0xFFFFB84D) // HSL(43, 100%, 70%) = 金色
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6);

    final path3 = Path();
    path3.moveTo(center.dx - 18, center.dy + 18);
    path3.lineTo(center.dx - 10, center.dy + 6);
    path3.lineTo(center.dx, center.dy);
    path3.lineTo(center.dx + 10, center.dy - 6);
    path3.lineTo(center.dx + 18, center.dy - 18);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
