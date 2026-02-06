import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 仙侠主题导航图标枚举 - 对应五行
enum NavIconType {
  spirit, // 元神 (水 - 灵力核心)
  divination, // 问卜 (火 - 灵龟卜象)
  relationship, // 合盘 (木 - 连理双生)
  fortune, // 运势 (金 - 星宿流转)
  bazi, // 八字 (土 - 八卦阵)
}

/// 高阶仙侠图标绘制器 - 用 CustomPaint 实现 Rive 风格动画
class NavIconPainter extends CustomPainter {
  final NavIconType type;
  final double activeFraction; // 0.0 ~ 1.0 激活程度
  final double pulsePhase; // 0.0 ~ 1.0 脉冲相位（呼吸动画）
  final double rotatePhase; // 0.0 ~ 1.0 旋转相位
  final Color activeColor;
  final Color inactiveColor;
  final Color glowColor;

  NavIconPainter({
    required this.type,
    required this.activeFraction,
    required this.pulsePhase,
    required this.rotatePhase,
    required this.activeColor,
    required this.inactiveColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;

    // 当前插值颜色
    final color = Color.lerp(inactiveColor, activeColor, activeFraction)!;
    final glowAlpha = 0.3 * activeFraction;

    // 绘制发光背景（激活态）
    if (activeFraction > 0.01) {
      _drawGlowAura(canvas, center, radius, glowAlpha);
    }

    // 根据类型绘制不同图标
    switch (type) {
      case NavIconType.spirit:
        _drawSpiritIcon(canvas, center, radius, color);
      case NavIconType.divination:
        _drawDivinationIcon(canvas, center, radius, color);
      case NavIconType.relationship:
        _drawRelationshipIcon(canvas, center, radius, color);
      case NavIconType.fortune:
        _drawFortuneIcon(canvas, center, radius, color);
      case NavIconType.bazi:
        _drawBaziIcon(canvas, center, radius, color);
    }

    // 激活态：绘制粒子环绕
    if (activeFraction > 0.3) {
      _drawOrbitParticles(canvas, center, radius, color);
    }
  }

  /// 发光光环
  void _drawGlowAura(Canvas canvas, Offset center, double radius, double alpha) {
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius * 1.6,
        [
          glowColor.withOpacity(alpha * (0.6 + 0.4 * math.sin(pulsePhase * math.pi * 2))),
          glowColor.withOpacity(alpha * 0.2),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius * 1.6, glowPaint);
  }

  /// 元神图标 - 灵力核心（类似太极 + 灵球）
  void _drawSpiritIcon(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // 外环 - 灵力环
    final outerRect = Rect.fromCircle(center: center, radius: r * 0.85);
    canvas.drawArc(outerRect, -math.pi / 2 + rotatePhase * math.pi * 2, math.pi * 1.6, false, paint);

    // 内核 - 灵球
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        center + Offset(-r * 0.1, -r * 0.1),
        r * 0.45,
        [
          color.withOpacity(0.9),
          color.withOpacity(0.3),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(center, r * 0.35, corePaint);

    // 灵力线
    final linePaint = Paint()
      ..color = color.withOpacity(0.5 + 0.3 * activeFraction)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final angle = (rotatePhase * math.pi * 2) + (i * math.pi * 2 / 3);
      final startR = r * 0.4;
      final endR = r * 0.75;
      final start = center + Offset(math.cos(angle) * startR, math.sin(angle) * startR);
      final end = center + Offset(math.cos(angle) * endR, math.sin(angle) * endR);
      
      final path = Path();
      path.moveTo(start.dx, start.dy);
      final ctrl = center + Offset(
        math.cos(angle + 0.3) * (startR + endR) / 2,
        math.sin(angle + 0.3) * (startR + endR) / 2,
      );
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      canvas.drawPath(path, linePaint);
    }
  }

  /// 问卜图标 - 灵龟卜象（龟壳 + 灵火）
  void _drawDivinationIcon(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // 龟壳六边形
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 3);
      final x = center.dx + r * 0.7 * math.cos(angle);
      final y = center.dy + r * 0.7 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);

