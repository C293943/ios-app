import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 液态玻璃风格输入框 - 如意卷轴主题
class RuyiInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmitted;
  final Color? accentColor;
  final IconData? prefixIcon;
  final Widget? suffixWidget;

  const RuyiInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
    this.accentColor,
    this.prefixIcon,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppTheme.amberGold;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. 液态玻璃卷轴端装饰
        Positioned(
          left: 0,
          child: _buildScrollEnd(effectiveAccent),
        ),
        Positioned(
          right: 0,
          child: _buildScrollEnd(effectiveAccent),
        ),

        // 2. 液态玻璃输入区域
        Container(
          height: 60,
          margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            boxShadow: [
              BoxShadow(
                color: effectiveAccent.withOpacity(0.12),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              ...AppTheme.liquidGlassShadows(),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppTheme.blurStandard,
                sigmaY: AppTheme.blurStandard,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.liquidGlassBase.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.liquidGlassBorder,
                      width: AppTheme.borderThin,
                    ),
                    bottom: BorderSide(
                      color: AppTheme.liquidGlassBorder,
                      width: AppTheme.borderThin,
                    ),
                    left: BorderSide(
                      color: AppTheme.liquidGlassBorderSoft,
                      width: AppTheme.borderThin,
                    ),
                    right: BorderSide(
                      color: AppTheme.liquidGlassBorderSoft,
                      width: AppTheme.borderThin,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      effectiveAccent.withOpacity(0.06),
                      Colors.transparent,
                      effectiveAccent.withOpacity(0.03),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        color: effectiveAccent.withOpacity(0.7),
                        size: 20,
                      ),
                      SizedBox(width: AppTheme.spacingMd),
                    ],
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                          color: AppTheme.inkText,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                        cursorColor: effectiveAccent,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            color: AppTheme.inkText.withOpacity(0.4),
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onSubmitted: (_) => onSubmitted?.call(),
                      ),
                    ),
                    if (suffixWidget != null) suffixWidget!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollEnd(Color accentColor) {
    return Container(
      width: 14,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[700]!,
            Colors.grey[500]!,
            Colors.grey[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: AppTheme.borderThin,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 顶端装饰
          Container(
            margin: EdgeInsets.only(top: AppTheme.spacingXs),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          // 底端装饰
          Container(
            margin: EdgeInsets.only(bottom: AppTheme.spacingXs),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

