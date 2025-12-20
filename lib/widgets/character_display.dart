import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/character_3d_viewer.dart';
import 'package:primordial_spirit/widgets/character_2d_viewer.dart';
import 'package:primordial_spirit/widgets/character_live2d_viewer.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/models/fortune_models.dart';

/// 角色显示组件 - 支持3D、2D和Live2D模式切换
class CharacterDisplay extends StatefulWidget {
  final String? modelPath3D;
  final String? animationPath2D;
  final String? modelPathLive2D;
  final double size;
  final bool showControls;
  final Function(List<String> animations, String? currentAnimation)? onAnimationsChanged;

  const CharacterDisplay({
    super.key,
    this.modelPath3D,
    this.animationPath2D,
    this.modelPathLive2D,
    this.size = 250.0,
    this.showControls = false, // Default to hidden
    this.onAnimationsChanged,
  });

  @override
  State<CharacterDisplay> createState() => CharacterDisplayState();
}

class CharacterDisplayState extends State<CharacterDisplay> {
  // late DisplayMode _currentMode; // Managed by Service now
  bool _showModelSelector = false;
  GlobalKey<Character3DViewerState> _viewer3DKey = GlobalKey();
  List<String> _animations = [];
  String? _currentAnimation;
  List<String> _textures = [];
  String? _currentTexture;

  /// 获取当前可用的动画列表
  List<String> get animations => _animations;

  /// 获取当前播放的动画
  String? get currentAnimation => _currentAnimation;

  /// 播放指定动画
  void playAnimation(String animation) {
    final viewerState = _viewer3DKey.currentState;
    if (viewerState != null) {
      viewerState.playAnimation(animation);
      setState(() {
        _currentAnimation = animation;
      });
      widget.onAnimationsChanged?.call(_animations, _currentAnimation);
    }
  }

  @override
  void initState() {
    super.initState();
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
        final currentMode = modelManager.displayMode;
        final fortuneData = modelManager.fortuneData;

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
                    child: _buildCurrentViewer(
                      selectedModel,
                      currentMode,
                      fortuneData?.avatar3dInfo,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 动画选择器（仅3D模式且有动画时显示，且 showControls 为 true）
            if (widget.showControls && currentMode == DisplayMode.mode3D)
              _buildAnimationSelectorWrapper(),

            // 纹理选择器（仅3D模式且有纹理时显示，且 showControls 为 true）
            if (widget.showControls && currentMode == DisplayMode.mode3D && _textures.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildTextureSelectorWrapper(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentViewer(
    Model3DConfig? selectedModel,
    DisplayMode currentMode,
    Avatar3dInfo? avatar3dInfo,
  ) {
    switch (currentMode) {
      case DisplayMode.mode3D:
        // 优先展示刚生成的远程 GLB，其次使用传入/选中模型
        final generatedModelPath =
            (avatar3dInfo?.isReady ?? false) ? avatar3dInfo!.glbUrl : null;
        final modelPath = widget.modelPath3D ?? generatedModelPath ?? selectedModel?.path ?? '';
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
          taskId: avatar3dInfo?.taskId, // 传递 taskId 用于缓存标识
          onAnimationsLoaded: (animations) {
             if (mounted) {
               setState(() {
                 _animations = animations;
                 // 如果有默认动画，也更新当前动画状态
                 if (selectedModel?.defaultAnimation != null && animations.contains(selectedModel!.defaultAnimation)) {
                   _currentAnimation = selectedModel!.defaultAnimation;
                 } else if (animations.isNotEmpty) {
                    _currentAnimation = animations.first;
                 }
               });
               // 通知父组件动画列表已更新
               widget.onAnimationsChanged?.call(_animations, _currentAnimation);
             }
          },
          onTexturesLoaded: (textures) {
            if (mounted) {
              setState(() {
                _textures = textures;
                if (textures.isNotEmpty) {
                  _currentTexture = textures.first;
                }
              });
              debugPrint('模型纹理已加载: $textures');
            }
          },
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
    if (_animations.isEmpty) {
      return const SizedBox(height: 36);
    }

    return Container(
      height: 44, // Slightly taller for glass effect
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // 确保可以滚动
          itemCount: _animations.length,
          itemBuilder: (context, index) {
            final anim = _animations[index];
            final isSelected = anim == _currentAnimation;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque, // 确保点击事件被正确捕获
                onTap: () {
                  final viewerState = _viewer3DKey.currentState;
                  if (viewerState != null) {
                    viewerState.playAnimation(anim);
                    setState(() {
                      _currentAnimation = anim;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.jadeGreen
                        : AppTheme.deepVoidBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.deepVoidBlue.withOpacity(0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatAnimationName(anim),
                    style: GoogleFonts.notoSerifSc(
                      color: isSelected ? Colors.white : AppTheme.deepVoidBlue,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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

  /// 构建纹理选择器包装器
  Widget _buildTextureSelectorWrapper() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // 纹理图标标签
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.palette,
              color: Colors.teal.shade300,
              size: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '皮肤',
            style: TextStyle(
              color: Colors.teal.shade300,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // 纹理列表
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(), // 确保可以滚动
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _textures.length,
              itemBuilder: (context, index) {
                final texture = _textures[index];
                final isSelected = texture == _currentTexture;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque, // 确保点击事件被正确捕获
                    onTap: () {
                      final viewerState = _viewer3DKey.currentState;
                      if (viewerState != null) {
                        viewerState.setTexture(texture);
                        setState(() {
                          _currentTexture = texture;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.teal.shade400
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _formatTextureName(texture),
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
          ),
        ],
      ),
    );
  }

  /// 格式化纹理名称
  String _formatTextureName(String name) {
    // 去掉文件扩展名
    if (name.contains('.')) {
      name = name.substring(0, name.lastIndexOf('.'));
    }
    // 将下划线替换为空格
    return name.replaceAll('_', ' ');
  }

}
