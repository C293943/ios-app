import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.voidGradient,
        ),
        child: Stack(
          children: [
            const _BackgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  const _FortuneAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100), // Space for nav bar
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const _DailyFortuneCard(),
                          const SizedBox(height: 16),
                          const _FortuneGrid(),
                          const SizedBox(height: 16),
                          const _LuckyActionCard(),
                          const SizedBox(height: 16),
                          const _YiJiCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNavBar(
                currentTarget: AppNavTarget.fortune,
                onNavigation: (target) => _handleNavigation(context, target),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, AppNavTarget target) {
    if (target == AppNavTarget.fortune) return;

    switch (target) {
      case AppNavTarget.home:
        // Return to home (pop everything)
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case AppNavTarget.chat:
        Navigator.of(context).pushNamed(AppRoutes.chat);
        break;
      case AppNavTarget.relationship:
        Navigator.of(context).pushNamed(AppRoutes.relationshipSelect);
        break;
      case AppNavTarget.bazi:
        Navigator.of(context).pushNamed(AppRoutes.baziInput);
        break;
      case AppNavTarget.plaza:
        // TODO: Implement Plaza route
        break;
      case AppNavTarget.fortune:
        // Already on fortune screen
        break;
    }
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    // Simple star field or similar decoration
    return Container(); 
  }
}

class _FortuneAppBar extends StatelessWidget {
  const _FortuneAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back_ios, color: AppTheme.inkText, size: 20),
          ),
          Expanded(
            child: Text(
              "今日运势",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.inkText,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppTheme.inkText, size: 24),
              const SizedBox(width: 16),
              Icon(Icons.share, color: AppTheme.inkText, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyFortuneCard extends StatelessWidget {
  const _DailyFortuneCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日，EEEE', 'zh_CN').format(now);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "今日吉星高照，宜静心修炼，静待花开",
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 22,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ZCOOLXiaoWei', // Assuming this font is used in theme
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.jadeGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.jadeGreen.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, color: AppTheme.jadeGreen, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "问问元神",
                      style: TextStyle(
                        color: AppTheme.jadeGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneGrid extends StatelessWidget {
  const _FortuneGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _FortuneItem(
                  icon: Icons.monetization_on_outlined,
                  title: "财运",
                  stars: 4,
                  color: AppTheme.amberGold,
                  iconBgColor: AppTheme.jadeGreen.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                _FortuneItem(
                  icon: Icons.favorite_outline,
                  title: "健康",
                  stars: 3,
                  color: AppTheme.lotusPink,
                  iconBgColor: AppTheme.fluorescentCyan.withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _FortuneItem(
                  icon: Icons.work_outline,
                  title: "事业",
                  stars: 5,
                  color: AppTheme.electricBlue,
                  iconBgColor: AppTheme.electricBlue.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                _FortuneItem(
                  icon: Icons.favorite,
                  title: "感情",
                  stars: 5,
                  color: AppTheme.lotusPink,
                  iconBgColor: AppTheme.lotusPink.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int stars;
  final Color color;
  final Color iconBgColor;

  const _FortuneItem({
    required this.icon,
    required this.title,
    required this.stars,
    required this.color,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.inkText, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 12,
                      color: index < stars ? AppTheme.amberGold : Colors.grey.withOpacity(0.3),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyActionCard extends StatelessWidget {
  const _LuckyActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.amberGold, size: 20),
          const SizedBox(width: 8),
          Text(
            "今日开运: ",
            style: TextStyle(
              color: AppTheme.inkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              "听一首轻音乐",
              style: TextStyle(
                color: AppTheme.inkText.withOpacity(0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _YiJiCard extends StatelessWidget {
  const _YiJiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _YiJiItem(
              type: "宜",
              items: const ["祭祀", "静修", "安床"],
              color: AppTheme.jadeGreen,
              bgColor: AppTheme.jadeGreen.withOpacity(0.1),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppTheme.scrollBorder.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _YiJiItem(
              type: "忌",
              items: const ["出行", "动土", "嫁娶"],
              color: const Color(0xFFFF6B6B), // Reddish
              bgColor: const Color(0xFFFF6B6B).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _YiJiItem extends StatelessWidget {
  final String type;
  final List<String> items;
  final Color color;
  final Color bgColor;

  const _YiJiItem({
    required this.type,
    required this.items,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'ZCOOLXiaoWei',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "【$type】 ${items.join('、')}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.inkText.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
