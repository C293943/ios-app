import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'hex_crystal_menu_item.dart';

/// 3D 旋转菜单组件
/// - 6 个菜单项围绕中心轴在 3D 空间均匀分布
/// - 使用 Transform + Matrix4，通过 setEntry(3, 2, 0.001) 开启透视感
/// - 支持平滑自转，并支持用户水平滑动控制转盘旋转方向和速度（含惯性衰减）
/// - 当菜单项转到后方时，透明度与缩放比例自动减小以增强空间深度
class Rotating3DMenu extends StatefulWidget {
  final List<MenuData> menuItems;
  final double radius;
  final Widget? centerChild;

  final double itemWidth;
  final double itemHeight;

  const Rotating3DMenu({
    super.key,
    required this.menuItems,
    this.radius = 160.0,
    this.centerChild,
    this.itemWidth = 120,
    this.itemHeight = 180,
  });

  @override
  State<Rotating3DMenu> createState() => _Rotating3DMenuState();
}

class _Rotating3DMenuState extends State<Rotating3DMenu> {
  static const double _perspective = 0.001;
  static const double _dragSensitivity = 0.005; // rad / px

  static const double _minBackOpacity = 0.25;
  static const double _minBackScale = 0.75;

  static const double _autoSpeedClamp = 1.2; // rad / s
  static const double _autoDefaultSpeed = 2 * math.pi / 30; // 30s 一圈

  static const double _inertiaDrag = 0.10;
  static const double _inertiaStopVelocity = 0.01;

  late final Ticker _ticker;
  Duration? _lastTick;

  double _rotationAngle = 0.0;
  double _autoSpeedRadPerSec = _autoDefaultSpeed;

  bool _isDragging = false;
  double _dragStartX = 0.0;
  double _dragStartAngle = 0.0;

  FrictionSimulation? _inertiaSimulation;
  double _inertiaElapsedSeconds = 0.0;
  double _lastInertiaDelta = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTickerMode();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateTickerMode() {
    final enabled = TickerMode.of(context);
    if (!enabled && _ticker.isActive) {
      _ticker.stop();
    } else if (enabled && !_ticker.isActive) {
      _lastTick = null;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == null) {
      _lastTick = elapsed;
      return;
    }

    final dtSeconds =
        (elapsed - _lastTick!).inMicroseconds.toDouble() / 1000000.0;
    _lastTick = elapsed;

    if (_isDragging) return;

    var changed = false;

    _rotationAngle += _autoSpeedRadPerSec * dtSeconds;
    changed = true;

    final simulation = _inertiaSimulation;
    if (simulation != null) {
      _inertiaElapsedSeconds += dtSeconds;
      final newDelta = simulation.x(_inertiaElapsedSeconds);
      _rotationAngle += (newDelta - _lastInertiaDelta);
      _lastInertiaDelta = newDelta;
      changed = true;

      if (simulation.dx(_inertiaElapsedSeconds).abs() < _inertiaStopVelocity) {
        _inertiaSimulation = null;
      }
    }

    if (changed && mounted) {
      setState(() {});
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _inertiaSimulation = null;
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartAngle = _rotationAngle;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final deltaX = details.globalPosition.dx - _dragStartX;
    setState(() {
      _rotationAngle = _dragStartAngle + deltaX * _dragSensitivity;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final velocityRadPerSec =
        details.velocity.pixelsPerSecond.dx * _dragSensitivity;

    if (velocityRadPerSec.abs() > 0.05) {
      _inertiaSimulation = FrictionSimulation(_inertiaDrag, 0.0, velocityRadPerSec);
      _inertiaElapsedSeconds = 0.0;
      _lastInertiaDelta = 0.0;

      if (details.velocity.pixelsPerSecond.dx.abs() > 300) {
        _autoSpeedRadPerSec =
            (velocityRadPerSec * 0.06).clamp(-_autoSpeedClamp, _autoSpeedClamp);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateTickerMode();

    final diameter =
        widget.radius * 2 + math.max(widget.itemWidth, widget.itemHeight);

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.centerChild != null) widget.centerChild!,
            ..._buildMenuItems(_rotationAngle),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(double rotation) {
    final itemCount = math.min(widget.menuItems.length, 6);
    if (itemCount <= 0) return const [];

    final items = <_MenuItem3D>[];

    for (int i = 0; i < itemCount; i++) {
      final baseAngle = (2 * math.pi / itemCount) * i;
      final angle = baseAngle + rotation;

      final depth = ((math.cos(angle) + 1) / 2).clamp(0.0, 1.0);
      items.add(_MenuItem3D(depth: depth, child: _buildMenuItem(i, angle, depth)));
    }

    items.sort((a, b) => a.depth.compareTo(b.depth));
    return items.map((e) => e.child).toList(growable: false);
  }

  Widget _buildMenuItem(int index, double angle, double depth) {
    final data = widget.menuItems[index];

    final opacity =
        (_minBackOpacity + (1 - _minBackOpacity) * depth).clamp(0.0, 1.0);
    final scale = _minBackScale + (1 - _minBackScale) * depth;

    final orbitMatrix = Matrix4.identity()
      ..setEntry(3, 2, _perspective)
      ..rotateY(angle)
      ..translate(0.0, 0.0, -widget.radius);

    final faceCameraMatrix = Matrix4.identity()..rotateY(-angle);

    return Transform(
      transform: orbitMatrix,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Transform(
            transform: faceCameraMatrix,
            alignment: Alignment.center,
            child: HexCrystalMenuItem(
              title: data.title,
              subtitle: data.subtitle,
              icon: data.icon,
              tintColor: data.color ?? const Color(0xFF00E5FF),
              onTap: data.onTap,
              width: widget.itemWidth,
              height: widget.itemHeight,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem3D {
  const _MenuItem3D({required this.depth, required this.child});

  final double depth;
  final Widget child;
}

/// 菜单数据模型
class MenuData {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  MenuData({
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  });
}

