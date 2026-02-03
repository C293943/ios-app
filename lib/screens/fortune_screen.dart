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
                          const SizedBox(height: 16),
                          const _AuspiciousTimeCard(), // Added
                          const SizedBox(height: 16),
                          const _FortuneTrendCard(), // Added
                          const SizedBox(height: 16),
                          const _AnalysisReportCard(), // Added
                          const SizedBox(height: 16),
                          const _WishesCard(), // Added
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
        _switchTab(context, AppRoutes.home);
        break;
      case AppNavTarget.chat:
        _switchTab(context, AppRoutes.chat);
        break;
      case AppNavTarget.relationship:
        _switchTab(context, AppRoutes.relationshipSelect);
        break;
      case AppNavTarget.bazi:
        _switchTab(context, AppRoutes.bazi);
        break;
      case AppNavTarget.plaza:
        // TODO: Implement Plaza route
        break;
      case AppNavTarget.fortune:
        // Already on fortune screen
        break;
    }
  }

  void _switchTab(BuildContext context, String routeName) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current == routeName) return;
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
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
          const SizedBox(width: 20),
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

// --- New Cards based on scroll view ---

class _AuspiciousTimeCard extends StatelessWidget {
  const _AuspiciousTimeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "今日吉时",
            style: TextStyle(
              color: AppTheme.inkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _TimeSlotRow(time: "14:00 - 15:00", activity: "宜：重要会议"),
          const SizedBox(height: 8),
          _TimeSlotRow(time: "16:00 - 17:00", activity: "宜：签约合作"),
          const SizedBox(height: 8),
          _TimeSlotRow(time: "19:00 - 20:00", activity: "宜：放松休息"),
        ],
      ),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final String time;
  final String activity;

  const _TimeSlotRow({required this.time, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, color: AppTheme.jadeGreen.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Text(
          time,
          style: TextStyle(
            color: AppTheme.inkText.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          activity,
          style: TextStyle(
            color: AppTheme.inkText.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _FortuneTrendCard extends StatelessWidget {
  const _FortuneTrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "运势走势",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _TabItem(title: "日", isSelected: false),
                    _TabItem(title: "月", isSelected: true),
                    _TabItem(title: "年", isSelected: false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _TrendLinePainter(color: AppTheme.jadeGreen),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("每一", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
              Text("2024年10月", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
              Text("每日", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _TabItem({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.jadeGreen.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.jadeGreen : AppTheme.inkText.withOpacity(0.6),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  final Color color;

  _TrendLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Simulate a curve
    path.moveTo(0, height * 0.8);
    path.quadraticBezierTo(width * 0.2, height * 0.4, width * 0.4, height * 0.6);
    path.quadraticBezierTo(width * 0.6, height * 0.9, width * 0.8, height * 0.3);
    path.quadraticBezierTo(width * 0.9, height * 0.2, width, height * 0.4);

    // Gradient shader for the line
    final shader = LinearGradient(
      colors: [Colors.cyanAccent, AppTheme.amberGold],
    ).createShader(Rect.fromLTWH(0, 0, width, height));
    paint.shader = shader;

    canvas.drawPath(path, paint);

    // Fill below
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw points
    final points = [
      Offset(width * 0.2, height * 0.52), // Approx from curve logic
      Offset(width * 0.4, height * 0.6),
      Offset(width * 0.6, height * 0.6), // logic
      Offset(width * 0.8, height * 0.3),
    ];
    
    for (var point in points) {
       canvas.drawCircle(point, 4, Paint()..color = Colors.white.withOpacity(0.8));
       canvas.drawCircle(point, 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalysisReportCard extends StatelessWidget {
  const _AnalysisReportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      height: 140, // Fixed height for visual consistency
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "分析报告",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Blurred content simulation
              Opacity(
                opacity: 0.3,
                child: Column(
                  children: [
                    _BlurredRow(),
                    const SizedBox(height: 8),
                    _BlurredRow(),
                    const SizedBox(height: 8),
                    _BlurredRow(),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                // Navigate to details
                Navigator.of(context).pushNamed(AppRoutes.fortuneDetail);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, color: AppTheme.amberGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "解锁本月运势报告 (5灵石)",
                      style: TextStyle(
                        color: AppTheme.inkText,
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

class _BlurredRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 100, height: 12, color: Colors.grey),
        const Spacer(),
        Container(width: 60, height: 12, color: Colors.grey),
      ],
    );
  }
}

class _WishesCard extends StatelessWidget {
  const _WishesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "我的愿望",
            style: TextStyle(
              color: AppTheme.inkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _WishItem(title: "考试顺利", date: "2024-10-28")),
              const SizedBox(width: 12),
              Expanded(child: _WishItem(title: "身体健康", date: "2024-09-30")),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.jadeGreen.withOpacity(0.8), AppTheme.fluorescentCyan.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "添加愿望",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

class _WishItem extends StatelessWidget {
  final String title;
  final String date;

  const _WishItem({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.inkText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
