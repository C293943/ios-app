import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';

class FortuneDetailScreen extends StatelessWidget {
  const FortuneDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingSm),
            child: ClipRRect(
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
                  child: Icon(Icons.arrow_back_ios, color: AppTheme.inkText, size: 18),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          "流年详情",
          style: TextStyle(
            color: AppTheme.inkText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
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
          SizedBox(width: AppTheme.spacingMd),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.voidGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            child: Column(
              children: [
                const _OverviewCard(),
                SizedBox(height: AppTheme.spacingMd),
                const _RadarChartCard(),
                SizedBox(height: AppTheme.spacingMd),
                const _MonthlyTrendCard(),
                SizedBox(height: AppTheme.spacingMd),
                const _TenGodsCard(),
                SizedBox(height: AppTheme.spacingMd),
                const _DetailedAnalysisList(),
                SizedBox(height: AppTheme.spacingMd),
                const _LuckTipsCard(),
                SizedBox(height: AppTheme.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      elevated: true,
      accentColor: AppTheme.jadeGreen,
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "2024年 甲辰年",
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  "当前大运: 癸亥 (33-42岁)",
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: AppTheme.spacingLg),
                LiquidInfoTag(
                  text: "整体运势: 平稳向上",
                  color: AppTheme.jadeGreen,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _ScoreCirclePainter(score: 75, color: AppTheme.jadeGreen),
              child: Center(
                child: Text(
                  "75分",
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double score;
  final Color color;

  _ScoreCirclePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [AppTheme.fluorescentCyan, color],
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = 2 * pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarChartCard extends StatelessWidget {
  const _RadarChartCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.amberGold,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar, color: AppTheme.amberGold, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "五维运势分析",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarChartPainter(
                values: [0.8, 0.7, 0.65, 0.75, 0.85],
                labels: ["事业运", "财运", "感情运", "健康运", "人际运"],
                color: AppTheme.amberGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;

  _RadarChartPainter({required this.values, required this.labels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20; // Padding for labels
    final angleStep = 2 * pi / values.length;

    final linePaint = Paint()
      ..color = AppTheme.inkText.withOpacity(0.2) // Adjusted for light/dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw web
    for (var i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (var j = 0; j < values.length; j++) {
        final angle = j * angleStep - pi / 2;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, linePaint);
    }

    // Draw values
    final valuePath = Path();
    for (var i = 0; i < values.length; i++) {
      final r = radius * values[i];
      final angle = i * angleStep - pi / 2;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) valuePath.moveTo(x, y);
      else valuePath.lineTo(x, y);
    }
    valuePath.close();
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, borderPaint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    for (var i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final r = radius + 15;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      
      textPainter.text = TextSpan(
        text: "${labels[i]}\n${(values[i]*100).toInt()}",
        style: TextStyle(color: AppTheme.inkText.withOpacity(0.8), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.fluorescentCyan,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.fluorescentCyan, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "流月运势走势",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLg),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _MonthlyTrendPainter(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTrendPainter extends CustomPainter {
  final Color color;

  _MonthlyTrendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Draw Axis lines
    final axisPaint = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 1;
    canvas.drawLine(Offset(0, height), Offset(width, height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, height), axisPaint);

    final path = Path();
    final points = <Offset>[];
    final stepX = width / 11;
    
    // Generate mock points
    for(int i=0; i<12; i++) {
        double y = height * 0.5 + 30 * sin(i * 0.5); // Mock wave
        points.add(Offset(i * stepX, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for(int i=1; i<points.length; i++) {
        // Cubic bezier for smooth curve
        final p0 = points[i-1];
        final p1 = points[i];
        final cp1 = Offset(p0.dx + stepX/2, p0.dy);
        final cp2 = Offset(p1.dx - stepX/2, p1.dy);
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawPath(path, paint);
    
    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();
    
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
      
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TenGodsCard extends StatelessWidget {
  const _TenGodsCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.amberGold,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: AppTheme.amberGold, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "流年十神与神煞",
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
              Expanded(child: _InfoBox(title: "主导十神", content: "🟡 正财")),
              SizedBox(width: AppTheme.spacingMd),
              Expanded(child: _InfoBox(title: "吉神", content: "✨ 天乙贵人, 文昌")),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          _InfoBox(title: "凶煞", content: "⚠️ 无"),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBox({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return LiquidMiniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          SizedBox(height: AppTheme.spacingXs),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.inkText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedAnalysisList extends StatelessWidget {
  const _DetailedAnalysisList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
          child: Row(
            children: [
              Icon(Icons.article_outlined, color: AppTheme.inkText, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "详细运势分析",
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppTheme.spacingMd),
        _AnalysisItem(
          icon: Icons.work_outline,
          title: "事业运 (Career) - 80分",
          content: "今年事业运势较好，有升迁机会。正财星得地，适合稳扎稳打...",
          color: AppTheme.electricBlue,
        ),
        SizedBox(height: AppTheme.spacingMd),
        _AnalysisItem(
          icon: Icons.monetization_on_outlined,
          title: "财运 (Wealth) - 70分",
          content: "正财稳定，偏财一般。上半年财运较好，下半年需谨慎投资...",
          color: AppTheme.amberGold,
        ),
        SizedBox(height: AppTheme.spacingMd),
        _AnalysisItem(
          icon: Icons.favorite_border,
          title: "感情运 (Love) - 65分",
          content: "感情运势平稳，已婚者需注意沟通。单身者桃花运一般...",
          color: AppTheme.lotusPink,
        ),
      ],
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _AnalysisItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: color,
      margin: EdgeInsets.zero,
      compact: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Icon(icon, color: color, size: 20),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  content,
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "展开全文",
                        style: TextStyle(
                          color: color.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: color.withOpacity(0.8), size: 16),
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
}

class _LuckTipsCard extends StatelessWidget {
  const _LuckTipsCard();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      accentColor: AppTheme.jadeGreen,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.jadeGreen, size: 20),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                "开运锦囊",
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
              Expanded(child: _TipBox(label: "幸运色", value: "绿色, 青色", highlight: true)),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(child: _TipBox(label: "幸运数字", value: "3, 8")),
              SizedBox(width: AppTheme.spacingSm),
              Expanded(child: _TipBox(label: "吉利方位", value: "东方, 东南")),
            ],
          ),
          SizedBox(height: AppTheme.spacingMd),
          LiquidMiniCard(
            accentColor: AppTheme.jadeGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("宜: ", style: TextStyle(color: AppTheme.jadeGreen, fontWeight: FontWeight.bold)),
                    Text("求职, 投资, 结婚", style: TextStyle(color: AppTheme.inkText.withOpacity(0.9))),
                  ],
                ),
                SizedBox(height: AppTheme.spacingXs),
                Row(
                  children: [
                    Text("忌: ", style: TextStyle(color: const Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                    Text("搬家, 动土, 大额借贷", style: TextStyle(color: AppTheme.inkText.withOpacity(0.9))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _TipBox({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = highlight ? AppTheme.jadeGreen : AppTheme.liquidGlow;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.spacingMd,
        horizontal: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: highlight 
            ? AppTheme.jadeGreen.withOpacity(0.15) 
            : AppTheme.liquidGlassLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: highlight 
              ? AppTheme.jadeGreen.withOpacity(0.4) 
              : AppTheme.liquidGlassBorderSoft,
          width: AppTheme.borderThin,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: effectiveColor.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          SizedBox(height: AppTheme.spacingXs),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppTheme.jadeGreen : AppTheme.inkText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
