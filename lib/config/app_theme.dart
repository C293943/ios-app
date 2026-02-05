import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/models/avatar_theme_config.dart';

/// 🎨 Mystic Void Palette - Design System
/// 包含 "幽冥玄虚" (Dark) 和 "昆仑云境" (Light) 两套视觉体系
class AppTheme {
  // 私有构造，防止实例化
  AppTheme._();

  static bool _isDark = true;

  static void setThemeMode(AvatarThemeMode mode) {
    _isDark = mode == AvatarThemeMode.dark;
  }

  static bool get isDark => _isDark;

  // ===========================================================================
  // 🟢 基础色板 (Primitives) - 物理颜色定义
  // ===========================================================================

  // --- 灵气青 (Spirit Cyan) ---
  static const Color _cyanGlow = Color(0xFF22D3EE); // 高亮荧光
  static const Color _cyanDeep = Color(0xFF0E7490); // 深层灵力
  static const Color _cyanInk  = Color(0xFF155E75); // 水墨青 (浅色模式主色)

  // --- 翡翠绿 (Mystical Jade) ---
  static const Color _jadeLight = Color(0xFF4ADE80); // 翡翠亮色
  static const Color _jadeDeep  = Color(0xFF14532D); // 翡翠深色

  // --- 鎏金 (Champagne Gold) ---
  static const Color _goldBright = Color(0xFFFCD34D); // 亮金
  static const Color _goldMuted  = Color(0xFFC8AA6E); // 哑光金 (主装饰色)
  static const Color _bronzeText = Color(0xFF785C32); // 古铜色 (浅色模式高对比文字)
  static const Color _bronzeDeep = Color(0xFF4E3F20); // 深古铜

  // --- 背景基调 (Void / Cloud) ---
  static const Color _voidDark    = Color(0xFF0B181B); // 深渊黑
  static const Color _voidSurface = Color(0xFF13282C); // 深层表面
  
  // 浅色模式背景优化：更纯净的灰白，带极淡的青色倾向，去除浑浊感
  static const Color _cloudPaper  = Color(0xFFFAFCFD); 
  static const Color _jadeWhite   = Color(0xFFFFFFFF); 
  static const Color _cloudDeep   = Color(0xFFF1F5F9); 

  static const Color _jadeGlassBase = Color(0xCC0F2222); // Jade Glass base

  // --- 墨色 (Ink / Text) ---
  static const Color _inkDark     = Color(0xFF0F172A); // 浓墨 (浅色模式主字)
  static const Color _inkLight    = Color(0xFF94A3B8); // 淡墨
  static const Color _textWhite   = Color(0xFFF2F4F5); // 深色模式主字

  // --- 特殊色 (Special) ---
  static const Color _lotusPink   = Color(0xFFFFB7B2); // 莲花粉 (用于兼容)
  static const Color _lotusPinkLight = Color(0xFFE5A6A2);

  // ===========================================================================
  // 📏 Design System Constants (设计规范常量) - 布局与尺寸
  // ===========================================================================

  /// 间距规范
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  /// 圆角规范
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  /// 模糊度规范 - Liquid Glass
  static const double blurSubtle = 8.0;
  static const double blurMd = 16.0;
  static const double blurStandard = 20.0;
  static const double blurLg = 28.0;
  static const double blurPremium = 32.0;
  static const double blurIntense = 48.0;

  /// 边框宽度
  static const double borderThin = 0.5;
  static const double borderStandard = 1.0;
  static const double borderThick = 1.5;
  static const double borderMedium = 1.2; // 兼容旧代码

  /// 动画时长 (兼容旧代码)
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animStandard = Duration(milliseconds: 400); // 旧代码用400ms
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animPulse = Duration(milliseconds: 2000);

  /// 动画时长毫秒值 (用于 Duration(milliseconds: x) 场景)
  static const int animNormal = 300;

