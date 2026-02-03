import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

class BaziReportScreen extends StatefulWidget {
  const BaziReportScreen({super.key});

  @override
  State<BaziReportScreen> createState() => _BaziReportScreenState();
}

class _BaziReportScreenState extends State<BaziReportScreen> {
  // Mock unlocking state
  final Map<String, bool> _unlockedItems = {
    "整体解读": true,
    "大运分析": false,
    "姻缘分析": false,
    "事业分析": false,
    "财运分析": false,
    "学业分析": false,
  };

  void _unlockItem(String title, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spiritGlass,
        title: Text("解锁$title", style: TextStyle(color: AppTheme.inkText)),
        content: Text("确认支付 $price 灵石解锁该模块吗？", style: TextStyle(color: AppTheme.inkText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _unlockedItems[title] = true;
              });
              Navigator.pop(context);
            },
            child: Text("确认解锁", style: TextStyle(color: AppTheme.jadeGreen)),
          ),
        ],
      ),
    );
  }

  void _unlockAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spiritGlass,
        title: Text("解锁全部报告", style: TextStyle(color: AppTheme.inkText)),
        content: Text("确认支付 50 灵石解锁全部模块吗？", style: TextStyle(color: AppTheme.inkText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _unlockedItems.updateAll((key, value) => true);
              });
              Navigator.pop(context);
            },
            child: Text("确认解锁", style: TextStyle(color: AppTheme.jadeGreen)),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: AppTheme.inkText, size: 20),
              Text(
                "返回",
                style: TextStyle(color: AppTheme.inkText, fontSize: 16),
              ),
            ],
          ),
        ),
        leadingWidth: 80,
        title: Text(
          "完整命理报告",
          style: TextStyle(
            color: AppTheme.inkText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.voidGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Spirit Stones Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.spiritGlass.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.diamond, color: Colors.blue[200], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "我的灵石: 120",
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8, // Adjusted from 0.85 to 0.8 to prevent overflow
                  children: [
                    _ReportGridItem(
                      title: "整体解读",
                      subtitle: "基础必读",
                      price: 10,
                      isUnlocked: _unlockedItems["整体解读"]!,
                      icon: Icons.bar_chart,
                      iconColor: Colors.blue,
                      tagColor: Colors.tealAccent,
                      onTap: () {}, // Already unlocked
                    ),
                    _ReportGridItem(
                      title: "大运分析",
                      subtitle: "十年运势",
                      price: 15,
                      isUnlocked: _unlockedItems["大运分析"]!,
                      icon: Icons.show_chart,
                      iconColor: Colors.redAccent,
                      tagColor: const Color(0xFF9F7AEA),
                      onTap: () => _unlockItem("大运分析", 15),
                    ),
                    _ReportGridItem(
                      title: "姻缘分析",
                      subtitle: "正缘预测",
                      price: 12,
                      isUnlocked: _unlockedItems["姻缘分析"]!,
                      icon: Icons.favorite,
                      iconColor: Colors.pinkAccent,
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("姻缘分析", 12),
                    ),
                    _ReportGridItem(
                      title: "事业分析",
                      subtitle: "职场指南",
                      price: 12,
                      isUnlocked: _unlockedItems["事业分析"]!,
                      icon: Icons.work,
                      iconColor: Colors.brown,
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("事业分析", 12),
                    ),
                    _ReportGridItem(
                      title: "财运分析",
                      subtitle: "财富密码",
                      price: 12,
                      isUnlocked: _unlockedItems["财运分析"]!,
                      icon: Icons.attach_money,
                      iconColor: Colors.amber,
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("财运分析", 12),
                    ),
                    _ReportGridItem(
                      title: "学业分析",
                      subtitle: "学运提升",
                      price: 10,
                      isUnlocked: _unlockedItems["学业分析"]!,
                      icon: Icons.menu_book,
                      iconColor: Colors.blueAccent,
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("学业分析", 10),
                    ),
                  ],
                ),
              ),
              // Bottom Action Bar
              _BottomPurchaseBar(onUnlockAll: _unlockAll),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportGridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final bool isUnlocked;
  final IconData icon;
  final Color iconColor;
  final Color tagColor;
  final VoidCallback onTap;

  const _ReportGridItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isUnlocked,
    required this.icon,
    required this.iconColor,
    required this.tagColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? null : onTap,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 32),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.green.withOpacity(0.2) : (tagColor == Colors.grey ? Colors.grey.withOpacity(0.2) : tagColor.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: isUnlocked ? Colors.greenAccent : (tagColor == Colors.grey ? AppTheme.inkText.withOpacity(0.6) : Colors.white),
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Price / Status
                  if (isUnlocked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.greenAccent, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "已解锁",
                          style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    )
                  else
                    Text(
                      "$price灵石",
                      style: TextStyle(
                        color: AppTheme.inkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (!isUnlocked)
              Positioned(
                bottom: 12,
                right: 12,
                child: Icon(Icons.lock, color: AppTheme.amberGold.withOpacity(0.6), size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomPurchaseBar extends StatelessWidget {
  final VoidCallback onUnlockAll;
  
  const _BottomPurchaseBar({required this.onUnlockAll});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "单独解锁: 71灵石",
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "|",
                style: TextStyle(color: AppTheme.inkText.withOpacity(0.3)),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "全本: ",
                      style: TextStyle(color: AppTheme.inkText.withOpacity(0.7), fontSize: 14),
                    ),
                    TextSpan(
                      text: "50灵石",
                      style: TextStyle(color: AppTheme.inkText, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "立省21灵石",
                  style: TextStyle(color: Colors.brown, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onUnlockAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.amberGold, Color(0xFFE6C17A)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amberGold.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                "50灵石 解锁全部",
                style: TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "解锁后永久查看",
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
