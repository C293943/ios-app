import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/widgets/app_bottom_nav_bar.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class HePanScreen extends StatefulWidget {
  const HePanScreen({super.key});

  @override
  State<HePanScreen> createState() => _HePanScreenState();
}

class _HePanScreenState extends State<HePanScreen> {
  // 对方信息表单状态
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLunar = false; // 农历/阳历切换
  String _birthCity = '请选择地区';
  String _currentCity = '请选择地区';
  String _otherGender = '女'; // Default to female
  String _selectedRelation = '配偶';

  // 关系类型选项
  final List<String> _relationTypes = ['配偶', '情侣', '朋友', '同事', '师徒', '亲子', '合作伙伴'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取我的信息
    final modelManager = context.watch<ModelManagerService>();
    final userBazi = modelManager.userBaziData;
    
    // 构造我的显示数据 (如果没有数据则显示默认/占位)
    final String myName = '我'; // 暂时没有存储用户真实姓名，用"我"代替
    String myBirthDate = '未设置';
    String myBirthCity = '未设置';
    
    if (userBazi != null) {
      // 解析日期时间
      try {
        final dateStr = userBazi['date'] as String;
        final date = DateTime.parse(dateStr);
        final hour = userBazi['hour'] ?? 12;
        final minute = userBazi['minute'] ?? 0;
        myBirthDate = '${date.year}年${date.month}月${date.day}日 $hour:${minute.toString().padLeft(2, '0')} (阳历)';
        myBirthCity = userBazi['city'] ?? '未设置';
      } catch (e) {
        debugPrint('解析用户八字数据失败: $e');
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '八字合盘', // Hardcoded as per screenshot, or context.l10n.relationshipSelectTitle
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppTheme.inkText),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.relationshipHistory);
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: AppTheme.inkText),
            onPressed: () {
              // TODO: 分享
            },
          ),
        ],
      ),
      body: ThemedBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 140),
              child: Column(
                children: [
                  // 本命盘 (我)
                  _buildMyChartCard(myName, myBirthDate, myBirthCity, '上海市'), // '上海市' is mocked current city
                  
                  const SizedBox(height: 16),
                  
                  // 应缘盘 (对方)
                  _buildOtherChartCard(context),
                  
                  const SizedBox(height: 32),
                  
                  // 开始合盘按钮
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: MysticButton(
                      text: '开始合盘',
                      onPressed: _startHePan,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNavBar(currentTarget: AppNavTarget.relationship),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyChartCard(String name, String birthInfo, String birthPlace, String currentPlace) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本命盘 (我)',
            style: GoogleFonts.notoSerifSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.inkText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('姓名：', name),
          const SizedBox(height: 8),
          _buildInfoRow('出生日期：', birthInfo),
          const SizedBox(height: 8),
          _buildInfoRow('出生地区：', birthPlace),
          const SizedBox(height: 8),
          _buildInfoRow('现居地区：', currentPlace),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.notoSansSc(
              fontSize: 14,
              color: AppTheme.inkText.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSansSc(
              fontSize: 14,
              color: AppTheme.inkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherChartCard(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '应缘盘 (对方)',
            style: GoogleFonts.notoSerifSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.inkText,
            ),
          ),
          const SizedBox(height: 20),
          
          // 姓名输入
          _buildInputRow(
            label: '姓名：',
            child: _buildTextField(controller: _nameController, hint: '请输入姓名'),
          ),
          const SizedBox(height: 16),
          
           // 性别选择
          _buildInputRow(
            label: '性别：',
            child: Row(
              children: [
                _buildGenderChip('男', _otherGender == '男'),
                const SizedBox(width: 16),
                _buildGenderChip('女', _otherGender == '女'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 出生日期
          _buildInputRow(
            label: '出生日期：',
            child: GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.spiritGlass.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null 
                            ? '请选择日期时间 >' 
                            : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day} ${_selectedTime?.format(context) ?? ""}',
                        style: TextStyle(
                          color: _selectedDate == null 
                              ? AppTheme.inkText.withOpacity(0.5) 
                              : AppTheme.inkText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // 阳历/农历 切换 (Mock UI mainly)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLunar ? '农历' : '阳历',
                            style: TextStyle(fontSize: 12, color: AppTheme.inkText),
                          ),
                          const SizedBox(width: 4),
                          Switch(
                            value: _isLunar,
                            onChanged: (val) {
                              setState(() {
                                _isLunar = val;
                              });
                            },
                            activeColor: AppTheme.jadeGreen,
                            activeTrackColor: AppTheme.jadeGreen.withOpacity(0.3),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 出生地区
          _buildInputRow(
            label: '出生地区：',
            child: _buildDropdownButton(_birthCity, (val) {
              setState(() => _birthCity = val);
            }),
          ),
          const SizedBox(height: 16),
          
          // 现居地区
          _buildInputRow(
            label: '现居地区：',
            child: _buildDropdownButton(_currentCity, (val) {
              setState(() => _currentCity = val);
            }),
          ),
          const SizedBox(height: 24),
          
          // 关系类型 Tag 选择
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _relationTypes.map((type) {
              final isSelected = _selectedRelation == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRelation = type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.jadeGreen.withOpacity(0.8) 
                        : AppTheme.spiritGlass.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.scrollBorder,
                    ),
                    boxShadow: isSelected 
                        ? [BoxShadow(color: AppTheme.jadeGreen.withOpacity(0.4), blurRadius: 8)] 
                        : [],
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.inkText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _otherGender = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.jadeGreen.withOpacity(0.8) 
              : AppTheme.spiritGlass.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.scrollBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.inkText,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align center for inputs
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.notoSansSc(
              fontSize: 15,
              color: AppTheme.inkText,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: AppTheme.inkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.inkText.withOpacity(0.5), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // Center vertically
          isDense: false,
          filled: false,
          focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: AppTheme.jadeGreen, width: 1),
          ),
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String value, Function(String) onChanged) {
    return GestureDetector(
      onTap: () {
        _showCityPicker(context, onChanged);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.spiritGlass.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
               value,
               style: TextStyle(
                 color: value == '请选择地区' ? AppTheme.inkText.withOpacity(0.5) : AppTheme.inkText,
                 fontSize: 14,
               ),
             ),
             Icon(Icons.keyboard_arrow_right, color: AppTheme.inkText.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (date != null) {
          if (!mounted) return;
          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (time != null) {
              setState(() {
                  _selectedDate = date;
                  _selectedTime = time;
              });
          }
      }
  }

  void _showCityPicker(BuildContext context, Function(String) onSelected) {
    // Reusing the logic from BaziInputScreen simplified
     showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.spiritGlass.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
             children: [
                 Padding(
                   padding: const EdgeInsets.all(16),
                   child: Text('选择城市', style: TextStyle(color: AppTheme.warmYellow, fontSize: 16)),
                 ),
                 Expanded(
                     child: ListView(
                         children: ['北京', '上海', '广州', '深圳', '杭州', '成都', '武汉']
                             .map((e) => ListTile(
                                 title: Text(e, style: TextStyle(color: AppTheme.inkText), textAlign: TextAlign.center),
                                 onTap: () {
                                     Navigator.pop(context, e);
                                     onSelected(e);
                                 },
                             )).toList(),
                     ),
                 ),
             ],
          ),
        );
      },
    );
  }

  void _startHePan() {
      // Validate
      if (_nameController.text.isEmpty || _selectedDate == null || _birthCity == '请选择地区') {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请填写完整信息')));
          return;
      }

      // 构建 PersonA (我)
      final modelManager = context.read<ModelManagerService>();
      final userBazi = modelManager.userBaziData;
      RelationshipPerson? personA;
      
      if (userBazi != null) {
          try {
             final dateStr = userBazi['date'] as String;
             final date = DateTime.parse(dateStr);
             personA = RelationshipPerson(
                 year: date.year,
                 month: date.month,
                 day: date.day,
                 hour: userBazi['hour'] ?? 12,
                 minute: userBazi['minute'] ?? 0,
                 city: userBazi['city'] ?? '北京',
                 gender: userBazi['gender'] ?? '男',
             );
          } catch(e) {
              debugPrint('Error parsing user bazi: $e');
          }
      }
      
      // Fallback for personA if null
      personA ??= RelationshipPerson(year: 1990, month: 1, day: 1, hour: 12, minute: 0, city: '北京', gender: '男');

      // 构建 PersonB (对方)
      final personB = RelationshipPerson(
          year: _selectedDate!.year,
          month: _selectedDate!.month,
          day: _selectedDate!.day,
          hour: _selectedTime?.hour ?? 12,
          minute: _selectedTime?.minute ?? 0,
          city: _birthCity,
          gender: _otherGender,
      );
      
      // Navigate to Report
      Navigator.of(context).pushNamed(
          AppRoutes.relationshipReport,
          arguments: {
              'relationType': _selectedRelation,
              'personA': personA,
              'personB': personB,
          }
      );
  }
}
