import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'dart:ui';

class MysticButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double letterSpacing;

  const MysticButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.isOutline = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    this.fontSize = 16,
    this.letterSpacing = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);
    final borderColor = AppTheme.amberGold.withOpacity(isOutline ? 0.45 : 0.65);
    final glowColor = isOutline ? AppTheme.amberGold : AppTheme.jadeGreen;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isOutline ? [] : AppTheme.qiGlowShadows(color: glowColor, intensity: 0.75),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: isOutline ? null : AppTheme.spiritStoneGradient(intensity: 1.0),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
              color: isOutline ? Colors.transparent : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: glowColor.withOpacity(0.18),
                highlightColor: glowColor.withOpacity(0.08),
                child: Padding(
                  padding: padding,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isOutline ? AppTheme.warmYellow : AppTheme.inkText,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
