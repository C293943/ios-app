import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/character_display.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/chat_overlay.dart';

/// 主页 - 核心祭坛
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isChatMode = false;
  final GlobalKey<CharacterDisplayState> _characterDisplayKey = GlobalKey();
  List<String> _animations = [];
  String? _currentAnimation;

  void _openSettings() {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  void _onAnimationsChanged(List<String> animations, String? currentAnimation) {
    setState(() {
      _animations = animations;
      _currentAnimation = currentAnimation;
    });
  }

  void _onAnimationSelected(String animation) {
    _characterDisplayKey.currentState?.playAnimation(animation);
    setState(() {
      _currentAnimation = animation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MysticBackground(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 设置按钮（右上角）
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _isChatMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _isChatMode,
                  child: GestureDetector(
                    onTap: _openSettings,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: AppTheme.deepVoidBlue.withOpacity(0.8),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Layer 0: 3D 灵体展示区 (Unity/3D)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: _isChatMode 
                    ? const EdgeInsets.only(top: 80, bottom: 200) // 聊天时留出空间
                    : EdgeInsets.only(top: 100, bottom: screenHeight * 0.3), // 默认留出底部面板空间
                child: CharacterDisplay(
                  key: _characterDisplayKey,
                  animationPath2D: 'assets/images/back-1.png',
                  modelPathLive2D: 'c_9999.model3.json',
                  size: 600,
                  showControls: false, // 不再在 CharacterDisplay 中显示控件
                  onAnimationsChanged: _onAnimationsChanged,
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
                    const Spacer(),
                    // 底部控制台 (Floating Glass Card)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GlassContainer(
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(32),
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Greeting / Title
                            Text(
                              '鸿初元灵',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 24,
                                color: AppTheme.deepVoidBlue,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // 主对话按钮
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.jadeGreen.withOpacity(0.8),
                                  foregroundColor: AppTheme.primaryBlack,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isChatMode = true;
                                  });
                                },
                                child: Text(
                                  '聆听天命',
                                  style: GoogleFonts.notoSerifSc(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
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
                    const SizedBox(height: 48), // Bottom padding
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
                  animations: _animations,
                  currentAnimation: _currentAnimation,
                  onAnimationSelected: _onAnimationSelected,
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
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppTheme.deepVoidBlue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.deepVoidBlue.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
