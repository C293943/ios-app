import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/character_display.dart';
import 'package:primordial_spirit/widgets/chat_overlay.dart';
import 'package:primordial_spirit/widgets/common/background_container.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';

/// 主页 - 核心祭坛
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isChatMode = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      // 如果需要保留AppBar在非聊天模式，可以根据_isChatMode显示/隐藏
      // 这里为了沉浸式，可以在Dashboard模式下显示，Chat模式下隐藏
      appBar: _isChatMode ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '鸿初元灵',
          style: TextStyle(
            color: AppTheme.accentJade,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppTheme.accentJade),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 0: 3D 灵体展示区 (Unity/3D)
            // 在聊天模式下，可能需要调整模型位置或缩放（可选）
            // 这里简单处理：全屏显示
             Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                // 可以根据需要在Chat模式调整padding或transform
                padding: _isChatMode 
                    ? const EdgeInsets.only(top: 100, bottom: 200) // 聊天时留出空间
                    : EdgeInsets.only(top: 100, bottom: screenHeight * 0.3), // 默认留出底部面板空间
                child: CharacterDisplay(
                  animationPath2D: 'assets/images/back-1.png',
                  modelPathLive2D: 'c_9999.model3.json',
                  // size属性在Positioned.fill中有时候可能不起作用，取决于内部实现
                  // 但CharacterDisplay似乎用了size来决定内部容器。
                  // 我们给它一个相对较大的值，或者修改CharacterDisplay适配布局
                  size: 600, 
                  defaultMode: DisplayMode.mode3D,
                  showBottomControls: false, // 隐藏底部控制，避免被Dashboard遮挡
                ),
              ),
            ),
            
            // Layer 1: Dashboard UI (Fade out when Chat Mode)
            AnimatedOpacity(
              opacity: _isChatMode ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: _isChatMode,
                child: Column(
                  children: [
                    const Spacer(flex: 6),
                    // 底部控制台 (玻璃拟态)
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.surfaceGlass.withOpacity(0.1),
                              AppTheme.primaryBlack.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.accentJade.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 主对话按钮
                              SizedBox(
                                width: double.infinity,
                                child: MysticButton(
                                  text: '聆听天命',
                                  onPressed: () {
                                    setState(() {
                                      _isChatMode = true;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // 次要功能区
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMysticIconBtn(context, Icons.fingerprint, '命格'),
                                  _buildMysticIconBtn(context, Icons.auto_awesome, '运势'),
                                  _buildMysticIconBtn(context, Icons.history_edu, '灵迹'),
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

            // Layer 2: Chat Overlay (Fade in when Chat Mode)
            if (_isChatMode)
              Positioned.fill(
                child: ChatOverlay(
                  onBack: () {
                    setState(() {
                      _isChatMode = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMysticIconBtn(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.accentJade.withOpacity(0.3)),
            color: AppTheme.surfaceGlass,
          ),
          child: Icon(icon, color: AppTheme.accentJade, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
