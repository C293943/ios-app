import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

/// 3D角色查看器组件
/// 支持 GLB, GLTF, OBJ 格式，可控制动画
class Character3DViewer extends StatefulWidget {
  final String modelPath;
  final double size;
  final bool autoPlay;
  final String? initialAnimation;

  const Character3DViewer({
    super.key,
    required this.modelPath,
    this.size = 250.0,
    this.autoPlay = true,
    this.initialAnimation,
  });

  @override
  State<Character3DViewer> createState() => Character3DViewerState();
}

class Character3DViewerState extends State<Character3DViewer> {
  Flutter3DController? _controller;
  List<String> _availableAnimations = [];
  String? _currentAnimation;
  bool _isLoading = true;
  bool _isModelReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();

    // 监听模型加载状态
    _controller!.onModelLoaded.addListener(_onControllerModelLoaded);
  }

  void _onControllerModelLoaded() {
    debugPrint('控制器模型加载状态变化: ${_controller!.onModelLoaded.value}');
    if (_controller!.onModelLoaded.value) {
      debugPrint('控制器确认模型已加载');
      setState(() {
        _isModelReady = true;
        _isLoading = false;
      });
      _loadAnimationsAndPlay();
    }
  }

  Future<void> _loadAnimationsAndPlay() async {
    if (!_isModelReady || _controller == null || _isObjFormat) return;

    try {
      final animations = await _controller!.getAvailableAnimations();
      debugPrint('可用动画列表: $animations');

      if (mounted) {
        setState(() {
          _availableAnimations = animations;
        });

        // 自动播放初始动画（无限循环）
        if (widget.autoPlay && animations.isNotEmpty) {
          final animToPlay = widget.initialAnimation ?? animations.first;
          debugPrint('准备播放动画: $animToPlay (无限循环)');
          if (animations.contains(animToPlay)) {
            // 不传 loopCount 参数表示无限循环
            _controller!.playAnimation(animationName: animToPlay);
            debugPrint('动画已开始播放: $animToPlay');
            setState(() {
              _currentAnimation = animToPlay;
            });
          }
        } else if (animations.isEmpty) {
          debugPrint('模型没有可用的动画');
        }
      }
    } catch (e) {
      debugPrint('获取动画列表失败: $e');
    }
  }

  /// 获取所有可用的动画列表
  List<String> get availableAnimations => _availableAnimations;

  /// 获取当前播放的动画名称
  String? get currentAnimation => _currentAnimation;

  /// 模型是否已加载完成
  bool get isModelReady => _isModelReady;

  /// 播放指定动画
  void playAnimation(String animationName) {
    if (!_isModelReady || _controller == null) return;
    if (_availableAnimations.contains(animationName)) {
      _controller!.playAnimation(animationName: animationName);
      setState(() {
        _currentAnimation = animationName;
      });
    }
  }

  /// 播放动画（指定循环次数）
  void playAnimationWithLoop(String animationName, int loopCount) {
    if (!_isModelReady || _controller == null) return;
    if (_availableAnimations.contains(animationName)) {
      _controller!.playAnimation(
        animationName: animationName,
        loopCount: loopCount,
      );
      setState(() {
        _currentAnimation = animationName;
      });
    }
  }

  /// 暂停当前动画
  void pauseAnimation() {
    if (!_isModelReady) return;
    _controller?.pauseAnimation();
  }

  /// 重置动画到初始状态并重新播放
  void resetAnimation() {
    if (!_isModelReady) return;
    _controller?.resetAnimation();
  }

  /// 停止动画
  void stopAnimation() {
    if (!_isModelReady) return;
    _controller?.stopAnimation();
    setState(() {
      _currentAnimation = null;
    });
  }

  /// 开始旋转模型
  void startRotation({int rotationSpeed = 10}) {
    if (!_isModelReady) return;
    _controller?.startRotation(rotationSpeed: rotationSpeed);
  }

  /// 暂停旋转
  void pauseRotation() {
    if (!_isModelReady) return;
    _controller?.pauseRotation();
  }

  /// 停止旋转并重置
  void stopRotation() {
    if (!_isModelReady) return;
    _controller?.stopRotation();
  }

  /// 设置相机轨道（旋转视角）
  void setCameraOrbit(double theta, double phi, double radius) {
    if (!_isModelReady) return;
    _controller?.setCameraOrbit(theta, phi, radius);
  }

  /// 重置相机轨道
  void resetCameraOrbit() {
    if (!_isModelReady) return;
    _controller?.resetCameraOrbit();
  }

  /// 设置相机目标
  void setCameraTarget(double x, double y, double z) {
    if (!_isModelReady) return;
    _controller?.setCameraTarget(x, y, z);
  }

  /// 重置相机到默认位置
  void resetCameraTarget() {
    if (!_isModelReady) return;
    _controller?.resetCameraTarget();
  }

  void _onModelLoaded() {
    debugPrint('onLoad 回调触发，模型加载完成');
    setState(() {
      _isLoading = false;
      _isModelReady = true;
    });
    // 直接在这里也尝试加载动画
    _loadAnimationsAndPlay();
  }

  void _onModelError(String error) {
    debugPrint('3D模型加载错误: $error');
    setState(() {
      _isLoading = false;
      _errorMessage = '模型加载失败: $error';
    });
  }

  /// 判断是否为 OBJ 格式
  bool get _isObjFormat {
    return widget.modelPath.toLowerCase().endsWith('.obj');
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 3D 查看器需要占满整个容器
          Positioned.fill(
            child: _isObjFormat ? _buildObjViewer() : _buildGlbViewer(),
          ),
          // 加载指示器
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建独立的动画选择器（供外部调用）
  Widget buildAnimationSelector() {
    if (_availableAnimations.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildAnimationSelector();
  }

  /// 构建动画选择器
  Widget _buildAnimationSelector() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _availableAnimations.length,
        itemBuilder: (context, index) {
          final anim = _availableAnimations[index];
          final isSelected = anim == _currentAnimation;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: GestureDetector(
              onTap: () => playAnimation(anim),
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

  /// 格式化动画名称（去掉前缀，美化显示）
  String _formatAnimationName(String name) {
    // 去掉常见前缀如 "Armature|"
    if (name.contains('|')) {
      name = name.split('|').last;
    }
    // 将下划线替换为空格
    return name.replaceAll('_', ' ');
  }

  /// 获取正确的模型路径（处理外部文件）
  String get _effectiveModelPath {
    final path = widget.modelPath;
    // 如果是 assets 路径，直接返回
    if (path.startsWith('assets/')) {
      return path;
    }
    // 如果已经是 file:// 协议，直接返回
    if (path.startsWith('file://')) {
      return path;
    }
    // 外部文件路径需要添加 file:// 协议
    return 'file://$path';
  }

  /// 构建 GLB/GLTF 查看器（支持动画）
  Widget _buildGlbViewer() {
    final modelSrc = _effectiveModelPath;
    debugPrint('加载 GLB 模型: $modelSrc');
    return Flutter3DViewer(
      controller: _controller,
      src: modelSrc,
      enableTouch: true,
      activeGestureInterceptor: true,  // 防止手势冲突
      progressBarColor: Colors.orange,
      onLoad: (modelAddress) {
        debugPrint('GLB 模型加载成功: $modelAddress');
        _onModelLoaded();
      },
      onError: (error) => _onModelError(error),
      onProgress: (progress) {
        debugPrint('GLB 加载进度: $progress');
      },
    );
  }

  /// 构建 OBJ 查看器（静态模型）
  Widget _buildObjViewer() {
    final modelSrc = _effectiveModelPath;
    debugPrint('加载 OBJ 模型: $modelSrc');
    return Flutter3DViewer.obj(
      src: modelSrc,
      scale: 10,
      cameraX: 0,
      cameraY: 2,
      cameraZ: 0,
      onLoad: (modelAddress) => _onModelLoaded(),
      onError: (error) => _onModelError(error),
      onProgress: (progress) {
        // 可以在这里处理加载进度
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.onModelLoaded.removeListener(_onControllerModelLoaded);
    _controller = null;
    super.dispose();
  }
}
