import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';

class RelationshipHistoryScreen extends StatelessWidget {
  const RelationshipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final historyList = [
      _HistoryItem(name: '李四', date: '2024-01-15 14:30'),
      _HistoryItem(name: '王五', date: '2024-01-10 10:00'),
      _HistoryItem(name: '赵六', date: '2024-01-05 18:45'),
      _HistoryItem(name: '孙七', date: '2024-01-01 09:15'),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '合盘历史',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.inkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ThemedBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _HistoryCard(item: item),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String name;
  final String date;

  _HistoryItem({required this.name, required this.date});
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Me
              Text(
                '我',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.inkText,
                ),
              ),
              // Other
              Row(
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.inkText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.inkText.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          // Center Icon and Date
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MysticIcon(),
              const SizedBox(height: 8),
              Text(
                item.date,
                style: GoogleFonts.notoSansSc(
                  fontSize: 12,
                  color: AppTheme.inkText.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MysticIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.jadeGreen.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.balance, // Using balance to represent Yin-Yang/Harmony for now
          color: AppTheme.inkGreen.withOpacity(0.8),
          size: 24,
        ),
      ),
    );
  }
}
