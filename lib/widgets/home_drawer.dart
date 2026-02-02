import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

import 'package:provider/provider.dart';
import 'package:primordial_spirit/services/theme_service.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/screens/member_recharge_screen.dart';
// import 'package:primordial_spirit/widgets/common/mystic_button.dart'; // No longer needed

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    return Drawer(
      width: 280,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Blur Background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.voidBackground.withOpacity(0.4),
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.scrollBorder.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 30),
                        _buildStatsCard(context),
                        const SizedBox(height: 16),
                        _buildUsageCard(context),
                        const SizedBox(height: 30),
                        Text(
                          context.l10n.accountSettings,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuItem(
                          context, 
                          icon: Icons.settings, 
                          title: context.l10n.accountSettings,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.settings);
                          },
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.language, 
                          title: context.l10n.languageSelection,
                          onTap: () {
                            Navigator.pop(context); // Close drawer
                            Navigator.pushNamed(context, AppRoutes.language);
                          },
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.dark_mode_outlined, 
                          title: context.l10n.themeToggle,
                          onTap: () {
                            context.read<ThemeService>().toggleTheme();
                            // Theme toggle is instant, maybe don't close drawer? 
                            // Or close it to show effect on main screen? 
                            // User request: "点击后抽屉是不是放回去更好" -> applies to navigation mainly
                            // For theme toggle, let's keep it open so they can see the change in drawer too?
                            // Or close it as per general request. Let's close it.
                            // Actually, theme toggle is a switch, usually doesn't close drawer.
                            // But user said "点击后抽屉是不是放回去更好", I'll assume for navigation items.
                          },
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.info_outline, 
                          title: context.l10n.aboutUs,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.about);
                          },
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.exit_to_app, 
                          title: context.l10n.logout,
                          isLogout: true,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                        ),
                        const SizedBox(height: 40), // Bottom padding for safety
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.amberGold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.amberGold.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppTheme.spiritGlass,
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.spiritName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Text(
                context.l10n.edit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.spirit,
      glowColor: AppTheme.jadeGreen.withOpacity(0.3),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.spiritStoneCount,
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.diamond, size: 16, color: AppTheme.fluorescentCyan),
                ],
              ),
            ],
          ),
          // 添加一个半透明的装饰性背景或图标
          Opacity(
            opacity: 0.8,
            child: Icon(
              Icons.auto_awesome, 
              size: 40, 
              color: AppTheme.fluorescentCyan.withOpacity(0.2)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.spirit,
      glowColor: AppTheme.fluorescentCyan.withOpacity(0.3),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dailyChatCount,
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '10',
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/10',
                    style: TextStyle(
                      color: AppTheme.inkText.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemberRechargeScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.inkText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.inkText.withOpacity(0.2)),
              ),
              child: Text(
                context.l10n.recharge,
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLogout 
                  ? AppTheme.lotusPink.withOpacity(0.2)
                  : AppTheme.spiritGlass,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isLogout ? AppTheme.lotusPink : AppTheme.fluorescentCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
