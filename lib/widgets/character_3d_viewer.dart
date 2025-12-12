import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;

/// 3D角色查看器组件
class Character3DViewer extends StatefulWidget {
  final String modelPath;
  final double size;
  
  const Character3DViewer({
    super.key,
    required this.modelPath,
    this.size = 250.0,
  });

  @override
  State<Character3DViewer> createState() => _Character3DViewerState();
}

class _Character3DViewerState extends State<Character3DViewer>
    with SingleTickerProviderStateMixin {
  cube.Object? _object;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // 尝试加载3D模型
      final object = cube.Object(fileName: widget.modelPath);
      setState(() {
        _object = object;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '模型加载失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: ClipOval(
        child: cube.Cube(
          onSceneCreated: (cube.Scene scene) {
            if (_object != null) {
              scene.world.add(_object!);
            }
            // 调整相机位置和缩放,让模型显示更大
            scene.camera.position.setValues(0, 0, 6);  // 相机靠近模型
            scene.camera.zoom = 0.1;  // 减小zoom值(zoom值越小,模型越大)
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}