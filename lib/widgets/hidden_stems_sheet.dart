import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

class HiddenStemsSheet extends StatelessWidget {
  const HiddenStemsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.voidBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Background Gradient/Decor
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.spiritGlass.withOpacity(0.1),
                    AppTheme.voidBackground,
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Column(
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.inkText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Icon Box
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.amberGold.withOpacity(0.3),
                            AppTheme.amberGold.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.amberGold.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberGold.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.inventory_2_outlined, color: AppTheme.amberGold, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "藏干详情",
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "地支中蕴藏的天干能量",
                      style: TextStyle(
                        color: AppTheme.inkText.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Main Table
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Pillars Grid
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            // Header Row
                            _buildGridRow(
                              ["", "年柱", "月柱", "日柱", "时柱"],
                              isHeader: true,
                            ),
                            const Divider(height: 1, color: Colors.white10),
                            // Ten Gods (Main Star)
                            _buildGridRow(["主星", "偏印", "正财", "日元", "食神"]),
                            // Heavenly Stems
                            _buildGridRow(
                              ["天干", "戊", "乙", "庚", "辛"],
                              colors: [null, AppTheme.amberGold, Colors.green, Colors.grey, AppTheme.amberGold],
                              isLarge: true,
                            ),
                            // Earthly Branches
                            _buildGridRow(
                              ["地支", "辰", "卯", "申", "巳"],
                              colors: [null, AppTheme.amberGold, Colors.green, Colors.grey, Colors.red],
                              isLarge: true,
                            ),
                            // Hidden Stems Detail
                            const Divider(height: 1, color: Colors.white10),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        "藏干",
                                        style: TextStyle(
                                          color: AppTheme.inkText.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: _buildHiddenStemColumn(["戊·偏印", "乙·正官", "癸·伤官"])), // Dragon (Chen)
                                  Expanded(child: _buildHiddenStemColumn(["乙·正财"])), // Rabbit (Mao)
                                  Expanded(child: _buildHiddenStemColumn(["庚·比肩", "壬·食神", "戊·偏印"])), // Monkey (Shen)
                                  Expanded(child: _buildHiddenStemColumn(["丙·七杀", "戊·偏印", "庚·比肩"])), // Snake (Si)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Diagram Section (Exploded View)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.spiritGlass.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            // Example Diagram Title
                            Text(
                              "地支藏干示意图 (例: 寅木)",
                              style: TextStyle(
                                color: AppTheme.inkText.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 150,
                              child: CustomPaint(
                                painter: _HiddenStemDiagramPainter(),
                                child: Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Colors.green.shade300, Colors.green.shade700],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "寅木",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Close Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.jadeGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppTheme.jadeGreen.withOpacity(0.5)),
                          ),
                          child: Text(
                            "【收起藏干】",
                            style: TextStyle(
                              color: AppTheme.jadeGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridRow(List<String> items, {bool isHeader = false, bool isLarge = false, List<Color?>? colors}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(items.length, (index) {
          final isLabel = index == 0;
          final color = (colors != null && index < colors.length) ? colors[index] : null;
          
          return Expanded(
            flex: isLabel ? 0 : 1,
            child: SizedBox(
              width: isLabel ? 60 : null,
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    color: color ?? (isHeader || isLabel ? AppTheme.inkText.withOpacity(0.6) : AppTheme.inkText),
                    fontSize: isLarge ? 24 : 14,
                    fontWeight: isLarge || isHeader ? FontWeight.bold : FontWeight.normal,
                    fontFamily: isLarge ? 'NotoSerifSC' : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHiddenStemColumn(List<String> stems) {
    return Column(
      children: stems.map((stem) {
        final parts = stem.split('·');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text(
                parts[0], // Stem
                style: TextStyle(
                  color: _getStemColor(parts[0]),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                parts.length > 1 ? parts[1] : "", // God
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStemColor(String stem) {
    if (['甲', '乙', '寅', '卯'].contains(stem)) return Colors.green;
    if (['丙', '丁', '巳', '午'].contains(stem)) return Colors.redAccent;
    if (['戊', '己', '辰', '戌', '丑', '未'].contains(stem)) return AppTheme.amberGold;
    if (['庚', '辛', '申', '酉'].contains(stem)) return Colors.grey;
    if (['壬', '癸', '亥', '子'].contains(stem)) return Colors.blue;
    return AppTheme.inkText;
  }
}

class _HiddenStemDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 40.0;
    
    // Draw arrows and labels for Hidden Stems of Yin Wood (Tiger)
    // Yin (Tiger) contains: Jia (Main), Bing (Middle), Wu (Residual)
    
    final items = [
      _DiagramItem("甲(本)", Colors.green, -30 * 3.14159 / 180),
      _DiagramItem("丙(中)", Colors.redAccent, 10 * 3.14159 / 180),
      _DiagramItem("戊(余)", AppTheme.amberGold, 50 * 3.14159 / 180),
    ];

    for (var item in items) {
      final dx = math.cos(item.angle) * (radius + 40);
      final dy = math.sin(item.angle) * (radius + 20); // Elliptical distribution
      final textOffset = center + Offset(dx, dy);
      
      // Draw Arrow
      final paint = Paint()
        ..color = item.color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
        
      final p1 = center + Offset(math.cos(item.angle) * radius, math.sin(item.angle) * radius);
      final p2 = textOffset - Offset(math.cos(item.angle) * 20, math.sin(item.angle) * 10);
      
      // canvas.drawLine(p1, p2, paint);
      // Draw simple line for now
      
      // Draw Text
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(color: AppTheme.inkText, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, textOffset - Offset(textPainter.width/2, textPainter.height/2));
      
      // Draw gradient arrow (simulated)
      final arrowPath = Path();
      arrowPath.moveTo(p1.dx, p1.dy);
      arrowPath.lineTo(textOffset.dx - 30 * math.cos(item.angle), textOffset.dy - 30 * math.sin(item.angle));
      
      final arrowPaint = Paint()
        ..shader = LinearGradient(colors: [item.color, item.color.withOpacity(0)])
            .createShader(Rect.fromPoints(p1, textOffset))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
        
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiagramItem {
  final String label;
  final Color color;
  final double angle;

  _DiagramItem(this.label, this.color, this.angle);
}