    // 内部三条卜辞线 (阴阳爻)
    final lineY = [-r * 0.25, 0.0, r * 0.25];
    final linePaint = Paint()
      ..color = color.withOpacity(0.7 + 0.3 * activeFraction)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final y = center.dy + lineY[i];
      final halfW = r * 0.35;
      if (i == 1) {
        // 阴爻 - 断裂
        canvas.drawLine(
          Offset(center.dx - halfW, y),
          Offset(center.dx - halfW * 0.15, y),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx + halfW * 0.15, y),
          Offset(center.dx + halfW, y),
          linePaint,
        );
      } else {
        // 阳爻 - 完整
        canvas.drawLine(
          Offset(center.dx - halfW, y),
          Offset(center.dx + halfW, y),
          linePaint,
        );
      }
    }

    // 灵火粒子
    if (activeFraction > 0.1) {
      final flamePaint = Paint()
        ..color = color.withOpacity(0.4 * activeFraction);
      for (int i = 0; i < 4; i++) {
        final angle = rotatePhase * math.pi * 2 + i * math.pi / 2;
        final dist = r * 0.85 + r * 0.1 * math.sin(pulsePhase * math.pi * 2 + i);
        final pos = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
        canvas.drawCircle(pos, 1.5, flamePaint);
      }
    }
  }

  /// 合盘图标 - 连理双环
  void _drawRelationshipIcon(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // 双心形路径
    final heartOffset = r * 0.25 * (1 - activeFraction * 0.3);

    _drawHeart(canvas, Offset(center.dx - heartOffset, center.dy), r * 0.55, color, paint);
    _drawHeart(canvas, Offset(center.dx + heartOffset, center.dy), r * 0.55, color, paint);

    // 连理丝线
    if (activeFraction > 0.2) {
      final silkPaint = Paint()
        ..color = color.withOpacity(0.4 * activeFraction)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      
      final path = Path();
      path.moveTo(center.dx - heartOffset, center.dy - r * 0.1);
      path.cubicTo(
        center.dx, center.dy - r * 0.3 - r * 0.1 * math.sin(pulsePhase * math.pi * 2),
        center.dx, center.dy + r * 0.3 + r * 0.1 * math.sin(pulsePhase * math.pi * 2),
        center.dx + heartOffset, center.dy - r * 0.1,
      );
      canvas.drawPath(path, silkPaint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color, Paint paint) {
    final s = size * 0.5;
    final path = Path();
    path.moveTo(center.dx, center.dy + s * 0.4);
    path.cubicTo(
      center.dx - s * 0.8, center.dy - s * 0.2,
      center.dx - s * 0.5, center.dy - s * 0.7,
      center.dx, center.dy - s * 0.35,
    );
    path.cubicTo(
      center.dx + s * 0.5, center.dy - s * 0.7,
      center.dx + s * 0.8, center.dy - s * 0.2,
      center.dx, center.dy + s * 0.4,
    );
    canvas.drawPath(path, paint);

    if (activeFraction > 0.5) {
      final fillPaint = Paint()
        ..color = color.withOpacity(0.15 * activeFraction)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }
  }

  /// 运势图标 - 星宿流转（星轨 + 闪耀星星）
  void _drawFortuneIcon(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // 星轨椭圆
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotatePhase * math.pi * 2 * 0.2);
    
    final orbitRect = Rect.fromCenter(
      center: Offset.zero,
      width: r * 1.6,
      height: r * 0.9,
    );
    canvas.drawOval(orbitRect, paint..color = color.withOpacity(0.4));

    // 第二条星轨（交叉）
    canvas.rotate(math.pi / 3);
    final orbit2Rect = Rect.fromCenter(
      center: Offset.zero,
      width: r * 1.5,
      height: r * 0.8,
    );
    canvas.drawOval(orbit2Rect, paint..color = color.withOpacity(0.3));
    
    canvas.restore();

    // 中心星星
    _drawStar(canvas, center, r * 0.3, color, filled: activeFraction > 0.5);

    // 流转星点
    for (int i = 0; i < 3; i++) {
      final phase = (rotatePhase + i / 3.0) % 1.0;
      final angle = phase * math.pi * 2;
      final orbitR = r * (0.65 + 0.1 * i);
      final pos = center + Offset(
        math.cos(angle) * orbitR,
        math.sin(angle) * orbitR * 0.55,
      );
      final dotPaint = Paint()
        ..color = color.withOpacity(0.5 + 0.5 * activeFraction);
      canvas.drawCircle(pos, 1.8 - i * 0.3, dotPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color, {bool filled = false}) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final innerAngle = outerAngle + math.pi / 5;
      final outer = center + Offset(math.cos(outerAngle) * size, math.sin(outerAngle) * size);
      final inner = center + Offset(math.cos(innerAngle) * size * 0.4, math.sin(innerAngle) * size * 0.4);
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();

    if (filled) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// 八字图标 - 八卦阵
  void _drawBaziIcon(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // 外圈
    canvas.drawCircle(center, r * 0.85, paint..color = color.withOpacity(0.5));

    // 八卦符号（简化版 - 8个方位点 + 连线）
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotatePhase * math.pi * 0.5); // 缓慢旋转

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final pos = Offset(math.cos(angle) * r * 0.65, math.sin(angle) * r * 0.65);
      
      // 方位标记（小三横线 - 卦象）
      final guaPaint = Paint()
        ..color = color.withOpacity(0.6 + 0.4 * activeFraction)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + math.pi / 2);
      
      final guaW = r * 0.15;
      // 每个卦象画2条线
      for (int j = 0; j < 2; j++) {
        final ly = (j - 0.5) * r * 0.08;
        if ((i + j) % 3 == 0) {
          // 断线
          canvas.drawLine(Offset(-guaW, ly), Offset(-guaW * 0.15, ly), guaPaint);
          canvas.drawLine(Offset(guaW * 0.15, ly), Offset(guaW, ly), guaPaint);
        } else {
          canvas.drawLine(Offset(-guaW, ly), Offset(guaW, ly), guaPaint);
        }
      }
      canvas.restore();
    }

    // 中心太极
    final yinYangR = r * 0.22;
    canvas.drawCircle(Offset.zero, yinYangR, paint..color = color);
    
    // S型分割线
    final sPath = Path();
    sPath.moveTo(0, -yinYangR);
    sPath.arcToPoint(
      Offset(0, 0),
      radius: Radius.circular(yinYangR / 2),
      clockwise: true,
    );
    sPath.arcToPoint(
      Offset(0, yinYangR),
      radius: Radius.circular(yinYangR / 2),
      clockwise: false,
    );
    canvas.drawPath(sPath, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // 两个鱼眼
    canvas.drawCircle(Offset(0, -yinYangR / 2), yinYangR * 0.12, Paint()..color = color);
    canvas.drawCircle(
      Offset(0, yinYangR / 2),
      yinYangR * 0.12,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.restore();
  }

  /// 绘制轨道粒子
  void _drawOrbitParticles(Canvas canvas, Offset center, double r, Color color) {
    final particleCount = 5;
    for (int i = 0; i < particleCount; i++) {
      final phase = (rotatePhase + i / particleCount) % 1.0;
      final angle = phase * math.pi * 2;
      final distance = r * 1.1 + r * 0.15 * math.sin(pulsePhase * math.pi * 4 + i);
      final pos = center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      final particleAlpha = (0.3 + 0.5 * math.sin(phase * math.pi)) * activeFraction;
      final particlePaint = Paint()
        ..color = color.withOpacity(particleAlpha.clamp(0.0, 1.0));
      canvas.drawCircle(pos, 1.2 + 0.5 * math.sin(pulsePhase * math.pi * 2 + i), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant NavIconPainter oldDelegate) {
    return oldDelegate.activeFraction != activeFraction ||
        oldDelegate.pulsePhase != pulsePhase ||
        oldDelegate.rotatePhase != rotatePhase ||
        oldDelegate.type != type ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
