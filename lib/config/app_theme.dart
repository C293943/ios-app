import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mystic Void Palette (虚空琉璃)
  static const Color cloudMistWhite = Color(0xFFDCEAF6); // 基调: 云霭白
  static const Color celestialCyan = Color(0xFF8FBBD9); // 过渡: 天青色
  static const Color deepVoidBlue = Color(0xFF4A6FA5); // 深层情绪: 深海蓝
  
  static const Color jadeGreen = Color(0xFFA8D8B9); // 疗愈: 淡玉绿
  static const Color muttonFatJade = Color(0xFFF0F4E3); // 温润: 羊脂白
  
  static const Color fluidGold = Color(0xFFEEDC82); // 指引: 流光金
  static const Color lotusPink = Color(0xFFFFB7B2); // 情感波动: 藕荷粉

  // Legacy/Compatibility Colors
  static const Color primaryDeepIndigo = Color(0xFF1A237E);
  static const Color primaryBlack = Color(0xFF0A0E17);
  static const Color accentJade = jadeGreen;
  static const Color accentGold = fluidGold;
  static const Color surfaceGlass = Color(0x1AFFFFFF); // Glassmorphism

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // Changing to light base for "Cloud Mist" feel, but controlling colors manually or will switch to dark if "Void" implies dark.
      // The user description "Cloud Mist White" and "Celestial Cyan" implies a lighter, airy feel, BUT "Deep Void" implies depth.
      // "降低焦虑...心率下降" -> likely soft light or very soft dark.
      // Given "Cloud Mist White" is the base key, Light mode seems more appropriate for the "Mist" feel, with Dark accents.
      
      scaffoldBackgroundColor: cloudMistWhite,
      
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.notoSerifSc(
          color: const Color(0xFF2C3E50), // 深灰蓝 for text
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.notoSerifSc(
          color: const Color(0xFF2C3E50),
          fontSize: 18,
        ),
        displayLarge: GoogleFonts.notoSerifSc(
          color: deepVoidBlue,
          fontWeight: FontWeight.w300,
        ),
        titleMedium: GoogleFonts.notoSerifSc(
          color: const Color(0xFF2C3E50),
          fontWeight: FontWeight.w500,
        ),
      ),
      
      colorScheme: const ColorScheme.light(
        primary: celestialCyan,
        secondary: fluidGold,
        surface: Colors.transparent, // For glass effect layers mainly
        onSurface: Color(0xFF2C3E50),
        background: cloudMistWhite,
        onBackground: Color(0xFF2C3E50),
      ),
    );
  }
}
