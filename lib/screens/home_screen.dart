import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/widgets/character_display.dart';

/// 主页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade500,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '鸿初元灵',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // TODO: 打开设置页面
                      },
                    ),
                  ],
                ),
              ),
              
              // 3D形象展示区 - 使用Flexible防止溢出
              Flexible(
                flex: 3,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 3D/2D角色显示组件
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final size = (constraints.maxWidth * 0.6).clamp(150.0, 220.0);
                            return CharacterDisplay(
                              modelPath3D: 'assets/3d_models/XBot.obj',
                              animationPath2D: 'assets/images/back-0.png',
                              modelPathLive2D: 'c_9999.model3.json',
                              size: size,
                              defaultMode: DisplayMode.live2D, // 默认使用Live2D模式
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '您的专属元灵',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '五行属性:木火相生',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 功能按钮区 - 使用SingleChildScrollView防止溢出
              Flexible(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '开启您的心灵之旅',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // 主要功能按钮
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.chat);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 42,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 22),
                              SizedBox(width: 10),
                              Text(
                                '开始对话',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        
                        // 次要功能按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureButton(
                              icon: Icons.person_outline,
                              label: '我的信息',
                              onTap: () {
                                // TODO: 查看个人信息
                              },
                            ),
                            _buildFeatureButton(
                              icon: Icons.auto_awesome,
                              label: '每日运势',
                              onTap: () {
                                // TODO: 查看每日运势
                              },
                            ),
                            _buildFeatureButton(
                              icon: Icons.history,
                              label: '对话历史',
                              onTap: () {
                                // TODO: 查看对话历史
                              },
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
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}