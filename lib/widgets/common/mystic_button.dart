import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'dart:ui';

/// 液态玻璃风格按钮 - 神秘主题按钮组件
class MysticButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final double letterSpacing;
  final Color? accentColor;
  final IconData? icon;

  const MysticButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.isOutline = false,
    this.padding,
    this.fontSize = 16,
    this.letterSpacing = 1.5,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusFull);
    final glowColor = accentColor ?? (isOutline ? AppTheme.amberGold : AppTheme.jadeGreen);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.spacingXl,
      vertical: AppTheme.spacingMd,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // 主色发光
          BoxShadow(
            color: glowColor.withOpacity(isOutline ? 0.15 : 0.25),
            blurRadius: 16,
            spreadRadius: isOutline ? 0 : 2,
          ),
          // 液态玻璃阴影
          if (!isOutline) ...AppTheme.liquidGlassShadows(),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.blurSubtle,
            sigmaY: AppTheme.blurSubtle,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: isOutline 
                  ? Colors.transparent 
                  : AppTheme.liquidGlassBase.withOpacity(0.8),
              border: Border.all(
                color: glowColor.withOpacity(isOutline ? 0.5 : 0.6),
                width: isOutline ? AppTheme.borderStandard : AppTheme.borderThin,
              ),
              gradient: isOutline 
                  ? null 
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        glowColor.withOpacity(0.15),
                        Colors.transparent,
                        glowColor.withOpacity(0.08),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
            ),
            child: Stack(
              children: [
                // 顶部高光
                if (!isOutline)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 20,
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: radius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppTheme.liquidTopHighlight(intensity: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: radius,
                    splashColor: glowColor.withOpacity(0.2),
                    highlightColor: glowColor.withOpacity(0.1),
                    child: Padding(
                      padding: effectivePadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isOutline ? glowColor : AppTheme.inkText,
                              size: fontSize + 2,
                            ),
                            SizedBox(width: AppTheme.spacingSm),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: isOutline ? glowColor : AppTheme.inkText,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: letterSpacing,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
