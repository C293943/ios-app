import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';

  Locale _currentLocale = const Locale('zh', 'CN');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null) {
        _currentLocale = Locale(languageCode, countryCode);
      } else {
        // Default to zh_CN
        _currentLocale = const Locale('zh', 'CN');
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load language settings: $e');
      _currentLocale = const Locale('zh', 'CN');
      _isInitialized = true;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        await prefs.remove(_countryCodeKey);
      }
    } catch (e) {
      debugPrint('Failed to save language settings: $e');
    }
  }
}
