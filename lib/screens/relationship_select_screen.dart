// 关系合盘入口页，选择关系类型后进入双人信息填写。
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';

class RelationshipSelectScreen extends StatelessWidget {
  const RelationshipSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '关系合盘',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MysticBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                child: ListTile(
                  leading: Icon(option.icon, color: AppTheme.amberGold),
                  title: Text(
                    option.title,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    option.subtitle,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.inkText.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.fluorescentCyan,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.relationshipForm,
                      arguments: {'relationType': option.title},
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_RelationOption> _buildOptions() {
    return const [
      _RelationOption('恋人', '感情发展与磨合', Icons.favorite),
      _RelationOption('夫妻', '长期相处与家庭节奏', Icons.home),
      _RelationOption('朋友', '性格互补与信任', Icons.people_alt),
      _RelationOption('亲子', '陪伴与成长', Icons.child_care),
      _RelationOption('同事', '协作与共识', Icons.work),
    ];
  }
}

class _RelationOption {
  final String title;
  final String subtitle;
  final IconData icon;

  const _RelationOption(this.title, this.subtitle, this.icon);
}
