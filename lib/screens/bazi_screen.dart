import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const _UserInfoCard(),
                          const SizedBox(height: 16),
                          const _FourPillarsCard(),
                          const SizedBox(height: 16),
                          const _FiveElementsChartCard(),
                          const SizedBox(height: 16),
                          const _XiYongShenCard(),
                          const SizedBox(height: 16),
                          const _DaYunCard(),
                          const SizedBox(height: 16),
                          const _SpiritChatCard(),
                          const SizedBox(height: 16),
                          const _LockedReportCard(),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            '八字',
            style: AppTheme.mysticTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.inkText,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: Icon(Icons.share, color: AppTheme.inkText),
            onPressed: () {
              // Share functionality
            },
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
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '用户资料',
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  '编辑',
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                        const SizedBox(width: 6),
                        Icon(Icons.male, color: Colors.blue[300], size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '生肖: 龙',
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.sunny, color: Colors.orange[300], size: 16),
                        const SizedBox(width: 4),
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
                    const SizedBox(height: 8),
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
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '四柱排盘',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const HiddenStemsSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '展开藏干',
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
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
    return GlassContainer(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '五行强弱分析',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
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
                      _buildStatusChip('最旺: 木', const Color(0xFF98CAA6)),
                      const SizedBox(width: 16),
                      _buildStatusChip('最弱: 水', const Color(0xFFA4C8E8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.inkText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
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
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '喜用神 / 忌神',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '喜用神',
                        style: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('木', style: TextStyle(color: const Color(0xFF98CAA6), fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('火', style: TextStyle(color: const Color(0xFFE8B0B0), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 8)), // Reduced from 16
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '忌神',
                        style: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('金', style: TextStyle(color: const Color(0xFFE8EBF0), fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('水', style: TextStyle(color: const Color(0xFFA4C8E8), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  '八字格局: 正官格',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
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
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '大运流年',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDaYunItem('23-32岁', false),
              _buildDaYunItem('33-42岁', true),
              _buildDaYunItem('43-52岁', false),
              _buildDaYunItem('53-62岁', false),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '当前大运: 癸亥 (水水)',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.water_drop, size: 14, color: Color(0xFFA4C8E8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaYunItem(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding from 12 to 8 to prevent overflow
      decoration: BoxDecoration(
        color: isActive ? AppTheme.jadeGreen.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: AppTheme.jadeGreen.withOpacity(0.6)) : null,
        boxShadow: isActive ? [BoxShadow(color: AppTheme.jadeGreen.withOpacity(0.2), blurRadius: 8)] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.inkText : AppTheme.inkText.withOpacity(0.6),
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
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chat_bubble_outline, color: AppTheme.jadeGreen, size: 24),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.jadeGreen.withOpacity(0.8), AppTheme.fluorescentCyan.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
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
      child: GlassContainer(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '详细命理报告',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Opacity(
                    opacity: 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(4, (index) => 
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: double.infinity,
                          height: 12,
                          color: Colors.grey,
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.amberGold.withOpacity(0.9), Color(0xFFF0E68C)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.amberGold.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Color(0xFF8B6D43), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '解锁完整报告',
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
