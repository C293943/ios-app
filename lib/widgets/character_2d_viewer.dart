import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 2D角色动画查看器组件
class Character2DViewer extends StatelessWidget {
  final String? animationPath;
  final double size;
  final bool animate;
  
  const Character2DViewer({
    super.key,
    this.animationPath,
    this.size = 250.0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了Lottie动画路径,使用Lottie
    if (animationPath != null && animationPath!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: ClipOval(
          child: Lottie.asset(
            animationPath!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            animate: animate,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        ),
      );
    }
    
    // 默认占位符
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: size * 0.48,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

/// 2D精灵动画查看器(支持多帧动画)
class SpriteAnimationViewer extends StatefulWidget {
  final List<String> framePaths;
  final double size;
  final Duration frameDuration;
  
  const SpriteAnimationViewer({
    super.key,
    required this.framePaths,
    this.size = 250.0,
    this.frameDuration = const Duration(milliseconds: 100),
  });

  @override
  State<SpriteAnimationViewer> createState() => _SpriteAnimationViewerState();
}

class _SpriteAnimationViewerState extends State<SpriteAnimationViewer> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration * widget.framePaths.length,
    )..repeat();
    
    _controller.addListener(() {
      final newFrame = (_controller.value * widget.framePaths.length).floor() % widget.framePaths.length;
      if (newFrame != _currentFrame) {
        setState(() {
          _currentFrame = newFrame;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.framePaths.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: ClipOval(
        child: Image.asset(
          widget.framePaths[_currentFrame],
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.animation,
          size: widget.size * 0.48,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}