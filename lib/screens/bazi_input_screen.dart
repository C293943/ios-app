import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/widgets/qi_convergence_animation.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';

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
          '开启命轮',
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
          MysticBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
              child: Column(
                children: [
                  Text(
                    '请输入生辰信息',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.warmYellow,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '唤醒您的五行守护灵',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 14,
                      color: AppTheme.inkText.withOpacity(0.72),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 40),

                  GlassContainer(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('阴阳 (Gender)'),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderOption('男', Icons.male),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGenderOption('女', Icons.female),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          _buildSectionLabel('天干 (Date)'),
                          _buildMysticInput(
                            value: _selectedDate == null
                                ? '选择出生日期'
                                : '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日',
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                          ),
                          if (_selectedDate == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                '请选择出生日期',
                                style: GoogleFonts.notoSerifSc(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          _buildSectionLabel('地支 (Time)'),
                          _buildMysticInput(
                            value: _selectedTime == null
                                ? '选择出生时辰'
                                : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                            icon: Icons.access_time,
                            onTap: _selectTime,
                          ),
                          if (_selectedTime == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12),
                              child: Text(
                                '请选择出生时辰',
                                style: GoogleFonts.notoSerifSc(
                                  color: Colors.red.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          _buildSectionLabel('出生地 (City)'),
                          _buildMysticInput(
                            value: _city,
                            icon: Icons.location_on,
                            onTap: _selectCity,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: MysticButton(
                      text: '凝 聚 灵 体',
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
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildGenderOption(String value, IconData icon) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.jadeGreen.withOpacity(0.14) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppTheme.jadeGreen.withOpacity(0.55)
                : AppTheme.amberGold.withOpacity(0.22),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.warmYellow
                  : AppTheme.inkText.withOpacity(0.65),
            ),
            const SizedBox(height: 4),
            Text(
              value,
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
    );
  }

  Widget _buildMysticInput({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.spiritGlass.withOpacity(0.35),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.amberGold.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: GoogleFonts.notoSerifSc(
                color: value.contains('选择')
                    ? AppTheme.inkText.withOpacity(0.55)
                    : AppTheme.inkText,
                fontSize: 16,
                fontWeight: value.contains('选择') ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(icon, color: AppTheme.amberGold.withOpacity(0.85), size: 20),
          ],
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
                  '选择出生城市',
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
        message: '请完整填写出生时间，以便推算命格',
        backgroundColor: AppTheme.primaryDeepIndigo,
      );
      return;
    }

    setState(() {
      _showQiAnimation = true;
    });
  }
}
