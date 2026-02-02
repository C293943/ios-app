import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '关于我们',
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GlassContainer(
              variant: GlassVariant.spirit,
              blurSigma: 16,
              glowColor: AppTheme.jadeGreen,
              borderRadius: BorderRadius.circular(22),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.jadeGreen.withOpacity(0.1),
                      border: Border.all(color: AppTheme.jadeGreen, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.jadeGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppTheme.jadeGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '元神',
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppTheme.inkText.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '以科技之力，探寻东方神秘文化。\n为您提供个性化的运势分析与灵性陪伴。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.inkText.withOpacity(0.9),
                      height: 1.8,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    '© 2026 Primordial Spirit Team',
                    style: TextStyle(
                      color: AppTheme.inkText.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
