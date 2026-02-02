// 关系合盘信息填写页，采集双方出生信息并生成报告。
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class RelationshipFormScreen extends StatefulWidget {
  final String relationType;

  const RelationshipFormScreen({super.key, required this.relationType});

  @override
  State<RelationshipFormScreen> createState() => _RelationshipFormScreenState();
}

class _RelationshipFormScreenState extends State<RelationshipFormScreen> {
  DateTime? _dateA;
  TimeOfDay? _timeA;
  String _genderA = '男';
  String _cityA = '北京';

  DateTime? _dateB;
  TimeOfDay? _timeB;
  String _genderB = '女';
  String _cityB = '北京';

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
          context.l10n.relationshipFormTitle(widget.relationType),
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ThemedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          child: Column(
            children: [
              _buildPersonSection(
                title: context.l10n.relationshipPersonATitle,
                gender: _genderA,
                date: _dateA,
                time: _timeA,
                city: _cityA,
                onGenderChanged: (value) => setState(() => _genderA = value),
                onDateTap: () => _selectDate(isPersonA: true),
                onTimeTap: () => _selectTime(isPersonA: true),
                onCityTap: () => _selectCity(isPersonA: true),
              ),
              const SizedBox(height: 16),
              _buildPersonSection(
                title: context.l10n.relationshipPersonBTitle,
                gender: _genderB,
                date: _dateB,
                time: _timeB,
                city: _cityB,
                onGenderChanged: (value) => setState(() => _genderB = value),
                onDateTap: () => _selectDate(isPersonA: false),
                onTimeTap: () => _selectTime(isPersonA: false),
                onCityTap: () => _selectCity(isPersonA: false),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: MysticButton(
                  text: context.l10n.relationshipGenerateReport,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonSection({
    required String title,
    required String gender,
    required DateTime? date,
    required TimeOfDay? time,
    required String city,
    required ValueChanged<String> onGenderChanged,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    required VoidCallback onCityTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.warmYellow,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildGenderRow(gender, onGenderChanged),
          const SizedBox(height: 12),
          _buildSelector(
            label: context.l10n.birthDateLabel,
            value: date == null
                ? context.l10n.selectDate
                : context.l10n.birthDateFormat(date.year, date.month, date.day),
            icon: Icons.calendar_today,
            onTap: onDateTap,
            isPlaceholder: date == null,
          ),
          const SizedBox(height: 12),
          _buildSelector(
            label: context.l10n.birthTimeLabel,
            value: time == null
                ? context.l10n.selectTime
                : context.l10n.birthTimeFormat(
                    time.hour.toString(),
                    time.minute.toString().padLeft(2, '0'),
                  ),
            icon: Icons.access_time,
            onTap: onTimeTap,
            isPlaceholder: time == null,
          ),
          const SizedBox(height: 12),
          _buildSelector(
            label: context.l10n.birthCityLabel,
            value: city,
            icon: Icons.location_on,
            onTap: onCityTap,
            isPlaceholder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow(String gender, ValueChanged<String> onChanged) {
    return Row(
      children: [
        _buildGenderOption(
          value: '男',
          label: context.l10n.genderMale,
          selected: gender == '男',
          onChanged: onChanged,
        ),
        const SizedBox(width: 12),
        _buildGenderOption(
          value: '女',
          label: context.l10n.genderFemale,
          selected: gender == '女',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String value,
    required String label,
    required bool selected,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.jadeGreen.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.jadeGreen.withOpacity(0.6)
                  : AppTheme.amberGold.withOpacity(0.22),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.notoSerifSc(
              color: selected ? AppTheme.warmYellow : AppTheme.inkText,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPlaceholder,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.spiritGlass.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.amberGold.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.amberGold.withOpacity(0.85), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.selectorLabelValue(label, value),
                style: GoogleFonts.notoSerifSc(
                  color: isPlaceholder
                      ? AppTheme.inkText.withOpacity(0.55)
                      : AppTheme.inkText,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isPersonA}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isPersonA) {
        _dateA = picked;
      } else {
        _dateB = picked;
      }
    });
  }

  Future<void> _selectTime({required bool isPersonA}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isPersonA) {
        _timeA = picked;
      } else {
        _timeB = picked;
      }
    });
  }

  Future<void> _selectCity({required bool isPersonA}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppTheme.amberGold.withOpacity(0.25), width: 0.8),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final city = _cities[index];
              final selectedCity = isPersonA ? _cityA : _cityB;
              final isSelected = city == selectedCity;
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
                      fontSize: 12,
                      color: AppTheme.inkText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    if (selected == null) return;
    setState(() {
      if (isPersonA) {
        _cityA = selected;
      } else {
        _cityB = selected;
      }
    });
  }

  void _submit() {
    if (_dateA == null || _timeA == null || _dateB == null || _timeB == null) {
      ToastOverlay.show(
        context,
        message: context.l10n.relationshipBirthInfoIncomplete,
        backgroundColor: AppTheme.primaryDeepIndigo,
      );
      return;
    }

    final personA = RelationshipPerson(
      year: _dateA!.year,
      month: _dateA!.month,
      day: _dateA!.day,
      hour: _timeA!.hour,
      minute: _timeA!.minute,
      city: _cityA,
      gender: _genderA,
    );

    final personB = RelationshipPerson(
      year: _dateB!.year,
      month: _dateB!.month,
      day: _dateB!.day,
      hour: _timeB!.hour,
      minute: _timeB!.minute,
      city: _cityB,
      gender: _genderB,
    );

    Navigator.of(context).pushNamed(
      AppRoutes.relationshipReport,
      arguments: {
        'relationType': widget.relationType,
        'personA': personA,
        'personB': personB,
      },
    );
  }
}
