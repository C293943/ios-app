import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/avatar_theme_config.dart';

/// 主题管理服务 - 全局主题状态管理
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  AvatarThemeMode _themeMode = AvatarThemeMode.dark;
  bool _isInitialized = false;

  /// 当前主题模式
  AvatarThemeMode get themeMode => _themeMode;

  /// 是否为浅色模式
  bool get isLightMode => _themeMode == AvatarThemeMode.light;

  /// 是否为深色模式
  bool get isDarkMode => _themeMode == AvatarThemeMode.dark;

  /// 初始化主题服务
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);

      if (savedMode != null) {
        _themeMode = savedMode == 'light'
            ? AvatarThemeMode.light
            : AvatarThemeMode.dark;
      } else {
        // 默认使用深色模式
        _themeMode = AvatarThemeMode.dark;
      }

      AppTheme.setThemeMode(_themeMode);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // 发生错误时使用默认值
      _themeMode = AvatarThemeMode.dark;
      AppTheme.setThemeMode(_themeMode);
      _isInitialized = true;
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(AvatarThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    AppTheme.setThemeMode(mode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString().split('.').last);
    } catch (e) {
      // 持久化失败，但不影响主题切换
      debugPrint('Failed to save theme mode: $e');
    }

    notifyListeners();
  }

  /// 切换主题模式
  Future<void> toggleTheme() async {
    final newMode = _themeMode == AvatarThemeMode.light
        ? AvatarThemeMode.dark
        : AvatarThemeMode.light;
    await setThemeMode(newMode);
  }

  /// 获取当前主题配置
  AvatarThemeConfig get currentTheme {
    return AvatarThemeConfig.fromMode(_themeMode);
  }
}
