import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';

/// 3D形象生成页面
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
    
    // 模拟生成过程
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _statusText = '正在解析五行属性...');
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _statusText = '正在生成3D形象...');
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _statusText = '生成完成!');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // 导航到主页
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.deepPurple.shade700,
              Colors.pink.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 动画图标
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 120,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  // 状态文本
                  Text(
                    _statusText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // 进度条
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 进度百分比
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // 提示文本
                  Text(
                    '基于您的八字信息\n正在创建专属数字人',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
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