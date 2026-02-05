import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/theme_service.dart';

import 'package:primordial_spirit/widgets/home_drawer.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:primordial_spirit/widgets/common/liquid_glass_container.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

/// 首页 - 仙侠主题沉浸式界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    return Scaffold(
      drawer: const HomeDrawer(),
      extendBody: true,
      body: AnimatedContainer(
        duration: AppTheme.animStandard,
        decoration: BoxDecoration(
          gradient: AppTheme.voidGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _DecorLayer(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppTheme.spacingSm),
                  _Header(),
                  SizedBox(height: AppTheme.spacingLg),
                  _StatsGlassCard(),
                  SizedBox(height: AppTheme.spacingLg),
                  Expanded(
                    child: Center(
                      child: _HeroAvatar(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 136,
              child: Center(
                child: _CtaButton(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.chat),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNavBar(currentTarget: AppNavTarget.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorLayer extends StatelessWidget {
  const _DecorLayer();

  @override
  Widget build(BuildContext context) {
    return _StarDustPainter();
  }
}

class _StarDustPainter extends StatelessWidget {
  const _StarDustPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(
        starColor: AppTheme.inkText.withValues(alpha: 0.6),
        glowColor: AppTheme.jadeGreen.withValues(alpha: 0.2),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.starColor, required this.glowColor});

  final Color starColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = starColor;
    final glowPaint = Paint()..color = glowColor;

    const stars = <Offset>[
      Offset(0.12, 0.18),
      Offset(0.22, 0.12),
      Offset(0.36, 0.22),
      Offset(0.48, 0.15),
      Offset(0.72, 0.2),
      Offset(0.82, 0.12),
      Offset(0.16, 0.42),
      Offset(0.3, 0.52),
      Offset(0.52, 0.48),
      Offset(0.68, 0.44),
      Offset(0.86, 0.38),
      Offset(0.12, 0.72),
      Offset(0.28, 0.68),
      Offset(0.46, 0.78),
      Offset(0.7, 0.7),
      Offset(0.86, 0.76),
    ];

    for (final star in stars) {
      final position = Offset(size.width * star.dx, size.height * star.dy);
      canvas.drawCircle(position, 1.4, paint);
      canvas.drawCircle(position, 5.2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.starColor != starColor ||
        oldDelegate.glowColor != glowColor;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProfileAvatar(),
          _LiquidNoteButton(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.note),
            label: context.l10n.spiritNotes,
          ),
        ],
      ),
    );
  }
}

/// 液态玻璃笔记按钮
class _LiquidNoteButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _LiquidNoteButton({
    required this.onTap,
    required this.label,
  });

  @override
  State<_LiquidNoteButton> createState() => _LiquidNoteButtonState();
}

class _LiquidNoteButtonState extends State<_LiquidNoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.jadeGreen.withOpacity(
                        0.15 * _glowAnimation.value,
                      ),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.liquidGlassBase,
                        border: Border.all(
                          color: AppTheme.jadeGreen.withOpacity(
                            0.2 + 0.15 * _glowAnimation.value,
                          ),
                          width: 0.8,
                        ),
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.5),
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.08 * _glowAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.edit_calendar_outlined,
                        color: AppTheme.inkText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.7),
                  fontSize: 10,
                ),
                child: Text(widget.label),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsGlassCard extends StatelessWidget {
  const _StatsGlassCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: LiquidGlassContainer(
        height: 104,
        borderRadius: AppTheme.radiusLg,
        variant: LiquidGlassVariant.premium,
        blurSigma: AppTheme.blurPremium,
        glowIntensity: 0.8,
        showIridescent: true,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // 流动光晕背景
            Positioned.fill(
              child: _LiquidGlowEffect(),
            ),
            // 内容
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  title: context.l10n.todayQiValue,
                  child: _GradientValueWithArrow(value: '88'),
                ),
                _LiquidDivider(),
                _StatItem(
                  title: context.l10n.luckyNumber,
                  child: _GradientNumber(value: '8'),
                ),
                _LiquidDivider(),
                _StatItem(
                  title: context.l10n.luckyColor,
                  child: _LuckyColorDot(),
                ),
                _LiquidDivider(),
                _StatItem(
                  title: context.l10n.luckyDirection,
                  child: Icon(
                    Icons.explore,
                    color: AppTheme.inkText,
                    size: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 液态分隔线 - 带渐变的半透明分隔
class _LiquidDivider extends StatelessWidget {
  const _LiquidDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.borderStandard,
      height: AppTheme.spacingXxl,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.liquidGlassBorderSoft,
            AppTheme.liquidGlassBorder.withOpacity(0.5),
            AppTheme.liquidGlassBorderSoft,
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }
}

/// 液态光晕效果 - 卡片内部流动光效
class _LiquidGlowEffect extends StatefulWidget {
  const _LiquidGlowEffect();

  @override
  State<_LiquidGlowEffect> createState() => _LiquidGlowEffectState();
}

class _LiquidGlowEffectState extends State<_LiquidGlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _glowPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    
    _glowPosition = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-1.2, -0.3),
          end: const Alignment(0.0, 0.3),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.0, 0.3),
          end: const Alignment(1.2, -0.3),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowPosition,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            gradient: AppTheme.liquidRippleGradient(
              center: _glowPosition.value,
              radius: 0.9,
              opacity: 0.2,
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          SizedBox(height: AppTheme.spacingSm),
          AnimatedDefaultTextStyle(
            duration: AppTheme.animStandard,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 11,
            ),
            child: Text(title, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _GradientValueWithArrow extends StatelessWidget {
  const _GradientValueWithArrow({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _GradientText(
          value,
          gradient: LinearGradient(
            colors: [AppTheme.amberGold, AppTheme.jadeGreen],
          ),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: Icon(
            Icons.arrow_drop_up,
            color: AppTheme.inkText,
            size: 16,
          ),
        ),
      ],
    );
  }
}

class _GradientNumber extends StatelessWidget {
  const _GradientNumber({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return _GradientText(
      value,
      gradient: LinearGradient(
        colors: [AppTheme.amberGold, AppTheme.jadeGreen],
      ),
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: AppTheme.inkText),
      ),
    );
  }
}

