import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 液态玻璃底部弹窗 - 统一的底部弹窗样式
/// 
/// 特性：
/// - 液态玻璃背景效果
/// - 统一的拖动指示器
/// - 可选的标题栏
/// - 主题自适应
class LiquidBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final double maxHeightFactor;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;

  const LiquidBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
    this.maxHeightFactor = 0.85,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.padding,
  });

  /// 显示液态玻璃底部弹窗
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    IconData? titleIcon,
    double maxHeightFactor = 0.85,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => LiquidBottomSheet(
        title: title,
        titleIcon: titleIcon,
        maxHeightFactor: maxHeightFactor,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        onClose: () => Navigator.pop(context),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFactor),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
        boxShadow: [
          // 外发光
          BoxShadow(
            color: AppTheme.liquidGlow.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, -4),
          ),
          // 深度阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.blurPremium,
            sigmaY: AppTheme.blurPremium,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassBase,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Stack(
              children: [
                // 内层渐变
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusLg),
                      ),
                      gradient: AppTheme.liquidGlassInnerGradient(),
                    ),
                  ),
                ),

                // 顶部高光
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLg),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.liquidTopHighlight(intensity: 0.8),
                      ),
                    ),
                  ),
                ),

                // 边框
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLg),
                        ),
                        border: Border.all(
                          color: AppTheme.liquidGlassBorder,
                          width: AppTheme.borderStandard,
                        ),
                      ),
                    ),
                  ),
                ),

                // 内容
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 拖动指示器
                    if (showDragHandle) _buildDragHandle(),

                    // 标题栏
                    if (title != null) _buildTitleBar(context),

                    // 分隔线
                    if (title != null) _buildDivider(),

                    // 主内容
                    Flexible(
                      child: Padding(
                        padding: padding ?? EdgeInsets.only(
                          left: AppTheme.spacingLg,
                          right: AppTheme.spacingLg,
                          top: title != null ? 0 : AppTheme.spacingMd,
                          bottom: bottomPadding + AppTheme.spacingMd,
                        ),
                        child: child,
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

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.only(top: AppTheme.spacingMd),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.liquidGlassBorderSoft,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingLg),
      child: Row(
        children: [
          if (titleIcon != null) ...[
            Icon(titleIcon, color: AppTheme.jadeGreen, size: 28),
            SizedBox(width: AppTheme.spacingMd),
          ],
          Expanded(
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.warmYellow,
              ),
            ),
          ),
          if (showCloseButton)
            GestureDetector(
              onTap: onClose ?? () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.liquidGlassLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppTheme.liquidGlassBorderSoft,
                    width: AppTheme.borderThin,
                  ),
                ),
                child: Icon(
                  Icons.close,
                  color: AppTheme.inkText.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: AppTheme.borderStandard,
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.liquidGlassBorder.withOpacity(0.5),
            AppTheme.liquidGlassBorder.withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.1, 0.9, 1.0],
        ),
      ),
    );
  }
}

/// 液态玻璃内容卡片 - 用于底部弹窗内的信息区块
class LiquidContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const LiquidContentCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppTheme.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.liquidGlassLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.liquidGlassBorderSoft,
          width: AppTheme.borderThin,
        ),
      ),
      child: child,
    );
  }
}

/// 液态玻璃分区标题
class LiquidSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const LiquidSectionTitle({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppTheme.jadeGreen),
          SizedBox(width: AppTheme.spacingSm),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmYellow,
          ),
        ),
      ],
    );
  }
}

/// 液态玻璃关闭按钮 - 底部弹窗的收起按钮
class LiquidCloseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const LiquidCloseButton({
    super.key,
    this.label = '收起',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXl,
          vertical: AppTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppTheme.jadeGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: AppTheme.jadeGreen.withOpacity(0.4),
            width: AppTheme.borderStandard,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.jadeGreen.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Text(
          '【$label】',
          style: TextStyle(
            color: AppTheme.jadeGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
