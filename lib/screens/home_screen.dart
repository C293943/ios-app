import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/theme_service.dart';

import 'package:primordial_spirit/widgets/home_drawer.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

/// 首页 - 仙侠主题沉浸式界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _HomeNavTarget { home, chat, relationship, fortune, bazi }

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    return Scaffold(
      drawer: const HomeDrawer(),
      extendBody: true,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
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
                  const SizedBox(height: 8),
                  _Header(),
                  const SizedBox(height: 20),
                  _StatsGlassCard(),
                  const SizedBox(height: 20),
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
              bottom: 130,
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
              child: _BottomNavBar(),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.note),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.spiritGlass,
                    border: Border.all(color: AppTheme.scrollBorder, width: 0.6),
                  ),
                  child: Icon(
                    Icons.edit_calendar_outlined,
                    color: AppTheme.inkText,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: TextStyle(
                    color: AppTheme.inkText.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  child: Text(context.l10n.spiritNotes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGlassCard extends StatelessWidget {
  const _StatsGlassCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.qiGlowShadows(intensity: 0.6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: AppTheme.spiritGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.scrollBorder, width: 0.5),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: AppTheme.fogGradient(opacity: 0.15),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        title: context.l10n.todayQiValue,
                        child: _GradientValueWithArrow(value: '88'),
                      ),
                      _divider(),
                      _StatItem(
                        title: context.l10n.luckyNumber,
                        child: _GradientNumber(value: '8'),
                      ),
                      _divider(),
                      _StatItem(
                        title: context.l10n.luckyColor,
                        child: _LuckyColorDot(),
                      ),
                      _divider(),
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
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      color: AppTheme.scrollBorder,
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
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              color: AppTheme.inkText.withValues(alpha: 0.7),
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
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.jadeGreen.withValues(alpha: 0.75),
        boxShadow: [
          BoxShadow(
            color: AppTheme.jadeGreen.withValues(alpha: 0.35),
            blurRadius: 12,
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

class _HaloRing extends StatelessWidget {
  const _HaloRing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.jadeGreen.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.jadeGreen.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 220,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [AppTheme.spiritJade, AppTheme.fluorescentCyan],
          ),
          border: Border.all(
            color: AppTheme.jadeGreen.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.jadeGreen.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: -6,
            ),
            BoxShadow(
              color: AppTheme.voidDeeper.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                color: AppTheme.inkText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        ModalRoute.of(context)?.settings.name ?? AppRoutes.home;
    return SizedBox(
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.spiritGlass,
                border: Border.all(color: AppTheme.scrollBorder, width: 0.6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavLabelOnly(
                            label: context.l10n.navFortune,
                            isActive: currentRoute == AppRoutes.home,
                            onTap: () => _handleNavTap(context, _HomeNavTarget.home),
                          ),
                        ),
                        _NavItem(
                          icon: Icons.help_outline,
                          label: context.l10n.navBazi,
                          isActive: currentRoute == AppRoutes.chat,
                          onTap: () => _handleNavTap(context, _HomeNavTarget.chat),
                        ),
                        _NavItem(
                          icon: Icons.favorite_border,
                          label: context.l10n.navRelationship,
                          isActive: currentRoute == AppRoutes.relationshipSelect,
                          onTap: () => _handleNavTap(context, _HomeNavTarget.relationship),
                        ),
                        _NavItem(
                          icon: Icons.auto_graph,
                          label: context.l10n.navFortune,
                          isActive: currentRoute == AppRoutes.avatarGeneration,
                          onTap: () => _handleNavTap(context, _HomeNavTarget.fortune),
                        ),
                        _NavItem(
                          icon: Icons.grid_view,
                          label: context.l10n.navBazi,
                          isActive: currentRoute == AppRoutes.baziInput,
                          onTap: () => _handleNavTap(context, _HomeNavTarget.bazi),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 28,
            child: _FloatingCrystal(),
          ),
        ],
      ),
    );
  }

  void _handleNavTap(BuildContext context, _HomeNavTarget target) {
    switch (target) {
      case _HomeNavTarget.home:
        _navigateTo(context, AppRoutes.home);
        break;
      case _HomeNavTarget.chat:
        _navigateTo(context, AppRoutes.chat);
        break;
      case _HomeNavTarget.relationship:
        _navigateTo(context, AppRoutes.relationshipSelect);
        break;
      case _HomeNavTarget.fortune:
        _handleFortuneTap(context);
        break;
      case _HomeNavTarget.bazi:
        _navigateTo(context, AppRoutes.baziInput);
        break;
    }
  }

  void _navigateTo(BuildContext context, String routeName) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == routeName) return;
    Navigator.of(context).pushNamed(routeName);
  }

  void _handleFortuneTap(BuildContext context) {
    final modelManager = context.read<ModelManagerService>();
    final baziData = _buildBaziData(modelManager);
    if (baziData == null) {
      _navigateTo(context, AppRoutes.baziInput);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.avatarGeneration,
      arguments: {'baziData': baziData},
    );
  }

  Map<String, dynamic>? _buildBaziData(ModelManagerService modelManager) {
    final fortune = modelManager.fortuneData;
    if (fortune != null) {
      final birth = fortune.birthInfo;
      return {
        'gender': birth.gender,
        'date': DateTime(birth.year, birth.month, birth.day),
        'time': TimeOfDay(hour: birth.hour, minute: birth.minute),
        'city': birth.city,
      };
    }

    final stored = modelManager.userBaziData;
    if (stored == null) return null;
    try {
      final birth = BirthInfo.fromStoredData(stored);
      return {
        'gender': birth.gender,
        'date': DateTime(birth.year, birth.month, birth.day),
        'time': TimeOfDay(hour: birth.hour, minute: birth.minute),
        'city': birth.city,
      };
    } catch (_) {
      return null;
    }
  }

}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.warmYellow
        : AppTheme.inkText.withValues(alpha: 0.8);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.85),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLabelOnly extends StatelessWidget {
  const _NavLabelOnly({
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.warmYellow
        : AppTheme.inkText.withValues(alpha: 0.7);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}

class _FloatingCrystal extends StatelessWidget {
  const _FloatingCrystal();

  static const String _crystalAsset = 'assets/images/spirit-stone-egg.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.jadeGreen.withValues(alpha: 0.5),
            blurRadius: 26,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          _crystalAsset,
          fit: BoxFit.cover,
        ),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.jadeGreen.withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.jadeGreen.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: AppTheme.spiritGlass,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTheme.inkText,
                ),
              ),
            ),
            const SizedBox(width: 10),
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

