import 'package:flutter/material.dart';
import 'package:primordial_spirit/widgets/character_3d_viewer.dart';
import 'package:primordial_spirit/widgets/character_2d_viewer.dart';
import 'package:primordial_spirit/widgets/character_live2d_viewer.dart';

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

  @override
  void initState() {
    super.initState();
    _currentMode = widget.defaultMode;
  }

  void _switchMode(DisplayMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 3D/2D/Live2D视图切换
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
          child: _buildCurrentViewer(),
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
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentViewer() {
    switch (_currentMode) {
      case DisplayMode.mode3D:
        return Character3DViewer(
          key: const ValueKey('3d'),
          modelPath: widget.modelPath3D ?? 'assets/3d_models/Meshy_AI_biped/Meshy_AI_Character_output.glb',
          size: widget.size,
          autoPlay: true,
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
              ? Colors.white.withOpacity(0.3) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
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