import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'rive_nav_icon_painter.dart';

/// 单个导航项 - 高阶交互动画
/// 
/// 状态机模式：
/// - idle: 图标微呼吸，低饱和度
/// - hover/pressed: 缩放弹性反馈
/// - active: 完整动画（发光、粒子、旋转）+ 指示灯
/// - transition: idle ↔ active 平滑过渡
///
/// 支持 [activeImageAsset]：选中时用图片覆盖在 tab 上方（如首页的 home-active.png）
class RiveNavItem extends StatefulWidget {
  final NavIconType iconType;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  /// 选中态覆盖图片资源路径（如 'assets/images/home-active.png'）
  final String? activeImageAsset;

  /// 覆盖图片尺寸
  final double activeImageSize;

  /// 覆盖图片向上偏移量（负值 = 向上突出导航栏）
  final double activeImageOffsetY;

  const RiveNavItem({
    super.key,
    required this.iconType,
    required this.label,
    required this.isActive,
    this.onTap,
    this.activeImageAsset,
    this.activeImageSize = 64,
    this.activeImageOffsetY = -28,
  });

  @override
  State<RiveNavItem> createState() => _RiveNavItemState();
}

class _RiveNavItemState extends State<RiveNavItem>
    with TickerProviderStateMixin {
  // 激活过渡动画
  late AnimationController _activeController;
  late Animation<double> _activeCurve;

  // 呼吸/脉冲动画（持续）
  late AnimationController _pulseController;

  // 旋转动画（持续）
  late AnimationController _rotateController;

  // 点击弹性动画
  late AnimationController _bounceController;
  late Animation<double> _bounceCurve;

  // 涟漪扩散动画
  late AnimationController _rippleController;
  late Animation<double> _rippleCurve;

  @override
  void initState() {
    super.initState();

    // 激活过渡 (300ms 弹性)
    _activeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _activeCurve = CurvedAnimation(
      parent: _activeController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    if (widget.isActive) {
      _activeController.value = 1.0;
    }

    // 呼吸 (2s 循环)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 旋转 (10s 循环)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..repeat();

    // 点击弹性 (300ms)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceCurve = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_bounceController);

    // 涟漪扩散 (600ms)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleCurve = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(RiveNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _activeController.forward();
        _bounceController.forward(from: 0);
        _rippleController.forward(from: 0);
      } else {
        _activeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _activeController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _bounceController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    // 触觉反馈
    HapticFeedback.lightImpact();
    // 弹性动画
    _bounceController.forward(from: 0);
    // 涟漪
    _rippleController.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _activeCurve,
            _pulseController,
            _rotateController,
            _bounceCurve,
            _rippleCurve,
          ]),
          builder: (context, _) {
            final activeVal = _activeCurve.value;
            final pulseVal = _pulseController.value;
            final rotateVal = _rotateController.value;
            final bounceScale = _bounceCurve.value;
            final rippleVal = _rippleCurve.value;

            final activeColor = AppTheme.fluorescentCyan;
            final inactiveColor = AppTheme.inkText.withOpacity(0.45);
            final labelColor = Color.lerp(inactiveColor, activeColor, activeVal)!;

            // 是否有激活态覆盖图片
            final hasActiveImage = widget.activeImageAsset != null;
            final imgSize = widget.activeImageSize;
            final imgOffsetY = widget.activeImageOffsetY;
            // 图片出现的动画进度（呼吸 + 激活）
            final imgScale = activeVal;
            final imgPulse = 1.0 + 0.03 * math.sin(pulseVal * math.pi * 2);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标区域（含涟漪 + 弹性缩放 + 可选覆盖图片）
                SizedBox(
                  width: math.max(48, imgSize),
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 涟漪效果
                      if (_rippleController.isAnimating)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RipplePainter(
                              progress: rippleVal,
                              color: activeColor,
                            ),
                          ),
                        ),
                      // 图标本体（有激活图片时，选中后淡出）
                      Opacity(
                        opacity: hasActiveImage ? (1.0 - activeVal * 0.85) : 1.0,
                        child: Transform.scale(
                          scale: bounceScale * (1.0 + 0.06 * activeVal),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CustomPaint(
                              painter: NavIconPainter(
                                type: widget.iconType,
                                activeFraction: activeVal,
                                pulsePhase: pulseVal,
                                rotatePhase: rotateVal,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor,
                                glowColor: activeColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 激活态覆盖图片（从下方弹出，带发光）
                      if (hasActiveImage && activeVal > 0.01)
                        Positioned(
                          top: imgOffsetY * activeVal,
                          child: Transform.scale(
                            scale: bounceScale * imgScale * imgPulse,
                            child: _ActiveImageOverlay(
                              asset: widget.activeImageAsset!,
                              size: imgSize,
                              glowColor: activeColor,
                              glowIntensity: activeVal,
                              pulsePhase: pulseVal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // 标签文字
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.normal,
                    letterSpacing: widget.isActive ? 0.3 : 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // 底部灵力指示灯
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  width: widget.isActive ? 16 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: activeColor.withOpacity(activeVal),
                    boxShadow: widget.isActive
                        ? [
                            BoxShadow(
                              color: activeColor.withOpacity(0.6 * activeVal),
                              blurRadius: 8,
                              spreadRadius: -1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 涟漪绘制器
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.max(size.width, size.height) * 0.8;
    final r = maxR * progress;
    final alpha = (1.0 - progress) * 0.35;

    if (alpha <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * (1.0 - progress);

    canvas.drawCircle(center, r, paint);

    // 第二层涟漪（延迟）
    if (progress > 0.2) {
      final r2 = maxR * (progress - 0.2);
      final alpha2 = (1.0 - progress) * 0.2;
      canvas.drawCircle(
        center,
        r2,
        Paint()
          ..color = color.withOpacity(alpha2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 * (1.0 - progress),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 选中态覆盖图片 - 带发光光环和呼吸动画
class _ActiveImageOverlay extends StatelessWidget {
  final String asset;
  final double size;
  final Color glowColor;
  final double glowIntensity;
  final double pulsePhase;

  const _ActiveImageOverlay({
    required this.asset,
    required this.size,
    required this.glowColor,
    required this.glowIntensity,
    required this.pulsePhase,
  });

  @override
  Widget build(BuildContext context) {
    final pulseGlow = 0.5 + 0.5 * math.sin(pulsePhase * math.pi * 2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // 外层灵力光环
          BoxShadow(
            color: glowColor.withOpacity(0.35 * glowIntensity * pulseGlow),
            blurRadius: 20 * glowIntensity,
            spreadRadius: 2,
          ),
          // 内层柔光
          BoxShadow(
            color: glowColor.withOpacity(0.15 * glowIntensity),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