  // ===========================================================================
  // 🎭 语义化颜色 Accessors (兼容旧 API)
  // ===========================================================================

  static Color get voidBackground => _isDark ? _voidDark : _cloudPaper;
  static Color get inkGreen => _isDark ? _voidSurface : _cloudDeep;
  static Color get voidDeeper => _isDark ? const Color(0xFF091214) : _cloudDeep;
  
  // Accents
  static Color get fluorescentCyan => _isDark ? _cyanGlow : _cyanInk;
  static Color get jadeGreen => _isDark ? _jadeLight : _jadeDeep;
  static Color get amberGold => _isDark ? _goldMuted : _bronzeText;
  static Color get warmYellow => _isDark ? _goldBright : _bronzeDeep;

  // Text
  static Color get inkText => _isDark ? _textWhite : _inkDark;
  static Color get softGrayText => _isDark 
      ? Colors.white.withValues(alpha: 0.5) 
      : _inkDark.withValues(alpha: 0.6);

  // Surfaces
  static Color get spiritGlass => _isDark 
      ? _voidSurface.withValues(alpha: 0.8) 
      : _jadeWhite.withValues(alpha: 0.9);
      
  static Color get scrollBorder => _isDark 
      ? _goldMuted.withValues(alpha: 0.4) 
      : _bronzeText.withValues(alpha: 0.2);

  // Legacy Aliases (保留以兼容现有代码)
  static Color get electricBlue => _cyanDeep;
  static Color get bronzeGold => _goldMuted;
  static Color get deepSpaceBlue => _isDark ? const Color(0xFF0B1026) : const Color(0xFFE6EEF2);
  static Color get pureBlack => _isDark ? Colors.black : const Color(0xFF0B0F10);
  
  static Color get lotusPink => _isDark ? _lotusPink : _lotusPinkLight;
  static Color get moonHalo => warmYellow;
  static Color get mountainMist => _isDark ? const Color(0xFF2C4E55) : const Color(0xFFB8C9CF);
  static Color get spiritJadeDim => _isDark ? const Color(0xFF1F4E4E) : const Color(0xFFDCEFE6);
  
  // 新增兼容性修复
  static Color get primaryDeepIndigo => voidBackground;
  static Color get spiritJade => jadeGreen;
  static Color get scrollPaper => _isDark ? _jadeGlassBase : _cloudPaper;
  static Color get fluidGold => amberGold;

  // ===========================================================================
  // 💧 Liquid Glass System 2.0 (液态玻璃系统 - 优化版)
  // ===========================================================================

  /// 液态玻璃基础色 - 增强通透感
  static Color get liquidGlassBase => _isDark
      ? const Color(0xFF0E1F24).withValues(alpha: 0.60) // Dark: 降低不透明度，增加通透
      : const Color(0xFFFFFFFF).withValues(alpha: 0.65); // Light: 纯白底，高通透

  /// 液态玻璃 - 更强透明度变体
  static Color get liquidGlassLight => _isDark
      ? const Color(0xFF152A30).withValues(alpha: 0.40)
      : const Color(0xFFFFFFFF).withValues(alpha: 0.40);

  /// 液态玻璃高光 - 顶部边缘微光 (减弱强度)
  static Color get liquidGlassHighlight => _isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.white.withValues(alpha: 0.60);

