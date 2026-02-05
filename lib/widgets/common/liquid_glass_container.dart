import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 液态玻璃容器变体
enum LiquidGlassVariant {
  /// 默认 - 适中的效果
  standard,
  /// 高级 - 更强的模糊和发光
  premium,
  /// 微妙 - 轻微的效果
  subtle,
  /// 导航栏 - 专为导航栏优化
  navigation,
}

/// 液态玻璃容器 - 高级玻璃形态效果
/// 
/// 特性：
/// - 多层玻璃深度（外边框、内高光、深度阴影）
/// - 动态模糊 (backdrop-filter)
/// - 虹彩边缘效果
/// - 可选的脉冲动画
/// - 浅色/深色主题自动适配
class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final LiquidGlassVariant variant;
  final double blurSigma;
  final Color? glowColor;
  final bool enablePulse;
  final bool showIridescent;
  final double glowIntensity;
  final bool elevated;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusLg,
    this.onTap,
    this.variant = LiquidGlassVariant.standard,
    this.blurSigma = AppTheme.blurStandard,
    this.glowColor,
    this.enablePulse = false,
    this.showIridescent = true,
    this.glowIntensity = 0.7,
    this.elevated = true,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTheme.animPulse,
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.enablePulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double get _effectiveBlur {
    switch (widget.variant) {
      case LiquidGlassVariant.premium:
        return AppTheme.blurPremium;
      case LiquidGlassVariant.subtle:
        return AppTheme.blurSubtle;
      case LiquidGlassVariant.navigation:
        return AppTheme.blurStandard;
      case LiquidGlassVariant.standard:
        return widget.blurSigma;
    }
  }

  double get _effectiveGlowIntensity {
    switch (widget.variant) {
      case LiquidGlassVariant.premium:
        return widget.glowIntensity * 1.5;
      case LiquidGlassVariant.subtle:
        return widget.glowIntensity * 0.4;
      case LiquidGlassVariant.navigation:
        return widget.glowIntensity * 0.8;
      case LiquidGlassVariant.standard:
        return widget.glowIntensity;
    }
  }

  Color get _effectiveGlassBase {
    switch (widget.variant) {
      case LiquidGlassVariant.premium:
        return AppTheme.liquidGlassBase;
      case LiquidGlassVariant.subtle:
        return AppTheme.liquidGlassLight;
      case LiquidGlassVariant.navigation:
        return AppTheme.liquidGlassBase;
      case LiquidGlassVariant.standard:
        return AppTheme.liquidGlassBase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final effectiveGlowColor = widget.glowColor ?? AppTheme.getGlowColor();

    Widget container = AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseValue = widget.enablePulse ? _pulseAnimation.value : 1.0;
        
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: widget.elevated 
                ? _buildShadows(effectiveGlowColor, pulseValue)
                : null,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _effectiveBlur,
                sigmaY: _effectiveBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _effectiveGlassBase,
                  borderRadius: radius,
                ),
                child: Stack(
                  children: [
                    // 内层渐变 - 顶部高光到底部阴影
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: AppTheme.liquidGlassInnerGradient(
                              opacity: pulseValue,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 虹彩边框效果
                    if (widget.showIridescent)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _IridescentBorder(
                            borderRadius: widget.borderRadius,
                            intensity: _effectiveGlowIntensity * pulseValue,
                          ),
                        ),
                      ),

                    // 外边框
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            border: Border.all(
                              color: AppTheme.liquidGlassBorder.withOpacity(
                                0.25 + 0.2 * _effectiveGlowIntensity * pulseValue,
                              ),
                              width: AppTheme.borderStandard,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 内边框 - 深度层
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                widget.borderRadius - 1.5,
                              ),
                              border: Border.all(
                                color: AppTheme.liquidGlassBorderSoft,
                                width: AppTheme.borderThin,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 顶部高光条 - 增强玻璃质感
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 36,
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(widget.borderRadius),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.liquidTopHighlight(
                                intensity: pulseValue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 底部深度阴影
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 24,
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(widget.borderRadius),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.liquidBottomShadow(
                                intensity: pulseValue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: widget.padding ?? EdgeInsets.all(AppTheme.spacingMd),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: container,
      );
    }

    return container;
  }

  List<BoxShadow> _buildShadows(Color glowColor, double pulseValue) {
    return AppTheme.liquidGlassShadows(
      intensity: _effectiveGlowIntensity * pulseValue,
      glowColor: glowColor,
      elevated: widget.elevated,
    );
  }
}

/// 虹彩边框效果组件 - 增强版
class _IridescentBorder extends StatelessWidget {
  final double borderRadius;
  final double intensity;

  const _IridescentBorder({
    required this.borderRadius,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IridescentBorderPainter(
        borderRadius: borderRadius,
        intensity: intensity,
      ),
    );
  }
}

class _IridescentBorderPainter extends CustomPainter {
  final double borderRadius;
  final double intensity;

  _IridescentBorderPainter({
    required this.borderRadius,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // 使用 AppTheme 的虹彩渐变
    final gradient = SweepGradient(
      colors: [
        AppTheme.fluorescentCyan.withOpacity(0.4 * intensity),
        AppTheme.jadeGreen.withOpacity(0.35 * intensity),
        AppTheme.amberGold.withOpacity(0.25 * intensity),
        AppTheme.fluorescentCyan.withOpacity(0.4 * intensity),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppTheme.borderThick;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _IridescentBorderPainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// 流动光晕效果组件 - 可叠加在任何组件上
class LiquidGlowOverlay extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double intensity;
  final Duration duration;

  const LiquidGlowOverlay({
    super.key,
    required this.child,
    this.glowColor,
    this.intensity = 0.5,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<LiquidGlowOverlay> createState() => _LiquidGlowOverlayState();
}

class _LiquidGlowOverlayState extends State<LiquidGlowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _alignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(-1.0, -0.5),
          end: const Alignment(0.5, -0.8),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(0.5, -0.8),
          end: const Alignment(1.0, 0.0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: const Alignment(1.0, 0.0),
          end: const Alignment(-1.0, -0.5),
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.glowColor ?? AppTheme.jadeGreen;
    
    return AnimatedBuilder(
      animation: _alignmentAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: _alignmentAnimation.value,
                      radius: 0.8,
                      colors: [
                        color.withOpacity(0.15 * widget.intensity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
