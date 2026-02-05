import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
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
  bool _isUnlocked = false; // 是否已解锁深度报告
  late RelationshipReport _report;

  @override
  void initState() {
    super.initState();
    // 使用传入的 report 或构建 Mock 数据
    _report = widget.report ?? RelationshipReport.mock(widget.relationType);
  }

  void _unlockReport() {
    // 模拟支付/消耗灵石逻辑
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.spiritGlass,
        title: Text('解锁深度解读', style: TextStyle(color: AppTheme.warmYellow)),
        content: Text('确认消耗 5 灵石解锁完整合盘报告吗？', style: TextStyle(color: AppTheme.inkText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: AppTheme.inkText.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isUnlocked = true;
              });
            },
            child: Text('确定', style: TextStyle(color: AppTheme.jadeGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '合盘报告',
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
        actions: [
          _buildActionButton(Icons.history, '历史', () {}),
          _buildActionButton(Icons.share, '分享', () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: ThemedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 40),
          child: Column(
            children: [
              if (!_isUnlocked) _buildBriefReport() else _buildFullReport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: AppTheme.inkText.withOpacity(0.8), size: 20),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            color: AppTheme.inkText.withOpacity(0.6),
          ),
        )
      ],
    );
  }

  // --- 简略报告视图 ---
  Widget _buildBriefReport() {
    return Column(
      children: [
        // 1. 合盘总览 (简略)
        GlassContainer(
          height: 140,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('合盘总览', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Center(
                        child: _ScoreCircle(score: _report.score, size: 80),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('合盘契合度', style: TextStyle(color: AppTheme.inkText.withOpacity(0.7), fontSize: 14)),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppTheme.warmYellow, AppTheme.jadeGreen],
                      ).createShader(bounds),
                      child: Text(
                        '天作之合',
                        style: GoogleFonts.zcoolXiaoWei(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. 多维契合度分析 (雷达图)
        GlassContainer(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('多维契合度分析', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: CustomPaint(
                  painter: RadarChartPainter(
                    values: [0.8, 0.7, 0.9, 0.85, 0.6], // Mock values
                    labels: ['性格', '事业', '家庭', '沟通', '财运'],
                    color: AppTheme.jadeGreen,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. 深度解读 (锁住)
        Stack(
          children: [
            GlassContainer(
              height: 220,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('深度解读', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      '命盘显示二人缘分深厚，天干地支多处相合。初见即有似曾相识之感，可谓前世修来的缘分。在性格方面，双方互补性强，一方热情似火，一方温润如玉... 后续的运势发展中，虽然会有小波折，但只要秉持初心，定能修成正果。建议在沟通中多一份包容...',
                      style: TextStyle(color: AppTheme.inkText.withOpacity(0.3), height: 1.5),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
            // 模糊层 + 锁
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: AppTheme.voidBackground.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: AppTheme.jadeGreen.withOpacity(0.8), size: 40),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _unlockReport,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppTheme.spiritGlass, AppTheme.spiritGlass.withOpacity(0.8)]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.jadeGreen.withOpacity(0.5)),
                              boxShadow: [BoxShadow(color: AppTheme.jadeGreen.withOpacity(0.2), blurRadius: 10)],
                            ),
                            child: Text(
                              '解锁深度解读 (5灵石)',
                              style: TextStyle(color: AppTheme.inkText, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 完整报告视图 ---
  Widget _buildFullReport() {
    return Column(
      children: [
        // 1. 顶部 Header
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('你们是：', style: TextStyle(color: AppTheme.inkText, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('天作之合', style: TextStyle(color: AppTheme.inkText, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('💫', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _HeaderTag(icon: Icons.local_fire_department, label: '激情', color: Colors.blue),
                  _HeaderTag(icon: Icons.chat_bubble_outline, label: '沟通', color: Colors.teal),
                  _HeaderTag(icon: Icons.favorite_border, label: '灵魂共鸣', color: Colors.green),
                  _HeaderTag(icon: Icons.trending_up, label: '共同成长', color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. 分数 & 人物 & 雷达图
        Row(
          children: [
            // 左侧：分数
            Expanded(
              child: GlassContainer(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ScoreCircle(score: _report.score, size: 90),
                    const SizedBox(height: 12),
                    Text('天作之合', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => Icon(Icons.star, color: AppTheme.amberGold, size: 14)),
                    ),
                    const SizedBox(height: 4),
                    Text('超越了95%的配对', style: TextStyle(color: AppTheme.inkText.withOpacity(0.5), fontSize: 10)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 右侧：人物关系
            Expanded(
              child: GlassContainer(
                height: 200,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         _AvatarItem(name: '小青龙', element: '木', isMale: true),
                         _AvatarItem(name: '紫薇仙子', element: '火', isMale: false),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('(木) 木生火 (火)', style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.jadeGreen.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('互补型 √', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 3. 雷达图
        GlassContainer(
          height: 240,
          padding: const EdgeInsets.all(20),
          child: CustomPaint(
             painter: RadarChartPainter(
                values: [0.8, 0.7, 0.9, 0.85, 0.6], 
                labels: ['性格', '事业', '家庭', '沟通', '财运'],
                color: Colors.blueAccent, // Use gradient logic in painter ideally
             ),
             size: Size.infinite,
          ),
        ),
        const SizedBox(height: 16),

        // 4. 优势与挑战
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('💪 你们的优势', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _CheckItem('沟通默契：你们总能理解对方的想法'),
              _CheckItem('价值观一致：对未来有共同的愿景'),
              _CheckItem('互相激励：彼此是对方前进的动力'),
              
              const SizedBox(height: 20),
              Divider(color: AppTheme.scrollBorder.withOpacity(0.5)),
              const SizedBox(height: 20),

              Row(
                children: [
                  Text('⚠️ 需要注意的挑战', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _BulletedItem('财务观念：你更保守，TA更冒险', '建议：制定共同理财计划，7:3分配'),
              _BulletedItem('生活节奏：你快，TA慢', '建议：互相包容，找到平衡点'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. 五行能量流动
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('🌊 五行能量流动', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ElementCircle(element: '木', label: '你(木)', color: Colors.green),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text('火↙木', style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
                       Icon(Icons.arrow_right_alt, color: AppTheme.jadeGreen, size: 40),
                       Text('火↗木', style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
                    ],
                  ),
                  _ElementCircle(element: '火', label: 'TA(火)', color: Colors.redAccent),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.spiritGlass, borderRadius: BorderRadius.circular(8)),
                child: Text('木生火：你是TA的灵感源泉\n火反哺：TA给你温暖和激情', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.inkText.withOpacity(0.8), fontSize: 12)),
              ),
              const SizedBox(height: 8),
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.jadeGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: Text('能量循环：良性互动 √', style: TextStyle(color: AppTheme.inkText, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 6. 生活场景预测 (Mock Horizon Scroll)
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 生活场景预测', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ScenarioCard('理财决策', '你倾向保守投资，TA喜欢冒险', '建议: 7:3分配，稳健+激进', Icons.monetization_on),
                    const SizedBox(width: 12),
                    _ScenarioCard('家务分工', '你擅长规划，TA擅长执行', '建议: 你做计划，TA来实施', Icons.home),
                    const SizedBox(width: 12),
                    _ScenarioCard('社交活动', '你喜欢热闹，TA喜欢安静', '建议: 轮流选择活动方式', Icons.celebration),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7. 未来一年关系运势 (Mock Chart)
        GlassContainer(
          height: 260,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📈 未来一年关系运势', style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: CustomPaint(
                  painter: TrendChartPainter(),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TrendLabel('3月: 感情升温期', Colors.green),
                  _TrendLabel('7月: 需要沟通', Colors.orange),
                  _TrendLabel('10月: 关系稳定', Colors.blue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 8. 缘分故事 & 行动清单
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               child: GlassContainer(
                 height: 340,
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('📖 你们的缘分故事', style: TextStyle(color: AppTheme.inkText, fontSize: 14, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     Text(
                       '在浩瀚的宇宙中，你们的元神跨越了千万光年相遇。\n\n你是木，代表生机与成长；\nTA是火，代表热情与光明。\n\n木生火，你滋养了TA的激情；\n火温暖了你的生命。',
                       style: TextStyle(color: AppTheme.inkText.withOpacity(0.8), fontSize: 12, height: 1.5),
                     ),
                   ],
                 ),
               ),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: GlassContainer(
                 height: 340,
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('💡 提升关系的行动清单', style: TextStyle(color: AppTheme.inkText, fontSize: 14, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 12),
                     _CheckBoxItem('每周至少一次深度对话'),
                     _CheckBoxItem('每月一起尝试新事物'),
                     _CheckBoxItem('尊重彼此的独处时间'),
                     _CheckBoxItem('定期表达感激和欣赏'),
                     const Spacer(),
                     Container(
                       padding: const EdgeInsets.symmetric(vertical: 8),
                       alignment: Alignment.center,
                       decoration: BoxDecoration(
                         color: AppTheme.jadeGreen,
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: Text('保存到我的计划', style: TextStyle(color: Colors.white, fontSize: 12)),
                     ),
                   ],
                 ),
               ),
             ),
           ],
        ),
        const SizedBox(height: 24),

        // 底部：生成分享卡
        Row(
          children: [
             if(_report.avatar3dUrl != null) // Mock placeholder logic for "share card preview"
               Container(
                 width: 100,
                 height: 60,
                 margin: const EdgeInsets.only(right: 12),
                 decoration: BoxDecoration(
                   color: Colors.black38,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: AppTheme.scrollBorder),
                 ),
               ),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('📤 生成专属分享卡', style: TextStyle(color: AppTheme.inkText, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Row(
                     children: [
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.symmetric(vertical: 8),
                           alignment: Alignment.center,
                           decoration: BoxDecoration(
                             color: AppTheme.spiritGlass,
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: AppTheme.jadeGreen),
                           ),
                           child: Text('生成卡片', style: TextStyle(color: AppTheme.jadeGreen, fontSize: 12)),
                         ),
                       ),
                       const SizedBox(width: 8),
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.symmetric(vertical: 8),
                           alignment: Alignment.center,
                           decoration: BoxDecoration(
                             color: Colors.green, // WeChat green
                             borderRadius: BorderRadius.circular(16),
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.share, color: Colors.white, size: 14),
                               const SizedBox(width: 4),
                               Text('分享到朋友圈', style: TextStyle(color: Colors.white, fontSize: 12)),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
          ],
        ),
      ],
    );
  }
}

// --- Helper Widgets ---

class _HeaderTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderTag({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 28),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
      ],
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  final double size;

  const _ScoreCircle({required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.jadeGreen, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.jadeGreen.withOpacity(0.3), Colors.transparent],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Text(
             '$score分',
             style: GoogleFonts.notoSerifSc(
               color: Colors.white,
               fontSize: size * 0.35,
               fontWeight: FontWeight.bold,
             ),
           ),
        ],
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final String name;
  final String element;
  final bool isMale;

  const _AvatarItem({required this.name, required this.element, required this.isMale});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.scrollBorder),
          ),
          // Placeholder for image
          child: Icon(isMale ? Icons.face : Icons.face_3, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, color: element == '木' ? Colors.green : Colors.red),
          child: Text(element, style: TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check, color: Colors.greenAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: AppTheme.inkText, fontSize: 13))),
      ],
    );
  }
}

class _BulletedItem extends StatelessWidget {
  final String title;
  final String advice;

  const _BulletedItem(this.title, this.advice);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(Icons.circle, size: 6, color: AppTheme.inkText),
               const SizedBox(width: 8),
               Expanded(child: Text(title, style: TextStyle(color: AppTheme.inkText, fontSize: 13))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 4),
            child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.amberGold),
                  const SizedBox(width: 4),
                  Expanded(child: Text(advice, style: TextStyle(color: AppTheme.inkText.withOpacity(0.7), fontSize: 12))),
               ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementCircle extends StatelessWidget {
  final String element;
  final String label;
  final Color color;

  const _ElementCircle({required this.element, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
          ),
          child: Icon(element == '木' ? Icons.forest : Icons.local_fire_department, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String desc;
  final String advice;
  final IconData icon;

  const _ScenarioCard(this.title, this.desc, this.advice, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.scrollBorder.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.amberGold),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: AppTheme.inkText, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.inkText.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 8),
          Container(
             padding: const EdgeInsets.all(4),
             decoration: BoxDecoration(color: AppTheme.voidBackground.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
             child: Text(advice, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.inkText.withOpacity(0.6), fontSize: 9)),
          ),
        ],
      ),
    );
  }
}

class _TrendLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _TrendLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.label, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: AppTheme.inkText, fontSize: 10)),
      ],
    );
  }
}

class _CheckBoxItem extends StatelessWidget {
  final String text;

  const _CheckBoxItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_box_outline_blank, color: AppTheme.inkText.withOpacity(0.6), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: AppTheme.inkText.withOpacity(0.8), fontSize: 12))),
        ],
      ),
    );
  }
}

// --- Custom Painters ---

class RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;

  RadarChartPainter({required this.values, required this.labels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY) * 0.8;

    final paintBorder = Paint()
      ..color = AppTheme.inkText.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final paintFill = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw grid
    for (int i = 1; i <= 4; i++) {
       final r = radius * (i / 4);
       final path = Path();
       for (int j = 0; j < 5; j++) {
         final angle = -pi / 2 + (2 * pi * j) / 5;
         final x = centerX + r * cos(angle);
         final y = centerY + r * sin(angle);
         if (j == 0) path.moveTo(x, y);
         else path.lineTo(x, y);
       }
       path.close();
       canvas.drawPath(path, paintBorder);
    }

    // Draw lines to corners
    for (int j = 0; j < 5; j++) {
         final angle = -pi / 2 + (2 * pi * j) / 5;
         final x = centerX + radius * cos(angle);
         final y = centerY + radius * sin(angle);
         canvas.drawLine(Offset(centerX, centerY), Offset(x, y), paintBorder);
         
         // Labels
         final labelX = centerX + (radius + 20) * cos(angle);
         final labelY = centerY + (radius + 20) * sin(angle);
         final textPainter = TextPainter(
           text: TextSpan(text: labels[j], style: TextStyle(color: AppTheme.inkText, fontSize: 12)),
           textDirection: TextDirection.ltr,
         );
         textPainter.layout();
         textPainter.paint(canvas, Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2));
    }

    // Draw data
    final pathData = Path();
    for (int j = 0; j < 5; j++) {
         final angle = -pi / 2 + (2 * pi * j) / 5;
         final r = radius * values[j];
         final x = centerX + r * cos(angle);
         final y = centerY + r * sin(angle);
         if (j == 0) pathData.moveTo(x, y);
         else pathData.lineTo(x, y);
    }
    pathData.close();
    canvas.drawPath(pathData, paintFill);
    canvas.drawPath(pathData, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppTheme.amberGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.amberGold.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Mock smooth curve
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.5);

    canvas.drawPath(path, paintLine);

    final pathFill = Path.from(path);
    pathFill.lineTo(size.width, size.height);
    pathFill.lineTo(0, size.height);
    pathFill.close();
    canvas.drawPath(pathFill, paintFill);

    // Draw Axis lines
    final paintGrid = Paint()..color = AppTheme.inkText.withOpacity(0.1)..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintGrid); // Bottom
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paintGrid); // Left

    // Labels
    final textStyle = TextStyle(color: AppTheme.inkText.withOpacity(0.5), fontSize: 10);
    _drawText(canvas, '高', Offset(10, 10), textStyle);
    _drawText(canvas, '低', Offset(10, size.height - 20), textStyle);
    
    _drawText(canvas, '1月', Offset(10, size.height + 5), textStyle);
    _drawText(canvas, '6月', Offset(size.width * 0.5, size.height + 5), textStyle);
    _drawText(canvas, '12月', Offset(size.width - 20, size.height + 5), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
