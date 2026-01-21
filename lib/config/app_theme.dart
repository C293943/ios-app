import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mystic Void Palette (Xianxia Fantasy)
  //
  // 设计目标：幽深灵渊（深青）+ 玉质半透 + 古金丝纹 + 气机辉光

  // Background Core (Void)
  static const Color voidBackground = Color(0xFF0B181B); // Deep Teal Base
  static const Color inkGreen = Color(0xFF122A2E); // Depth Teal
  static const Color voidDeeper = Color(0xFF091214); // Near-black teal

  // Accents (Qi Flow)
  static const Color fluorescentCyan = Color(0xFF22D3EE); // Spirit Cyan
  static const Color electricBlue = Color(0xFF0EA5E9); // Supporting cyan-blue
  static const Color jadeGreen = Color(0xFF4ADE80); // Mystical Jade

  // Antique Gold Filigree (avoid bright yellow)
  static const Color amberGold = Color(0xFFC8AA6E); // Champagne Gold
  static const Color warmYellow = Color(0xFFFFEFB0); // Soft highlight gold
  static const Color bronzeGold = Color(0xFF8B6D43); // Dark Bronze

  // Legacy/Compatibility Aliases (保留旧命名，统一视觉实现)
  static const Color daiDeep = voidBackground;
  static const Color crowCyan = inkGreen;
  static const Color mountainMist = Color(0xFF2C4E55); // Keep for variety
  
  static const Color moonHalo = warmYellow;
  static const Color spiritJade = jadeGreen;
  static const Color spiritJadeDim = Color(0xFF1F4E4E);
  
  // UI Controls / Materials
  static const Color inkText = Color(0xFFF2F4F5); // Readable on void
  static const Color scrollPaper = Color(0xCC0F2222); // Jade Glass base
  static const Color spiritGlass = Color(0xCC0F1C20); // Dark Spirit Glass
  static const Color scrollBorder = Color(0x66C8AA6E); // Antique gold hairline
  static const Color cloudMistWhite = warmYellow;
  static const Color fluidGold = amberGold;
  static const Color lotusPink = Color(0xFFFFB7B2);
  static const Color celestialCyan = fluorescentCyan;
  static const Color primaryDeepIndigo = voidBackground;
  static const Color primaryBlack = voidBackground;
  static const Color deepVoidBlue = voidBackground;
  static const Color accentJade = fluorescentCyan;
  // jadeGreen 已在上方定义为 Mystical Jade

  // Gradients (统一背景与材质层)
  static const LinearGradient voidGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      voidDeeper,
      voidBackground,
      inkGreen,
      voidDeeper,
    ],
    stops: [0.0, 0.25, 0.7, 1.0],
  );

  static RadialGradient fogGradient({
    Alignment center = Alignment.center,
    double opacity = 0.18,
    double radius = 1.2,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        jadeGreen.withOpacity(opacity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7],
    );
  }

  static LinearGradient spiritStoneGradient({double intensity = 1.0}) {
    final clamped = intensity.clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        inkGreen.withOpacity(0.95),
        voidDeeper.withOpacity(0.95),
        inkGreen.withOpacity(0.85 + 0.1 * clamped),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }

  static List<BoxShadow> qiGlowShadows({
    Color color = jadeGreen,
    double intensity = 1.0,
  }) {
    final clamped = intensity.clamp(0.0, 1.0);
    return [
      BoxShadow(
        color: color.withOpacity(0.18 + 0.22 * clamped),
        blurRadius: 18 + 14 * clamped,
        spreadRadius: -6,
        offset: const Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBackground,
      
      // Typography: Title=书卷感，Body=可读性优先
      textTheme: GoogleFonts.notoSansScTextTheme().apply(
        bodyColor: inkText,
        displayColor: inkText,
      ).copyWith(
        headlineLarge: GoogleFonts.zcoolXiaoWei(
          color: warmYellow,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.8,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          color: warmYellow,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyMedium: GoogleFonts.notoSansSc(
          color: inkText.withOpacity(0.92),
          fontSize: 16,
          height: 1.55,
        ),
      ),
      
      colorScheme: const ColorScheme.dark(
        primary: jadeGreen,
        secondary: amberGold,
        surface: spiritGlass,
        background: voidBackground,
        onBackground: inkText,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: spiritGlass,
        hintStyle: TextStyle(color: inkText.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: scrollBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: scrollBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: jadeGreen, width: 1.2),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: inkText,
        titleTextStyle: GoogleFonts.notoSerifSc(
          color: warmYellow,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
