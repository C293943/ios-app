import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
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
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          SizedBox(height: AppTheme.spacingMd),
                          const _DailyFortuneCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _FortuneGrid(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _LuckyActionCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _YiJiCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _AuspiciousTimeCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _FortuneTrendCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _AnalysisReportCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _WishesCard(),
                          SizedBox(height: AppTheme.spacingLg),
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
              child: AppBottomNavBar(currentTarget: AppNavTarget.fortune),
            ),
          ],
        ),
      ),
    );
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
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: AppTheme.spacingLg),
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
              _buildIconButton(Icons.calendar_month),
              SizedBox(width: AppTheme.spacingMd),
              _buildIconButton(Icons.share),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacingSm),
          decoration: BoxDecoration(
            color: AppTheme.liquidGlassLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: AppTheme.liquidGlassBorderSoft,
              width: AppTheme.borderThin,
            ),
          ),
          child: Icon(icon, color: AppTheme.inkText, size: 22),
        ),
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
    
    return LiquidCard(
      elevated: true,
      accentColor: AppTheme.amberGold,
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
          SizedBox(height: AppTheme.spacingMd),
          Text(
            "今日吉星高照，宜静心修炼，静待花开",
            style: TextStyle(
              color: AppTheme.inkText,
              fontSize: 22,
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontFamily: 'ZCOOLXiaoWei',
            ),
          ),
          SizedBox(height: AppTheme.spacingMd),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat),
              child: LiquidInfoTag(
                text: "问问元神",
                icon: Icons.chat_bubble_outline,
                color: AppTheme.jadeGreen,
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
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
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
                ),
                SizedBox(height: AppTheme.spacingMd),
                _FortuneItem(
                  icon: Icons.favorite_outline,
                  title: "健康",
                  stars: 3,
                  color: AppTheme.lotusPink,
                ),
              ],
            ),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              children: [
                _FortuneItem(
                  icon: Icons.work_outline,
                  title: "事业",
                  stars: 5,
                  color: AppTheme.electricBlue,
                ),
                SizedBox(height: AppTheme.spacingMd),
                _FortuneItem(
                  icon: Icons.favorite,
                  title: "感情",
                  stars: 5,
                  color: AppTheme.lotusPink,
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

  const _FortuneItem({
    required this.icon,
    required this.title,
    required this.stars,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidMiniCard(
      accentColor: color,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: AppTheme.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: AppTheme.spacingMd),
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
                SizedBox(height: AppTheme.spacingXs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isActive = index < stars;
                      return Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(
                          isActive ? Icons.star : Icons.star_outline,
                          size: 14,
                          color: isActive ? AppTheme.amberGold : AppTheme.inkText.withOpacity(0.2),
                        ),
                      );
                    }),
                  ),
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
    return LiquidCard(
      compact: true,
      accentColor: AppTheme.amberGold,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.amberGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(Icons.auto_awesome, color: AppTheme.amberGold, size: 18),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Text(
            "今日开运: ",
            style: TextStyle(
              color: AppTheme.amberGold,
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
          Icon(
            Icons.chevron_right,
            color: AppTheme.inkText.withOpacity(0.4),
            size: 20,
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
    return LiquidCard(
      child: Row(
        children: [
          Expanded(
            child: _YiJiItem(
              type: "宜",
              items: const ["祭祀", "静修", "安床"],
              color: AppTheme.jadeGreen,
            ),
          ),
          Container(
            width: AppTheme.borderStandard,
            height: 70,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.liquidGlassBorder.withOpacity(0.5),
                  AppTheme.liquidGlassBorder.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(
            child: _YiJiItem(
              type: "忌",
              items: const ["出行", "动土", "嫁娶"],
              color: const Color(0xFFFF6B6B),
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

  const _YiJiItem({
    required this.type,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.4),
              width: AppTheme.borderStandard,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: -2,
              ),
            ],
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
        SizedBox(height: AppTheme.spacingMd),
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
    return LiquidCard(
      accentColor: AppTheme.fluorescentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppTheme.fluorescentCyan, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "今日吉时",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          _TimeSlotRow(time: "14:00 - 15:00", activity: "宜：重要会议"),
          SizedBox(height: AppTheme.spacingSm),
          _TimeSlotRow(time: "16:00 - 17:00", activity: "宜：签约合作"),
          SizedBox(height: AppTheme.spacingSm),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.liquidGlassLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.liquidGlassBorderSoft,
          width: AppTheme.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppTheme.jadeGreen, size: 16),
          SizedBox(width: AppTheme.spacingSm),
          Text(
            time,
            style: TextStyle(
              color: AppTheme.inkText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            activity,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneTrendCard extends StatelessWidget {
  const _FortuneTrendCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.jadeGreen,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, color: AppTheme.jadeGreen, size: 20),
                  SizedBox(width: AppTheme.spacingSm),
                  Text(
                    "运势走势",
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: AppTheme.liquidGlassLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: AppTheme.liquidGlassBorderSoft,
                    width: AppTheme.borderThin,
                  ),
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
          SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _TrendLinePainter(color: AppTheme.jadeGreen),
              child: Container(),
            ),
          ),
          SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("周一", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
              Text("2024年10月", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
              Text("周日", style: TextStyle(fontSize: 12, color: AppTheme.inkText.withOpacity(0.5))),
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
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.jadeGreen.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isSelected
            ? Border.all(
                color: AppTheme.jadeGreen.withOpacity(0.5),
                width: AppTheme.borderThin,
              )
            : null,
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
    return LiquidCard(
      accentColor: AppTheme.amberGold,
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: SizedBox(
        height: 120,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: AppTheme.amberGold, size: 20),
                    SizedBox(width: AppTheme.spacingSm),
                    Text(
                      "分析报告",
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingMd),
                // 模糊内容
                Opacity(
                  opacity: 0.3,
                  child: Column(
                    children: [
                      _BlurredRow(),
                      SizedBox(height: AppTheme.spacingSm),
                      _BlurredRow(),
                      SizedBox(height: AppTheme.spacingSm),
                      _BlurredRow(),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.fortuneDetail),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                        vertical: AppTheme.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.liquidGlassBase.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: AppTheme.amberGold.withOpacity(0.5),
                          width: AppTheme.borderStandard,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberGold.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, color: AppTheme.amberGold, size: 18),
                          SizedBox(width: AppTheme.spacingSm),
                          Text(
                            "解锁本月运势报告 (5灵石)",
                            style: TextStyle(
                              color: AppTheme.inkText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurredRow extends StatelessWidget {
  const _BlurredRow({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.inkText.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
        const Spacer(),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.inkText.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      ],
    );
  }
}

class _WishesCard extends StatelessWidget {
  const _WishesCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.lotusPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.lotusPink, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "我的愿望",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(child: _WishItem(title: "考试顺利", date: "2024-10-28")),
              SizedBox(width: AppTheme.spacingMd),
              Expanded(child: _WishItem(title: "身体健康", date: "2024-09-30")),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.jadeGreen.withOpacity(0.8),
                    AppTheme.fluorescentCyan.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.jadeGreen.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: AppTheme.spacingXs),
                  Text(
                    "添加愿望",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
    return LiquidMiniCard(
      accentColor: AppTheme.lotusPink,
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
          SizedBox(height: AppTheme.spacingXs),
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
