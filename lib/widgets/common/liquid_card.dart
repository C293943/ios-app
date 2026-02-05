import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 液态玻璃卡片 - 统一的卡片样式
/// 
/// 特性：
/// - 背景模糊效果
/// - 液态玻璃边框和高光
/// - 可选的主色调发光
/// - 主题自适应
class LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? accentColor;
  final double glowIntensity;
  final VoidCallback? onTap;
  final bool elevated;
  final bool compact;

  const LiquidCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.accentColor,
    this.glowIntensity = 0.15,
    this.onTap,
    this.elevated = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusLg;
    final effectiveAccent = accentColor ?? AppTheme.liquidGlow;
    final effectivePadding = padding ?? EdgeInsets.all(
      compact ? AppTheme.spacingMd : AppTheme.spacingLg,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          // 主色发光 - 大幅减弱
          if (glowIntensity > 0)
            BoxShadow(
              color: effectiveAccent.withOpacity(glowIntensity * (isDark ? 0.8 : 0.3)),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          // 深度阴影
          ...AppTheme.liquidGlassShadows(
            elevated: elevated, 
            intensity: isDark ? 1.0 : 0.5 // 浅色模式阴影减半
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: elevated ? AppTheme.blurPremium : AppTheme.blurStandard,
            sigmaY: elevated ? AppTheme.blurPremium : AppTheme.blurStandard,
          ),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              // 减少不透明度，增加毛玻璃感
              color: AppTheme.liquidGlassBase.withOpacity(elevated ? (isDark ? 0.6 : 0.4) : (isDark ? 0.4 : 0.2)),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: AppTheme.liquidGlassBorder.withOpacity(isDark ? 0.2 : 0.15),
                width: AppTheme.borderThin,
              ),
            ),
            child: Stack(
              children: [
                // 内部渐变层 - 几乎透明，仅保留极微弱的光感
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: AppTheme.liquidGlassInnerGradient(opacity: 0.5),
                      ),
                    ),
                  ),
                ),
                // 顶部高光 - 更加柔和
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.liquidTopHighlight(intensity: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                // 主色点缀
                if (accentColor != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              effectiveAccent.withOpacity(0.08),
                              Colors.transparent,
                              effectiveAccent.withOpacity(0.04),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                // 内容
                child,
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// 液态玻璃小卡片 - 用于网格布局中的小型信息卡片
class LiquidMiniCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;
  final VoidCallback? onTap;

  const LiquidMiniCard({
    super.key,
    required this.child,
    this.padding,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppTheme.liquidGlow;

    Widget card = Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppTheme.liquidGlassLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.liquidGlassBorderSoft,
          width: AppTheme.borderThin,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// 液态玻璃信息标签
class LiquidInfoTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final bool outlined;

  const LiquidInfoTag({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.jadeGreen;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : effectiveColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: effectiveColor.withOpacity(outlined ? 0.5 : 0.3),
          width: AppTheme.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveColor, size: 16),
            SizedBox(width: AppTheme.spacingXs),
          ],
          Text(
            text,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 液态玻璃分割线
class LiquidDivider extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const LiquidDivider({
    super.key,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppTheme.borderStandard,
      margin: margin ?? EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.liquidGlassBorder.withOpacity(0.5),
            AppTheme.liquidGlassBorder.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.15, 0.85, 1.0],
        ),
      ),
    );
  }
}
