import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/divination_models.dart';

/// 六爻卦象显示组件
/// 支持显示本卦和变卦（双列布局）
class HexagramDisplay extends StatefulWidget {
  /// 本卦
  final Hexagram primaryHexagram;
  
  /// 变卦（可选）
  final Hexagram? changedHexagram;
  
  /// 是否显示动画
  final bool animated;
  
  /// 动画时长
  final Duration animationDuration;

  const HexagramDisplay({
    super.key,
    required this.primaryHexagram,
    this.changedHexagram,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<HexagramDisplay> createState() => _HexagramDisplayState();
}

class _HexagramDisplayState extends State<HexagramDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _lineAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 为每一爻创建错开的动画
    _lineAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
        ),
      );
    });

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChanged = widget.changedHexagram != null;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurMd, sigmaY: AppTheme.blurMd),
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.liquidGlassBase,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.liquidGlassBorder,
              width: AppTheme.borderThin,
            ),
          ),
          child: hasChanged
              ? _buildDualHexagram()
              : _buildSingleHexagram(widget.primaryHexagram, '本卦'),
        ),
      ),
    );
  }

  /// 构建双卦显示（本卦+变卦）
  Widget _buildDualHexagram() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildSingleHexagram(widget.primaryHexagram, '本卦'),
        ),
        Container(
          width: 1,
          height: 200,
          margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppTheme.liquidGlassBorder,
                AppTheme.liquidGlassBorder,
                Colors.transparent,
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        Expanded(
          child: _buildSingleHexagram(widget.changedHexagram!, '变卦'),
        ),
      ],
    );
  }

  /// 构建单个卦象
  Widget _buildSingleHexagram(Hexagram hexagram, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签
        Text(
          label,
          style: TextStyle(
            color: AppTheme.inkText.withOpacity(0.6),
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: AppTheme.spacingSm),
        
        // 六爻图形（从上到下显示，即从上爻到初爻）
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(6, (index) {
                // 从上爻（索引5）到初爻（索引0）
                final yaoIndex = 5 - index;
                final yao = hexagram.lines[yaoIndex];
                final animation = _lineAnimations[yaoIndex];
                
                return Opacity(
                  opacity: animation.value,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * animation.value,
                    child: _buildYaoLine(yao),
                  ),
                );
              }),
            );
          },
        ),
        
        SizedBox(height: AppTheme.spacingMd),
        
        // 卦名
        Text(
          hexagram.name,
          style: TextStyle(
            color: AppTheme.inkText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// 构建单爻线条
  Widget _buildYaoLine(Yao yao) {
    final lineColor = yao.isChanging
        ? AppTheme.amberGold  // 动爻用金色
        : AppTheme.inkText;
    
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(vertical: 4),
      child: yao.isYang
          ? _buildYangLine(lineColor, yao.isChanging)
          : _buildYinLine(lineColor, yao.isChanging),
    );
  }

  /// 阳爻（实线）
  Widget _buildYangLine(Color color, bool isChanging) {
    return Container(
      width: 80,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: isChanging
            ? [
                BoxShadow(
                  color: AppTheme.amberGold.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isChanging
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.voidBackground,
                ),
              ),
            )
          : null,
    );
  }

  /// 阴爻（断线）
  Widget _buildYinLine(Color color, bool isChanging) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: isChanging
                ? [
                    BoxShadow(
                      color: AppTheme.amberGold.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: 16),
        Container(
          width: 32,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: isChanging
                ? [
                    BoxShadow(
                      color: AppTheme.amberGold.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

/// 简化版卦象卡片（用于历史列表）
class HexagramCard extends StatelessWidget {
  final Hexagram hexagram;
  final String? subtitle;
  final VoidCallback? onTap;

  const HexagramCard({
    super.key,
    required this.hexagram,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                // 小型卦象显示
                _buildMiniHexagram(),
                SizedBox(width: AppTheme.spacingMd),
                // 卦名和说明
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hexagram.name,
                        style: TextStyle(
                          color: AppTheme.inkText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: AppTheme.inkText.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.inkText.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniHexagram() {
    return Container(
      width: 40,
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          final yaoIndex = 5 - index;
          final yao = hexagram.lines[yaoIndex];
          return Container(
            height: 6,
            child: yao.isYang
                ? Container(
                    width: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.inkText.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.inkText.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.inkText.withOpacity(0.8),
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
}