  /// 液态玻璃高光渐变起始色 (大幅减弱，避免金属感)
  static Color get liquidHighlightStart => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.40);

  /// 液态玻璃内阴影 - 移除脏感
  static Color get liquidGlassInnerShadow => _isDark
      ? Colors.black.withValues(alpha: 0.3)
      : const Color(0xFF0F172A).withValues(alpha: 0.03); // Light: 极淡的蓝灰色阴影

  /// 液态玻璃边框色
  static Color get liquidGlassBorder => _isDark
      ? const Color(0xFF4ADE80).withValues(alpha: 0.15) // 微弱的翡翠绿边框
      : const Color(0xFFCBD5E1).withValues(alpha: 0.30); // 浅色模式用淡灰边框

  /// 液态玻璃边框色 - 柔和版
  static Color get liquidGlassBorderSoft => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0xFFE2E8F0).withValues(alpha: 0.40);


  /// 液态玻璃发光色
  static Color get liquidGlow => _isDark
      ? _jadeLight.withValues(alpha: 0.4)
      : _cyanGlow.withValues(alpha: 0.3);
      
  /// 获取主题感知的发光颜色
  static Color getGlowColor({Color? custom}) {
    if (custom != null) return custom;
    return _isDark ? jadeGreen : fluorescentCyan;
  }

  /// 液态玻璃虹彩渐变 - 彩虹边缘效果
  static LinearGradient get liquidIridescentBorder => LinearGradient(
        colors: _isDark
            ? [
                _cyanGlow.withValues(alpha: 0.6),
                _jadeLight.withValues(alpha: 0.5),
                _goldMuted.withValues(alpha: 0.4),
                _cyanGlow.withValues(alpha: 0.6),
              ]
            : [
                const Color(0xFF00C8D4).withValues(alpha: 0.5),
                const Color(0xFF00D4A8).withValues(alpha: 0.4),
                const Color(0xFFD4A800).withValues(alpha: 0.3),
                const Color(0xFF00C8D4).withValues(alpha: 0.5),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// 液态玻璃装饰 - 完整的 BoxDecoration (UI-UX-Pro-Max 优化版)
  static BoxDecoration liquidGlassDecoration({
    double borderRadius = radiusLg, // 使用常量
    double borderWidth = borderThin, // 减细边框
    double glowIntensity = 0.6,
    bool showIridescent = true,
    bool elevated = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: liquidGlassBase,
      border: Border.all(
        color: showIridescent
            ? liquidGlassBorder.withValues(alpha: 0.3 + 0.2 * glowIntensity)
            : liquidGlassBorderSoft,
        width: borderWidth,
      ),
      boxShadow: elevated ? [
        // 外发光 (更柔和)
        BoxShadow(
          color: liquidGlow.withValues(alpha: (_isDark ? 0.15 : 0.1) * glowIntensity),
          blurRadius: 20,
          spreadRadius: -4,
        ),
        // 底部阴影 (更通透)
        BoxShadow(
          color: (_isDark ? Colors.black : const Color(0xFF64748B)).withValues(alpha: _isDark ? 0.4 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ] : [],
    );
  }

  /// 液态玻璃阴影 - 用于玻璃容器
  static List<BoxShadow> liquidGlassShadows({
    double intensity = 1.0,
    Color? glowColor,
    bool elevated = true,
  }) {
    if (!elevated) return [];
    final glow = glowColor ?? liquidGlow;
    return [
      // 柔和辉光
      BoxShadow(
        color: glow.withValues(alpha: (_isDark ? 0.15 : 0.08) * intensity),
        blurRadius: 24,
        spreadRadius: -4,
      ),
      // 投影
      BoxShadow(
        color: (_isDark ? Colors.black : const Color(0xFF475569)).withValues(alpha: _isDark ? 0.4 : 0.06),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
    ];
  }
  
  /// 液态玻璃内层渐变 - 顶部高光效果 (优化版：移除强烈渐变)
  static LinearGradient liquidGlassInnerGradient({double opacity = 1.0}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        // 顶部极淡的高光，几乎透明
        liquidHighlightStart.withValues(alpha: (_isDark ? 0.05 : 0.2) * opacity),
        Colors.transparent,
        // 底部极淡的阴影
        liquidGlassInnerShadow.withValues(alpha: (_isDark ? 0.2 : 0.02) * opacity),
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }

  /// 液态玻璃顶部高光条渐变 (优化版：更细更淡)
  static LinearGradient liquidTopHighlight({double intensity = 1.0}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(
          alpha: (_isDark ? 0.15 : 0.4) * intensity,
        ),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
  }

  /// 液态玻璃底部阴影渐变 (优化版：几乎不可见)
  static LinearGradient liquidBottomShadow({double intensity = 1.0}) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        liquidGlassInnerShadow.withValues(alpha: 0.1 * intensity),
        Colors.transparent,
      ],
    );
  }
  
  /// 流体波纹渐变 - 用于动态效果
  static RadialGradient liquidRippleGradient({
    Alignment center = Alignment.center,
    double radius = 0.8,
    double opacity = 0.25,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        fluorescentCyan.withValues(alpha: opacity * (_isDark ? 1.0 : 0.8)),
        jadeGreen.withValues(alpha: opacity * 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ===========================================================================
  // 🌈 Legacy Gradients & Effects (兼容旧 API)
  // ===========================================================================

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
        jadeGreen.withValues(alpha: opacity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7],
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
        color: glowColor.withValues(alpha: 0.18 + 0.22 * clamped),
        blurRadius: 18 + 14 * clamped,
        spreadRadius: -6,
        offset: const Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 24,
        spreadRadius: 0,
        offset: const Offset(0, 12),
      ),
    ];
  }

  // ===========================================================================
  // 🌓 ThemeData Factory
  // ===========================================================================

  static ThemeData get mysticTheme => darkTheme; // 别名兼容
  static ThemeData get mysticLightTheme => lightTheme; // 别名兼容

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      background: _voidDark,
      surface: _voidSurface,
      primary: _cyanGlow,
      onPrimary: _voidDark,
      secondary: _goldMuted,
      textPrimary: _textWhite,
      textSecondary: _textWhite.withValues(alpha: 0.7),
      borderColor: _goldMuted.withValues(alpha: 0.4),
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      background: _cloudPaper,
      surface: _jadeWhite,
      primary: _cyanInk,
      onPrimary: Colors.white,
      secondary: _bronzeText,
      textPrimary: _inkDark,
      textSecondary: _inkDark.withValues(alpha: 0.7),
      borderColor: _bronzeText.withValues(alpha: 0.2),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    // 字体系统 (Chinese Traditional Pairing)
    final textTheme = GoogleFonts.notoSansScTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ).copyWith(
      headlineLarge: GoogleFonts.zcoolXiaoWei(
        color: secondary,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.8,
      ),
      titleLarge: GoogleFonts.notoSerifSc(
        color: brightness == Brightness.dark ? _goldBright : secondary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      bodyMedium: GoogleFonts.notoSansSc(
        color: textPrimary.withValues(alpha: 0.92),
        fontSize: 16,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.notoSansSc(
        color: textSecondary,
        fontSize: 14,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: surface,
        onSurface: textPrimary,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
        background: background,
        onBackground: textPrimary,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.notoSerifSc(
          color: secondary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: 0.8),
        hintStyle: TextStyle(color: textPrimary.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.8),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ⚡ 动画与工具类 (Utilities)
// ===========================================================================

class AppAnim {
  // 遵循 UX 规范的时长 (150-300ms 微交互)
  static const Duration fast = Duration(milliseconds: 200);     // 点击/Hover
  static const Duration standard = Duration(milliseconds: 300); // 页面/Tab切换
  static const Duration slow = Duration(milliseconds: 500);     // 复杂展开/变形
  static const Duration pulse = Duration(milliseconds: 2000);   // 呼吸效果

  /// 智能动画时长：如果是用户开启了“减弱动态效果”，则返回 0
  static Duration getDuration(BuildContext context, Duration original) {
    bool reduceMotion = MediaQuery.of(context).disableAnimations;
    return reduceMotion ? Duration.zero : original;
  }
  
  /// 缓动曲线
  static const Curve liquidCurve = Curves.easeInOutCubicEmphasized;
}
