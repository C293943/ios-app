// 合盘报告页面，展示核心结论并进入合盘对话。
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/common/mystic_button.dart';

class RelationshipReportScreen extends StatefulWidget {
  final String relationType;
  final RelationshipReport? report;
  final RelationshipPerson? personA;
  final RelationshipPerson? personB;

  const RelationshipReportScreen({
    super.key,
    required this.relationType,
    this.report,
    this.personA,
    this.personB,
  });

  @override
  State<RelationshipReportScreen> createState() => _RelationshipReportScreenState();
}

class _RelationshipReportScreenState extends State<RelationshipReportScreen> {
  RelationshipReport? _report;
  bool _isLoading = true;
  String _statusText = '正在生成合盘报告...';

  @override
  void initState() {
    super.initState();
    _report = widget.report;
    if (_report != null) {
      _isLoading = false;
    } else {
      _fetchReport();
    }
  }

  Future<void> _fetchReport() async {
    final personA = widget.personA;
    final personB = widget.personB;
    if (personA == null || personB == null) {
      setState(() {
        _isLoading = false;
        _statusText = '缺少合盘信息';
      });
      return;
    }

    final response = await FortuneApiService().fetchRelationshipReport(
      relationType: widget.relationType,
      personA: personA,
      personB: personB,
    );

    if (!mounted) return;
    setState(() {
      _report = response.report;
      _isLoading = false;
      _statusText = response.message ?? '报告已生成';
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '合盘报告',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ThemedBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          children: [
            if (_isLoading)
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.jadeGreen),
                    const SizedBox(height: 12),
                    Text(
                      _statusText,
                      style: GoogleFonts.notoSerifSc(
                        color: AppTheme.inkText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else if (report == null)
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _statusText,
                  style: GoogleFonts.notoSerifSc(
                    color: AppTheme.inkText,
                    fontSize: 13,
                  ),
                ),
              )
            else ...[
              _buildScoreCard(report),
              const SizedBox(height: 16),
              _buildSection('合盘概要', report.summary),
              const SizedBox(height: 16),
              _buildListSection('亮点', report.highlights),
              const SizedBox(height: 16),
              _buildListSection('建议', report.advice),
              const SizedBox(height: 24),
              MysticButton(
                text: '进入合盘对话',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.relationshipChat,
                    arguments: {'report': report},
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(RelationshipReport report) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.jadeGreen, AppTheme.amberGold],
              ),
            ),
            child: Text(
              '${report.score}',
              style: GoogleFonts.notoSerifSc(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.relationType,
                  style: GoogleFonts.notoSerifSc(
                    color: AppTheme.warmYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '合盘匹配度',
                  style: GoogleFonts.notoSerifSc(
                    color: AppTheme.inkText.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.warmYellow,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.inkText.withOpacity(0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.warmYellow,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(color: AppTheme.jadeGreen)),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.notoSerifSc(
                          color: AppTheme.inkText.withOpacity(0.85),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

