import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/language_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  static final List<Map<String, dynamic>> _languages = [
    {'code': 'zh', 'country': 'CN', 'name': '简体中文', 'nativeName': '简体中文'},
    {'code': 'en', 'country': null, 'name': 'English', 'nativeName': 'English'},
    // Add other languages if supported by AppLocalizations
  ];

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    final currentLocale = languageService.currentLocale;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '语言选择',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.warmYellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _languages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final String langCode = lang['code'];
              final String? countryCode = lang['country'];
              
              final bool isSelected = currentLocale.languageCode == langCode &&
                  (countryCode == null || currentLocale.countryCode == countryCode);
              
              return GlassContainer(
                variant: GlassVariant.spirit,
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  languageService.setLocale(Locale(langCode, countryCode));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang['nativeName']!,
                              style: TextStyle(
                                color: isSelected ? AppTheme.warmYellow : AppTheme.inkText,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (lang['name'] != lang['nativeName'])
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    color: AppTheme.inkText.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.jadeGreen,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
