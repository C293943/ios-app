import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';

/// 命盘摘要覆盖层 - 作为角色背景衬托显示
class BaziSummaryOverlay extends StatelessWidget {
  final FortuneData fortuneData;
  final VoidCallback? onTap;

  const BaziSummaryOverlay({
    super.key,
    required this.fortuneData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bazi = fortuneData.baziInfo;
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            // 顶部：出生信息 + 格局（小巧的标签）
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: _buildTopInfo(bazi),
            ),

            // 左侧：四柱八字（竖向排列，半透明）
            Positioned(
              left: 8,
              top: screenSize.height * 0.25,
              child: _buildVerticalPillars(bazi),
            ),

            // 右侧：五行分布（竖向排列，半透明）
            Positioned(
              right: 8,
              top: screenSize.height * 0.25,
              child: _buildVerticalElements(bazi),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部信息：出生信息 + 格局
  Widget _buildTopInfo(BaziInfo bazi) {
    final birth = fortuneData.birthInfo;
    final pattern = bazi.patterns?.isNotEmpty == true ? bazi.patterns!.first : null;

    return Column(
      children: [
        // 出生信息
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.amberGold.withOpacity(0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                birth.gender == '男' ? Icons.male : Icons.female,
                color: birth.gender == '男'
                    ? const Color(0xFF64B5F6)
                    : const Color(0xFFFFB7B2),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${birth.year}.${birth.month}.${birth.day} ${birth.hour}:${birth.minute.toString().padLeft(2, '0')} ${birth.city}',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 11,
                  color: AppTheme.inkText.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        if (pattern != null) ...[
          const SizedBox(height: 6),
          // 格局标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.jadeGreen.withOpacity(0.15),
                  AppTheme.celestialCyan.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.jadeGreen.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.jadeGreen.withOpacity(0.7), size: 12),
                const SizedBox(width: 4),
                Text(
                  pattern.patternName,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.jadeGreen.withOpacity(0.8),
                  ),
                ),
                if (pattern.levelName.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    pattern.levelName,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 10,
                      color: _getLevelColor(pattern.level).withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 左侧竖向四柱八字
  Widget _buildVerticalPillars(BaziInfo bazi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amberGold.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillarVertical('年', bazi.yearPillar),
          const SizedBox(height: 8),
          _buildPillarVertical('月', bazi.monthPillar),
          const SizedBox(height: 8),
          _buildPillarVertical('日', bazi.dayPillar, isMain: true),
          const SizedBox(height: 8),
          _buildPillarVertical('时', bazi.hourPillar),
        ],
      ),
    );
  }

  Widget _buildPillarVertical(String label, String pillar, {bool isMain = false}) {
    final gan = pillar.isNotEmpty ? pillar[0] : '';
    final zhi = pillar.length > 1 ? pillar[1] : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: isMain
          ? BoxDecoration(
              color: AppTheme.jadeGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.jadeGreen.withOpacity(0.3)),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSerifSc(
              fontSize: 8,
              color: AppTheme.inkText.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            gan,
            style: GoogleFonts.notoSerifSc(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getElementColor(gan).withOpacity(0.7),
            ),
          ),
          Text(
            zhi,
            style: GoogleFonts.notoSerifSc(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getElementColor(zhi).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 右侧竖向五行分布
  Widget _buildVerticalElements(BaziInfo bazi) {
    if (bazi.fiveElements == null) return const SizedBox.shrink();

    final elements = bazi.fiveElements!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amberGold.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildElementVertical('木', elements['木'] ?? 0, const Color(0xFF4CAF50)),
          const SizedBox(height: 6),
          _buildElementVertical('火', elements['火'] ?? 0, const Color(0xFFF44336)),
          const SizedBox(height: 6),
          _buildElementVertical('土', elements['土'] ?? 0, const Color(0xFFFF9800)),
          const SizedBox(height: 6),
          _buildElementVertical('金', elements['金'] ?? 0, AppTheme.amberGold),
          const SizedBox(height: 6),
          _buildElementVertical('水', elements['水'] ?? 0, const Color(0xFF2196F3)),
        ],
      ),
    );
  }

  Widget _buildElementVertical(String element, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              element,
              style: GoogleFonts.notoSerifSc(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: GoogleFonts.notoSerifSc(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.inkText.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'high':
        return AppTheme.amberGold;
      case 'medium':
        return AppTheme.jadeGreen;
      case 'low':
        return Colors.grey;
      default:
        return AppTheme.inkText.withOpacity(0.75);
    }
  }

  /// 根据天干地支获取五行颜色
  Color _getElementColor(String char) {
    const ganElements = {
      '甲': '木', '乙': '木',
      '丙': '火', '丁': '火',
      '戊': '土', '己': '土',
      '庚': '金', '辛': '金',
      '壬': '水', '癸': '水',
    };
    const zhiElements = {
      '子': '水', '丑': '土', '寅': '木', '卯': '木',
      '辰': '土', '巳': '火', '午': '火', '未': '土',
      '申': '金', '酉': '金', '戌': '土', '亥': '水',
    };

    final element = ganElements[char] ?? zhiElements[char];
    switch (element) {
      case '木':
        return const Color(0xFF4CAF50);
      case '火':
        return const Color(0xFFF44336);
      case '土':
        return const Color(0xFFFF9800);
      case '金':
        return AppTheme.amberGold;
      case '水':
        return const Color(0xFF2196F3);
      default:
        return AppTheme.inkText.withOpacity(0.75);
    }
  }
}
