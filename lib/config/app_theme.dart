import 'package:flutter/material.dart';

class AppTheme {
  // Mystic Void Palette
  static const Color primaryDeepIndigo = Color(0xFF1A237E); // Void base
  static const Color primaryBlack = Color(0xFF0A0E17); // Deepest void
  static const Color accentJade = Color(0xFF00BFA5); // Wood/Life spirit
  static const Color accentGold = Color(0xFFFFD700); // Divine guidance
  static const Color surfaceGlass = Color(0x1AFFFFFF); // Glassmorphism

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      fontFamily: 'PingFang SC', // As requested in original main.dart
      
      colorScheme: const ColorScheme.dark(
        primary: accentJade,
        secondary: accentGold,
        surface: primaryDeepIndigo,
        background: primaryBlack,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
          color: accentJade,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentJade.withOpacity(0.8),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