class _LuckyColorDot extends StatelessWidget {
  const _LuckyColorDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.jadeGreen.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.liquidGlow,
            blurRadius: AppTheme.spacingMd,
            spreadRadius: -2,
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar();

  static const String _defaultHeroAsset = 'assets/images/back-1.png';

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        ModalRoute.of(context)?.settings.name ?? AppRoutes.home;
    return SizedBox(
      width: 320,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: _HaloRing(),
          ),
          Positioned.fill(
            child: Image.asset(
              _defaultHeroAsset,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _HaloRing extends StatefulWidget {
  const _HaloRing();

  @override
  State<_HaloRing> createState() => _HaloRingState();
}

class _HaloRingState extends State<_HaloRing>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // 脉冲动画
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTheme.animPulse,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 虹彩旋转动画
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
      builder: (context, _) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // 外层流动光晕
              BoxShadow(
                color: AppTheme.jadeGreen.withOpacity(
                  0.35 * _pulseAnimation.value,
                ),
                blurRadius: 40 * _pulseAnimation.value,
                spreadRadius: 8,
              ),
              // 内层虹彩光晕
              BoxShadow(
                color: AppTheme.fluorescentCyan.withOpacity(
                  0.2 * _pulseAnimation.value,
                ),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 主光环 - 液态玻璃边框
              Positioned.fill(
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.jadeGreen.withOpacity(
                            0.5 + 0.3 * _pulseAnimation.value,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 虹彩旋转环
              Positioned.fill(
                child: CustomPaint(
                  painter: _IridescentRingPainter(
                    rotation: _rotateAnimation.value * 2 * 3.14159,
                    intensity: _pulseAnimation.value,
                  ),
                ),
              ),
              // 内层高光环
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.1 * _pulseAnimation.value,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 虹彩光环画笔
class _IridescentRingPainter extends CustomPainter {
  final double rotation;
  final double intensity;

  _IridescentRingPainter({
    required this.rotation,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradient = SweepGradient(
      startAngle: rotation,
      endAngle: rotation + 2 * 3.14159,
      colors: [
        AppTheme.fluorescentCyan.withOpacity(0.4 * intensity),
        AppTheme.jadeGreen.withOpacity(0.3 * intensity),
        AppTheme.amberGold.withOpacity(0.2 * intensity),
        AppTheme.fluorescentCyan.withOpacity(0.4 * intensity),
      ],
      stops: const [0.0, 0.33, 0.66, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant _IridescentRingPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.intensity != intensity;
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            width: 220,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                // 外发光 - 液态效果
                BoxShadow(
                  color: AppTheme.jadeGreen.withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                // 深度阴影
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                // 虹彩光晕
                BoxShadow(
                  color: AppTheme.fluorescentCyan.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    // 液态渐变背景
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.spiritJade.withOpacity(0.85),
                        AppTheme.jadeGreen.withOpacity(0.75),
                        AppTheme.fluorescentCyan.withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 流动光泽层
                      Positioned.fill(
                        child: _LiquidShimmer(progress: _shimmerAnimation.value),
                      ),
                      // 顶部高光
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 24,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(999),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 内容
                      Center(child: child),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                color: AppTheme.inkText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(context.l10n.startSpiritChat),
            ),
            const SizedBox(width: 8),
            _BlinkingStar(),
          ],
        ),
      ),
    );
  }
}

/// 液态流光效果
class _LiquidShimmer extends StatelessWidget {
  final double progress;

  const _LiquidShimmer({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(progress - 1, 0),
          end: Alignment(progress, 0),
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BlinkingStar extends StatefulWidget {
  const _BlinkingStar();

  @override
  State<_BlinkingStar> createState() => _BlinkingStarState();
}

class _BlinkingStarState extends State<_BlinkingStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(
        Icons.auto_awesome,
        color: AppTheme.inkText,
        size: 20,
      ),
    );
  }
}


class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar();

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).openDrawer();
      },
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Row(
          children: [
            _LiquidAvatarRing(
              size: 52,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.liquidGlassBase,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTheme.inkText,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                color: AppTheme.inkText,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              child: Text(context.l10n.spiritName),
            ),
          ],
        ),
      ),
    );
  }
}

/// 液态玻璃头像环 - 带动态光晕的圆形容器
class _LiquidAvatarRing extends StatefulWidget {
  final double size;
  final Widget child;

  const _LiquidAvatarRing({
    required this.size,
    required this.child,
  });

  @override
  State<_LiquidAvatarRing> createState() => _LiquidAvatarRingState();
}

class _LiquidAvatarRingState extends State<_LiquidAvatarRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // 外发光 - 动态强度
              BoxShadow(
                color: AppTheme.jadeGreen.withOpacity(
                  0.25 * _glowAnimation.value,
                ),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2,
              ),
              // 虹彩光晕
              BoxShadow(
                color: AppTheme.fluorescentCyan.withOpacity(
                  0.15 * _glowAnimation.value,
                ),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.liquidGlassBase,
                  border: Border.all(
                    color: AppTheme.jadeGreen.withOpacity(
                      0.4 + 0.3 * _glowAnimation.value,
                    ),
                    width: 1.5,
                  ),
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.5),
                    radius: 1.2,
                    colors: [
                      Colors.white.withOpacity(0.12 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Center(child: widget.child),
    );
  }
}

