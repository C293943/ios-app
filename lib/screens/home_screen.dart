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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 模型区域占屏幕高度的 60%
    final modelHeight = screenHeight * 0.6;
    final modelWidth = screenWidth * 0.9;
    final modelSize = modelWidth < modelHeight ? modelWidth : modelHeight;

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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '鸿初元灵',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      },
                    ),
                  ],
                ),
              ),

              // 3D 模型展示区 - 占主要空间
              Expanded(
                flex: 5,
                child: Center(
                  child: CharacterDisplay(
                    animationPath2D: 'assets/images/back-1.png',
                    modelPathLive2D: 'c_9999.model3.json',
                    size: modelSize,
                    defaultMode: DisplayMode.mode3D,
                  ),
                ),
              ),

              // 底部功能区
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 主要功能按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.chat);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '开始对话',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 次要功能按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureButton(
                            icon: Icons.person_outline,
                            label: '我的信息',
                            onTap: () {},
                          ),
                          _buildFeatureButton(
                            icon: Icons.auto_awesome,
                            label: '每日运势',
                            onTap: () {},
                          ),
                          _buildFeatureButton(
                            icon: Icons.history,
                            label: '对话历史',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
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
              size: 22,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 4),
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
