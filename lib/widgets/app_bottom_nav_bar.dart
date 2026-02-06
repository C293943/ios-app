import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/l10n/l10n.dart';
import 'package:primordial_spirit/widgets/rive_nav/rive_nav_item.dart';
import 'package:primordial_spirit/widgets/rive_nav/rive_nav_icon_painter.dart';

enum AppNavTarget { home, divination, relationship, fortune, bazi }

/// 高阶交互动画底部导航栏
/// 
/// 设计亮点：
/// 1. 仙侠主题 CustomPaint 图标（灵力核心、卜象、连理、星宿、八卦）
/// 2. 多层动画状态机（idle/active/hover/transition）
/// 3. 点击弹性反馈 + 涟漪扩散 + 触觉振动
/// 4. 灵力指示灯 + 粒子环绕
/// 5. 液态玻璃容器 + 流动光效
/// 6. 五行灵气流（底部流动的灵力粒子带）
class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentTarget,
  });

  final AppNavTarget currentTarget;

  /// 统一的导航处理
  static void navigateTo(
      BuildContext context, AppNavTarget target, AppNavTarget current) {
    if (target == current) return;

    final route = switch (target) {
      AppNavTarget.home => AppRoutes.home,
      AppNavTarget.divination => AppRoutes.divination,
      AppNavTarget.relationship => AppRoutes.relationshipSelect,
      AppNavTarget.fortune => AppRoutes.fortune,
      AppNavTarget.bazi => AppRoutes.bazi,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with TickerProviderStateMixin {
  // 容器呼吸光效
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // 五行灵气流动画
  late AnimationController _qiFlowController;

  // 选中项切换时的光柱动画
  late AnimationController _lightBeamController;
  late Animation<double> _lightBeamCurve;

  int _prevIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentTarget.index;
    _prevIndex = _currentIndex;

    _glowController = AnimationController(
      vsync: this,
      duration: AppTheme.animPulse,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _qiFlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _lightBeamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _lightBeamCurve = CurvedAnimation(
      parent: _lightBeamController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTarget != oldWidget.currentTarget) {
      _prevIndex = oldWidget.currentTarget.index;
      _currentIndex = widget.currentTarget.index;
      _lightBeamController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _qiFlowController.dispose();
    _lightBeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            bottom: AppTheme.spacingMd,
            child: AnimatedBuilder(
              animation: Listenable.merge([_glowAnimation, _qiFlowController, _lightBeamCurve]),
              builder: (context, child) {
                return Container(
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: [
                      // 动态外发光
                      BoxShadow(
                        color: AppTheme.liquidGlow.withOpacity(
                          0.18 * _glowAnimation.value,
                        ),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                      // 深度阴影
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                      // 虹彩边缘光
                      BoxShadow(
                        color: AppTheme.fluorescentCyan.withOpacity(
                          0.08 * _glowAnimation.value,
                        ),
                        blurRadius: 16,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: AppTheme.blurPremium,
                        sigmaY: AppTheme.blurPremium,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.liquidGlassBase,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Stack(
                          children: [
                            // 底层：五行灵气流
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusLg),
                                child: CustomPaint(
                                  painter: _QiFlowPainter(
                                    phase: _qiFlowController.value,
                                    glowIntensity: _glowAnimation.value,
                                    activeIndex: _currentIndex,
                                    activeColor: AppTheme.fluorescentCyan,
                                    secondaryColor: AppTheme.jadeGreen,
                                  ),
                                ),
                              ),
                            ),
                            // 内层渐变
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLg),
                                  gradient:
                                      AppTheme.liquidGlassInnerGradient(
                                    opacity: _glowAnimation.value,
                                  ),
                                ),
                              ),
                            ),
                            // 光柱过渡效果
                            if (_lightBeamController.isAnimating)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLg),
                                  child: CustomPaint(
                                    painter: _LightBeamPainter(
                                      fromIndex: _prevIndex,
                                      toIndex: _currentIndex,
                                      progress: _lightBeamCurve.value,
                                      color: AppTheme.fluorescentCyan,
                                      itemCount: 5,
                                    ),
                                  ),
                                ),
                              ),
                            // 顶部高光
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 24,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppTheme.radiusLg),
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.liquidTopHighlight(
                                      intensity: _glowAnimation.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 边框
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLg),
                                  border: Border.all(
                                    color: AppTheme.liquidGlassBorder
                                        .withOpacity(
                                      0.3 + 0.2 * _glowAnimation.value,
                                    ),
                                    width: AppTheme.borderStandard,
                                  ),
                                ),
                              ),
                            ),
                            // 内容：导航项
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSm,
                              ),
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                children: _buildNavItems(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    return [
      RiveNavItem(
        iconType: NavIconType.spirit,
        label: context.l10n.spiritName,
        isActive: widget.currentTarget == AppNavTarget.home,
        activeImageAsset: 'assets/images/home-active.png',
        activeImageSize: 64,
        activeImageOffsetY: -28,
        onTap: () => AppBottomNavBar.navigateTo(
            context, AppNavTarget.home, widget.currentTarget),
      ),
      RiveNavItem(
        iconType: NavIconType.divination,
        label: context.l10n.divinationTitle,
        isActive: widget.currentTarget == AppNavTarget.divination,
        onTap: () => AppBottomNavBar.navigateTo(
            context, AppNavTarget.divination, widget.currentTarget),
      ),
      RiveNavItem(
        iconType: NavIconType.relationship,
        label: context.l10n.navRelationship,
        isActive: widget.currentTarget == AppNavTarget.relationship,
        onTap: () => AppBottomNavBar.navigateTo(
            context, AppNavTarget.relationship, widget.currentTarget),
      ),
      RiveNavItem(
        iconType: NavIconType.fortune,
        label: context.l10n.navFortune,
        isActive: widget.currentTarget == AppNavTarget.fortune,
        onTap: () => AppBottomNavBar.navigateTo(
            context, AppNavTarget.fortune, widget.currentTarget),
      ),
      RiveNavItem(
        iconType: NavIconType.bazi,
        label: context.l10n.navBazi,
        isActive: widget.currentTarget == AppNavTarget.bazi,
        onTap: () => AppBottomNavBar.navigateTo(
            context, AppNavTarget.bazi, widget.currentTarget),
      ),
    ];
  }
}

