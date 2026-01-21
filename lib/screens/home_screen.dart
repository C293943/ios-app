import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/character_display.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/services/task_manager_service.dart';
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
import 'package:primordial_spirit/widgets/common/toast_overlay.dart';
import 'package:primordial_spirit/widgets/motion_preview_overlay.dart';

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
  TaskManagerService? _taskManager;

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
      _initTaskManagerListener();
    });
  }

  @override
  void dispose() {
    // 移除状态监听器
    _cultivationService?.removeListener(_onCultivationChanged);
    _taskManager?.removeListener(_onTaskManagerChanged);
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

  /// 初始化TaskManagerService状态监听
  void _initTaskManagerListener() {
    if (!mounted) return;
    final taskManager = _taskManager ??= context.read<TaskManagerService>();

    // 监听任务状态变化
    taskManager.addListener(_onTaskManagerChanged);
  }

  /// TaskManagerService状态变化回调
  void _onTaskManagerChanged() {
    if (!mounted) return;
    final taskManager = _taskManager;
    if (taskManager == null) return;

    // 检查是否有新完成的任务
    final completedTasks = taskManager.tasks.where((t) =>
        t.isCompletedSuccessfully &&
        t.completedAt != null &&
        DateTime.now().difference(t.completedAt!).inSeconds < 10
    ).toList();

    for (final task in completedTasks) {
      if (task.type == TaskType.imageGeneration) {
        // 图片生成完成，显示提示
        ToastOverlay.show(
          context,
          message: '形象绘制完成！',
          icon: Icons.check_circle,
          backgroundColor: AppTheme.jadeGreen,
          duration: const Duration(seconds: 3),
        );
        debugPrint('[HomeScreen] 形象绘制完成: ${task.resultUrl}');
      } else if (task.type == TaskType.videoGeneration) {
        // 视频生成完成，显示提示
        ToastOverlay.show(
          context,
          message: '元神动画已就绪！',
          icon: Icons.video_library,
          backgroundColor: AppTheme.amberGold,
          duration: const Duration(seconds: 3),
        );
        debugPrint('[HomeScreen] 视频生成完成: ${task.resultUrl}');
      }
    }
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

  Future<void> _showMotionPreview() async {
    final modelManager = context.read<ModelManagerService>();
    final imageUrl = modelManager.image2dUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      ToastOverlay.show(
        context,
        message: '暂无可用形象图片，请先生成 2D 形象',
        backgroundColor: AppTheme.amberGold,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final cachedVideoUrl = modelManager.getMotionVideoUrl(imageUrl);

    await MotionPreviewOverlay.show(
      context,
      imageUrl: imageUrl,
      visitorId: modelManager.visitorId,
      cachedVideoUrl: cachedVideoUrl,
      onVideoUrlReady: (videoUrl) =>
          modelManager.setMotionVideoUrl(imageUrl, videoUrl),
    );
  }

  /// 修行 - 增加养成值
  Future<void> _cultivate() async {
    final cultivationService = context.read<CultivationService>();

    // 增加养成值
    final shouldAwaken = await cultivationService.addCultivationValue(10);

    // 显示修行提示
    if (mounted) {
      ToastOverlay.show(
        context,
        message: '修行完成，养成值 +10',
        backgroundColor: AppTheme.fluorescentCyan,
        duration: const Duration(seconds: 1),
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
      ToastOverlay.show(
        context,
        message: '元神已经觉醒，无需再次觉醒',
        backgroundColor: AppTheme.amberGold,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 检查养成值是否足够
    if (cultivationService.cultivationValue <
        cultivationService.maxCultivationValue) {
      ToastOverlay.show(
        context,
        message:
            '修行尚未圆满，当前 ${cultivationService.cultivationValue}/${cultivationService.maxCultivationValue}',
        backgroundColor: AppTheme.electricBlue,
        duration: const Duration(seconds: 2),
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
    final modelManager = context.read<ModelManagerService>();
    final taskManager = context.read<TaskManagerService>();

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
      ToastOverlay.show(
        context,
        message: '元神觉醒！神识初成',
        icon: Icons.auto_awesome,
        backgroundColor: AppTheme.amberGold,
        duration: const Duration(seconds: 3),
      );
    }

    // 觉醒后自动触发视频生成任务(后台)
    final imageUrl = modelManager.image2dUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      debugPrint('[HomeScreen] 觉醒完成,提交后台视频生成任务');
      taskManager.submitVideoGenerationTask(
        imageUrl: imageUrl,
        visitorId: modelManager.visitorId,
        metadata: {
          'trigger': 'awakening',
          'awakened_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // 提示用户视频正在生成中
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ToastOverlay.show(
            context,
            message: '元神动画正在生成中...',
            backgroundColor: AppTheme.fluorescentCyan,
            duration: const Duration(seconds: 2),
          );
        }
      });
    } else {
      debugPrint('[HomeScreen] 觉醒完成,但没有2D形象URL,跳过视频生成');
    }
  }

  /// 计算当前等级
  int _getCurrentLevel() {
    if (_cultivationService == null) return 1;

    // 觉醒前：根据养成值计算等级 (1-5级)
    if (!_cultivationService!.isAwakened) {
      final value = _cultivationService!.cultivationValue;
      if (value < 20) return 1;
      if (value < 40) return 2;
      if (value < 60) return 3;
      if (value < 80) return 4;
      return 5;
    }

    // 觉醒后：基础等级为6，未来可以根据羁绊值继续提升
    return 6;
  }

  List<MenuData> _buildMenuItems() {
    final currentLevel = _getCurrentLevel();

    final items = <MenuData>[
      MenuData(
        title: '梅花易数',
        subtitle: '卦象推演',
        icon: Icons.auto_awesome,
        color: AppTheme.fluorescentCyan,
        onTap: _cultivate,
        unlockLevel: 1,
        isLocked: currentLevel < 1,
      ),
      MenuData(
        title: '紫微斗数',
        subtitle: '命盘解读',
        icon: Icons.stars,
        color: AppTheme.amberGold,
        onTap: _triggerEvolution,
        unlockLevel: 2,
        isLocked: currentLevel < 2,
      ),
      MenuData(
        title: '关系合盘',
        subtitle: '两人互动',
        icon: Icons.favorite,
        color: AppTheme.electricBlue,
        onTap: _showBaziProfile,
        unlockLevel: 3,
        isLocked: currentLevel < 3,
      ),
      MenuData(
        title: '元神对话',
        subtitle: 'AI 交互',
        icon: Icons.lightbulb,
        color: AppTheme.jadeGreen,
        onTap: () => setState(() => _isChatMode = true),
        unlockLevel: 4,
        isLocked: currentLevel < 4,
      ),
      MenuData(
        title: '八字流年',
        subtitle: '年运分析',
        icon: Icons.calendar_today,
        color: AppTheme.bronzeGold,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        unlockLevel: 5,
        isLocked: currentLevel < 5,
      ),
      MenuData(
        title: '六爻问卦',
        subtitle: '事项占卜',
        icon: Icons.explore,
        color: AppTheme.fluorescentCyan,
        onTap: _showMotionPreview,
        unlockLevel: 6,
        isLocked: currentLevel < 6,
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
    final modelManager = context.read<ModelManagerService>(); // ✅ 添加modelManager引用

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
              if (_isCharacterVisible)
                Positioned(
                  top: size.height * 0.25 + 400, // SpiritStage高度之后
                  child: DivineRipple(
                    width: 350,
                    height: 80,
                    baseColor: AppTheme.amberGold,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
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
                              child: CompactQiSummary(totalQi: 450, maxQi: 500),
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
              if (!_showEvolutionAnimation)
                Positioned(
                  top: size.height * 0.15,
                  child: Column(
                    children: [
                      Rotating3DMenu(
                        menuItems: _buildMenuItems(),
                        radius: _isCharacterVisible
                            ? 220
                            : 160, // 觉醒后扩大半径，避免遮挡元神
                        centerChild: _isCharacterVisible
                            ? null
                            : _buildSpiritStone(),
                      ),
                      // 菜单底部的金色水波动效
                      DivineRipple(
                        width: 350,
                        height: 60,
                        baseColor: AppTheme.amberGold,
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
                    avatarSpiritAsset: modelManager.image2dUrl ?? 'assets/images/back-1.png', // ✅ 使用生成的图片
                  ),
                ),

              // 聊天覆盖层（只占据底部和中间部分，保留顶部背景可见）
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

    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                AppTheme.fluorescentCyan.withValues(
                  alpha: _pulseAnimation.value * 0.3,
                ),
                AppTheme.fluorescentCyan.withValues(
                  alpha: _pulseAnimation.value * 0.1,
                ),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}
