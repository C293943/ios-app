import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/divination_models.dart';
import 'package:primordial_spirit/services/divination_service.dart';
import 'package:primordial_spirit/widgets/hexagram_display.dart';

/// 问卜历史记录页面
class DivinationHistoryScreen extends StatefulWidget {
  const DivinationHistoryScreen({super.key});

  @override
  State<DivinationHistoryScreen> createState() =>
      _DivinationHistoryScreenState();
}

class _DivinationHistoryScreenState extends State<DivinationHistoryScreen> {
  final DivinationService _divinationService = DivinationService();
  List<DivinationSession> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _divinationService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载历史记录失败: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.voidBackground,
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.voidGradient,
            ),
          ),

          // 内容
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 自定义 AppBar
  Widget _buildAppBar() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final textColor = AppTheme.inkText;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusXl),
        bottomRight: Radius.circular(AppTheme.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: AppTheme.blurMd, sigmaY: AppTheme.blurMd),
        child: Container(
          height: statusBarHeight + 60,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            top: statusBarHeight,
            bottom: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.liquidGlassBase,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppTheme.radiusXl),
              bottomRight: Radius.circular(AppTheme.radiusXl),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.liquidGlassBorder,
                width: AppTheme.borderThin,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 标题
              Text(
                '历史记录',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              // 左侧返回按钮
              Align(
                alignment: Alignment.centerLeft,
                child: _buildAppBarButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // 右侧清空按钮
              if (_history.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAppBarButton(
                    icon: Icons.delete_outline,
                    onTap: _showClearConfirmDialog,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.liquidGlassBorderSoft,
                width: AppTheme.borderThin,
              ),
            ),
            child: Icon(icon, color: AppTheme.inkText, size: 18),
          ),
        ),
      ),
    );
  }

  /// 主内容
  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.amberGold,
        ),
      );
    }

    if (_history.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppTheme.amberGold,
      backgroundColor: AppTheme.liquidGlassBase,
      child: ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        itemCount: _history.length,
        itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.inkText.withOpacity(0.3),
          ),
          SizedBox(height: AppTheme.spacingLg),
          Text(
            '暂无问卜记录',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          SizedBox(height: AppTheme.spacingSm),
          Text(
            '开始您的第一次问卜吧',
            style: TextStyle(
              color: AppTheme.inkText.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 历史记录项
  Widget _buildHistoryItem(DivinationSession session) {
    final result = session.result;
    final dateFormat = DateFormat('MM/dd HH:mm');
    final dateStr = dateFormat.format(session.createdAt);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppTheme.spacingLg),
        margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(session);
      },
      onDismissed: (direction) {
        _deleteSession(session);
      },
      child: GestureDetector(
        onTap: () => _openSession(session),
        child: Container(
          margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingMd),
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
                    // 小型卦象
                    _buildMiniHexagram(result.primaryHexagram),

                    SizedBox(width: AppTheme.spacingMd),

                    // 信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 问题
                          Text(
                            result.question,
                            style: TextStyle(
                              color: AppTheme.inkText,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: AppTheme.spacingXs),

                          // 卦名和时间
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingSm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.amberGold.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusXs),
                                ),
                                child: Text(
                                  result.primaryHexagram.name,
                                  style: TextStyle(
                                    color: AppTheme.amberGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (result.changedHexagram != null) ...[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 12,
                                    color: AppTheme.inkText.withOpacity(0.4),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacingSm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.jadeGreen.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusXs),
                                  ),
                                  child: Text(
                                    result.changedHexagram!.name,
                                    style: TextStyle(
                                      color: AppTheme.jadeGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              Spacer(),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: AppTheme.inkText.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: AppTheme.spacingSm),

                    // 箭头
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.inkText.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 小型卦象显示
  Widget _buildMiniHexagram(Hexagram hexagram) {
    return Container(
      width: 36,
      height: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          final yaoIndex = 5 - index;
          final yao = hexagram.lines[yaoIndex];
          return Container(
            height: 5,
            child: yao.isYang
                ? Container(
                    width: 28,
                    decoration: BoxDecoration(
                      color: yao.isChanging
                          ? AppTheme.amberGold
                          : AppTheme.inkText.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        decoration: BoxDecoration(
                          color: yao.isChanging
                              ? AppTheme.amberGold
                              : AppTheme.inkText.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 10,
                        decoration: BoxDecoration(
                          color: yao.isChanging
                              ? AppTheme.amberGold
                              : AppTheme.inkText.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }

  /// 打开会话
  void _openSession(DivinationSession session) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, session);
  }

  /// 删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(DivinationSession session) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: Text(
          '删除记录',
          style: TextStyle(color: AppTheme.inkText),
        ),
        content: Text(
          '确定要删除这条问卜记录吗？',
          style: TextStyle(color: AppTheme.inkText.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.inkText.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 清空确认对话框
  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: Text(
          '清空记录',
          style: TextStyle(color: AppTheme.inkText),
        ),
        content: Text(
          '确定要清空所有问卜记录吗？此操作不可撤销。',
          style: TextStyle(color: AppTheme.inkText.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.inkText.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            child: Text(
              '清空',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// 删除单条记录
  Future<void> _deleteSession(DivinationSession session) async {
    await _divinationService.deleteSession(session.id);
    setState(() {
      _history.removeWhere((s) => s.id == session.id);
    });
    _showSnackBar('记录已删除');
  }

  /// 清空所有记录
  Future<void> _clearAllHistory() async {
    await _divinationService.clearHistory();
    setState(() {
      _history.clear();
    });
    _showSnackBar('记录已清空');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.jadeGreen.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
