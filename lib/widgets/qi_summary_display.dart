import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 紧凑版元气值汇总显示（用于顶部数据看板）
class CompactQiSummary extends StatelessWidget {
  final int totalQi;
  final int maxQi;

  const CompactQiSummary({
    super.key,
    required this.totalQi,
    required this.maxQi,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQi / maxQi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.fluorescentCyan.withValues(alpha: 0.1),
            AppTheme.electricBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.fluorescentCyan.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '元气',
            style: GoogleFonts.zhiMangXing(
              fontSize: 14,
              color: AppTheme.moonHalo,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          // 圆形进度条
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景圆环
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.voidBackground.withValues(alpha: 0.3),
                  ),
                ),
                // 进度圆环
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? AppTheme.amberGold : AppTheme.fluorescentCyan,
                  ),
                ),
                // 中心数值
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.amberGold,
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

/// 元气值汇总显示
class QiSummaryDisplay extends StatelessWidget {
  final int totalQi;
  final int maxQi;
  final Map<String, int> elementQi; // 各元素的气值

  const QiSummaryDisplay({
    super.key,
    required this.totalQi,
    required this.maxQi,
    required this.elementQi,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQi / maxQi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.fluorescentCyan.withValues(alpha: 0.1),
            AppTheme.electricBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.fluorescentCyan.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '元气汇聚',
            style: GoogleFonts.zhiMangXing(
              fontSize: 16,
              color: AppTheme.moonHalo,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // 总气值显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                totalQi.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.amberGold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ $maxQi',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.inkText.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppTheme.amberGold : AppTheme.fluorescentCyan,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 五行气值分布
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildElementQiChip('金', elementQi['金'] ?? 0, const Color(0xFFE8E8E8)),
              _buildElementQiChip('木', elementQi['木'] ?? 0, const Color(0xFF4CAF50)),
              _buildElementQiChip('水', elementQi['水'] ?? 0, const Color(0xFF2196F3)),
              _buildElementQiChip('火', elementQi['火'] ?? 0, const Color(0xFFFF6B6B)),
              _buildElementQiChip('土', elementQi['土'] ?? 0, const Color(0xFFD4A574)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementQiChip(String name, int qi, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            qi.toString(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
