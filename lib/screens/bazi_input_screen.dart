import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';

/// 八字输入页面
class BaziInputScreen extends StatefulWidget {
  const BaziInputScreen({super.key});

  @override
  State<BaziInputScreen> createState() => _BaziInputScreenState();
}

class _BaziInputScreenState extends State<BaziInputScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 年月日时输入控制器
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _gender = '男';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('输入生辰八字'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '请输入您的出生信息',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '我们将根据您的八字生成专属数字人',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // 性别选择
              const Text(
                '性别',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('男'),
                      value: '男',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('女'),
                      value: '女',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 出生日期选择
              const Text(
                '出生日期',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? '请选择日期'
                            : '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 出生时间选择
              const Text(
                '出生时间',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? '请选择时间'
                            : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedTime == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // 提交按钮
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '生成数字人',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onSubmit() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请完整填写出生日期和时间')),
      );
      return;
    }

    // 准备八字数据
    final baziData = {
      'gender': _gender,
      'date': _selectedDate,
      'time': _selectedTime,
    };

    // 导航到形象生成页面
    Navigator.of(context).pushNamed(
      AppRoutes.avatarGeneration,
      arguments: {'baziData': baziData},
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}