import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/widgets/qi_convergence_animation.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

/// 八字输入页面
class BaziInputScreen extends StatefulWidget {
  const BaziInputScreen({super.key});

  @override
  State<BaziInputScreen> createState() => _BaziInputScreenState();
}

class _BaziInputScreenState extends State<BaziInputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _gender = '男';
  String _city = '北京';
  bool _showQiAnimation = false;

  // 常用城市列表
  static const List<String> _cities = [
    '北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '重庆',
    '武汉', '西安', '天津', '苏州', '郑州', '长沙', '青岛', '大连',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          context.l10n.baziStartTitle,
          style: TextStyle(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ThemedBackground(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: 80.0,
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.baziPromptTitle,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.warmYellow,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(
                    context.l10n.baziPromptSubtitle,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 14,
                      color: AppTheme.inkText.withOpacity(0.72),
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXl),

                  LiquidCard(
                    margin: EdgeInsets.zero,
                    accentColor: AppTheme.amberGold,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(context.l10n.baziGenderLabel),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderOption(
                                  value: '男',
                                  label: context.l10n.genderMale,
                                  icon: Icons.male,
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: _buildGenderOption(
                                  value: '女',
                                  label: context.l10n.genderFemale,
                                  icon: Icons.female,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.spacingLg),

                          _buildSectionLabel(context.l10n.baziDateLabel),
                          _buildMysticInput(
                            value: _selectedDate == null
                                ? context.l10n.selectBirthDate
                                : context.l10n.birthDateFormat(
                                    _selectedDate!.year,
                                    _selectedDate!.month,
                                    _selectedDate!.day,
                                  ),
                            isPlaceholder: _selectedDate == null,
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                          ),
                          if (_selectedDate == null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppTheme.spacingXs,
                                left: AppTheme.spacingMd,
                              ),
                              child: Text(
                                context.l10n.birthDateRequired,
                                style: GoogleFonts.notoSerifSc(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: AppTheme.spacingLg),

                          _buildSectionLabel(context.l10n.baziTimeLabel),
                          _buildMysticInput(
                            value: _selectedTime == null
                                ? context.l10n.selectBirthTime
                                : context.l10n.birthTimeFormat(
                                    _selectedTime!.hour.toString(),
                                    _selectedTime!.minute.toString().padLeft(2, '0'),
                                  ),
                            isPlaceholder: _selectedTime == null,
                            icon: Icons.access_time,
                            onTap: _selectTime,
                          ),
                          if (_selectedTime == null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppTheme.spacingXs,
                                left: AppTheme.spacingMd,
                              ),
                              child: Text(
                                context.l10n.birthTimeRequired,
                                style: GoogleFonts.notoSerifSc(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: AppTheme.spacingLg),

                          _buildSectionLabel(context.l10n.baziCityLabel),
                          _buildMysticInput(
                            value: _city,
                            icon: Icons.location_on,
                            onTap: _selectCity,
                            isPlaceholder: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingXl),

                  SizedBox(
                    width: double.infinity,
                    child: MysticButton(
                      text: context.l10n.baziSubmit,
                      onPressed: _onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 灵气汇聚动画层
          if (_showQiAnimation)
            Positioned.fill(
              child: QiConvergenceAnimation(
                isTriggered: _showQiAnimation,
                onComplete: _onAnimationComplete,
              ),
            ),
        ],
      ),
    );
  }

  void _onAnimationComplete() async {
    debugPrint('[BaziInputScreen] 动画完成，准备跳转');

    // 重置养成进度，让用户重新体验从蛋到元神的养成过程
    final cultivationService = context.read<CultivationService>();
    await cultivationService.reset();
    debugPrint('[BaziInputScreen] 养成进度已重置');

    if (!mounted) return;

    final baziData = {
      'gender': _gender,
      'date': _selectedDate,
      'time': _selectedTime,
      'city': _city,
    };

    debugPrint('[BaziInputScreen] 跳转到 AvatarGenerationScreen，数据: $baziData');
    Navigator.of(context).pushNamed(
      AppRoutes.avatarGeneration,
      arguments: {'baziData': baziData},
    );
  }

  // _buildGlassCard removed/replaced by GlassContainer class usage

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Text(
        text,
        style: GoogleFonts.notoSerifSc(
          color: AppTheme.warmYellow.withOpacity(0.85),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: AnimatedContainer(
            duration: Duration(milliseconds: AppTheme.animNormal),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.jadeGreen.withOpacity(0.18)
                  : AppTheme.liquidGlassLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AppTheme.jadeGreen.withOpacity(0.55)
                    : AppTheme.liquidGlassBorderSoft,
                width: AppTheme.borderThin,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.jadeGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.warmYellow
                      : AppTheme.inkText.withOpacity(0.65),
                ),
                SizedBox(height: AppTheme.spacingXs),
                Text(
                  label,
                  style: GoogleFonts.notoSerifSc(
                    color: isSelected
                        ? AppTheme.warmYellow
                        : AppTheme.inkText.withOpacity(0.65),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMysticInput({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPlaceholder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.liquidGlassBorderSoft,
                width: AppTheme.borderThin,
              ),
            ),
            child: Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.notoSerifSc(
                    color: isPlaceholder
                        ? AppTheme.inkText.withOpacity(0.55)
                        : AppTheme.inkText,
                    fontSize: 16,
                    fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(icon, color: AppTheme.amberGold.withOpacity(0.85), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectCity() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = screenHeight * 0.5; // 最大高度为屏幕的50%

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppTheme.amberGold.withOpacity(0.25), width: 0.8),
          ),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.selectBirthCity,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warmYellow,
                  ),
                ),
              ),
              Divider(height: 1, color: AppTheme.amberGold.withOpacity(0.18)),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final isSelected = city == _city;
                    return InkWell(
                      onTap: () => Navigator.pop(context, city),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.jadeGreen.withOpacity(0.18)
                              : AppTheme.spiritGlass.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.jadeGreen.withOpacity(0.7)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          city,
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 14,
                            color: AppTheme.inkText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _city = selected);
    }
  }

  void _onSubmit() {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ToastOverlay.show(
        context,
        message: context.l10n.birthInfoIncomplete,
        backgroundColor: AppTheme.primaryDeepIndigo,
      );
      return;
    }

    setState(() {
      _showQiAnimation = true;
    });
  }
}
