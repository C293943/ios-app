import 'package:flutter/material.dart';

enum AvatarThemeMode {
  light,
  dark,
}

class AvatarThemeConfig {
  const AvatarThemeConfig({
    required this.mode,
    required this.bgGradientStart,
    required this.bgGradientEnd,
    required this.glassColor,
    required this.glassBorder,
    required this.textColorPrimary,
    required this.textColorSecondary,
    required this.accentColor,
    required this.crystalAsset,
    required this.buttonGradient,
    required this.statNumberGradient,
  });

  final AvatarThemeMode mode;
  final Color bgGradientStart;
  final Color bgGradientEnd;
  final Color glassColor;
  final Color glassBorder;
  final Color textColorPrimary;
  final Color textColorSecondary;
  final Color accentColor;
  final String crystalAsset;
  final List<Color> buttonGradient;
  final Gradient statNumberGradient;

  bool get isLight => mode == AvatarThemeMode.light;

  static const String _crystalLightAsset = 'assets/images/back-0.png';
  static const String _crystalDarkAsset = 'assets/images/spirit-stone-egg.png';

  static AvatarThemeConfig fromMode(AvatarThemeMode mode) {
    switch (mode) {
      case AvatarThemeMode.light:
        return AvatarThemeConfig(
          mode: AvatarThemeMode.light,
          bgGradientStart: const Color(0xFFF0FCFF),
          bgGradientEnd: const Color(0xFFB9F2FF),
          glassColor: const Color(0x66FFFFFF),
          glassBorder: const Color(0x99FFFFFF),
          textColorPrimary: const Color(0xFF37474F),
          textColorSecondary: const Color(0xFF90A4AE),
          accentColor: const Color(0xFF00BCD4),
          crystalAsset: _crystalLightAsset,
          buttonGradient: const [
            Color(0xFFE0F7FA),
            Color(0xFFFFFFFF),
          ],
          statNumberGradient: const LinearGradient(
            colors: [
              Color(0xFF9C27B0),
              Color(0xFF00BCD4),
            ],
          ),
        );
      case AvatarThemeMode.dark:
        return AvatarThemeConfig(
          mode: AvatarThemeMode.dark,
          bgGradientStart: const Color(0xFF0B1026),
          bgGradientEnd: const Color(0xFF000000),
          glassColor: const Color(0x4D000000),
          glassBorder: const Color(0x1AFFFFFF),
          textColorPrimary: Colors.white,
          textColorSecondary: Colors.grey.shade400,
          accentColor: const Color(0xFFFFD700),
          crystalAsset: _crystalDarkAsset,
          buttonGradient: const [
            Color(0xFF2C3E50),
            Color(0xFF4B3621),
          ],
          statNumberGradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFB87333),
            ],
          ),
        );
    }
  }
}