/// 五行灵气流绘制器 - 导航栏底部流动的灵力粒子带
class _QiFlowPainter extends CustomPainter {
  final double phase;
  final double glowIntensity;
  final int activeIndex;
  final Color activeColor;
  final Color secondaryColor;

  _QiFlowPainter({
    required this.phase,
    required this.glowIntensity,
    required this.activeIndex,
    required this.activeColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 底部灵力流（sine 波浪）
    final wavePath = Path();
    final waveHeight = size.height * 0.08;
    final baseY = size.height * 0.85;

    wavePath.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 2) {
      final normalX = x / size.width;
      final wave = math.sin(normalX * math.pi * 4 + phase * math.pi * 2) *
          waveHeight *
          glowIntensity;
      wavePath.lineTo(x, baseY + wave);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          activeColor.withOpacity(0.06 * glowIntensity),
          secondaryColor.withOpacity(0.03 * glowIntensity),
          activeColor.withOpacity(0.06 * glowIntensity),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(wavePath, wavePaint);

    // 灵力聚集点（在激活 tab 下方显示更强光效）
    final itemWidth = size.width / 5;
    final activeX = itemWidth * activeIndex + itemWidth / 2;
    
    final focusPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          activeColor.withOpacity(0.12 * glowIntensity),
          activeColor.withOpacity(0.04 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(activeX, size.height * 0.5), radius: itemWidth * 0.8),
      );
    canvas.drawCircle(
      Offset(activeX, size.height * 0.5),
      itemWidth * 0.8,
      focusPaint,
    );

    // 漂浮粒子
    final random = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseSpeed = 0.3 + random.nextDouble() * 0.7;
      final x = (baseX + phase * size.width * baseSpeed) % size.width;
      final y = size.height * (0.3 + random.nextDouble() * 0.5) +
          math.sin(phase * math.pi * 2 + i * 0.8) * 4;
      final radius = 0.6 + random.nextDouble() * 0.8;
      final alpha = (0.1 + random.nextDouble() * 0.15) * glowIntensity;

      // 靠近激活项的粒子更亮
      final distToActive = (x - activeX).abs() / itemWidth;
      final boost = distToActive < 1.0 ? (1.0 - distToActive) * 0.15 : 0.0;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = activeColor.withOpacity((alpha + boost).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QiFlowPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.activeIndex != activeIndex;
  }
}

/// 光柱过渡效果绘制器 - tab 切换时的灵光流动
class _LightBeamPainter extends CustomPainter {
  final int fromIndex;
  final int toIndex;
  final double progress;
  final Color color;
  final int itemCount;

  _LightBeamPainter({
    required this.fromIndex,
    required this.toIndex,
    required this.progress,
    required this.color,
    required this.itemCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final itemWidth = size.width / itemCount;
    final fromX = itemWidth * fromIndex + itemWidth / 2;
    final toX = itemWidth * toIndex + itemWidth / 2;

    // 光柱当前位置（贝塞尔插值）
    final currentX = fromX + (toX - fromX) * progress;
    final beamWidth = itemWidth * 0.6 * (1.0 - (progress - 0.5).abs() * 2);

    if (beamWidth <= 0) return;

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.15 * (1 - progress)),
          color.withOpacity(0.08 * (1 - progress)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(currentX, size.height / 2),
        width: beamWidth,
        height: size.height,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, beamPaint);
  }

  @override
  bool shouldRepaint(covariant _LightBeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fromIndex != fromIndex ||
        oldDelegate.toIndex != toIndex;
  }
}
