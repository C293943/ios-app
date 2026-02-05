import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

enum GlassVariant {
  jade,
  spirit,
  /// 液态玻璃变体 - 更强的模糊和高光效果
  liquid,
}

/// 玻璃容器组件 - 支持多种玻璃风格变体
/// 已升级支持液态玻璃设计系统
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final GlassVariant variant;
  final double? blurSigma;
  final Color? glowColor;
  final double glowIntensity;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.variant = GlassVariant.jade,
    this.blurSigma,
    this.glowColor,
    this.glowIntensity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);
    final effectiveBlur = blurSigma ?? _getDefaultBlur();

    final baseColor = _getBaseColor();
    final effectiveGlowColor = glowColor ?? _getDefaultGlowColor();

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // 主色发光
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.15 * glowIntensity),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          // 液态玻璃阴影
          ...AppTheme.liquidGlassShadows(),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: radius,
            ),
            child: Stack(
              children: [
                // 液态玻璃内部渐变
                if (variant == GlassVariant.liquid)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: AppTheme.liquidGlassInnerGradient(),
                        ),
                      ),
                    ),
                  ),

                // 顶部高光层
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 32,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: radius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.liquidTopHighlight(
                            intensity: variant == GlassVariant.liquid ? 0.8 : 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 边框层
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: variant == GlassVariant.liquid
                              ? AppTheme.liquidGlassBorder
                              : AppTheme.liquidGlassBorderSoft,
                          width: variant == GlassVariant.liquid
                              ? AppTheme.borderStandard
                              : AppTheme.borderThin,
                        ),
                      ),
                    ),
                  ),
                ),

                // 主色点缀渐变
                if (effectiveGlowColor != Colors.transparent)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              effectiveGlowColor.withOpacity(0.08),
                              Colors.transparent,
                              effectiveGlowColor.withOpacity(0.04),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: padding ?? EdgeInsets.all(AppTheme.spacingMd),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }

  double _getDefaultBlur() {
    switch (variant) {
      case GlassVariant.liquid:
        return AppTheme.blurPremium;
      case GlassVariant.spirit:
        return AppTheme.blurStandard;
      case GlassVariant.jade:
      default:
        return AppTheme.blurSubtle;
    }
  }

  Color _getBaseColor() {
    switch (variant) {
      case GlassVariant.liquid:
        return AppTheme.liquidGlassBase;
      case GlassVariant.spirit:
        return AppTheme.spiritGlass.withOpacity(0.6);
      case GlassVariant.jade:
      default:
        return AppTheme.liquidGlassLight;
    }
  }

  Color _getDefaultGlowColor() {
    switch (variant) {
      case GlassVariant.liquid:
        return AppTheme.fluorescentCyan;
      case GlassVariant.spirit:
        return AppTheme.fluorescentCyan;
      case GlassVariant.jade:
      default:
        return AppTheme.jadeGreen;
    }
  }
}
