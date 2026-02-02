import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

enum GlassVariant {
  jade,
  spirit,
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final GlassVariant variant;
  final double blurSigma;
  final Color? glowColor;

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
    this.blurSigma = 12,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    final baseColor =
        variant == GlassVariant.jade ? AppTheme.scrollPaper : AppTheme.spiritGlass;
    final outerBorderColor = AppTheme.amberGold.withOpacity(0.32);
    final innerBorderColor = AppTheme.glassInnerBorder;
    final highlightColor = AppTheme.glassHighlight;
    final effectiveGlowColor = glowColor ??
        (variant == GlassVariant.jade ? AppTheme.jadeGreen : AppTheme.fluorescentCyan);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: radius,
              boxShadow: AppTheme.qiGlowShadows(
                color: effectiveGlowColor,
                intensity: 0.85,
              ),
            ),
            child: Stack(
              children: [
                // Outer filigree hairline
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(color: outerBorderColor, width: 0.8),
                      ),
                    ),
                  ),
                ),

                // Inner dark line (double-border illusion)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(color: innerBorderColor, width: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top highlight (bezel)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 26,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            highlightColor,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: padding ?? const EdgeInsets.all(16.0),
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
}
