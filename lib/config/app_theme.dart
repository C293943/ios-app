import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mystic Void Palette (Digital Xianxia)
  
  // Background Core
  static const Color voidBackground = Color(0xFF050A10);  // Deep Blue-Black (Void)
  static const Color inkGreen = Color(0xFF0F2420);        // Ink Green (Universe depth)
  
  // Accents
  static const Color fluorescentCyan = Color(0xFF00FFD1); // Fluorescent Cyan (Tech/Energy)
  static const Color electricBlue = Color(0xFF00A2FF);    // Electric Blue (Tech)
  static const Color amberGold = Color(0xFFFFBF00);       // Amber Gold (Reiki/Holy)
  static const Color warmYellow = Color(0xFFFFEDA0);      // Warm Yellow (Slightly softer gold)

  // Legacy/Compatibility Aliases
  static const Color daiDeep = voidBackground;
  static const Color crowCyan = inkGreen;
  static const Color mountainMist = Color(0xFF2C4E55); // Keep for variety
  
  static const Color moonHalo = warmYellow;
  static const Color spiritJade = fluorescentCyan;
  static const Color spiritJadeDim = Color(0xFF005949);
  
  // UI Controls
  static const Color scrollPaper = Color(0x0FFFFFFF); // More transparent
  static const Color scrollBorder = Color(0x4D00FFD1); // Cyan tint border
  static const Color inkText = Color(0xFFF0F0F0); // Bright text
  static const Color cloudMistWhite = warmYellow;
  static const Color fluidGold = amberGold;
  static const Color lotusPink = Color(0xFFFFB7B2);
  static const Color celestialCyan = fluorescentCyan;
  static const Color primaryDeepIndigo = voidBackground;
  static const Color primaryBlack = voidBackground;
  static const Color deepVoidBlue = voidBackground;
  static const Color accentJade = fluorescentCyan;
  static const Color jadeGreen = fluorescentCyan;

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBackground,
      
      // Font: Crisp, Modern yet Mystical
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: inkText,
        displayColor: fluorescentCyan,
      ).copyWith(
        headlineLarge: GoogleFonts.zcoolXiaoWei( // Or similar mystical font if available, else Outfit
          color: fluorescentCyan,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: inkText.withOpacity(0.9),
          fontSize: 16,
          height: 1.5,
        ),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: fluorescentCyan,
        secondary: amberGold,
        surface: Color(0x0DFFFFFF),
        background: voidBackground,
        onBackground: inkText,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scrollPaper,
        hintStyle: TextStyle(color: inkText.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: scrollBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: scrollBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: fluorescentCyan, width: 1.0),
        ),
      ),
    );
  }
}
