import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildUsageCard(),
                  const SizedBox(height: 30),
                  const Text(
                    '账号设置',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context, 
                    icon: Icons.settings, 
                    title: '账号设置',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  _buildMenuItem(
                    context, 
                    icon: Icons.language, 
                    title: '语言选择',
                  ),
                  _buildMenuItem(
                    context, 
                    icon: Icons.dark_mode_outlined, 
                    title: '主题切换',
                  ),
                  _buildMenuItem(
                    context, 
                    icon: Icons.info_outline, 
                    title: '关于我们',
                  ),
                  _buildMenuItem(
                    context, 
                    icon: Icons.exit_to_app, 
                    title: '退出登录',
                    isLogout: true,
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  ),
                ],
              ),
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
            const Text(
              '元神',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Text(
                '编辑',
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

  Widget _buildStatsCard() {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '灵石数量',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildUsageCard() {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '每日对话次数',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    '10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/10',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '充值',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
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
