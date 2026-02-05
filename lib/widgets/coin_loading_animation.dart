import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_theme.dart';

/// 铜钱加载动画组件
/// 模拟古代铜钱翻转的效果
class CoinLoadingAnimation extends StatefulWidget {
  /// 铜钱大小
  final double size;
  
  /// 动画时长
  final Duration duration;
  
  /// 是否显示文字提示
  final bool showText;
  
  /// 提示文字
  final String? text;

  const CoinLoadingAnimation({
    super.key,
    this.size = 80,
    this.duration = const Duration(milliseconds: 1200),
    this.showText = true,
    this.text,
  });

  @override
  State<CoinLoadingAnimation> createState() => _CoinLoadingAnimationState();
}

class _CoinLoadingAnimationState extends State<CoinLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _pulseController;
  late Animation<double> _flipAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 翻转动画
    _flipController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutSine,
    ));
    
    // 脉冲发光动画
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 铜钱动画
        AnimatedBuilder(
          animation: Listenable.merge([_flipAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amberGold.withOpacity(_pulseAnimation.value * 0.5),
                    blurRadius: 30 + _pulseAnimation.value * 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 透视效果
                    ..rotateY(_flipAnimation.value),
                  child: _flipAnimation.value > math.pi / 2 && 
                         _flipAnimation.value < 3 * math.pi / 2
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCoinBack(),
                        )
                      : _buildCoinFront(),
                ),
              ),
            );
          },
        ),
        
        // 文字提示
        if (widget.showText) ...[
          SizedBox(height: AppTheme.spacingLg),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + _pulseAnimation.value * 0.5,
                child: Text(
                  widget.text ?? '正在问卜...',
                  style: TextStyle(
                    color: AppTheme.inkText,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  /// 铜钱正面（圆形方孔）
  Widget _buildCoinFront() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A84B), // 亮金色
            const Color(0xFFB8860B), // 暗金色
            const Color(0xFFC9A227), // 中金色
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 3,
        ),
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.25,
          height: widget.size * 0.25,
          decoration: BoxDecoration(
            color: AppTheme.voidBackground,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xFF8B7355),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  /// 铜钱背面（带文字）
  Widget _buildCoinBack() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFB8860B), // 暗金色
            const Color(0xFFD4A84B), // 亮金色
            const Color(0xFFA0522D), // 赭石色
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(-2, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '乾',
              style: TextStyle(
                color: const Color(0xFF4A3728),
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: widget.size * 0.25,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                color: AppTheme.voidBackground,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFF8B7355),
                  width: 2,
                ),
              ),
            ),
            Text(
              '坤',
              style: TextStyle(
                color: const Color(0xFF4A3728),
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 三枚铜钱摇卦动画
class ThreeCoinsAnimation extends StatefulWidget {
  final Duration duration;
  final String? text;

  const ThreeCoinsAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.text,
  });

  @override
  State<ThreeCoinsAnimation> createState() => _ThreeCoinsAnimationState();
}

class _ThreeCoinsAnimationState extends State<ThreeCoinsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late List<Animation<double>> _coinAnimations;
  late Animation<double> _glowAnimation;
  
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // 摇动动画
    _shakeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    // 为每枚铜钱创建不同的动画
    _coinAnimations = List.generate(3, (index) {
      final start = index * 0.1;
      return Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(
          parent: _shakeController,
          curve: Interval(start, 1.0, curve: Curves.easeInOutSine),
        ),
      );
    });
    
    // 发光动画
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 三枚铜钱
        AnimatedBuilder(
          animation: Listenable.merge([_shakeController, _glowController]),
          builder: (context, child) {
            return Container(
              width: 200,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 背景光晕
                  Container(
                    width: 180,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.amberGold.withOpacity(_glowAnimation.value * 0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // 三枚铜钱
                  ..._buildCoins(),
                ],
              ),
            );
          },
        ),
        
        SizedBox(height: AppTheme.spacingLg),
        
        // 文字提示
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + _glowAnimation.value * 0.5,
              child: Text(
                widget.text ?? '摇卦中...',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildCoins() {
    final positions = [
      const Offset(-50, -15),
      const Offset(0, 15),
      const Offset(50, -5),
    ];
    
    return List.generate(3, (index) {
      final animation = _coinAnimations[index];
      final position = positions[index];
      
      return Positioned(
        left: 100 + position.dx - 25,
        top: 60 + position.dy - 25 + math.sin(animation.value * 2) * 10,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(animation.value * 0.5)
            ..rotateY(animation.value)
            ..rotateZ(math.sin(animation.value) * 0.2),
          child: _buildMiniCoin(index),
        ),
      );
    });
  }

  Widget _buildMiniCoin(int index) {
    final showFront = ((_coinAnimations[index].value / math.pi).floor() % 2) == 0;
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: showFront ? Alignment.topLeft : Alignment.topRight,
          end: showFront ? Alignment.bottomRight : Alignment.bottomLeft,
          colors: [
            const Color(0xFFD4A84B),
            const Color(0xFFB8860B),
            const Color(0xFFC9A227),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.voidBackground,
            borderRadius: BorderRadius.circular(1),
            border: Border.all(
              color: const Color(0xFF8B7355),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
