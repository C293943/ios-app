import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '开启命轮',
          style: TextStyle(
            color: AppTheme.accentJade,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 移除返回按钮
      ),
      body: MysticBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            children: [
              // Header Text
              Text(
                '请输入生辰信息',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.deepVoidBlue,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '唤醒您的五行守护灵',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 14,
                  color: AppTheme.deepVoidBlue.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),

              // Form Area
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
                      const SizedBox(height: 24),

                      _buildSectionLabel('地支 (Time)'),
                      _buildMysticInput(
                        value: _selectedTime == null
                            ? '选择出生时辰'
                            : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        icon: Icons.access_time,
                        onTap: _selectTime,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Submit Button
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
    );
  }

  // _buildGlassCard removed/replaced by GlassContainer class usage

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.notoSerifSc(
          color: AppTheme.deepVoidBlue.withOpacity(0.8),
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
              ? AppTheme.accentJade.withOpacity(0.3) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppTheme.accentJade : AppTheme.deepVoidBlue.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.deepVoidBlue : AppTheme.deepVoidBlue.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.notoSerifSc(
                color: isSelected ? AppTheme.deepVoidBlue : AppTheme.deepVoidBlue.withOpacity(0.4),
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
          color: AppTheme.deepVoidBlue.withOpacity(0.08), // Slightly darker for contrast
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.deepVoidBlue.withOpacity(0.2)), // Stronger border
        ),
        child: Row(
          children: [
            Text(
              value,
              style: GoogleFonts.notoSerifSc(
                color: value.contains('选择') 
                    ? AppTheme.deepVoidBlue.withOpacity(0.6) 
                    : AppTheme.deepVoidBlue,
                fontSize: 16,
                fontWeight: value.contains('选择') ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(icon, color: AppTheme.deepVoidBlue.withOpacity(0.8), size: 20),
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

  void _onSubmit() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请完整填写出生时间，以便推算命格'),
          backgroundColor: AppTheme.primaryDeepIndigo,
        ),
      );
      return;
    }

    final baziData = {
      'gender': _gender,
      'date': _selectedDate,
      'time': _selectedTime,
    };

    Navigator.of(context).pushNamed(
      AppRoutes.avatarGeneration,
      arguments: {'baziData': baziData},
    );
  }
}