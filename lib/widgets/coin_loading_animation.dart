import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/divination_models.dart';

/// 单次掷币动画（三枚铜钱一排）
/// 掷出后翻转，最终显示阳面或阴面
class CoinCastAnimation extends StatefulWidget {
  /// 铜钱大小
  final double coinSize;
  
  /// 掷币结果（null 表示还在翻转中）
  final List<bool>? results; // true=阳（字面），false=阴（花面）
  
  /// 掷币完成回调
  final VoidCallback? onCastComplete;
  
  /// 是否正在掷币
  final bool isCasting;

  const CoinCastAnimation({
    super.key,
    this.coinSize = 56,
    this.results,
    this.onCastComplete,
    this.isCasting = false,
  });

  @override
  State<CoinCastAnimation> createState() => _CoinCastAnimationState();
}

class _CoinCastAnimationState extends State<CoinCastAnimation>
    with TickerProviderStateMixin {
  late AnimationController _castController;
  late AnimationController _glowController;
  late List<Animation<double>> _coinFlipAnimations;
  late List<Animation<double>> _coinBounceAnimations;
  late Animation<double> _glowAnimation;
  
  bool _showingResults = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // 掷币动画 - 2秒内完成
    _castController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 三枚铜钱的翻转动画（错开启动）
    _coinFlipAnimations = List.generate(3, (index) {
      final delay = index * 0.08;
      return Tween<double>(begin: 0, end: 6 * math.pi).animate(
        CurvedAnimation(
          parent: _castController,
          curve: Interval(delay, 0.7 + delay * 0.1, curve: Curves.easeOutCubic),
        ),
      );
    });
    
    // 弹跳动画
    _coinBounceAnimations = List.generate(3, (index) {
      final delay = index * 0.08;
      return Tween<double>(begin: -60, end: 0).animate(
        CurvedAnimation(
          parent: _castController,
          curve: Interval(delay, 0.6 + delay * 0.1, curve: Curves.bounceOut),
        ),
      );
    });
    
    // 发光动画
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _castController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showingResults = true);
        HapticFeedback.mediumImpact();
        widget.onCastComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(CoinCastAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCasting && !oldWidget.isCasting) {
      _startCasting();
    }
  }

  void _startCasting() {
    setState(() => _showingResults = false);
    _castController.reset();
    _castController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _castController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_castController, _glowController]),
      builder: (context, child) {
        return Container(
          height: widget.coinSize + 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景光晕
              if (widget.isCasting || _castController.isAnimating)
                Container(
                  width: widget.coinSize * 4,
                  height: widget.coinSize + 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.coinSize),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.amberGold.withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              
              // 三枚铜钱一排
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Transform.translate(
                      offset: Offset(0, _coinBounceAnimations[index].value),
                      child: _buildFlippingCoin(index),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlippingCoin(int index) {
    final flipValue = _coinFlipAnimations[index].value;
    final isShowingFront = ((flipValue / math.pi).floor() % 2) == 0;
    
    // 如果有结果且动画完成，显示最终状态
    final showYang = _showingResults && widget.results != null
        ? widget.results![index]
        : isShowingFront;
    
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(flipValue),
      child: Container(
        width: widget.coinSize,
        height: widget.coinSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: showYang ? Alignment.topLeft : Alignment.topRight,
            end: showYang ? Alignment.bottomRight : Alignment.bottomLeft,
            colors: const [
              Color(0xFFD4A84B),
              Color(0xFFB8860B),
              Color(0xFFC9A227),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF8B7355),
            width: 2.5,
          ),
        ),
        child: Center(
          child: _showingResults && widget.results != null
              ? _buildResultIndicator(widget.results![index])
              : _buildCoinHole(),
        ),
      ),
    );
  }

  Widget _buildCoinHole() {
    return Container(
      width: widget.coinSize * 0.22,
      height: widget.coinSize * 0.22,
      decoration: BoxDecoration(
        color: AppTheme.voidBackground,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFF8B7355),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildResultIndicator(bool isYang) {
    // 阳面显示方孔，阴面显示文字
    if (isYang) {
      return _buildCoinHole();
    } else {
      return Text(
        '文',
        style: TextStyle(
          color: const Color(0xFF4A3728),
          fontSize: widget.coinSize * 0.35,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}

/// 逐爻显示的卦象构建动画
class HexagramBuildAnimation extends StatefulWidget {
  /// 当前已生成的爻列表（从初爻到上爻）
  final List<Yao> lines;
  
  /// 卦名（可选，六爻完成后显示）
  final String? hexagramName;
  
  /// 爻线高度
  final double lineHeight;
  
  /// 爻线宽度
  final double lineWidth;

  const HexagramBuildAnimation({
    super.key,
    required this.lines,
    this.hexagramName,
    this.lineHeight = 16,
    this.lineWidth = 100,
  });

  @override
  State<HexagramBuildAnimation> createState() => _HexagramBuildAnimationState();
}

class _HexagramBuildAnimationState extends State<HexagramBuildAnimation>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _lineControllers = {};
  int _lastLineCount = 0;

  @override
  void initState() {
    super.initState();
    _initControllersForCurrentLines();
  }

  void _initControllersForCurrentLines() {
    for (int i = 0; i < widget.lines.length; i++) {
      if (!_lineControllers.containsKey(i)) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        );
        _lineControllers[i] = controller;
        // 新爻进入时播放动画
        if (i >= _lastLineCount) {
          controller.forward();
        } else {
          controller.value = 1.0;
        }
      }
    }
    _lastLineCount = widget.lines.length;
  }

  @override
  void didUpdateWidget(HexagramBuildAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lines.length != oldWidget.lines.length) {
      _initControllersForCurrentLines();
    }
  }

  @override
  void dispose() {
    for (final controller in _lineControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 卦象显示区域（从上爻到初爻，即索引5到0）
        // 但生成顺序是从初爻到上爻（索引0到5）
        // 所以显示时要倒序，但动画要按生成顺序
        SizedBox(
          height: (widget.lineHeight + 8) * 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(6, (displayIndex) {
              // displayIndex 0 = 上爻（索引5），displayIndex 5 = 初爻（索引0）
              final yaoIndex = 5 - displayIndex;
              
              if (yaoIndex >= widget.lines.length) {
                // 还未生成的爻显示占位
                return _buildPlaceholderLine();
              }
              
              final yao = widget.lines[yaoIndex];
              final controller = _lineControllers[yaoIndex];
              
              return AnimatedBuilder(
                animation: controller ?? const AlwaysStoppedAnimation(1.0),
                builder: (context, child) {
                  final progress = controller?.value ?? 1.0;
                  return Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.5 + 0.5 * progress,
                      child: _buildYaoLine(yao),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        
        // 卦名（六爻完成后显示）
        if (widget.hexagramName != null && widget.lines.length == 6) ...[
          SizedBox(height: AppTheme.spacingMd),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.8 + 0.2 * value,
                  child: Text(
                    widget.hexagramName!,
                    style: TextStyle(
                      color: AppTheme.amberGold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderLine() {
    return Container(
      height: widget.lineHeight + 8,
      child: Center(
        child: Container(
          width: widget.lineWidth,
          height: widget.lineHeight,
          decoration: BoxDecoration(
            color: AppTheme.inkText.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildYaoLine(Yao yao) {
    final lineColor = yao.isChanging ? AppTheme.amberGold : AppTheme.inkText;
    
    return Container(
      height: widget.lineHeight + 8,
      child: Center(
        child: yao.isYang
            ? _buildYangLine(lineColor, yao.isChanging)
            : _buildYinLine(lineColor, yao.isChanging),
      ),
    );
  }

  Widget _buildYangLine(Color color, bool isChanging) {
    return Container(
      width: widget.lineWidth,
      height: widget.lineHeight,
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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.voidBackground,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildYinLine(Color color, bool isChanging) {
    final segmentWidth = (widget.lineWidth - 20) / 2;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: segmentWidth,
          height: widget.lineHeight,
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
        SizedBox(width: 20),
        Container(
          width: segmentWidth,
          height: widget.lineHeight,
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

/// 完整的摇卦动画组件
/// 整合掷币动画和卦象构建动画
class DivinationCastingWidget extends StatefulWidget {
  /// 当前爻数（0-6）
  final int currentYaoIndex;
  
  /// 已生成的爻列表
  final List<Yao> lines;
  
  /// 卦名
  final String? hexagramName;
  
  /// 当前掷币结果
  final List<bool>? currentCoinResults;
  
  /// 是否正在掷币
  final bool isCasting;
  
  /// 掷币完成回调
  final VoidCallback? onCastComplete;
  
  /// 提示文字
  final String? text;

  const DivinationCastingWidget({
    super.key,
    required this.currentYaoIndex,
    required this.lines,
    this.hexagramName,
    this.currentCoinResults,
    this.isCasting = false,
    this.onCastComplete,
    this.text,
  });

  @override
  State<DivinationCastingWidget> createState() => _DivinationCastingWidgetState();
}

class _DivinationCastingWidgetState extends State<DivinationCastingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _textAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 掷币动画
        CoinCastAnimation(
          coinSize: 52,
          results: widget.currentCoinResults,
          isCasting: widget.isCasting,
          onCastComplete: widget.onCastComplete,
        ),
        
        SizedBox(height: AppTheme.spacingXl),
        
        // 卦象构建动画
        HexagramBuildAnimation(
          lines: widget.lines,
          hexagramName: widget.hexagramName,
        ),
        
        SizedBox(height: AppTheme.spacingLg),
        
        // 提示文字
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value,
              child: Text(
                widget.text ?? _getDefaultText(),
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getDefaultText() {
    if (widget.lines.length == 6) {
      return '卦象已成';
    }
    return '第${_getYaoName(widget.currentYaoIndex)}爻...';
  }

  String _getYaoName(int index) {
    const names = ['初', '二', '三', '四', '五', '上'];
    if (index >= 0 && index < names.length) {
      return names[index];
    }
    return '${index + 1}';
  }
}

/// 保留旧的 ThreeCoinsAnimation 以保持兼容
class ThreeCoinsAnimation extends StatelessWidget {
  final Duration duration;
  final String? text;

  const ThreeCoinsAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return DivinationCastingWidget(
      currentYaoIndex: 0,
      lines: const [],
      isCasting: true,
      text: text,
    );
  }
}
