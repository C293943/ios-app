import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';

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
      builder: (context) => _LiquidAlertDialog(
        title: "解锁$title",
        content: "确认支付 $price 灵石解锁该模块吗？",
        onConfirm: () {
          setState(() {
            _unlockedItems[title] = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _unlockAll() {
    showDialog(
      context: context,
      builder: (context) => _LiquidAlertDialog(
        title: "解锁全部报告",
        content: "确认支付 50 灵石解锁全部模块吗？",
        onConfirm: () {
          setState(() {
            _unlockedItems.updateAll((key, value) => true);
          });
          Navigator.pop(context);
        },
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
              SizedBox(width: AppTheme.spacingSm),
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
              SizedBox(height: AppTheme.spacingSm),
              // Spirit Stones Bar
              _buildSpiritStonesBar(),
              SizedBox(height: AppTheme.spacingLg),
              // Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                  mainAxisSpacing: AppTheme.spacingMd,
                  crossAxisSpacing: AppTheme.spacingMd,
                  childAspectRatio: 0.8,
                  children: [
                    _ReportGridItem(
                      title: "整体解读",
                      subtitle: "基础必读",
                      price: 10,
                      isUnlocked: _unlockedItems["整体解读"]!,
                      icon: Icons.bar_chart,
                      iconColor: AppTheme.electricBlue,
                      tagColor: AppTheme.fluorescentCyan,
                      onTap: () {}, // Already unlocked
                    ),
                    _ReportGridItem(
                      title: "大运分析",
                      subtitle: "十年运势",
                      price: 15,
                      isUnlocked: _unlockedItems["大运分析"]!,
                      icon: Icons.show_chart,
                      iconColor: const Color(0xFFFF6B6B),
                      tagColor: const Color(0xFF9F7AEA),
                      onTap: () => _unlockItem("大运分析", 15),
                    ),
                    _ReportGridItem(
                      title: "姻缘分析",
                      subtitle: "正缘预测",
                      price: 12,
                      isUnlocked: _unlockedItems["姻缘分析"]!,
                      icon: Icons.favorite,
                      iconColor: const Color(0xFFFF69B4),
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("姻缘分析", 12),
                    ),
                    _ReportGridItem(
                      title: "事业分析",
                      subtitle: "职场指南",
                      price: 12,
                      isUnlocked: _unlockedItems["事业分析"]!,
                      icon: Icons.work,
                      iconColor: const Color(0xFF8B4513),
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("事业分析", 12),
                    ),
                    _ReportGridItem(
                      title: "财运分析",
                      subtitle: "财富密码",
                      price: 12,
                      isUnlocked: _unlockedItems["财运分析"]!,
                      icon: Icons.attach_money,
                      iconColor: AppTheme.amberGold,
                      tagColor: Colors.grey,
                      onTap: () => _unlockItem("财运分析", 12),
                    ),
                    _ReportGridItem(
                      title: "学业分析",
                      subtitle: "学运提升",
                      price: 10,
                      isUnlocked: _unlockedItems["学业分析"]!,
                      icon: Icons.menu_book,
                      iconColor: AppTheme.electricBlue,
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

  Widget _buildSpiritStonesBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppTheme.blurMd, sigmaY: AppTheme.blurMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.liquidGlassBorderSoft,
                width: AppTheme.borderThin,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.electricBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(Icons.diamond, color: AppTheme.electricBlue, size: 20),
                ),
                SizedBox(width: AppTheme.spacingMd),
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
      child: LiquidCard(
        margin: EdgeInsets.zero,
        accentColor: isUnlocked ? AppTheme.jadeGreen : iconColor,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                      width: AppTheme.borderThin,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
                SizedBox(height: AppTheme.spacingMd),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingSm),
                // Tag
                LiquidInfoTag(
                  text: subtitle,
                  color: isUnlocked
                      ? AppTheme.jadeGreen
                      : (tagColor == Colors.grey
                          ? AppTheme.inkText.withOpacity(0.6)
                          : tagColor),
                ),
                SizedBox(height: AppTheme.spacingMd),
                // Price / Status
                if (isUnlocked)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: AppTheme.jadeGreen, size: 16),
                      SizedBox(width: AppTheme.spacingXs),
                      Text(
                        "已解锁",
                        style: TextStyle(color: AppTheme.jadeGreen, fontSize: 12),
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
            if (!isUnlocked)
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.lock,
                  color: AppTheme.amberGold.withOpacity(0.6),
                  size: 20,
                ),
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
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppTheme.spacingLg,
            AppTheme.spacingMd,
            AppTheme.spacingLg,
            AppTheme.spacingXl,
          ),
          decoration: BoxDecoration(
            color: AppTheme.liquidGlassBase,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
            border: Border(
              top: BorderSide(
                color: AppTheme.liquidGlassBorder,
                width: AppTheme.borderThin,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top highlight
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.inkText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                  SizedBox(width: AppTheme.spacingSm),
                  Text(
                    "|",
                    style: TextStyle(color: AppTheme.inkText.withOpacity(0.3)),
                  ),
                  SizedBox(width: AppTheme.spacingSm),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "全本: ",
                          style: TextStyle(
                            color: AppTheme.inkText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: "50灵石",
                          style: TextStyle(
                            color: AppTheme.inkText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingSm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.amberGold, const Color(0xFFF0E68C)],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: const Text(
                      "立省21灵石",
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingMd),
              GestureDetector(
                onTap: onUnlockAll,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.amberGold, const Color(0xFFE6C17A)],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: AppTheme.borderThin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberGold.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "50灵石 解锁全部",
                        style: TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spacingMd),
              Text(
                "解锁后永久查看",
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const _LiquidAlertDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassBase,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.liquidGlassBorder,
                width: AppTheme.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingMd),
                Text(
                  content,
                  style: TextStyle(color: AppTheme.inkText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.liquidGlassLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.liquidGlassBorderSoft,
                              width: AppTheme.borderThin,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "取消",
                            style: TextStyle(
                              color: AppTheme.inkText.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.jadeGreen.withOpacity(0.8),
                                AppTheme.jadeGreen,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.jadeGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "确认解锁",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
