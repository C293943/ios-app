import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class MysticBackground extends StatelessWidget {
  final Widget child;

  const MysticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.voidBackground, // Deep Blue-Black
            AppTheme.inkGreen,       // Ink Green
            AppTheme.voidBackground, // Fade back to void at bottom
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Optional: Add subtle noise or nebula overlay images here
          
          // Main content
          SafeArea(child: child),
        ],
      ),
    );
  }
}
