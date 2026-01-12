import 'package:flutter/material.dart';
import 'common/glass_container.dart';
import '3d_rotating_menu.dart';

/// 菱形玻璃拟态菜单项
class RhombusMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const RhombusMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.width = 140,
    this.height = 180,
  });

  /// 从 MenuData 创建
  factory RhombusMenuItem.fromData(MenuData data, {double? width, double? height}) {
    return RhombusMenuItem(
      title: data.title,
      subtitle: data.subtitle,
      icon: data.icon,
      color: data.color,
      onTap: data.onTap,
      width: width ?? 140,
      height: height ?? 180,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 菱形玻璃容器
            CustomPaint(
              size: Size(width, height),
              painter: RhombusPainter(
                color: color ?? Colors.blue.withValues(alpha: 0.3),
              ),
              child: Center(
                child: ClipPath(
                  clipper: RhombusClipper(),
                  child: GlassContainer(
                    width: width,
                    height: height,
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 菱形裁剪器
class RhombusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // 菱形的四个顶点
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 上顶点
    path.moveTo(centerX, 0);
    // 右顶点
    path.lineTo(size.width, centerY);
    // 下顶点
    path.lineTo(centerX, size.height);
    // 左顶点
    path.lineTo(0, centerY);
    // 闭合
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 菱形绘制器 - 绘制边框
class RhombusPainter extends CustomPainter {
  final Color color;

  RhombusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    final Path path = Path();

    // 菱形的四个顶点
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    path.moveTo(centerX, 0);
    path.lineTo(size.width, centerY);
    path.lineTo(centerX, size.height);
    path.lineTo(0, centerY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
