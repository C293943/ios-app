import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'dart:math' as math;

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

/// 3D蛋形水晶菜单
class EggCrystalMenu extends StatefulWidget {
  final List<CrystalMenuItem> items;
  final double eggSize;
  final double crystalSize;
  final int evolutionStage; // 0-100，进化程度

  const EggCrystalMenu({
    super.key,
    required this.items,
    this.eggSize = 200,
    this.crystalSize = 60,
    this.evolutionStage = 0,
  });

  @override
  State<EggCrystalMenu> createState() => _EggCrystalMenuState();
}

class _EggCrystalMenuState extends State<EggCrystalMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.eggSize * 2.5,
          height: widget.eggSize * 2.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 蛋形背景
              _buildEgg(),
              // 6个水晶按钮
              ..._buildCrystals(_rotationAnimation.value),
            ],
          ),
        );
      },
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
            color: AppTheme.fluorescentCyan.withValues(alpha: 0.22),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCrystals(double rotation) {
    final crystals = <Widget>[];
    final itemCount = widget.items.length;
    final radius = widget.eggSize * 0.8;

    for (int i = 0; i < itemCount; i++) {
      final angle = (2 * math.pi / itemCount) * i + rotation;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      // 3D透视效果 - 围绕Y轴旋转
      final perspective = 0.001;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, perspective)
        ..rotateY(angle)  // 围绕Y轴旋转
        ..rotateX(math.sin(angle) * 0.2);  // 轻微的X轴旋转

      crystals.add(
        Positioned(
          left: widget.eggSize * 1.25 + x - widget.crystalSize / 2,
          top: widget.eggSize * 1.25 + y - widget.crystalSize / 2,
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: _CrystalButton(
              item: widget.items[i],
              size: widget.crystalSize,
              evolutionStage: widget.evolutionStage,
            ),
          ),
        ),
      );
    }

    return crystals;
  }
}

class _CrystalButton extends StatefulWidget {
  final CrystalMenuItem item;
  final double size;
  final int evolutionStage;

  const _CrystalButton({
    required this.item,
    required this.size,
    required this.evolutionStage,
  });

  @override
  State<_CrystalButton> createState() => _CrystalButtonState();
}

class _CrystalButtonState extends State<_CrystalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovered = false;

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = 1.0 + math.sin(_pulseController.value * 2 * math.pi) * 0.05;
            final scale = _isHovered ? 1.1 : pulse;

            // 竖长水晶尺寸
            final crystalWidth = widget.size * 0.6;
            final crystalHeight = widget.size * 1.2;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: crystalWidth,
                height: crystalHeight,
                decoration: BoxDecoration(
                  // 竖长水晶形状
                  borderRadius: BorderRadius.circular(crystalWidth * 0.3),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.item.color.withValues(alpha: 0.9),
                      widget.item.color.withValues(alpha: 0.6),
                      widget.item.color.withValues(alpha: 0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.color.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: widget.item.color.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 图标
                    Icon(
                      widget.item.icon,
                      color: Colors.white,
                      size: crystalWidth * 0.4,
                    ),
                    SizedBox(height: crystalHeight * 0.05),

                    // 竖向文字
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: crystalWidth * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.item.label.split('').map((char) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: crystalHeight * 0.01),
                            child: Text(
                              char,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: crystalWidth * 0.2,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
