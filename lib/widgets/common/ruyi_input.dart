import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

class RuyiInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmitted;

  const RuyiInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Scroll Ends (Decoration)
        Positioned(
          left: 0,
          child: _buildScrollEnd(),
        ),
        Positioned(
          right: 0,
          child: _buildScrollEnd(),
        ),

        // 2. Main Input Area (Paper)
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.scrollPaper,
            borderRadius: BorderRadius.circular(4), // Slight curve, mostly flat like paper
            border: Border(
              top: BorderSide(color: AppTheme.scrollBorder.withOpacity(0.5), width: 1),
              bottom: BorderSide(color: AppTheme.scrollBorder.withOpacity(0.5), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: AppTheme.inkText, 
              fontSize: 16, 
              letterSpacing: 1.2
            ),
            cursorColor: AppTheme.spiritJade,
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
      ],
    );
  }

  Widget _buildScrollEnd() {
    return Container(
      width: 12, // Thin scroll cylinder
      height: 70, // Slightly taller than input
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[800]!,
            Colors.grey[600]!,
            Colors.grey[800]!,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cap details
          Container(height: 6, decoration: const BoxDecoration(color: AppTheme.moonHalo, shape: BoxShape.circle)),
          Container(height: 6, decoration: const BoxDecoration(color: AppTheme.moonHalo, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
