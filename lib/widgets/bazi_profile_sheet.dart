import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/widgets/common/liquid_bottom_sheet.dart';

/// 八字命格展示底部弹窗
class BaziProfileSheet extends StatelessWidget {
  final FortuneData fortuneData;

  const BaziProfileSheet({super.key, required this.fortuneData});

  /// 显示八字命格弹窗
  static Future<void> show(BuildContext context, FortuneData fortuneData) {
    return LiquidBottomSheet.show(
      context: context,
      title: '命格详情',
      titleIcon: Icons.fingerprint,
      child: BaziProfileSheet(fortuneData: fortuneData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bazi = fortuneData.baziInfo;
    final birth = fortuneData.birthInfo;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 出生信息
          _buildSection(
            title: '出生信息',
            icon: Icons.cake,
            child: _buildBirthInfo(birth),
          ),

          SizedBox(height: AppTheme.spacingLg),

          // 四柱八字
          _buildSection(
            title: '四柱八字',
            icon: Icons.view_column,
            child: _buildFourPillars(bazi),
          ),

          SizedBox(height: AppTheme.spacingLg),

          // 五行分布
          if (bazi.fiveElements != null) ...[
            _buildSection(
              title: '五行分布',
              icon: Icons.pie_chart,
              child: _buildFiveElements(bazi),
            ),
            SizedBox(height: AppTheme.spacingLg),
          ],

          // 纳音
          if (bazi.nayin != null) ...[
            _buildSection(
              title: '纳音',
              icon: Icons.music_note,
              child: _buildNayin(bazi.nayin!),
            ),
            SizedBox(height: AppTheme.spacingLg),
          ],

          // 格局
          if (bazi.patterns != null && bazi.patterns!.isNotEmpty) ...[
            _buildSection(
              title: '命格',
              icon: Icons.auto_awesome,
              child: _buildPatterns(bazi.patterns!),
            ),
            SizedBox(height: AppTheme.spacingLg),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiquidSectionTitle(title: title, icon: icon),
        SizedBox(height: AppTheme.spacingMd),
        child,
      ],
    );
  }

  Widget _buildBirthInfo(BirthInfo birth) {
    return LiquidContentCard(
      child: Column(
        children: [
          _buildInfoRow('出生日期', '${birth.year}年${birth.month}月${birth.day}日'),
          SizedBox(height: AppTheme.spacingSm),
          _buildInfoRow('出生时辰', '${birth.hour}:${birth.minute.toString().padLeft(2, '0')}'),
          SizedBox(height: AppTheme.spacingSm),
          _buildInfoRow('出生地点', birth.city),
          SizedBox(height: AppTheme.spacingSm),
          _buildInfoRow('性别', birth.gender),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSerifSc(
            fontSize: 14,
            color: AppTheme.inkText.withOpacity(0.72),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSerifSc(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.inkText,
          ),
        ),
      ],
    );
  }

  Widget _buildFourPillars(BaziInfo bazi) {
    return Row(
      children: [
        _buildPillar('年柱', bazi.yearPillar, bazi.nayin?['年柱'],
            tenGod: bazi.tenGods?['年干'] as String?,
            zhiTenGods: bazi.tenGods?['年支'] as List<dynamic>?,
            hideGan: bazi.hideGan?['年支']),
        _buildPillar('月柱', bazi.monthPillar, bazi.nayin?['月柱'],
            tenGod: bazi.tenGods?['月干'] as String?,
            zhiTenGods: bazi.tenGods?['月支'] as List<dynamic>?,
            hideGan: bazi.hideGan?['月支']),
        _buildPillar('日柱', bazi.dayPillar, bazi.nayin?['日柱'],
            isMain: true,
            tenGod: bazi.tenGods?['日干'] as String?,
            zhiTenGods: bazi.tenGods?['日支'] as List<dynamic>?,
            hideGan: bazi.hideGan?['日支']),
        _buildPillar('时柱', bazi.hourPillar, bazi.nayin?['时柱'],
            tenGod: bazi.tenGods?['时干'] as String?,
            zhiTenGods: bazi.tenGods?['时支'] as List<dynamic>?,
            hideGan: bazi.hideGan?['时支']),
      ],
    );
  }

  Widget _buildPillar(
    String label,
    String pillar,
    String? nayin, {
    bool isMain = false,
    String? tenGod,
    List<dynamic>? zhiTenGods,
    List<String>? hideGan,
  }) {
    final gan = pillar.isNotEmpty ? pillar[0] : '';
    final zhi = pillar.length > 1 ? pillar[1] : '';

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.spacingMd,
          horizontal: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isMain
              ? AppTheme.jadeGreen.withOpacity(0.15)
              : AppTheme.liquidGlassLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isMain
                ? AppTheme.jadeGreen
                : AppTheme.liquidGlassBorderSoft,
            width: isMain ? AppTheme.borderThick : AppTheme.borderThin,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.notoSerifSc(
                fontSize: 12,
                color: AppTheme.inkText.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 8),
            // 天干十神
            if (tenGod != null && tenGod.isNotEmpty) ...[
              Text(
                tenGod,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 10,
                  color: _getTenGodColor(tenGod),
                ),
              ),
              const SizedBox(height: 2),
            ],
            // 天干
            Text(
              gan,
              style: GoogleFonts.notoSerifSc(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getElementColor(gan),
              ),
            ),
            const SizedBox(height: 4),
            // 地支
            Text(
              zhi,
              style: GoogleFonts.notoSerifSc(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getElementColor(zhi),
              ),
            ),
            // 藏干
            if (hideGan != null && hideGan.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                hideGan.join(' '),
                style: GoogleFonts.notoSerifSc(
                  fontSize: 10,
                  color: AppTheme.inkText.withOpacity(0.65),
                ),
              ),
            ],
            // 地支十神
            if (zhiTenGods != null && zhiTenGods.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                zhiTenGods.map((e) => e.toString()).join(' '),
                style: GoogleFonts.notoSerifSc(
                  fontSize: 9,
                  color: AppTheme.inkText.withOpacity(0.72),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // 纳音
            if (nayin != null) ...[
              const SizedBox(height: 8),
              Text(
                nayin,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 10,
                  color: AppTheme.inkText.withOpacity(0.65),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据十神获取颜色
  Color _getTenGodColor(String tenGod) {
    // 十神颜色映射
    switch (tenGod) {
      case '比肩':
      case '劫财':
        return const Color(0xFF4CAF50); // 绿色 - 比劫
      case '食神':
      case '伤官':
        return const Color(0xFFFF9800); // 橙色 - 食伤
      case '正财':
      case '偏财':
        return AppTheme.amberGold; // 古金 - 财星
      case '正官':
      case '七杀':
        return const Color(0xFF2196F3); // 蓝色 - 官杀
      case '正印':
      case '偏印':
        return const Color(0xFF9C27B0); // 紫色 - 印星
      case '日主':
        return AppTheme.jadeGreen;
      default:
        return AppTheme.inkText.withOpacity(0.7);
    }
  }

  Widget _buildFiveElements(BaziInfo bazi) {
    final elements = bazi.fiveElements!;
    final strength = bazi.fiveElementsStrength;
    final total = elements.values.fold(0, (a, b) => a + b);

    return Column(
      children: [
        // 五行数量条
        Row(
          children: [
            _buildElementBar('木', elements['木'] ?? 0, total, const Color(0xFF4CAF50)),
            _buildElementBar('火', elements['火'] ?? 0, total, const Color(0xFFF44336)),
            _buildElementBar('土', elements['土'] ?? 0, total, const Color(0xFFFF9800)),
            _buildElementBar('金', elements['金'] ?? 0, total, AppTheme.amberGold),
            _buildElementBar('水', elements['水'] ?? 0, total, const Color(0xFF2196F3)),
          ],
        ),

        const SizedBox(height: 16),

        // 五行力量百分比
        if (strength != null)
          LiquidContentCard(
            borderRadius: AppTheme.radiusMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '五行力量',
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 12,
                    color: AppTheme.inkText.withOpacity(0.72),
                  ),
                ),
                const SizedBox(height: 8),
                ...['木', '火', '土', '金', '水'].map((e) {
                  final value = strength[e] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            e,
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _getElementColorByName(e),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: value / 100,
                              backgroundColor: Colors.black.withOpacity(0.35),
                              valueColor: AlwaysStoppedAnimation(_getElementColorByName(e)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '${value.toStringAsFixed(1)}%',
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 12,
                              color: AppTheme.inkText.withOpacity(0.75),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildElementBar(String element, int count, int total, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FractionallySizedBox(
                    heightFactor: total > 0 ? count / total : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '$count',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: count > 0 ? Colors.white : color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              element,
              style: GoogleFonts.notoSerifSc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNayin(Map<String, String> nayin) {
    return LiquidContentCard(
      borderRadius: AppTheme.radiusMd,
      child: Column(
        children: nayin.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  e.key,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 14,
                    color: AppTheme.inkText.withOpacity(0.72),
                  ),
                ),
                Text(
                  e.value,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.inkText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPatterns(List<PatternInfo> patterns) {
    return Column(
      children: patterns.map((pattern) {
        return Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: LiquidContentCard(
            borderRadius: AppTheme.radiusMd,
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 格局名称和层次
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.jadeGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pattern.patternName,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.jadeGreen,
                        ),
                      ),
                    ),
                    if (pattern.levelName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor(pattern.level).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getLevelColor(pattern.level).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          pattern.levelName,
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getLevelColor(pattern.level),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // 格局描述
                if (pattern.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    pattern.description,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 13,
                      color: AppTheme.inkText.withOpacity(0.82),
                      height: 1.6,
                    ),
                  ),
                ],

                // 核心含义
                if (pattern.coreMeaning != null && pattern.coreMeaning!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPatternInfoRow('核心特质', pattern.coreMeaning!),
                ],

                // 性格特征
                if (pattern.traits.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPatternInfoRow('性格特征', pattern.traits.join('、')),
                ],

                // 适合领域
                if (pattern.suitableFields.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPatternInfoRow('适合领域', pattern.suitableFields.join('、')),
                ],

                // 层次特征
                if (pattern.levelFeatures.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '层次特征',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warmYellow.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...pattern.levelFeatures.map((feature) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: AppTheme.jadeGreen)),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 12,
                              color: AppTheme.inkText.withOpacity(0.78),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],

                // 喜忌神
                if (pattern.favorable != null || pattern.unfavorable != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (pattern.favorable != null &&
                          pattern.favorable!['conditions'] != null &&
                          (pattern.favorable!['conditions'] as List).isNotEmpty)
                        Expanded(
                          child: _buildFavorableTag(
                            '喜',
                            (pattern.favorable!['conditions'] as List).take(3).join('、'),
                            Colors.green,
                          ),
                        ),
                      if (pattern.favorable != null && pattern.unfavorable != null)
                        const SizedBox(width: 8),
                      if (pattern.unfavorable != null &&
                          pattern.unfavorable!['conditions'] != null &&
                          (pattern.unfavorable!['conditions'] as List).isNotEmpty)
                        Expanded(
                          child: _buildFavorableTag(
                            '忌',
                            (pattern.unfavorable!['conditions'] as List).take(3).join('、'),
                            Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.notoSerifSc(
              fontSize: 12,
              color: AppTheme.inkText.withOpacity(0.72),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSerifSc(
              fontSize: 12,
              color: AppTheme.inkText.withOpacity(0.82),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavorableTag(String prefix, String content, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              prefix,
              style: GoogleFonts.notoSerifSc(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.notoSerifSc(
                fontSize: 11,
                color: color.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'high':
        return AppTheme.amberGold; // 古金 - 贵格
      case 'medium':
        return AppTheme.jadeGreen; // 绿色 - 常格
      case 'low':
        return Colors.grey; // 灰色 - 破格
      default:
        return AppTheme.inkText.withOpacity(0.75);
    }
  }

  /// 根据天干地支获取五行颜色
  Color _getElementColor(String char) {
    // 天干五行
    const ganElements = {
      '甲': '木', '乙': '木',
      '丙': '火', '丁': '火',
      '戊': '土', '己': '土',
      '庚': '金', '辛': '金',
      '壬': '水', '癸': '水',
    };
    // 地支五行
    const zhiElements = {
      '子': '水', '丑': '土', '寅': '木', '卯': '木',
      '辰': '土', '巳': '火', '午': '火', '未': '土',
      '申': '金', '酉': '金', '戌': '土', '亥': '水',
    };

    final element = ganElements[char] ?? zhiElements[char];
    return _getElementColorByName(element ?? '');
  }

  Color _getElementColorByName(String element) {
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

