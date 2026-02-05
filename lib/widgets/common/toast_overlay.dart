import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 液态玻璃风格的中间非模态提示框组件
/// 用于替代 SnackBar，显示在屏幕中央，不阻塞用户操作
class ToastOverlay extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color accentColor;
  final Duration duration;
  final VoidCallback? onComplete;

  ToastOverlay({
    super.key,
    required this.message,
    this.icon,
    Color? accentColor,
    this.duration = const Duration(seconds: 2),
    this.onComplete,
  }) : accentColor = accentColor ?? AppTheme.fluorescentCyan;

  /// 显示提示框
  /// [backgroundColor] 是 [accentColor] 的别名，用于向后兼容
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? accentColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // backgroundColor 作为 accentColor 的别名，优先使用 accentColor
    final effectiveColor = accentColor ?? backgroundColor ?? AppTheme.fluorescentCyan;

    overlayEntry = OverlayEntry(
      builder: (context) => ToastOverlay(
        message: message,
        icon: icon,
        accentColor: effectiveColor,
        duration: duration,
        onComplete: () {
          overlayEntry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: AppTheme.animStandard.inMilliseconds),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // 自动关闭
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onComplete?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        // 不阻止下层交互，非模态
        ignoring: false,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildToast(),
          ),
        ),
      ),
    );
  }

  Widget _buildToast() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          // 主色发光
          BoxShadow(
            color: widget.accentColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          // 液态玻璃阴影
          ...AppTheme.liquidGlassShadows(),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.blurPremium,
            sigmaY: AppTheme.blurPremium,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLg,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppTheme.liquidGlassBase,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: widget.accentColor.withOpacity(0.4),
                width: AppTheme.borderStandard,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor.withOpacity(0.15),
                  Colors.transparent,
                  widget.accentColor.withOpacity(0.08),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingMd),
                ],
                Flexible(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.notoSansSc(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.inkText,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
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
