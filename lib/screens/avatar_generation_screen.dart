import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
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
  double _progress = 0.0;

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

    // 保存用户八字数据
    if (widget.baziData != null) {
      final modelManager = context.read<ModelManagerService>();
      await modelManager.saveUserBaziData(widget.baziData!);
    }

    // 模拟生成过程
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusText = '正在解析五行属性...');

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusText = '正在生成3D形象...');

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusText = '生成完成!');

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
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 灵体凝聚动画
                  const SizedBox(
                    width: 200,
                    height: 200,
                    child: LiquidAvatar(isTalking: true), // Pulse fast during generation
                  ),
                  const SizedBox(height: 48),
                  
                  // 状态文本
                  Text(
                    _statusText,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepVoidBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
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
                  const SizedBox(height: 16),
                  
                  // 进度百分比
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 16,
                      color: AppTheme.deepVoidBlue.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // 提示文本
                  Text(
                    '基于您的八字信息\n正在凝聚专属元神...',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 16,
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