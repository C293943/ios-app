import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/models/avatar_theme_config.dart';

class AppTheme {
  static bool _isDark = true;

  static void setThemeMode(AvatarThemeMode mode) {
    _isDark = mode == AvatarThemeMode.dark;
  }

  // Mystic Void Palette (Xianxia Fantasy)
  //
  // 设计目标：幽深灵渊（深青）+ 玉质半透 + 古金丝纹 + 气机荧光

  // Background Core (Void)
  static const Color _darkVoidBackground = Color(0xFF0B181B); // Deep Teal Base
  static const Color _darkInkGreen = Color(0xFF122A2E); // Depth Teal
  static const Color _darkVoidDeeper = Color(0xFF091214); // Near-black teal
  static const Color _darkDeepSpaceBlue = Color(0xFF0B1026); // Deep space blue
  static const Color _darkPureBlack = Color(0xFF000000); // Pure black

  static const Color _lightVoidBackground = Color(0xFFF6FBFD);
  static const Color _lightInkGreen = Color(0xFFE3F0F2);
  static const Color _lightVoidDeeper = Color(0xFFDDE8EC);
  static const Color _lightDeepSpaceBlue = Color(0xFFE6EEF2);
  static const Color _lightPureBlack = Color(0xFF0B0F10);

  static Color get voidBackground =>
      _isDark ? _darkVoidBackground : _lightVoidBackground;
  static Color get inkGreen => _isDark ? _darkInkGreen : _lightInkGreen;
  static Color get voidDeeper => _isDark ? _darkVoidDeeper : _lightVoidDeeper;
  static Color get deepSpaceBlue =>
      _isDark ? _darkDeepSpaceBlue : _lightDeepSpaceBlue;
  static Color get pureBlack => _isDark ? _darkPureBlack : _lightPureBlack;

  // Accents (Qi Flow)
  static const Color _darkFluorescentCyan = Color(0xFF22D3EE); // Spirit Cyan
  static const Color _darkElectricBlue = Color(0xFF0EA5E9); // Supporting cyan-blue
  static const Color _darkJadeGreen = Color(0xFF4ADE80); // Mystical Jade

  static const Color _lightFluorescentCyan = Color(0xFF0BB3C7);
  static const Color _lightElectricBlue = Color(0xFF1C8FC7);
  static const Color _lightJadeGreen = Color(0xFF27A86B);

  static Color get fluorescentCyan =>
      _isDark ? _darkFluorescentCyan : _lightFluorescentCyan;
  static Color get electricBlue =>
      _isDark ? _darkElectricBlue : _lightElectricBlue;
  static Color get jadeGreen => _isDark ? _darkJadeGreen : _lightJadeGreen;

  // Antique Gold Filigree (avoid bright yellow)
  static const Color _darkAmberGold = Color(0xFFC8AA6E); // Champagne Gold
  static const Color _darkWarmYellow = Color(0xFFFFEFB0); // Soft highlight gold
  static const Color _darkBronzeGold = Color(0xFF8B6D43); // Dark Bronze

  static const Color _lightAmberGold = Color(0xFFB08B4F);
  static const Color _lightWarmYellow = Color(0xFF4E3F20);
  static const Color _lightBronzeGold = Color(0xFF7C5A33);

  static Color get amberGold => _isDark ? _darkAmberGold : _lightAmberGold;
  static Color get warmYellow => _isDark ? _darkWarmYellow : _lightWarmYellow;
  static Color get bronzeGold => _isDark ? _darkBronzeGold : _lightBronzeGold;

  // Legacy/Compatibility Aliases (保留旧命名，统一视觉实现)
  static Color get daiDeep => voidBackground;
  static Color get crowCyan => inkGreen;
  static const Color _darkMountainMist = Color(0xFF2C4E55); // Keep for variety
  static const Color _lightMountainMist = Color(0xFFB8C9CF);
  static Color get mountainMist =>
      _isDark ? _darkMountainMist : _lightMountainMist;

  static Color get moonHalo => warmYellow;
  static Color get spiritJade => jadeGreen;
  static const Color _darkSpiritJadeDim = Color(0xFF1F4E4E);
  static const Color _lightSpiritJadeDim = Color(0xFFDCEFE6);
  static Color get spiritJadeDim =>
      _isDark ? _darkSpiritJadeDim : _lightSpiritJadeDim;

