import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:primordial_spirit/config/app_theme.dart';

/// 水晶菜单项定义
class CrystalMenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  CrystalMenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// 3D蛋形水晶菜单 - 真正的3D空间布局
/// 6个菜单项围绕Y轴旋转，支持手势滚动和透视效果
class EggCrystalMenu3D extends StatefulWidget {
  final List<CrystalMenuItem> items;
  final double eggSize;
  final double crystalSize;
  final int evolutionStage;

  const EggCrystalMenu3D({
    super.key,
    required this.items,
    this.eggSize = 200,
    this.crystalSize = 60,
    this.evolutionStage = 0,
  });

  @override
  State<EggCrystalMenu3D> createState() => _EggCrystalMenu3DState();
}

class _EggCrystalMenu3DState extends State<EggCrystalMenu3D>
    with TickerProviderStateMixin {
  late AnimationController _autoRotateController;
  late Animation<double> _autoRotateAnimation;

  double _rotationAngle = 0.0; // 当前旋转角度
  bool _isDragging = false;
  double _dragStartX = 0.0;
  double _dragStartRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _autoRotateController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _autoRotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_autoRotateController);
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  /// 处理手势拖动开始
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartRotation = _rotationAngle;
    });
  }

  /// 处理手势拖动更新
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final deltaX = details.globalPosition.dx - _dragStartX;
    final rotationDelta = deltaX * 0.005; // 调整灵敏度

    setState(() {
      _rotationAngle = _dragStartRotation + rotationDelta;
    });
  }

  /// 处理手势拖动结束
  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: SizedBox(
        width: widget.eggSize * 2.5,
        height: widget.eggSize * 2.5,
        child: AnimatedBuilder(
          animation: _autoRotateAnimation,
          builder: (context, child) {
            // 如果正在拖动，使用手动旋转角度；否则使用自动旋转
            final currentRotation = _isDragging
                ? _rotationAngle
                : _rotationAngle + _autoRotateAnimation.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // 蛋形背景（中心）
                _buildEgg(),

                // 3D旋转的水晶按钮
                ..._build3DCrystals(currentRotation),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEgg() {
    return Container(
      width: widget.eggSize,
      height: widget.eggSize * 1.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/spirit-stone-egg.png'),
          fit: BoxFit.contain,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fluorescentCyan.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  List<Widget> _build3DCrystals(double rotation) {
    final crystals = <Widget>[];
    final itemCount = widget.items.length;
    final radius = widget.eggSize * 1.0; // 扩大半径，远离主体

    for (int i = 0; i < itemCount; i++) {
      // 计算每个水晶的角度位置（围绕Y轴均匀分布）
      final baseAngle = (2 * math.pi / itemCount) * i;
      final finalAngle = baseAngle + rotation;

      // 3D透视投影
      const perspective = 0.003;
      const cameraZ = 1000.0;

      // 计算旋转后的3D坐标
      final x = radius * math.sin(finalAngle);
      final z = radius * math.cos(finalAngle);

      // 透视投影：远小近大
      final scale = cameraZ / (cameraZ - z);
      final opacity = ((z + radius) / (2 * radius)).clamp(0.3, 1.0);

      // 根据Z轴位置确定层级
      final zIndex = (z + radius).toInt();

      // 构建变换矩阵
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, perspective)
        ..rotateY(finalAngle)
        ..translate(0.0, 0.0, -radius)
        ..scale(scale);

      crystals.add(
        Positioned(
          left: widget.eggSize * 1.25 + x - widget.crystalSize / 2,
          top: widget.eggSize * 1.25 - widget.crystalSize / 2,
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: _CrystalButton3D(
                item: widget.items[i],
                size: widget.crystalSize * scale,
                baseSize: widget.crystalSize,
                scale: scale,
                zIndex: zIndex,
                evolutionStage: widget.evolutionStage,
              ),
            ),
          ),
        ),
      );
    }

    return crystals;
  }
}

class _CrystalButton3D extends StatefulWidget {
  final CrystalMenuItem item;
  final double size;
  final double baseSize;
  final double scale;
  final int zIndex;

  const _CrystalButton3D({
    required this.item,
    required this.size,
    required this.baseSize,
    required this.scale,
    required this.zIndex,
    required this.evolutionStage,
  });

  final int evolutionStage;

  @override
  State<_CrystalButton3D> createState() => _CrystalButton3DState();
}

class _CrystalButton3DState extends State<_CrystalButton3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse =
              1.0 + math.sin(_pulseController.value * 2 * math.pi) * 0.08;
          final finalScale = widget.scale * pulse * (_isPressed ? 0.9 : 1.0);

          return Transform.scale(
            scale: finalScale,
            child: Transform.rotate(
              angle: math.pi / 4, // 旋转45度形成菱形
              child: Container(
                width: widget.baseSize * 0.5,
                height: widget.baseSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero, // 无圆角，保持正方形边缘
                  // 水晶风格：多层渐变 + 高光（对角线方向）
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      widget.item.color.withValues(alpha: 0.8),
                      widget.item.color.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    // 外层彩色光晕
                    BoxShadow(
                      color: widget.item.color.withValues(alpha: 0.4),
                      blurRadius: 30 * widget.scale,
                      spreadRadius: 10 * widget.scale,
                    ),
                    // 顶部左侧高光
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.4),
                      blurRadius: 18 * widget.scale,
                      spreadRadius: 3 * widget.scale,
                      offset: Offset(-4 * widget.scale, -4 * widget.scale),
                    ),
                    // 底部右侧深色阴影
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12 * widget.scale,
                      spreadRadius: 2 * widget.scale,
                      offset: Offset(3 * widget.scale, 3 * widget.scale),
                    ),
                    // 额外的对角线高光（强化菱形立体感）
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      blurRadius: 10 * widget.scale,
                      spreadRadius: 1 * widget.scale,
                      offset: Offset(-2 * widget.scale, -2 * widget.scale),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -math.pi / 4, // 反向旋转文字，保持水平
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 文字垂直展示
                      Text(
                        widget.item.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.baseSize * 0.18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
