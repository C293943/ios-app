import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/liquid_bottom_sheet.dart';

class HiddenStemsSheet extends StatelessWidget {
  const HiddenStemsSheet({super.key});

  /// 显示藏干详情弹窗
  static Future<void> show(BuildContext context) {
    return LiquidBottomSheet.show(
      context: context,
      title: '藏干详情',
      titleIcon: Icons.inventory_2_outlined,
      child: const HiddenStemsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: AppTheme.spacingMd),
      child: Column(
        children: [
          // 副标题
          Text(
            "地支中蕴藏的天干能量",
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          
          SizedBox(height: AppTheme.spacingLg),
          
          // Pillars Grid
          LiquidContentCard(
            borderRadius: AppTheme.radiusMd,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header Row
                _buildGridRow(
                  ["", "年柱", "月柱", "日柱", "时柱"],
                  isHeader: true,
                ),
                Divider(height: 1, color: AppTheme.liquidGlassBorderSoft),
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
                Divider(height: 1, color: AppTheme.liquidGlassBorderSoft),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
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
                      Expanded(child: _buildHiddenStemColumn(["戊·偏印", "乙·正官", "癸·伤官"])),
                      Expanded(child: _buildHiddenStemColumn(["乙·正财"])),
                      Expanded(child: _buildHiddenStemColumn(["庚·比肩", "壬·食神", "戊·偏印"])),
                      Expanded(child: _buildHiddenStemColumn(["丙·七杀", "戊·偏印", "庚·比肩"])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppTheme.spacingLg),
          
          // Diagram Section (Exploded View)
          LiquidContentCard(
            borderRadius: AppTheme.radiusLg,
            padding: EdgeInsets.all(AppTheme.spacingLg),
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
                SizedBox(height: AppTheme.spacingLg),
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
          
          SizedBox(height: AppTheme.spacingXl),
          
          // Close Button
          const LiquidCloseButton(label: '收起藏干'),
          
          SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }

  Widget _buildGridRow(List<String> items, {bool isHeader = false, bool isLarge = false, List<Color?>? colors}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
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
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
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
              SizedBox(height: 2),
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
