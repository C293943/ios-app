import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
import 'package:primordial_spirit/widgets/hidden_stems_sheet.dart';

class BaziScreen extends StatelessWidget {
  const BaziScreen({super.key});

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
            // Background decorations could go here
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        0,
                        AppTheme.spacingMd,
                        100,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: AppTheme.spacingMd),
                          const _UserInfoCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _FourPillarsCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _FiveElementsChartCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _XiYongShenCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _DaYunCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _SpiritChatCard(),
                          SizedBox(height: AppTheme.spacingMd),
                          const _LockedReportCard(),
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
              child: AppBottomNavBar(
                currentTarget: AppNavTarget.bazi,
                onNavigation: (target) {
                   if (target == AppNavTarget.bazi) return;
                   
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
                     case AppNavTarget.fortune:
                       _switchTab(context, AppRoutes.fortune); 
                       break;
                     default:
                       break;
                   }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 48),
          Text(
            '八字',
            style: AppTheme.mysticTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.inkText,
              fontSize: 20,
            ),
          ),
          ClipRRect(
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
                child: Icon(Icons.share, color: AppTheme.inkText, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _switchTab(BuildContext context, String routeName) {
  final current = ModalRoute.of(context)?.settings.name;
  if (current == routeName) return;
  Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: AppTheme.jadeGreen, size: 20),
                  SizedBox(width: AppTheme.spacingSm),
                  Text(
                    '用户资料',
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              LiquidInfoTag(
                text: '编辑',
                color: AppTheme.amberGold,
                outlined: true,
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '姓名: 张三',
                          style: TextStyle(
                            color: AppTheme.inkText,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingSm),
                        Icon(Icons.male, color: Colors.blue[300], size: 16),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                      '生肖: 龙',
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Icon(Icons.sunny, color: Colors.orange[300], size: 16),
                        SizedBox(width: AppTheme.spacingXs),
                        Text(
                          '真太阳时已校正',
                          style: TextStyle(
                            color: AppTheme.inkText.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '公历: 1988年3月15日 10:30',
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                      '农历: 戊辰年正月廿八',
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FourPillarsCard extends StatelessWidget {
  const _FourPillarsCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      accentColor: AppTheme.amberGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, color: AppTheme.amberGold, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                '四柱排盘',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPillarItem(
                title: '年柱',
                topChar: '戊',
                bottomChar: '辰',
                elementTop: '土',
                elementBottom: '土',
                god: '偏印',
                color1: const Color(0xFFD4B976),
                color2: const Color(0xFF8B7355).withOpacity(0.8),
              ),
              _buildPillarItem(
                title: '月柱',
                topChar: '乙',
                bottomChar: '卯',
                elementTop: '木',
                elementBottom: '木',
                god: '正财',
                color1: const Color(0xFF98CAA6),
                color2: const Color(0xFF568F6C).withOpacity(0.8),
              ),
              _buildPillarItem(
                title: '日柱',
                topChar: '庚',
                bottomChar: '申',
                elementTop: '金',
                elementBottom: '金',
                god: '日元',
                color1: const Color(0xFFE8EBF0),
                color2: const Color(0xFFAAB2BD).withOpacity(0.8),
                isDayMaster: true,
              ),
              _buildPillarItem(
                title: '时柱',
                topChar: '辛',
                bottomChar: '巳',
                elementTop: '金',
                elementBottom: '火',
                god: '食神',
                color1: const Color(0xFFE8B0B0),
                color2: const Color(0xFFC06C6C).withOpacity(0.8),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Center(
            child: GestureDetector(
              onTap: () => HiddenStemsSheet.show(context),
              child: LiquidInfoTag(
                text: '展开藏干',
                icon: Icons.expand_more,
                color: AppTheme.fluorescentCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem({
    required String title,
    required String topChar,
    required String bottomChar,
    required String elementTop,
    required String elementBottom,
    required String god,
    required Color color1,
    required Color color2,
    bool isDayMaster = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.inkText.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
          Container(
          width: 68,
          height: 160, // Increased from 140 to prevent overflow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color1.withOpacity(0.9),
                color2.withOpacity(0.6), // Fade out slightly
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color1.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              if (isDayMaster)
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                topChar,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A), // Dark text for contrast on these colors
                  fontFamily: 'NotoSerifSC', // Assuming serif font available
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bottomChar,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  fontFamily: 'NotoSerifSC',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    elementTop,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                    ),
                  ),
                  Text(
                    elementBottom,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                god,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FiveElementsChartCard extends StatelessWidget {
  const _FiveElementsChartCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      accentColor: AppTheme.fluorescentCyan,
      child: SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: AppTheme.fluorescentCyan, size: 20),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  '五行强弱分析',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingMd),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _FiveElementsRadarChart(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LiquidInfoTag(
                          text: '最旺: 木',
                          color: const Color(0xFF98CAA6),
                        ),
                        SizedBox(width: AppTheme.spacingMd),
                        LiquidInfoTag(
                          text: '最弱: 水',
                          color: const Color(0xFFA4C8E8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiveElementsRadarChart extends StatelessWidget {
  const _FiveElementsRadarChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _RadarChartPainter(),
      child: const SizedBox(
        width: 200,
        height: 200,
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values = [0.35, 0.20, 0.25, 0.15, 0.05];
  final List<String> labels = ['木 35%', '火 20%', '土 25%', '金 15%', '水 5%'];
  
  List<double> get normalizedValues {
    double max = values.reduce(math.max);
    return values.map((e) => (e / max) * 0.8 + 0.1).toList(); 
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.75; 

    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintFill = Paint()
      ..style = PaintingStyle.fill;
    
    for (int i = 1; i <= 5; i++) {
      _drawPentagon(canvas, center, radius * (i / 5), paintGrid);
    }
    
    _drawSpokes(canvas, center, radius, paintGrid);

    final path = Path();
    final normValues = normalizedValues;
    final angleStep = (2 * math.pi) / 5;
    
    double startAngle = -math.pi / 2;

    for (int i = 0; i < 5; i++) {
      final r = radius * normValues[i];
      final angle = startAngle + i * angleStep;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    paintFill.shader = const LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFFE8C872)], 
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawPath(path, paintFill);
    
    final paintBorder = Paint()
      ..color = const Color(0xFFE8C872)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paintBorder);

    const textStyle = TextStyle(color: Colors.white70, fontSize: 12);
    for (int i = 0; i < 5; i++) {
      final angle = startAngle + i * angleStep;
      final labelRadius = radius + 20; 
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawPentagon(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    final angleStep = (2 * math.pi) / 5;
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSpokes(Canvas canvas, Offset center, double r, Paint paint) {
    final angleStep = (2 * math.pi) / 5;
    double startAngle = -math.pi / 2;
    for (int i = 0; i < 5; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- New Components ---

class _XiYongShenCard extends StatelessWidget {
  const _XiYongShenCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, color: AppTheme.jadeGreen, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                '喜用神 / 忌神',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: LiquidMiniCard(
                  accentColor: AppTheme.jadeGreen,
                  child: Column(
                    children: [
                      Text(
                        '喜用神',
                        style: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('木', style: TextStyle(color: const Color(0xFF98CAA6), fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(width: AppTheme.spacingSm),
                          Text('火', style: TextStyle(color: const Color(0xFFE8B0B0), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: AppTheme.borderStandard,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.liquidGlassBorder.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: LiquidMiniCard(
                  accentColor: const Color(0xFFFF6B6B),
                  child: Column(
                    children: [
                      Text(
                        '忌神',
                        style: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('金', style: TextStyle(color: const Color(0xFFE8EBF0), fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(width: AppTheme.spacingSm),
                          Text('水', style: TextStyle(color: const Color(0xFFA4C8E8), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          LiquidMiniCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '八字格局: 正官格',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '日元旺衰: 偏弱 (45分)',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 14,
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

class _DaYunCard extends StatelessWidget {
  const _DaYunCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      accentColor: AppTheme.electricBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppTheme.electricBlue, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                '大运流年',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDaYunItem('23-32岁', false),
              _buildDaYunItem('33-42岁', true),
              _buildDaYunItem('43-52岁', false),
              _buildDaYunItem('53-62岁', false),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          LiquidMiniCard(
            accentColor: const Color(0xFFA4C8E8),
            child: Row(
              children: [
                Icon(Icons.water_drop, size: 16, color: const Color(0xFFA4C8E8)),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  '当前大运: 癸亥 (水水)',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaYunItem(String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.jadeGreen.withOpacity(0.2) 
            : AppTheme.liquidGlassLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isActive 
              ? AppTheme.jadeGreen.withOpacity(0.5) 
              : AppTheme.liquidGlassBorderSoft,
          width: AppTheme.borderThin,
        ),
        boxShadow: isActive 
            ? [
                BoxShadow(
                  color: AppTheme.jadeGreen.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ] 
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.jadeGreen : AppTheme.inkText.withOpacity(0.6),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SpiritChatCard extends StatelessWidget {
  const _SpiritChatCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.zero,
      compact: true,
      accentColor: AppTheme.jadeGreen,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.jadeGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.jadeGreen.withOpacity(0.3),
                width: AppTheme.borderThin,
              ),
            ),
            child: Icon(Icons.chat_bubble_outline, color: AppTheme.jadeGreen, size: 24),
          ),
          SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '问问元神',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  '我的八字适合什么职业?',
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
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
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Text(
                '开始对话',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedReportCard extends StatelessWidget {
  const _LockedReportCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.baziReport),
      child: LiquidCard(
        margin: EdgeInsets.zero,
        accentColor: AppTheme.amberGold,
        elevated: true,
        child: SizedBox(
          height: 160,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.article_outlined, color: AppTheme.amberGold, size: 20),
                      SizedBox(width: AppTheme.spacingSm),
                      Text(
                        '详细命理报告',
                        style: TextStyle(
                          color: AppTheme.inkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Expanded(
                    child: Opacity(
                      opacity: 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(4, (index) => 
                          Container(
                            margin: EdgeInsets.only(bottom: AppTheme.spacingSm),
                            width: double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.inkText.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          )
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                        vertical: AppTheme.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.amberGold.withOpacity(0.9),
                            const Color(0xFFF0E68C),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: AppTheme.borderThin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberGold.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: const Color(0xFF8B6D43), size: 18),
                          SizedBox(width: AppTheme.spacingSm),
                          Text(
                            '解锁完整报告',
                            style: TextStyle(
                              color: const Color(0xFF5D4037),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
