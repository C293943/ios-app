import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/user_models.dart';
import 'package:primordial_spirit/services/auth_service.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

/// 个人信息页面 (重构版 - 全局风格适配)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  UserProfile? _profile;
  bool _loading = true;

  // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  String _gender = '男';
  
  // 八字信息
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _isLunar = false; // 是否农历
  bool _isTimeUnknown = false; // 是否时间不详
  String _birthCity = '';
  
  // 现状信息 (UI状态，暂无模型对应)
  String _currentCity = '';
  String? _occupation;
  String? _education;
  String _maritalStatus = '未婚';

  // 选项数据
  final List<String> _occupations = ['企业员工', '公务员/事业单位', '自由职业', '学生', '个体经营', '其他'];
  final List<String> _educations = ['高中及以下', '大专', '本科', '硕士', '博士'];
  final List<String> _cities = [
    '北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '重庆',
    '武汉', '西安', '天津', '苏州', '郑州', '长沙', '青岛', '大连',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _authService.fetchProfile(preferCache: true);
    if (!mounted) return;
    
    if (profile != null) {
      setState(() {
        _profile = profile;
        _nameController.text = profile.displayName ?? '';
        _gender = profile.gender ?? '男';
        _birthCity = profile.birthCity ?? '';
        if (profile.birthYear != null) {
          _birthDate = DateTime(
            profile.birthYear!,
            profile.birthMonth ?? 1,
            profile.birthDay ?? 1,
          );
        }
        if (profile.birthHour != null) {
          _birthTime = TimeOfDay(
            hour: profile.birthHour!,
            minute: profile.birthMinute ?? 0,
          );
        }
        _loading = false;
      });
    }

    final remote = await _authService.fetchProfile(preferCache: false);
    if (!mounted || remote == null) return;
    setState(() {
      _profile = remote;
      // 可以在这里更新状态，但为了避免用户输入冲突，仅当本地未修改时更新
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '完善个人信息',
          style: GoogleFonts.notoSerifSc(
            color: isDark ? AppTheme.warmYellow : const Color(0xFF1E293B), // Dark text for light mode
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, 
            color: isDark ? AppTheme.warmYellow : const Color(0xFF1E293B), 
            size: 20
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ThemedBackground(child: SizedBox.expand())),
          
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingSm, AppTheme.spacingLg, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '信息越详细，元神越准确',
                      style: GoogleFonts.notoSerifSc(
                        color: AppTheme.softGrayText,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingLg),

                    // 卡片 1: 基本信息
                    _buildCard(
                      title: '基本信息',
                      children: [
                        _buildTextField(
                          label: '姓名*',
                          hint: '请输入您的真实姓名',
                          controller: _nameController,
                          required: true,
                        ),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildLabel('性别*'),
                        SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            _buildGenderOption('男', Icons.male),
                            SizedBox(width: AppTheme.spacingMd),
                            _buildGenderOption('女', Icons.female),
                            SizedBox(width: AppTheme.spacingMd),
                            _buildGenderOption('其他', Icons.person_outline),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingMd),

                    // 卡片 2: 八字信息
                    _buildCard(
                      title: '八字信息',
                      children: [
                        _buildDateInput(),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildTimeInput(),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildCityInput(
                          label: '出生地*',
                          value: _birthCity,
                          placeholder: '省份-城市-区县',
                          onTap: () => _selectCity(isBirth: true),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingMd),

                    // 卡片 3: 现状信息
                    _buildCard(
                      title: '现状信息',
                      subtitle: ' (选填)',
                      children: [
                        _buildCityInput(
                          label: '现居地',
                          value: _currentCity,
                          placeholder: '省份-城市-区县',
                          isOptional: true,
                          onTap: () => _selectCity(isBirth: false),
                        ),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildDropdown(
                          label: '职业',
                          value: _occupation,
                          items: _occupations,
                          hint: '请选择您的职业',
                          isOptional: true,
                          onChanged: (v) => setState(() => _occupation = v),
                        ),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildDropdown(
                          label: '学历',
                          value: _education,
                          items: _educations,
                          hint: '高中及以下',
                          isOptional: true,
                          onChanged: (v) => setState(() => _education = v),
                        ),
                        SizedBox(height: AppTheme.spacingLg),
                        _buildLabel('婚姻状况'),
                        SizedBox(height: AppTheme.spacingMd),
                        Row(
                          children: [
                            _buildRadioOption('未婚', _maritalStatus, (v) => setState(() => _maritalStatus = v)),
                            SizedBox(width: AppTheme.spacingMd),
                            _buildRadioOption('已婚', _maritalStatus, (v) => setState(() => _maritalStatus = v)),
                            SizedBox(width: AppTheme.spacingMd),
                            _buildRadioOption('离异', _maritalStatus, (v) => setState(() => _maritalStatus = v)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppTheme.blurMd, sigmaY: AppTheme.blurMd),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassBase,
              border: Border(
                top: BorderSide(
                  color: AppTheme.liquidGlassBorder,
                  width: AppTheme.borderThin,
                ),
              ),
            ),
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: MysticButton(
                  text: '开启元神探索',
                  onPressed: _submitProfile,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.warmYellow : const Color(0xFF0F766E); // Jade/Teal for light mode

    return LiquidCard(
      margin: EdgeInsets.zero,
      accentColor: accentColor,
      glowIntensity: isDark ? 0.15 : 0.05, // 浅色模式减少发光
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: AppTheme.spacingSm),
              RichText(
                text: TextSpan(
                  text: title,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.warmYellow : const Color(0xFF334155), // Slate-700
                    letterSpacing: 1,
                  ),
                  children: [
                    if (subtitle != null)
                      TextSpan(
                        text: subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.softGrayText,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingLg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSerifSc(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.inkText.withOpacity(0.9),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: AppTheme.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withOpacity(0.2) // Dark: 深色半透明
                : const Color(0xFFF1F5F9).withOpacity(0.5), // Light: 极淡的 Slate-100
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : const Color(0xFFCBD5E1).withOpacity(0.5), // Slate-300
              width: AppTheme.borderThin,
            ),
          ),
          child: TextFormField(
            controller: controller,
            validator: required ? (v) => v?.isEmpty == true ? '此项必填' : null : null,
            style: GoogleFonts.notoSerifSc(
              color: isDark ? AppTheme.warmYellow : const Color(0xFF334155)
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? AppTheme.softGrayText : const Color(0xFF94A3B8), // Slate-400
                fontSize: 14
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingMd,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(
                  color: isDark ? AppTheme.fluorescentCyan : AppTheme.jadeGreen, 
                  width: 1
                ),
              ),
              filled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _gender == label;
    final activeColor = AppTheme.jadeGreen;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = label),
        child: AnimatedContainer(
          duration: Duration(milliseconds: AppTheme.animNormal),
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? activeColor.withOpacity(0.18) : activeColor.withOpacity(0.1))
                : (isDark ? AppTheme.liquidGlassLight : Colors.white),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppTheme.liquidGlassBorderSoft : Colors.grey.withOpacity(0.2)),
              width: isSelected ? AppTheme.borderMedium : AppTheme.borderThin,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 16, 
                color: isSelected ? activeColor : AppTheme.softGrayText,
              ),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : AppTheme.softGrayText,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('出生日期*'),
            Row(
              children: [
                Text('阳历', style: TextStyle(fontSize: 12, color: AppTheme.softGrayText)),
                Switch(
                  value: _isLunar,
                  onChanged: (v) => setState(() => _isLunar = v),
                  activeColor: AppTheme.fluorescentCyan,
                  inactiveTrackColor: isDark ? AppTheme.liquidGlassLight : Colors.grey.withOpacity(0.2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text('农历', style: TextStyle(fontSize: 12, color: AppTheme.softGrayText)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: isDark ? ColorScheme.dark(
                      primary: AppTheme.jadeGreen,
                      onPrimary: AppTheme.voidBackground,
                      surface: AppTheme.voidBackground,
                      onSurface: AppTheme.warmYellow,
                    ) : ColorScheme.light(
                      primary: AppTheme.jadeGreen,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) setState(() => _birthDate = picked);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.liquidGlassLight : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isDark ? AppTheme.liquidGlassBorderSoft : Colors.grey.withOpacity(0.2),
                width: AppTheme.borderThin,
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppTheme.amberGold.withOpacity(0.7)),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  _birthDate == null 
                      ? 'YYYY年 MM月 DD日' 
                      : '${_birthDate!.year}年 ${_birthDate!.month}月 ${_birthDate!.day}日',
                  style: GoogleFonts.notoSerifSc(
                    color: _birthDate == null ? AppTheme.softGrayText : (isDark ? AppTheme.warmYellow : AppTheme.inkText),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('出生时间*'),
            GestureDetector(
              onTap: () => setState(() => _isTimeUnknown = !_isTimeUnknown),
              child: Row(
                children: [
                  Icon(
                    _isTimeUnknown ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: _isTimeUnknown ? AppTheme.fluorescentCyan : AppTheme.softGrayText,
                  ),
                  SizedBox(width: AppTheme.spacingXs),
                  Text('不确定可选择"不详"', style: TextStyle(fontSize: 12, color: AppTheme.softGrayText)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: _isTimeUnknown ? null : () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: isDark ? ColorScheme.dark(
                      primary: AppTheme.jadeGreen,
                      onPrimary: AppTheme.voidBackground,
                      surface: AppTheme.voidBackground,
                      onSurface: AppTheme.warmYellow,
                    ) : ColorScheme.light(
                      primary: AppTheme.jadeGreen,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) setState(() => _birthTime = picked);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.liquidGlassLight : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isDark ? AppTheme.liquidGlassBorderSoft : Colors.grey.withOpacity(0.2),
                width: AppTheme.borderThin,
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 18, color: AppTheme.amberGold.withOpacity(0.7)),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  _isTimeUnknown
                      ? '时间不详'
                      : (_birthTime == null 
                          ? 'HH时 MM分' 
                          : '${_birthTime!.hour.toString().padLeft(2, '0')}时 ${_birthTime!.minute.toString().padLeft(2, '0')}分'),
                  style: GoogleFonts.notoSerifSc(
                    color: (_birthTime == null && !_isTimeUnknown) 
                      ? AppTheme.softGrayText 
                      : (isDark ? AppTheme.warmYellow : AppTheme.inkText),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: AppTheme.softGrayText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityInput({
    required String label,
    required String value,
    required String placeholder,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(label),
            if (isOptional)
              Text(' (选填)', style: TextStyle(fontSize: 12, color: AppTheme.softGrayText)),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.liquidGlassLight : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isDark ? AppTheme.liquidGlassBorderSoft : Colors.grey.withOpacity(0.2),
                width: AppTheme.borderThin,
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: AppTheme.amberGold.withOpacity(0.7)),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  value.isEmpty ? placeholder : value,
                  style: GoogleFonts.notoSerifSc(
                    color: value.isEmpty ? AppTheme.softGrayText : (isDark ? AppTheme.warmYellow : AppTheme.inkText),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.search, size: 20, color: AppTheme.softGrayText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool isOptional = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(label),
            if (isOptional)
              Text(' (选填)', style: TextStyle(fontSize: 12, color: AppTheme.softGrayText)),
          ],
        ),
        SizedBox(height: AppTheme.spacingMd),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.liquidGlassLight : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isDark ? AppTheme.liquidGlassBorderSoft : Colors.grey.withOpacity(0.2),
              width: AppTheme.borderThin,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: TextStyle(color: AppTheme.softGrayText, fontSize: 14)),
              isExpanded: true,
              dropdownColor: isDark ? AppTheme.liquidGlassBase : Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.softGrayText),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item, 
                    style: GoogleFonts.notoSerifSc(
                      color: isDark ? AppTheme.warmYellow : AppTheme.inkText
                    )
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String groupValue, ValueChanged<String> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = groupValue == label;
    final activeColor = AppTheme.fluorescentCyan;
    
    return GestureDetector(
      onTap: () => onChanged(label),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AppTheme.animFast,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: isSelected ? activeColor : AppTheme.softGrayText,
                width: isSelected ? AppTheme.borderMedium : AppTheme.borderThin,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: AppTheme.spacingSm),
          Text(
            label,
            style: GoogleFonts.notoSerifSc(
              color: isSelected ? (isDark ? AppTheme.warmYellow : AppTheme.jadeGreen) : AppTheme.softGrayText,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCity({required bool isBirth}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: AppTheme.liquidGlassBase,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.liquidGlassBorder,
                    width: AppTheme.borderThin,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.inkText.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppTheme.spacingLg),
                    child: Text(
                      '选择城市',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.warmYellow : AppTheme.jadeGreen,
                      ),
                    ),
                  ),
                  LiquidDivider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _cities.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.inkText.withOpacity(0.05)),
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        return ListTile(
                          title: Text(
                            city,
                            style: GoogleFonts.notoSerifSc(color: AppTheme.inkText),
                          ),
                          onTap: () => Navigator.pop(context, city),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    
    if (selected != null) {
      setState(() {
        if (isBirth) {
          _birthCity = selected;
        } else {
          _currentCity = selected;
        }
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 简单验证
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出生日期')),
      );
      return;
    }
    if (_birthTime == null && !_isTimeUnknown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出生时间')),
      );
      return;
    }
    if (_birthCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出生地')),
      );
      return;
    }

    final updated = UserProfile(
      displayName: _nameController.text,
      gender: _gender,
      birthCity: _birthCity,
      birthYear: _birthDate!.year,
      birthMonth: _birthDate!.month,
      birthDay: _birthDate!.day,
      birthHour: _isTimeUnknown ? null : _birthTime?.hour,
      birthMinute: _isTimeUnknown ? null : _birthTime?.minute,
      // 注意：现状信息（职业、学历等）暂未保存到后端，因为模型不支持
    );

    try {
      final result = await _authService.updateProfile(updated);
      if (mounted) {
        if (result != null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('个人信息保存成功，元神探索开启！')),
          );
          // 这里可以跳转到首页或者元神展示页
          // Navigator.pushNamed(context, AppRoutes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存失败，请重试')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: $e')),
        );
      }
    }
  }
}
