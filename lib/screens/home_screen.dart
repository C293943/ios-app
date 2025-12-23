import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/character_display.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/chat_overlay.dart';
import 'package:primordial_spirit/widgets/bazi_profile_sheet.dart';

import 'package:primordial_spirit/widgets/common/spirit_stage.dart';
import 'package:primordial_spirit/widgets/common/ruyi_input.dart';
import 'package:primordial_spirit/widgets/common/ritual_button.dart';

import 'package:primordial_spirit/widgets/common/firefly_particles.dart';

/// 主页 - 太虚幻境 (Taixu Realm)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isChatMode = false;
  final GlobalKey<CharacterDisplayState> _characterDisplayKey = GlobalKey();
  final TextEditingController _inputController = TextEditingController();
  
  List<String> _animations = [];
  String? _currentAnimation;

  void _openSettings() {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  void _showBaziProfile() {
    final modelManager = context.read<ModelManagerService>();
    final fortuneData = modelManager.fortuneData;

    if (fortuneData != null) {
      BaziProfileSheet.show(context, fortuneData);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.baziInput);
    }
  }

  void _onAnimationsChanged(List<String> animations, String? currentAnimation) {
    setState(() {
      _animations = animations;
      _currentAnimation = currentAnimation;
    });
  }
  
  void _onInputSubmitted() {
    // Transition to chat mode with the input
    if (_inputController.text.isNotEmpty) {
      setState(() {
        _isChatMode = true;
      });
      // In a real app, pass text to chat
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false, // Prevent background squeeze
      body: MysticBackground(
        child: FireflyParticles(
          isConverging: _isChatMode,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Top Bar (Logo/Title)
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                child: Opacity(
                  opacity: _isChatMode ? 0.0 : 1.0,
                  child: Column(
                    children: [
                      Text(
                        '询问', // "Dao Yuu" / Ask
                        style: GoogleFonts.zhiMangXing( // Calligraphy style if avail, else fallback
                          fontSize: 32,
                          color: AppTheme.moonHalo,
                          shadows: [
                            Shadow(color: AppTheme.spiritJade.withOpacity(0.5), blurRadius: 10),
                          ],
                        ),
                      ),
                      Text(
                        'Dao yuu',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          color: AppTheme.moonHalo.withOpacity(0.7),
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Settings Button (Top Right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.moonHalo),
                  onPressed: _openSettings,
                ),
              ),
              
              // 2. Main Spirit Stage (Golden Ratio positioning)
              // Positioned slightly above center
              Positioned(
                top: size.height * 0.25, // Golden ratioish
                child: SpiritStage(
                  isThinking: false, // Could be bound to state
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: CharacterDisplay(
                      key: _characterDisplayKey,
                      animationPath2D: 'assets/images/back-1.png',
                      modelPathLive2D: 'c_9999.model3.json',
                      size: 600,
                      showControls: false,
                      onAnimationsChanged: _onAnimationsChanged,
                    ),
                  ),
                ),
              ),

              // 3. New Control Layer (Bottom) - Replaces GlassContainer
              if (!_isChatMode)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ruyi Input (Scroll)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RuyiInput(
                          controller: _inputController,
                          hintText: '拨动尺号/今日心绪...', // "Pluck the scale/Today's mood..."
                          onSubmitted: _onInputSubmitted,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Ritual Buttons (Side by Side)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RitualButton(
                            label: '宿命', // Fate/Bazi
                            type: RitualType.lantern,
                            onTap: _showBaziProfile,
                          ),
                          
                          // Center Button (Main Action - Awakening/Listening) - Optional if Input is enough
                          // Maybe a smaller specialized button or just spacing
                           RitualButton(
                            label: '唤醒', 
                            type: RitualType.jade,
                            onTap: () => setState(() => _isChatMode = true),
                          ),

                          RitualButton(
                            label: '结缘', // Bond/History
                            type: RitualType.lantern,
                            onTap: () {
                               // TODO: History
                               Navigator.of(context).pushNamed(AppRoutes.settings); // Temp placeholder
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // 4. Chat Overlay (When active)
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
                    onAnimationSelected: (anim) {
                       _characterDisplayKey.currentState?.playAnimation(anim);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
