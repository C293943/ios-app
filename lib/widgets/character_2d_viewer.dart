import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Character2DViewer extends StatefulWidget {
  final String? animationPath;
  final String? imageUrl;
  final bool isLoading;
  final String? error;
  final double size;
  final bool animate;

  const Character2DViewer({
    super.key,
    this.animationPath,
    this.imageUrl,
    this.isLoading = false,
    this.error,
    this.size = 250.0,
    this.animate = true,
  });

  @override
  State<Character2DViewer> createState() => _Character2DViewerState();
}

class _Character2DViewerState extends State<Character2DViewer>
    with TickerProviderStateMixin {
  // 1. 悬浮动画控制器 (控制上下浮动)
  late final AnimationController _hoverController;
  late final Animation<double> _hoverAnimation;

  // 2. 交互状态 (控制气泡显示)
  bool _showBubble = false;
  String _currentMessage = "你好！我是你的 AI 助手。";

  // 简单的语录库
  final List<String> _messages = [
    "正在分析数据...",
    "有什么我可以帮你的吗？",
    "系统运行正常。",
    "今天也是充满活力的一天！",
    "点击我可以切换对话哦~",
  ];

  @override
  void initState() {
    super.initState();

    // 初始化悬浮动画：2秒一个周期，上下往复
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 循环往复

    // 设置移动范围：上下移动 10 像素
    _hoverAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // 点击触发的方法
  void _onCharacterTap() {
    setState(() {
      // 如果气泡没显示，就显示；如果显示了，就换句话
      if (!_showBubble) {
        _showBubble = true;
      } else {
        // 随机（或顺序）切换一句话
        _currentMessage = (_messages..shuffle()).first;
      }
    });

    // 3秒后自动隐藏气泡 (可选)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showBubble) {
        setState(() {
          _showBubble = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String assetPath =
        widget.animationPath ?? 'assets/animations/character.json';
    final imageUrl = widget.imageUrl;

    return SizedBox(
      width: widget.size,
      height: widget.size + 60, // 增加一点高度给气泡预留空间
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // 允许气泡超出边界
        children: [
          // --- 角色层 (带悬浮动画) ---
          AnimatedBuilder(
            animation: _hoverAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _hoverAnimation.value), // 应用上下位移
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _onCharacterTap, // 绑定点击事件
              child: Opacity(
                opacity: 0.7, // 透明度: 0.0(完全透明) ~ 1.0(完全不透明)
                child: _buildImage(assetPath, imageUrl),
              ),
            ),
          ),

          // --- 气泡对话框层 ---
          if (_showBubble)
            Positioned(
              top: 0, // 放在顶部
              child: _buildChatBubble(),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String assetPath, String? imageUrl) {
    // 优先显示 Base64 编码的图片（背景移除后的图片）
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('data:image')) {
      debugPrint('[Character2DViewer] 加载 Base64 图片');
      try {
        // 解码 Base64 图片
        final base64String = imageUrl.split(',').last;
        final imageBytes = base64Decode(base64String);

        return Image.memory(
          imageBytes,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[Character2DViewer] Base64 图片解码失败: $error');
            return Image.asset(
              assetPath,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            );
          },
        );
      } catch (e) {
        debugPrint('[Character2DViewer] Base64 解码异常: $e');
        // 回退到本地资源
        return Image.asset(
          assetPath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        );
      }
    }

    // 显示网络图片
    if (imageUrl != null && imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      debugPrint('[Character2DViewer] 加载网络图片: $imageUrl');
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        placeholder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, _, error) {
          debugPrint('[Character2DViewer] 图片加载失败: $error');
          return Image.asset(
            assetPath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          );
        },
      );
    }

    // 加载中状态
    if (widget.isLoading && (imageUrl == null || imageUrl.isEmpty)) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // 错误状态
    if (widget.error != null && widget.error!.isNotEmpty && (imageUrl == null || imageUrl.isEmpty)) {
      debugPrint('[Character2DViewer] 显示错误信息: ${widget.error}');
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    // 默认使用本地资源
    debugPrint('[Character2DViewer] 使用本地资源: $assetPath');
    return Image.asset(
      assetPath,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }

  // 构建气泡组件
  Widget _buildChatBubble() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value, // 弹出动画
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _currentMessage,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
