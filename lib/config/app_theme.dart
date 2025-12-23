import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mystic Void Palette (虚空琉璃 - Night Valley Edition)
  
  // Background Core
  static const Color daiDeep = Color(0xFF0F1E24);  // 黛色 (Deep Cyan/Black base)
  static const Color crowCyan = Color(0xFF1C3A40); // 鸦青 (Lighter Cyan/Greenish)
  static const Color mountainMist = Color(0xFF2C4E55); // 远山 (Mountain Silhouette)
  
  // Accents
  static const Color moonHalo = Color(0xFFE8DCCA); // 月晕 (Pale dry gold/Bone white)
  static const Color spiritJade = Color(0xFF66FFCC); // 灵体 (Bright glowing jade)
  static const Color spiritJadeDim = Color(0xFF2A5A4E); // 灵体暗部
  
  // UI Controls
  static const Color scrollPaper = Color(0x1AFFFFFF); // 卷轴底色 (Glassy)
  static const Color scrollBorder = Color(0xFF8C9E9A); // 卷轴边框 (Muted metallic)
  static const Color inkText = Color(0xFFE0E0E0); // 墨色 (Text, inverted for dark mode)
  
  // Legacy/Compatibility Aliases (map old names to new palette)
  static const Color deepVoidBlue = crowCyan;       // Maps to crowCyan for contrast
  static const Color accentJade = spiritJade;       // Maps to spiritJade
  static const Color jadeGreen = spiritJade;        // Maps to spiritJade
  static const Color primaryDeepIndigo = daiDeep;   // Maps to daiDeep
  static const Color primaryBlack = daiDeep;        // Maps to daiDeep
  static const Color fluidGold = Color(0xFFEEDC82); // 流光金 (Keep for ripples)
  static const Color celestialCyan = mountainMist;  // Maps to mountainMist
  static const Color lotusPink = Color(0xFFFFB7B2); // 藕荷粉 (Keep original pink)
  static const Color cloudMistWhite = moonHalo;     // Maps to moonHalo

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Default to dark for this theme
      scaffoldBackgroundColor: daiDeep,
      
      // Font: Simulating "Shoujin" or "Calligraphy" where possible, falling back to Serif
      textTheme: GoogleFonts.notoSerifScTextTheme().apply(
        bodyColor: inkText,
        displayColor: moonHalo,
      ).copyWith(
        headlineLarge: GoogleFonts.notoSerifSc(
          color: moonHalo,
          fontWeight: FontWeight.w300,
          letterSpacing: 2.0,
        ),
        bodyMedium: GoogleFonts.notoSerifSc(
          color: inkText.withOpacity(0.9),
          fontSize: 16,
          height: 1.5,
        ),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: spiritJade,
        secondary: moonHalo,
        surface: Color(0x0DFFFFFF), // Very subtle surface
        background: daiDeep,
        onBackground: inkText,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scrollPaper,
        hintStyle: TextStyle(color: inkText.withOpacity(0.4), fontStyle: FontStyle.italic),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Placeholder for Ruyi shape
          borderSide: const BorderSide(color: scrollBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: scrollBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: spiritJade, width: 1.0),
        ),
      ),
    );
  }
}
