import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/widgets/character_display.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/chat_overlay.dart';
import 'package:primordial_spirit/widgets/bazi_profile_sheet.dart';
import 'package:primordial_spirit/widgets/3d_rotating_menu.dart';
import 'package:primordial_spirit/widgets/cultivation_bar.dart';

import 'package:primordial_spirit/widgets/common/spirit_stage.dart';
import 'package:primordial_spirit/widgets/common/firefly_particles.dart';
import 'package:primordial_spirit/widgets/evolution_animation.dart';
import 'package:primordial_spirit/widgets/common/divine_ripple.dart';
import 'package:primordial_spirit/widgets/five_elements_progress.dart'
    show ElementProgressBar;
import 'package:primordial_spirit/widgets/qi_summary_display.dart'
    show CompactQiSummary;

/// 主页 - 太虚幻境 (Taixu Realm)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isChatMode = false;
  final GlobalKey<CharacterDisplayState> _characterDisplayKey = GlobalKey();
  CultivationService? _cultivationService;

  // 觉醒动画状态
  bool _showEvolutionAnimation = false;
  bool _isCharacterVisible = false; // 角色是否已觉醒（是否显示）

  List<String> _animations = [];
  String? _currentAnimation;

  @override
  void initState() {
    super.initState();
    // 延迟到第一帧后获取context并同步状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCultivationState();
      _initCultivationListener();
    });
  }

  @override
  void dispose() {
    // 移除状态监听器
    _cultivationService?.removeListener(_onCultivationChanged);
    super.dispose();
  }

  /// 同步CultivationService的觉醒状态
  void _syncCultivationState() {
    if (!mounted) return;
    final cultivationService = _cultivationService ??= context
        .read<CultivationService>();
    debugPrint(
      '[HomeScreen] 同步觉醒状态: isAwakened=${cultivationService.isAwakened}',
    );
    setState(() {
      _isCharacterVisible = cultivationService.isAwakened;
    });
  }

  /// 初始化CultivationService状态监听
  void _initCultivationListener() {
    if (!mounted) return;
    final cultivationService = _cultivationService ??= context
        .read<CultivationService>();
    cultivationService.addListener(_onCultivationChanged);
  }

  /// 觉醒状态变化回调
  void _onCultivationChanged() {
    if (!mounted) return;
    final cultivationService = _cultivationService;
    if (cultivationService == null) return;
    debugPrint(
      '[HomeScreen] 觉醒状态变化: isAwakened=${cultivationService.isAwakened}',
    );
    if (_isCharacterVisible != cultivationService.isAwakened) {
      setState(() {
        _isCharacterVisible = cultivationService.isAwakened;
      });
    }
  }

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

  /// 修行 - 增加养成值
  Future<void> _cultivate() async {
    final cultivationService = context.read<CultivationService>();

    // 增加养成值
    final shouldAwaken = await cultivationService.addCultivationValue(10);

    // 显示修行提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('修行完成，养成值 +10', style: GoogleFonts.outfit()),
          backgroundColor: AppTheme.fluorescentCyan.withValues(alpha: 0.9),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // 如果达到觉醒条件，触发觉醒动画
    if (shouldAwaken && mounted) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _triggerEvolution();
        }
      });
    }
  }

  /// 触发觉醒动画
  void _triggerEvolution() async {
    if (_showEvolutionAnimation) {
      debugPrint('[HomeScreen] 觉醒动画正在播放，忽略重复触发');
      return;
    }

    final cultivationService = context.read<CultivationService>();

    debugPrint(
      '[HomeScreen] 触发觉醒动画检查: isAwakened=${cultivationService.isAwakened}, cultivationValue=${cultivationService.cultivationValue}/${cultivationService.maxCultivationValue}',
    );

    // 检查是否已经觉醒
    if (cultivationService.isAwakened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('元神已经觉醒，无需再次觉醒', style: GoogleFonts.outfit()),
          backgroundColor: AppTheme.amberGold.withValues(alpha: 0.9),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 检查养成值是否足够
    if (cultivationService.cultivationValue <
        cultivationService.maxCultivationValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '修行尚未圆满，当前 ${cultivationService.cultivationValue}/${cultivationService.maxCultivationValue}',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppTheme.electricBlue.withValues(alpha: 0.9),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    debugPrint('[HomeScreen] 开始播放觉醒动画');
    setState(() {
      _showEvolutionAnimation = true;
    });
  }

  /// 觉醒动画完成回调
  void _onEvolutionComplete() async {
    debugPrint('[HomeScreen] 觉醒动画完成');
    final cultivationService = context.read<CultivationService>();

    // 标记为已觉醒
    await cultivationService.awaken();

    setState(() {
      _showEvolutionAnimation = false;
      _isCharacterVisible = true; // 觉醒完成后显示角色
    });

    debugPrint(
      '[HomeScreen] 觉醒状态更新完成: _isCharacterVisible=$_isCharacterVisible',
    );

    // 显示觉醒完成提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                '元神觉醒！神识初成',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppTheme.amberGold.withValues(alpha: 0.95),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<MenuData> _buildMenuItems() {
    final items = <MenuData>[
      MenuData(
        title: '修行',
        subtitle: '增加养成值',
        icon: Icons.self_improvement,
        color: AppTheme.fluorescentCyan,
        onTap: _cultivate,
      ),
      MenuData(
        title: '觉醒',
        subtitle: '触发进化',
        icon: Icons.auto_awesome,
        color: AppTheme.amberGold,
        onTap: _triggerEvolution,
      ),
      MenuData(
        title: '宿命',
        subtitle: '八字命盘',
        icon: Icons.stars,
        color: Colors.purple,
        onTap: _showBaziProfile,
      ),
      MenuData(
        title: '唤醒',
        subtitle: 'AI 对话',
        icon: Icons.lightbulb,
        color: Colors.amber,
        onTap: () => setState(() => _isChatMode = true),
      ),
      MenuData(
        title: '结缘',
        subtitle: '历史记录',
        icon: Icons.history,
        color: Colors.pink,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      ),
      MenuData(
        title: '秘境',
        subtitle: '探索更多',
        icon: Icons.explore,
        color: Colors.indigo,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      ),
    ];

    return items;
  }

  /// 构建中心灵石主体(蛋形)
  Widget _buildSpiritStone() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 200,
      height: 240,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/spirit-stone-egg.png'),
          fit: BoxFit.contain,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fluorescentCyan.withValues(alpha: 0.3),
            blurRadius: 35,
            spreadRadius: 15,
          ),
        ],
      ),
      child: const _SpiritStoneGlow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: MysticBackground(
        child: FireflyParticles(
          isConverging: _isChatMode,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ===== 背景层 =====

              // 角色显示层（觉醒后显示，作为背景）
              if (!_isChatMode)
                Positioned(
                  top: size.height * 0.25,
                  child: SpiritStage(
                    isThinking: false,
                    child: SizedBox(
                      width: 300,
                      height: 400,
                      child: CharacterDisplay(
                        key: _characterDisplayKey,
                        animationPath2D: 'assets/images/back-1.png',
                        modelPathLive2D: 'c_9999.model3.json',
                        size: 600,
                        showControls: false,
                        visible: _isCharacterVisible, // 只有觉醒后才显示元神
                        onAnimationsChanged: _onAnimationsChanged,
                      ),
                    ),
                  ),
                ),
              // 主体底部的金色水波动效（统一放在CharacterDisplay之后）
              if (!_isChatMode && _isCharacterVisible)
                Positioned(
                  top: size.height * 0.25 + 400, // SpiritStage高度之后
                  child: DivineRipple(
                    width: 350,
                    height: 80,
                    baseColor: const Color(0xFFFFD700), // 金色
                  ),
                ),

              // ===== UI层 =====

              // 顶部栏 - 五行进度条和元气汇总容器（紧凑版）
              Positioned(
                top: MediaQuery.of(context).padding.top + 15,
                left: 20,
                right: 80,
                child: Opacity(
                  opacity: _isChatMode ? 0.0 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 五行进度条和元气汇总组合容器（紧凑）
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.voidBackground.withValues(alpha: 0.3),
                              AppTheme.voidBackground.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.fluorescentCyan.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 左：5个水平排列的垂直进度条
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElementProgressBar(
                                  name: '金',
                                  ratio: 0.4,
                                  color: const Color(0xFFE8E8E8),
                                  height: 60,
                                  width: 16,
                                ),
                                const SizedBox(width: 6),
                                ElementProgressBar(
                                  name: '木',
                                  ratio: 0.36,
                                  color: const Color(0xFF4CAF50),
                                  height: 60,
                                  width: 16,
                                ),
                                const SizedBox(width: 6),
                                ElementProgressBar(
                                  name: '水',
                                  ratio: 0.44,
                                  color: const Color(0xFF2196F3),
                                  height: 60,
                                  width: 16,
                                ),
                                const SizedBox(width: 6),
                                ElementProgressBar(
                                  name: '火',
                                  ratio: 0.38,
                                  color: const Color(0xFFFF6B6B),
                                  height: 60,
                                  width: 16,
                                ),
                                const SizedBox(width: 6),
                                ElementProgressBar(
                                  name: '土',
                                  ratio: 0.42,
                                  color: const Color(0xFFD4A574),
                                  height: 60,
                                  width: 16,
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            // 右：元气值汇总（一行布局）
                            const Expanded(
                              child: CompactQiSummary(
                                totalQi: 450,
                                maxQi: 500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 养成值进度条
                      const CultivationBar(
                        showLabel: true,
                        showStage: true,
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // 设置按钮
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.moonHalo,
                  ),
                  onPressed: _openSettings,
                ),
              ),

              // 3D 旋转菜单（觉醒前后都显示）
              if (!_isChatMode && !_showEvolutionAnimation)
                Positioned(
                  top: size.height * 0.15,
                  child: Column(
                    children: [
                      Rotating3DMenu(
                        menuItems: _buildMenuItems(),
                        radius: _isCharacterVisible ? 220 : 160, // 觉醒后扩大半径，避免遮挡元神
                        centerChild: _isCharacterVisible ? null : _buildSpiritStone(),
                      ),
                      // 菜单底部的金色水波动效
                      DivineRipple(
                        width: 350,
                        height: 60,
                        baseColor: const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),

              // ===== 覆盖层 =====

              // 觉醒动画层（最上层，全屏覆盖）
              if (_showEvolutionAnimation)
                Positioned.fill(
                  child: EvolutionAnimation(
                    isTriggered: _showEvolutionAnimation,
                    onComplete: _onEvolutionComplete,
                    spiritStoneAsset: 'assets/images/spirit-stone-egg.png',
                    avatarSpiritAsset: 'assets/images/back-1.png',
                  ),
                ),

              // 聊天覆盖层
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

/// 灵石蛋发光效果组件
class _SpiritStoneGlow extends StatefulWidget {
  const _SpiritStoneGlow();

  @override
  State<_SpiritStoneGlow> createState() => _SpiritStoneGlowState();
}

class _SpiritStoneGlowState extends State<_SpiritStoneGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.fluorescentCyan.withValues(alpha: _pulseAnimation.value * 0.3),
                AppTheme.fluorescentCyan.withValues(alpha: _pulseAnimation.value * 0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}
