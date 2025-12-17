import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/liquid_avatar.dart';

/// 3D形象生成页面（加载过渡页）
class AvatarGenerationScreen extends StatefulWidget {
  final Map<String, dynamic>? baziData;

  const AvatarGenerationScreen({super.key, this.baziData});

  @override
  State<AvatarGenerationScreen> createState() => _AvatarGenerationScreenState();
}

class _AvatarGenerationScreenState extends State<AvatarGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _statusText = '正在分析八字...';
  String _detailText = '';
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
      });

    _startGeneration();
  }

  Future<void> _startGeneration() async {
    _controller.forward();

    final modelManager = context.read<ModelManagerService>();

    // 保存用户八字数据（兼容旧逻辑）
    if (widget.baziData != null) {
      await modelManager.saveUserBaziData(widget.baziData!);
    }

    // 构建出生信息
    if (widget.baziData == null) {
      if (!mounted) return;
      setState(() {
        _statusText = '缺少生辰信息';
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final date = widget.baziData!['date'] as DateTime;
    final time = widget.baziData!['time'];
    final city = widget.baziData!['city'] as String? ?? '北京';
    final birthInfo = BirthInfo(
      year: date.year,
      month: date.month,
      day: date.day,
      hour: time.hour as int,
      minute: time.minute as int,
      gender: widget.baziData!['gender'] as String,
      city: city,
    );

    // 显示请求信息
    setState(() {
      _statusText = '正在分析八字...';
      _detailText = '出生: ${date.year}年${date.month}月${date.day}日 ${time.hour}:${time.minute}';
    });

    // 调用计算API
    final apiService = FortuneApiService();

    // 设置状态回调
    apiService.onStatusChanged = (status) {
      if (mounted) {
        setState(() => _detailText = status);
      }
    };

    setState(() => _detailText = '正在连接 ${AppConfig.baseUrl}...');

    final response = await apiService.calculate(birthInfo);

    if (!mounted) return;

    if (response.success && response.baziInfo != null && response.ziweiInfo != null) {
      setState(() {
        _statusText = '正在解析五行属性...';
        _detailText = '八字: ${response.baziInfo!.yearPillar} ${response.baziInfo!.monthPillar} ${response.baziInfo!.dayPillar} ${response.baziInfo!.hourPillar}';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // 保存完整命盘数据
      final fortuneData = FortuneData(
        birthInfo: birthInfo,
        baziInfo: response.baziInfo!,
        ziweiInfo: response.ziweiInfo!,
        calculatedAt: DateTime.now(),
      );
      await modelManager.saveFortuneData(fortuneData);

      setState(() {
        _statusText = '正在生成3D形象...';
        _detailText = '命宫: ${response.ziweiInfo!.mingGong}';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      setState(() {
        _statusText = '生成完成!';
        _detailText = '';
      });
    } else {
      // API调用失败，显示错误信息
      setState(() {
        _statusText = '命盘计算失败';
        _detailText = response.message;
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // 仍然继续到主页，但没有命盘数据
      setState(() {
        _statusText = '正在生成3D形象...';
        _detailText = '(离线模式)';
        _hasError = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _statusText = '生成完成!';
        _detailText = '';
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 导航到主页（替换整个导航栈）
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 灵体凝聚动画
                  const SizedBox(
                    width: 160,
                    height: 160,
                    child: LiquidAvatar(isTalking: true),
                  ),
                  const SizedBox(height: 32),

                  // 状态文本
                  Text(
                    _statusText,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _hasError ? Colors.red.shade400 : AppTheme.deepVoidBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 详细信息
                  if (_detailText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _hasError
                            ? Colors.red.withOpacity(0.1)
                            : AppTheme.deepVoidBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _detailText,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 12,
                          color: _hasError
                              ? Colors.red.shade400
                              : AppTheme.deepVoidBlue.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 进度条
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.deepVoidBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.jadeGreen,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.jadeGreen.withOpacity(0.5),
                              blurRadius: 6,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 进度百分比
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 16,
                      color: AppTheme.deepVoidBlue.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 提示文本
                  Text(
                    '基于您的八字信息\n正在凝聚专属元神...',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 14,
                      color: AppTheme.deepVoidBlue.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}