  // UI Controls / Materials
  static const Color _darkInkText = Color(0xFFF2F4F5); // Readable on void
  static const Color _lightInkText = Color(0xFF1F2A2E);
  static const Color _darkScrollPaper = Color(0xCC0F2222); // Jade Glass base
  static const Color _lightScrollPaper = Color(0xFFF4F7FA);
  static const Color _darkSpiritGlass = Color(0xCC0F1C20); // Dark Spirit Glass
  static const Color _lightSpiritGlass = Color(0xE6FFFFFF);
  static const Color _darkScrollBorder = Color(0x66C8AA6E); // Antique gold hairline
  static const Color _lightScrollBorder = Color(0x336B5A3A);
  static const Color _darkLotusPink = Color(0xFFFFB7B2);
  static const Color _lightLotusPink = Color(0xFFE5A6A2);
  static const Color _darkSoftGrayText = Color(0xFFAAAAAA);
  static const Color _lightSoftGrayText = Color(0xFF6B767A);
  static Color get glassInnerBorder => _isDark
      ? _darkPureBlack.withOpacity(0.45)
      : _lightPureBlack.withOpacity(0.08);
  static Color get glassHighlight => _isDark
      ? Colors.white.withOpacity(0.10)
      : Colors.white.withOpacity(0.65);


  static Color get inkText => _isDark ? _darkInkText : _lightInkText;
  static Color get scrollPaper =>
      _isDark ? _darkScrollPaper : _lightScrollPaper;
  static Color get spiritGlass =>
      _isDark ? _darkSpiritGlass : _lightSpiritGlass;
  static Color get scrollBorder =>
      _isDark ? _darkScrollBorder : _lightScrollBorder;
  static Color get cloudMistWhite => warmYellow;
  static Color get fluidGold => amberGold;
  static Color get lotusPink => _isDark ? _darkLotusPink : _lightLotusPink;
  static Color get celestialCyan => fluorescentCyan;
  static Color get primaryDeepIndigo => voidBackground;
  static Color get primaryBlack => voidBackground;
  static Color get deepVoidBlue => voidBackground;
  static Color get accentJade => fluorescentCyan;
  static Color get softGrayText =>
      _isDark ? _darkSoftGrayText : _lightSoftGrayText;
  // jadeGreen 已在上方定义为 Mystical Jade

  // Gradients (统一背景与材质层)
  static LinearGradient get voidGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        voidDeeper,
        voidBackground,
        inkGreen,
        voidDeeper,
      ],
      stops: const [0.0, 0.25, 0.7, 1.0],
    );
  }

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
    Color color = Colors.transparent,
    double intensity = 1.0,
  }) {
    final clamped = intensity.clamp(0.0, 1.0);
    final glowColor = color == Colors.transparent ? jadeGreen : color;
    return [
      BoxShadow(
        color: glowColor.withOpacity(0.18 + 0.22 * clamped),
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
      scaffoldBackgroundColor: _darkVoidBackground,

      // Typography: Title=书卷感，Body=可读性优先
      textTheme: GoogleFonts.notoSansScTextTheme().apply(
        bodyColor: _darkInkText,
        displayColor: _darkInkText,
      ).copyWith(
        headlineLarge: GoogleFonts.zcoolXiaoWei(
          color: _darkWarmYellow,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.8,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          color: _darkWarmYellow,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyMedium: GoogleFonts.notoSansSc(
          color: _darkInkText.withOpacity(0.92),
          fontSize: 16,
          height: 1.55,
        ),
      ),

      colorScheme: const ColorScheme.dark(
        primary: _darkJadeGreen,
        secondary: _darkAmberGold,
        surface: _darkSpiritGlass,
        background: _darkVoidBackground,
        onBackground: _darkInkText,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSpiritGlass,
        hintStyle: TextStyle(color: _darkInkText.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkScrollBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkScrollBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkJadeGreen, width: 1.2),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _darkInkText,
        titleTextStyle: GoogleFonts.notoSerifSc(
          color: _darkWarmYellow,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static ThemeData get mysticLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightVoidBackground,
      textTheme: GoogleFonts.notoSansScTextTheme().apply(
        bodyColor: _lightInkText,
        displayColor: _lightInkText,
      ).copyWith(
        headlineLarge: GoogleFonts.zcoolXiaoWei(
          color: _lightWarmYellow,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.8,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          color: _lightWarmYellow,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        bodyMedium: GoogleFonts.notoSansSc(
          color: _lightInkText,
          fontSize: 16,
          height: 1.55,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: _lightFluorescentCyan,
        secondary: _lightAmberGold,
        surface: _lightSpiritGlass,
        background: _lightVoidBackground,
        onBackground: _lightInkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSpiritGlass,
        hintStyle: TextStyle(color: _lightInkText.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightScrollBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightScrollBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _lightFluorescentCyan, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _lightInkText,
        titleTextStyle: GoogleFonts.notoSerifSc(
          color: _lightWarmYellow,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
