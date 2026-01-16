import 'dart:ui';
import 'package:flutter/material.dart';

class HexCrystalMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color tintColor;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool isLocked; // 是否锁定
  final int unlockLevel; // 解锁所需等级

  const HexCrystalMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tintColor = const Color(0xFF00E5FF),
    this.onTap,
    this.width = 120,
    this.height = 150,
    this.isLocked = false,
    this.unlockLevel = 1,
  });

  @override
  Widget build(BuildContext context) {
    final lockedColor = Colors.grey.withValues(alpha: 0.5);
    final displayColor = isLocked ? lockedColor : tintColor;
    final displayOpacity = isLocked ? 0.4 : 1.0;

    final content = Opacity(
      opacity: displayOpacity,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipPath(
              clipper: _HexCrystalClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: isLocked ? 0.08 : 0.22),
                        displayColor.withValues(alpha: isLocked ? 0.05 : 0.18),
                        Colors.white.withValues(alpha: isLocked ? 0.03 : 0.08),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: Size(width, height),
              painter: _HexCrystalBorderPainter(tintColor: displayColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: _HexCrystalContent(
                title: title,
                subtitle: subtitle,
                icon: icon,
                isLocked: isLocked,
                unlockLevel: unlockLevel,
              ),
            ),
            // 锁定图标覆盖层
            if (isLocked)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 32,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isLocked ? null : onTap, // 锁定时不响应点击
      child: content,
    );
  }
}

class _HexCrystalContent extends StatelessWidget {
  const _HexCrystalContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLocked = false,
    this.unlockLevel = 1,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isLocked;
  final int unlockLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 34,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              height: 1.15,
              shadows: const [
                Shadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HexCrystalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final left = w * 0.18;
    final right = w * 0.82;
    final upper = h * 0.18;
    final lower = h * 0.82;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(right, upper)
      ..lineTo(right, lower)
      ..lineTo(w * 0.5, h)
      ..lineTo(left, lower)
      ..lineTo(left, upper)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HexCrystalBorderPainter extends CustomPainter {
  _HexCrystalBorderPainter({required this.tintColor});

  final Color tintColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _HexCrystalClipper().getClip(size);

    final edgeGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.75),
        tintColor.withValues(alpha: 0.65),
        Colors.white.withValues(alpha: 0.35),
      ],
    ).createShader(Offset.zero & size);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = edgeGradient
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = edgeGradient;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    final highlight = Path()
      ..moveTo(size.width * 0.5, size.height * 0.03)
      ..lineTo(size.width * 0.78, size.height * 0.22)
      ..lineTo(size.width * 0.60, size.height * 0.50)
      ..lineTo(size.width * 0.35, size.height * 0.22)
      ..close();

    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(highlight, highlightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HexCrystalBorderPainter oldDelegate) {
    return oldDelegate.tintColor != tintColor;
  }
}

