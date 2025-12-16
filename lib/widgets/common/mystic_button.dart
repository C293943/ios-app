import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'dart:ui';

class MysticButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline;

  const MysticButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: isOutline ? [] : [
          BoxShadow(
            color: AppTheme.accentJade.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: isOutline ? null : LinearGradient(
                colors: [
                  AppTheme.accentJade.withOpacity(0.8),
                  AppTheme.accentJade.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppTheme.accentJade.withOpacity(0.5),
                width: 1,
              ),
              color: isOutline ? Colors.transparent : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isOutline ? AppTheme.accentJade : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
