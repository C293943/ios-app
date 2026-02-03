import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

enum AppNavTarget { home, chat, relationship, fortune, bazi, plaza }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentTarget,
    required this.onNavigation,
  });

  final AppNavTarget currentTarget;
  final ValueChanged<AppNavTarget> onNavigation;

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
                        _NavItem(
                          icon: Icons.person_outline, // 元神 (Home) - using person as placeholder for "Spirit" if label only
                          label: context.l10n.spiritName, // "元神"
                          isActive: currentTarget == AppNavTarget.home,
                          onTap: () => onNavigation(AppNavTarget.home),
                          // Home in original was NavLabelOnly, let's keep it consistent or standard?
                          // Original had _NavLabelOnly for the first item. 
                          // Let's use standard items for all for consistency, or reproduce the special one.
                          // The image shows "元神" as just text or standard icon?
                          // Image: "元神" (bottom left). It looks like a standard tab.
                          // In original code, it was _NavLabelOnly.
                          // I will use _NavItem for all for now to ensure layout consistency.
                        ),
                        _NavItem(
                          icon: Icons.help_outline,
                          label: "问卜", // Need to find l10n key or use this
                          isActive: currentTarget == AppNavTarget.chat,
                          onTap: () => onNavigation(AppNavTarget.chat),
                        ),
                        _NavItem(
                          icon: Icons.favorite_border,
                          label: context.l10n.navRelationship, // "合盘"
                          isActive: currentTarget == AppNavTarget.relationship,
                          onTap: () => onNavigation(AppNavTarget.relationship),
                        ),
                        _NavItem(
                          icon: Icons.auto_graph,
                          label: context.l10n.navFortune, // "运势"
                          isActive: currentTarget == AppNavTarget.fortune,
                          onTap: () => onNavigation(AppNavTarget.fortune),
                        ),
                        _NavItem(
                          icon: Icons.grid_view,
                          label: context.l10n.navBazi, // "八字"
                          isActive: currentTarget == AppNavTarget.bazi,
                          onTap: () => onNavigation(AppNavTarget.bazi),
                        ),
                         _NavItem(
                          icon: Icons.public,
                          label: "广场", // "Plaza" - Placeholder
                          isActive: currentTarget == AppNavTarget.plaza,
                          onTap: () => onNavigation(AppNavTarget.plaza),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Center item floating effect if needed, otherwise just standard list
          // The original code had a _FloatingCrystal. 
          // If the "Fortune" is the center or highlighted one, or "Chat"?
          // In the image, "运势" is selected. Nothing is floating above others significantly.
          // But original code had _FloatingCrystal at `left: 24, bottom: 28`.
          // That seems to be an ornament near the "Home" tab (since left 24 is near start).
          // I'll leave the crystal out for generic nav bar or add it if it's part of the design.
          // The image doesn't clearly show a floating crystal, just tabs.
          // I will include the crystal decoration if it's part of the global theme, 
          // but maybe just positioned relative to the bar.
          Positioned(
             left: 24,
             bottom: 28,
             child: _FloatingCrystal(),
          ),
        ],
      ),
    );
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
    // If isActive, use special color/style
    final color = isActive
        ? AppTheme.warmYellow
        : AppTheme.inkText.withOpacity(0.5); // Fixed withOpacity for compatibility if withValues is new
        
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
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCrystal extends StatelessWidget {
  const _FloatingCrystal();

  static const String _crystalAsset = 'assets/images/spirit-stone-egg.png';

  @override
  Widget build(BuildContext context) {
    // Check if asset exists, otherwise use container
    return IgnorePointer( // Decoration only
      child: Container(
        width: 40, // Smaller than original 64 to fit better or as decoration
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.jadeGreen.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            _crystalAsset,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: AppTheme.jadeGreen.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}
