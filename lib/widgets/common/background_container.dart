import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.voidGradient),
      child: Stack(
        children: [
          // Optional: Add subtle particle or noise overlay here later
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.5),
                    radius: 0.8,
                    colors: [
                      AppTheme.jadeGreen,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
