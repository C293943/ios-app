import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class SpiritNoteScreen extends StatelessWidget {
  const SpiritNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.l10n.spiritNotes),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.voidGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [

              // 笔记列表
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      date: context.l10n.noteSampleDate1,
                      content: context.l10n.noteSampleContent,
                      isSelected: true,
                    ),
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      date: context.l10n.noteSampleDate1,
                      content: context.l10n.noteSampleContent,
                    ),
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      date: context.l10n.noteSampleDate2,
                      content: context.l10n.noteSampleContent,
                    ),
                    const SizedBox(height: 16),
                    _buildNoteItem(
                      date: context.l10n.noteSampleDate1,
                      content: context.l10n.noteSampleContent,
                    ),
                  ],
                ),
              ),

              // 底部删除按钮
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.fluorescentCyan.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      context.l10n.delete,
                      style: TextStyle(
                        color: AppTheme.voidBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem({
    required String date,
    required String content,
    bool isSelected = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.fluorescentCyan.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(16),
        variant: GlassVariant.spirit,
        glowColor: isSelected ? AppTheme.fluorescentCyan : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: AppTheme.fluorescentCyan,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: AppTheme.inkText.withOpacity(0.8),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
