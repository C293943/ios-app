import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/widgets/character_3d_viewer.dart';
import 'package:primordial_spirit/widgets/character_2d_viewer.dart';
import 'package:primordial_spirit/widgets/character_live2d_viewer.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';

enum DisplayMode { mode3D, mode2D, live2D }

/// 角色显示组件 - 支持3D、2D和Live2D模式切换
class CharacterDisplay extends StatefulWidget {
  final String? modelPath3D;
  final String? animationPath2D;
  final String? modelPathLive2D;
  final double size;
  final DisplayMode defaultMode;

  const CharacterDisplay({
    super.key,
    this.modelPath3D,
    this.animationPath2D,
    this.modelPathLive2D,
    this.size = 250.0,
    this.defaultMode = DisplayMode.live2D,
  });

  @override
  State<CharacterDisplay> createState() => _CharacterDisplayState();
}

class _CharacterDisplayState extends State<CharacterDisplay> {
  late DisplayMode _currentMode;
  bool _showModelSelector = false;
  GlobalKey<Character3DViewerState> _viewer3DKey = GlobalKey();
  List<String> _animations = [];
  String? _currentAnimation;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.defaultMode;
  }

  void _switchMode(DisplayMode mode) {
    setState(() {
      _currentMode = mode;
      _showModelSelector = false;
    });
  }

  void _switchModel(ModelManagerService modelManager, String modelId) {
    modelManager.setSelectedModel(modelId);
    setState(() {
      _showModelSelector = false;
      _animations = [];
      _currentAnimation = null;
      _viewer3DKey = GlobalKey();
    });
  }

  void _toggleModelSelector() {
    setState(() {
      _showModelSelector = !_showModelSelector;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelManagerService>(
      builder: (context, modelManager, child) {
        final selectedModel = modelManager.selectedModel;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主要显示区域
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 3D/2D/Live2D视图
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentViewer(selectedModel),
                  ),

                  // 模型选择器弹出层（仅3D模式显示）
                  if (_currentMode == DisplayMode.mode3D && _showModelSelector)
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: _buildModelSelector(modelManager),
                    ),

                  // 顶部模型切换按钮（仅3D模式显示）
                  if (_currentMode == DisplayMode.mode3D)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildModelSwitchButton(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 动画选择器（仅3D模式且有动画时显示）
            if (_currentMode == DisplayMode.mode3D)
              _buildAnimationSelectorWrapper(),

            const SizedBox(height: 8),

            // 底部模式切换按钮
            _buildModeButtons(),
          ],
        );
      },
    );
  }

  Widget _buildCurrentViewer(Model3DConfig? selectedModel) {
    switch (_currentMode) {
      case DisplayMode.mode3D:
        final modelPath = widget.modelPath3D ?? selectedModel?.path ?? '';
        if (modelPath.isEmpty) {
          return const Center(
            child: Text(
              '请在设置中选择模型',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return Character3DViewer(
          key: _viewer3DKey,
          modelPath: modelPath,
          size: widget.size,
          autoPlay: true,
          initialAnimation: selectedModel?.defaultAnimation,
        );
      case DisplayMode.mode2D:
        return Character2DViewer(
          key: const ValueKey('2d'),
          animationPath: widget.animationPath2D,
          size: widget.size,
        );
      case DisplayMode.live2D:
        return CharacterLive2DViewer(
          key: const ValueKey('live2d'),
          modelPath: widget.modelPathLive2D ?? 'c_9999.model3.json',
          size: widget.size,
        );
    }
  }

  /// 更新动画列表
  void _updateAnimations() {
    final viewerState = _viewer3DKey.currentState;
    if (viewerState != null && viewerState.availableAnimations.isNotEmpty) {
      if (_animations.isEmpty ||
          _animations.length != viewerState.availableAnimations.length) {
        setState(() {
          _animations = viewerState.availableAnimations;
          _currentAnimation = viewerState.currentAnimation;
        });
      }
    }
  }

  /// 构建动画选择器包装器
  Widget _buildAnimationSelectorWrapper() {
    // 延迟检查动画列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations();
    });

    if (_animations.isEmpty) {
      return const SizedBox(height: 36);
    }

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _animations.length,
        itemBuilder: (context, index) {
          final anim = _animations[index];
          final isSelected = anim == _currentAnimation;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: GestureDetector(
              onTap: () {
                final viewerState = _viewer3DKey.currentState;
                if (viewerState != null) {
                  viewerState.playAnimation(anim);
                  setState(() {
                    _currentAnimation = anim;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple.shade400
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _formatAnimationName(anim),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 格式化动画名称
  String _formatAnimationName(String name) {
    if (name.contains('|')) {
      name = name.split('|').last;
    }
    return name.replaceAll('_', ' ');
  }

  /// 构建模型切换按钮
  Widget _buildModelSwitchButton() {
    return GestureDetector(
      onTap: _toggleModelSelector,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showModelSelector ? Icons.close : Icons.swap_horiz,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              '模型',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建模型选择器
  Widget _buildModelSelector(ModelManagerService modelManager) {
    final allModels = modelManager.allModels;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '选择模型',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${allModels.length} 个模型',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allModels.length,
              itemBuilder: (context, index) {
                final model = allModels[index];
                final isSelected = modelManager.selectedModelId == model.id ||
                    (modelManager.selectedModelId == null && index == 0);

                return GestureDetector(
                  onTap: () => _switchModel(modelManager, model.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.shade400
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                model.isAsset ? '内置' : '自定义',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (model.defaultAnimation != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '动画',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建模式切换按钮组
  Widget _buildModeButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            mode: DisplayMode.mode3D,
            icon: Icons.view_in_ar,
            label: '3D',
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            mode: DisplayMode.mode2D,
            icon: Icons.animation,
            label: '2D',
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            mode: DisplayMode.live2D,
            icon: Icons.face,
            label: 'Live2D',
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required DisplayMode mode,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
