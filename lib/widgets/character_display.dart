import 'package:flutter/material.dart';
import 'package:primordial_spirit/widgets/character_3d_viewer.dart';
import 'package:primordial_spirit/widgets/character_2d_viewer.dart';

/// 角色显示组件 - 支持3D和2D模式切换
class CharacterDisplay extends StatefulWidget {
  final String? modelPath3D;
  final String? animationPath2D;
  final double size;
  final bool defaultTo3D;
  
  const CharacterDisplay({
    super.key,
    this.modelPath3D,
    this.animationPath2D,
    this.size = 250.0,
    this.defaultTo3D = true,
  });

  @override
  State<CharacterDisplay> createState() => _CharacterDisplayState();
}

class _CharacterDisplayState extends State<CharacterDisplay> {
  late bool _is3DMode;

  @override
  void initState() {
    super.initState();
    _is3DMode = widget.defaultTo3D;
  }

  void _toggleMode() {
    setState(() {
      _is3DMode = !_is3DMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 3D/2D视图切换
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
          child: _is3DMode
              ? Character3DViewer(
                  key: const ValueKey('3d'),
                  modelPath: widget.modelPath3D ?? 'assets/3d_models/default.obj',
                  size: widget.size,
                )
              : Character2DViewer(
                  key: const ValueKey('2d'),
                  animationPath: widget.animationPath2D,
                  size: widget.size,
                ),
        ),
        
        // 切换按钮
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _toggleMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _is3DMode 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.view_in_ar,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '3D',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: _is3DMode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _toggleMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_is3DMode 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.animation,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2D',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: !_is3DMode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}