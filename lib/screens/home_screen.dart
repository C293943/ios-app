import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/models/avatar_theme_config.dart';

/// 首页 - 动态主题切换 UI（占位资源版）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<AvatarThemeMode> _themeMode =
      ValueNotifier(AvatarThemeMode.light);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final next = _themeMode.value == AvatarThemeMode.light
        ? AvatarThemeMode.dark
        : AvatarThemeMode.light;
    _themeMode.value = next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: ValueListenableBuilder<AvatarThemeMode>(
        valueListenable: _themeMode,
        builder: (context, mode, _) {
          final theme = AvatarThemeConfig.fromMode(mode);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.bgGradientStart, theme.bgGradientEnd],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _DecorLayer(theme: theme),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _Header(theme: theme),
                      const SizedBox(height: 20),
                      _StatsGlassCard(theme: theme),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: _HeroAvatar(
                            theme: theme,
                            onToggleTheme: _toggleTheme,
                          ),
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
                      theme: theme,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.chat),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomNavBar(theme: theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DecorLayer extends StatelessWidget {
  const _DecorLayer({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: theme.isLight
          ? ColorFiltered(
              key: const ValueKey('light'),
              colorFilter: ColorFilter.mode(
                theme.accentColor.withOpacity(0.25),
                BlendMode.overlay,
              ),
            child: _WaterMistPainter(theme: theme),
            )
          : _StarDustPainter(
              key: const ValueKey('dark'),
              theme: theme,
            ),
    );
  }
}

class _WaterMistPainter extends StatelessWidget {
  const _WaterMistPainter({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveOverlayPainter(accentColor: theme.accentColor),
      child: const SizedBox.expand(),
    );
  }
}

class _WaveOverlayPainter extends CustomPainter {
  _WaveOverlayPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startY = size.height * (0.25 + i * 0.18);
      path.moveTo(0, startY);
      path.quadraticBezierTo(
        size.width * 0.3,
        startY - 24,
        size.width * 0.6,
        startY + 18,
      );
      path.quadraticBezierTo(
        size.width * 0.85,
        startY + 36,
        size.width,
        startY + 10,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarDustPainter extends StatelessWidget {
  const _StarDustPainter({super.key, required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(
        starColor: theme.textColorPrimary.withOpacity(0.6),
        glowColor: theme.accentColor.withOpacity(0.2),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProfileAvatar(theme: theme),
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.glassColor,
                  border: Border.all(color: theme.glassBorder, width: 0.6),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: theme.textColorPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  color: theme.textColorSecondary,
                  fontSize: 10,
                ),
                child: const Text('元神笔记'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGlassCard extends StatelessWidget {
  const _StatsGlassCard({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    final shadow = theme.isLight
        ? [
            BoxShadow(
              color: theme.accentColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ]
        : <BoxShadow>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: theme.glassColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.glassBorder, width: 0.5),
              ),
              child: Stack(
                children: [
                  if (!theme.isLight)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor.withOpacity(0.2),
                              theme.glassColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        title: '今日元气值',
                        theme: theme,
                        child: _GradientValueWithArrow(theme: theme, value: '88'),
                      ),
                      _divider(theme),
                      _StatItem(
                        title: '吉数',
                        theme: theme,
                        child: _GradientNumber(theme: theme, value: '8'),
                      ),
                      _divider(theme),
                      _StatItem(
                        title: '吉色',
                        theme: theme,
                        child: _LuckyColorDot(theme: theme),
                      ),
                      _divider(theme),
                      _StatItem(
                        title: '吉位',
                        theme: theme,
                        child: Icon(
                          Icons.explore,
                          color: theme.textColorPrimary,
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

  Widget _divider(AvatarThemeConfig theme) {
    return Container(
      width: 1,
      height: 48,
      color: theme.glassBorder,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.child,
    required this.theme,
  });

  final String title;
  final Widget child;
  final AvatarThemeConfig theme;

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
              color: theme.textColorSecondary,
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
  const _GradientValueWithArrow({required this.theme, required this.value});

  final AvatarThemeConfig theme;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _GradientText(
          value,
          gradient: theme.statNumberGradient,
          color: theme.textColorPrimary,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: Icon(
            Icons.arrow_drop_up,
            color: theme.textColorPrimary,
            size: 16,
          ),
        ),
      ],
    );
  }
}

class _GradientNumber extends StatelessWidget {
  const _GradientNumber({required this.theme, required this.value});

  final AvatarThemeConfig theme;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GradientText(
      value,
      gradient: theme.statNumberGradient,
      color: theme.textColorPrimary,
      style: const TextStyle(
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
    required this.color,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: color),
      ),
    );
  }
}

class _LuckyColorDot extends StatelessWidget {
  const _LuckyColorDot({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.accentColor.withOpacity(0.75),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withOpacity(0.35),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({
    required this.theme,
    required this.onToggleTheme,
  });

  static const String _defaultHeroAsset = 'assets/images/back-1.png';

  final AvatarThemeConfig theme;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleTheme,
      onHorizontalDragEnd: (_) => onToggleTheme(),
      child: SizedBox(
        width: 320,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: _HaloRing(theme: theme),
            ),
            Positioned.fill(
              child: Image.asset(
                _defaultHeroAsset,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HaloRing extends StatelessWidget {
  const _HaloRing({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.accentColor.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.theme, required this.onTap});

  final AvatarThemeConfig theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = theme.isLight ? theme.textColorPrimary : theme.textColorPrimary;
    final shadowColor = theme.accentColor.withOpacity(theme.isLight ? 0.35 : 0.2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 220,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(colors: theme.buttonGradient),
          border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              spreadRadius: -6,
            ),
            BoxShadow(
              color: theme.bgGradientEnd.withOpacity(0.35),
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
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              child: const Text('开启元神对话'),
            ),
            const SizedBox(width: 8),
            _BlinkingStar(color: theme.textColorPrimary),
          ],
        ),
      ),
    );
  }
}

class _BlinkingStar extends StatefulWidget {
  const _BlinkingStar({required this.color});

  final Color color;

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
        color: widget.color,
        size: 20,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
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
                color: theme.glassColor,
                border: Border.all(color: theme.glassBorder, width: 0.6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _NavLabelOnly(theme: theme, label: '元神')),
                        _NavItem(theme: theme, icon: Icons.help_outline, label: '问卜'),
                        _NavItem(
                          theme: theme,
                          icon: Icons.favorite_border,
                          label: '合盘',
                        ),
                        _NavItem(theme: theme, icon: Icons.auto_graph, label: '运势'),
                        _NavItem(theme: theme, icon: Icons.grid_view, label: '八字'),
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
            child: _FloatingCrystal(theme: theme),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.theme,
    required this.icon,
    required this.label,
  });

  final AvatarThemeConfig theme;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: theme.textColorPrimary.withOpacity(0.8),
            size: 22,
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: 11,
              color: theme.textColorSecondary,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class _NavLabelOnly extends StatelessWidget {
  const _NavLabelOnly({required this.theme, required this.label});

  final AvatarThemeConfig theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          style: TextStyle(
            fontSize: 11,
            color: theme.textColorSecondary,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

class _FloatingCrystal extends StatelessWidget {
  const _FloatingCrystal({required this.theme});

  final AvatarThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    final glowColor = theme.isLight
        ? theme.accentColor.withValues(alpha: 0.35)
        : theme.accentColor.withValues(alpha: 0.5);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(theme.crystalAsset),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: 26,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            theme.crystalAsset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({required this.theme});

  final AvatarThemeConfig theme;

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
        Navigator.of(context).pushNamed(AppRoutes.profile);
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
                  color: widget.theme.accentColor.withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.accentColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: widget.theme.glassColor,
                child: Icon(
                  Icons.auto_awesome,
                  color: widget.theme.textColorPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                color: widget.theme.textColorPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              child: const Text('元神'),
            ),
          ],
        ),
      ),
    );
  }
}
