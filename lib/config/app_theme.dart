import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mystic Void Palette (虚空琉璃)
  static const Color cloudMistWhite = Color(0xFFDCEAF6); // 基调: 云霭白
  static const Color celestialCyan = Color(0xFF8FBBD9); // 过渡: 天青色
  static const Color deepVoidBlue = Color(0xFF365B85); // Deepened from #4A6FA5 for better contrast
  
  static const Color jadeGreen = Color(0xFFA8D8B9); // 疗愈: 淡玉绿
  static const Color muttonFatJade = Color(0xFFF0F4E3); // 温润: 羊脂白
  
  static const Color fluidGold = Color(0xFFEEDC82); // 指引: 流光金
  static const Color lotusPink = Color(0xFFFFB7B2); // 情感波动: 藕荷粉

  // Legacy/Compatibility Colors
  static const Color primaryDeepIndigo = Color(0xFF1A237E);
  static const Color primaryBlack = Color(0xFF1A2633); // Darker black-blue
  static const Color accentJade = jadeGreen;
  static const Color accentGold = fluidGold;
  static const Color surfaceGlass = Color(0x1AFFFFFF); // Glassmorphism

  static ThemeData get mysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, 
      scaffoldBackgroundColor: cloudMistWhite,
      
      // Specialized Date/Time Picker Themes for "Mystic" Feel
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cloudMistWhite,
        headerBackgroundColor: deepVoidBlue,
        headerForegroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        dayStyle: GoogleFonts.notoSerifSc(fontSize: 14),
        yearStyle: GoogleFonts.notoSerifSc(fontSize: 14),
        weekdayStyle: GoogleFonts.notoSerifSc(color: deepVoidBlue.withOpacity(0.7)),
        dayForegroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return Colors.white;
          return primaryBlack;
        }),
        todayBackgroundColor: MaterialStateProperty.all(jadeGreen.withOpacity(0.3)),
        todayForegroundColor: MaterialStateProperty.all(deepVoidBlue),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cloudMistWhite,
        hourMinuteColor: deepVoidBlue.withOpacity(0.1),
        hourMinuteTextColor: deepVoidBlue,
        dayPeriodColor: jadeGreen.withOpacity(0.2),
        dayPeriodTextColor: deepVoidBlue,
        dialHandColor: jadeGreen,
        dialBackgroundColor: deepVoidBlue.withOpacity(0.05),
        entryModeIconColor: deepVoidBlue,
      ),
      
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.notoSerifSc(
          color: const Color(0xFF1A2633), // Darker text
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.notoSerifSc(
          color: const Color(0xFF1A2633),
          fontSize: 18,
        ),
        displayLarge: GoogleFonts.notoSerifSc(
          color: deepVoidBlue,
          fontWeight: FontWeight.w400, // Slightly bolder
        ),
        titleMedium: GoogleFonts.notoSerifSc(
          color: const Color(0xFF1A2633),
          fontWeight: FontWeight.w600,
        ),
      ),
      
      colorScheme: const ColorScheme.light(
        primary: deepVoidBlue, // Switched to Deep Void as primary for better active element contrast
        secondary: jadeGreen,
        surface: Colors.white24, // Touched up for dialogs
        onSurface: Color(0xFF1A2633),
        background: cloudMistWhite,
        onBackground: Color(0xFF1A2633),
      ),
    );
  }
}
