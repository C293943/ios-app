import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

enum AppNavTarget { home, divination, relationship, fortune, bazi }

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentTarget,
  });

  final AppNavTarget currentTarget;

  /// 统一的导航处理
  static void navigateTo(BuildContext context, AppNavTarget target, AppNavTarget current) {
    if (target == current) return;
    
    final route = switch (target) {
      AppNavTarget.home => AppRoutes.home,
      AppNavTarget.divination => AppRoutes.divination,
      AppNavTarget.relationship => AppRoutes.relationshipSelect,
      AppNavTarget.fortune => AppRoutes.fortune,
      AppNavTarget.bazi => AppRoutes.bazi,
    };
    
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: AppTheme.animPulse,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
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
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            bottom: AppTheme.spacingMd,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      // 外发光
                      BoxShadow(
                        color: AppTheme.liquidGlow.withOpacity(
                          0.15 * _glowAnimation.value,
                        ),
                        blurRadius: 20,
                        spreadRadius: -4,
                      ),
                      // 深度阴影
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: AppTheme.blurStandard,
                        sigmaY: AppTheme.blurStandard,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.liquidGlassBase,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Stack(
                          children: [
                            // 内层渐变
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  gradient: AppTheme.liquidGlassInnerGradient(
                                    opacity: _glowAnimation.value,
                                  ),
                                ),
                              ),
                            ),
                            // 顶部高光
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 28,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusLg),
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.liquidTopHighlight(
                                      intensity: _glowAnimation.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 边框
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  border: Border.all(
                                    color: AppTheme.liquidGlassBorder.withOpacity(
                                      0.3 + 0.15 * _glowAnimation.value,
                                    ),
                                    width: AppTheme.borderStandard,
                                  ),
                                ),
                              ),
                            ),
                            // 内容
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingMd,
                              ),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.person_outline,
                    label: context.l10n.spiritName,
                    isActive: widget.currentTarget == AppNavTarget.home,
                    onTap: () => AppBottomNavBar.navigateTo(context, AppNavTarget.home, widget.currentTarget),
                  ),
                  _NavItem(
                    icon: Icons.help_outline,
                    label: context.l10n.divinationTitle,
                    isActive: widget.currentTarget == AppNavTarget.divination,
                    onTap: () => AppBottomNavBar.navigateTo(context, AppNavTarget.divination, widget.currentTarget),
                  ),
                  _NavItem(
                    icon: Icons.favorite_border,
                    label: context.l10n.navRelationship,
                    isActive: widget.currentTarget == AppNavTarget.relationship,
                    onTap: () => AppBottomNavBar.navigateTo(context, AppNavTarget.relationship, widget.currentTarget),
                  ),
                  _NavItem(
                    icon: Icons.auto_graph,
                    label: context.l10n.navFortune,
                    isActive: widget.currentTarget == AppNavTarget.fortune,
                    onTap: () => AppBottomNavBar.navigateTo(context, AppNavTarget.fortune, widget.currentTarget),
                  ),
                  _NavItem(
                    icon: Icons.grid_view,
                    label: context.l10n.navBazi,
                    isActive: widget.currentTarget == AppNavTarget.bazi,
                    onTap: () => AppBottomNavBar.navigateTo(context, AppNavTarget.bazi, widget.currentTarget),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _activeController;
  late Animation<double> _activeAnimation;

  @override
  void initState() {
    super.initState();
    _activeController = AnimationController(
      vsync: this,
      duration: AppTheme.animStandard,
    );
    _activeAnimation = CurvedAnimation(
      parent: _activeController,
      curve: Curves.easeOutCubic,
    );
    if (widget.isActive) {
      _activeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _activeController.forward();
      } else {
        _activeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _activeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _activeAnimation,
          builder: (context, child) {
            // 激活时使用强调色，非激活时使用文本色
            final activeColor = AppTheme.fluorescentCyan;
            final inactiveColor = AppTheme.inkText.withOpacity(0.5);
            final color = Color.lerp(
              inactiveColor,
              activeColor,
              _activeAnimation.value,
            )!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标容器 - 激活时显示发光背景
                Container(
                  width: 40,
                  height: 32,
                  decoration: widget.isActive
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          color: activeColor.withOpacity(0.12 * _activeAnimation.value),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withOpacity(0.2 * _activeAnimation.value),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    widget.icon,
                    color: color,
                    size: 22,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
