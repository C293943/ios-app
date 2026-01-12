import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 单个五行垂直进度条
class ElementProgressBar extends StatelessWidget {
  final String name;
  final double ratio; // 0-1
  final Color color;
  final double height;
  final double width;

  const ElementProgressBar({
    super.key,
    required this.name,
    required this.ratio,
    required this.color,
    this.height = 120,
    this.width = 28,
  });

  @override
  Widget build(BuildContext context) {
    // 根据高度动态调整字体大小
    final labelFontSize = height <= 60 ? 9.0 : 12.0;
    final percentFontSize = height <= 60 ? 8.0 : 10.0;
    final spacing = height <= 60 ? 4.0 : 8.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 进度条
        SizedBox(
          height: height,
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 背景
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / 2),
                  color: AppTheme.voidBackground.withValues(alpha: 0.3),
                  border: Border.all(
                    color: AppTheme.fluorescentCyan.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              // 进度
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: height * ratio,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / 2),
                  color: color.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing),
        // 标签
        Text(
          name,
          style: GoogleFonts.outfit(
            fontSize: labelFontSize,
            color: AppTheme.inkText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(ratio * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.outfit(
            fontSize: percentFontSize,
            color: AppTheme.inkText.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
