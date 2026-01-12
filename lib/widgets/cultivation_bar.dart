import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/services/cultivation_service.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// 养成值进度条组件
class CultivationBar extends StatelessWidget {
  final bool showLabel;
  final bool showStage;
  final double height;
  final double? width;

  const CultivationBar({
    super.key,
    this.showLabel = true,
    this.showStage = true,
    this.height = 8.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CultivationService>(
      builder: (context, cultivation, child) {
        final progress = cultivation.progress;
        final stage = cultivation.getStageDescription();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 阶段描述和当前值
            if (showStage)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stage,
                    style: GoogleFonts.zcoolXiaoWei(
                      fontSize: 16,
                      color: AppTheme.warmYellow,
                      shadows: [
                        Shadow(
                          color: AppTheme.fluorescentCyan.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${cultivation.cultivationValue}/${cultivation.maxCultivationValue}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.inkText.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            if (showStage) const SizedBox(height: 8),

            // 主进度条
            Stack(
              children: [
                // 背景条
                Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: AppTheme.voidBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(
                      color: AppTheme.fluorescentCyan.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),

                // 进度条
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: height,
                  width: width != null ? width! * progress : null,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.fluorescentCyan,
                        AppTheme.electricBlue,
                        AppTheme.amberGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.fluorescentCyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // 发光效果
                if (progress > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppTheme.warmYellow.withValues(alpha: 0.0),
                            AppTheme.warmYellow.withValues(alpha: 0.8),
                            AppTheme.warmYellow,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warmYellow,
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 下阶段进度
            if (!cultivation.isAwakened && cultivation.cultivationValue < cultivation.maxCultivationValue)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '距离下一阶段: ${((cultivation.getNextStageThreshold() - cultivation.cultivationValue) / 10).ceil()} 次修行',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.inkText.withValues(alpha: 0.5),
                  ),
                ),
              ),

            // 觉醒提示
            if (cultivation.cultivationValue >= cultivation.maxCultivationValue && !cultivation.isAwakened)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.amberGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '修行圆满，可进行觉醒仪式',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.amberGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 简化的养成值指示器（用于显示在角落）
class CultivationIndicator extends StatelessWidget {
  final double size;

  const CultivationIndicator({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CultivationService>(
      builder: (context, cultivation, child) {
        final progress = cultivation.progress;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.voidBackground.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppTheme.fluorescentCyan.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),

              // 进度圆环
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? AppTheme.amberGold : AppTheme.fluorescentCyan,
                  ),
                ),
              ),

              // 图标
              if (cultivation.isAwakened)
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.amberGold,
                  size: size * 0.4,
                )
              else
                Text(
                  '${cultivation.cultivationValue}',
                  style: GoogleFonts.outfit(
                    fontSize: size * 0.25,
                    color: AppTheme.inkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
