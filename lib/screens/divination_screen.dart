import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/models/divination_models.dart';
import 'package:primordial_spirit/services/divination_service.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/hexagram_display.dart';
import 'package:primordial_spirit/widgets/coin_loading_animation.dart';

/// 问卜页面状态
enum DivinationState {
  welcome,      // 欢迎页，等待输入问题
  casting,      // 摇卦中
  showHexagram, // 显示卦象
  interpreting, // 解读中
  chatting,     // 对话中
}

/// 问卜页面
class DivinationScreen extends StatefulWidget {
  /// 恢复的会话（从历史记录进入时传入）
  final DivinationSession? restoredSession;

  const DivinationScreen({
    super.key,
    this.restoredSession,
  });

  @override
  State<DivinationScreen> createState() => _DivinationScreenState();
}

class _DivinationScreenState extends State<DivinationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DivinationService _divinationService = DivinationService();

  DivinationState _state = DivinationState.welcome;
  DivinationSession? _currentSession;
  StreamSubscription<String>? _interpretationSubscription;
  String _currentInterpretation = '';
  bool _isTyping = false;

  late AnimationController _welcomeAnimController;
  late Animation<double> _welcomeFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 欢迎动画
    _welcomeAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _welcomeFadeAnimation = CurvedAnimation(
      parent: _welcomeAnimController,
      curve: Curves.easeOut,
    );
    _welcomeAnimController.forward();

    // 恢复会话
    if (widget.restoredSession != null) {
      _currentSession = widget.restoredSession;
      _state = DivinationState.chatting;
    }
  }

  @override
  void dispose() {
    _welcomeAnimController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _interpretationSubscription?.cancel();
    if (_currentSession != null) {
      _divinationService.cancelInterpretation(_currentSession!.result.id);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.voidBackground,
      body: Stack(
        children: [
          // 背景
          _buildBackground(),

          // 内容
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildContent(),
              ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  /// 背景
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.voidGradient,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          color: Colors.transparent,
        ),
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
                '问卜',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              // 左右按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 返回按钮
                  _buildAppBarButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                  ),

                  // 历史记录按钮
                  _buildAppBarButton(
                    icon: Icons.history,
                    onTap: () => _navigateToHistory(),
                  ),
                ],
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

  /// 主内容区
  Widget _buildContent() {
    switch (_state) {
      case DivinationState.welcome:
        return _buildWelcomeContent();
      case DivinationState.casting:
        return _buildCastingContent();
      case DivinationState.showHexagram:
      case DivinationState.interpreting:
      case DivinationState.chatting:
        return _buildChatContent();
    }
  }

  /// 欢迎内容
  Widget _buildWelcomeContent() {
    return FadeTransition(
      opacity: _welcomeFadeAnimation,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: AppTheme.amberGold.withOpacity(0.8),
              ),
              SizedBox(height: AppTheme.spacingLg),
              Text(
                '请诚心默念您的问题',
                style: TextStyle(
                  color: AppTheme.inkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: AppTheme.spacingMd),
              Text(
                '然后在下方输入',
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: AppTheme.spacingXxl),
              _buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTips() {
    final tips = [
      '问卜需诚心正意',
      '每日同一事宜只问一次',
      '问题越具体，解读越精准',
    ];

    return Column(
      children: tips.map((tip) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: AppTheme.jadeGreen.withOpacity(0.6),
              ),
              SizedBox(width: AppTheme.spacingSm),
              Text(
                tip,
                style: TextStyle(
                  color: AppTheme.inkText.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 摇卦中内容
  Widget _buildCastingContent() {
    return Center(
      child: ThreeCoinsAnimation(
        text: '摇卦中，请稍候...',
      ),
    );
  }

  /// 聊天内容（包含卦象显示和对话）
  Widget _buildChatContent() {
    if (_currentSession == null) return const SizedBox.shrink();

    final result = _currentSession!.result;
    final messages = _currentSession!.messages;

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        100, // 底部留出空间
      ),
      children: [
        // 用户问题
        _buildMessageBubble(
          text: result.question,
          isUser: true,
        ),

        SizedBox(height: AppTheme.spacingMd),

        // 卦象显示
        HexagramDisplay(
          primaryHexagram: result.primaryHexagram,
          changedHexagram: result.changedHexagram,
          animated: _state == DivinationState.showHexagram,
        ),

        SizedBox(height: AppTheme.spacingMd),

        // 对话消息
        ...messages.map((msg) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: _buildMessageBubble(
                text: msg.text,
                isUser: msg.isUser,
              ),
            )),

        // 正在生成的解读
        if (_isTyping && _currentInterpretation.isNotEmpty)
          _buildMessageBubble(
            text: _currentInterpretation,
            isUser: false,
          ),

        // 打字指示器
        if (_isTyping && _currentInterpretation.isEmpty)
          _buildTypingIndicator(),
      ],
    );
  }

  /// 消息气泡
  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
  }) {
    final accentColor = isUser ? AppTheme.electricBlue : AppTheme.jadeGreen;
    final markdownText = text.replaceAll(r'\n', '\n');

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusMd),
              topRight: Radius.circular(AppTheme.radiusMd),
              bottomLeft: Radius.circular(
                  isUser ? AppTheme.radiusMd : AppTheme.radiusXs),
              bottomRight: Radius.circular(
                  isUser ? AppTheme.radiusXs : AppTheme.radiusMd),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.35),
                      accentColor.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMd),
                    topRight: Radius.circular(AppTheme.radiusMd),
                    bottomLeft: Radius.circular(
                        isUser ? AppTheme.radiusMd : AppTheme.radiusXs),
                    bottomRight: Radius.circular(
                        isUser ? AppTheme.radiusXs : AppTheme.radiusMd),
                  ),
                  border: Border.all(
                    color: accentColor.withOpacity(0.4),
                    width: AppTheme.borderThin,
                  ),
                ),
                child: isUser
                    ? Text(
                        text,
                        style: TextStyle(
                          color: AppTheme.inkText,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      )
                    : MarkdownWidget(
                        data: markdownText,
                        selectable: true,
                        shrinkWrap: true,
                        config: _buildMarkdownConfig(),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  MarkdownConfig _buildMarkdownConfig() {
    final textColor = AppTheme.inkText;
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 15,
      height: 1.5,
    );

    return MarkdownConfig.darkConfig.copy(
      configs: [
        PConfig(textStyle: textStyle),
        H1Config(
            style: textStyle.copyWith(
                fontSize: 20, fontWeight: FontWeight.bold)),
        H2Config(
            style: textStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.bold)),
        H3Config(
            style: textStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// 打字指示器
  Widget _buildTypingIndicator() {
    return Row(
      children: [
        ClipRRect(
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
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1.0),
                    duration: Duration(milliseconds: 600 + index * 200),
                    builder: (context, value, child) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.jadeGreen.withOpacity(value),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 输入区域
  Widget _buildInputArea() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 摇卦中禁止输入
    final isEnabled = _state != DivinationState.casting;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppTheme.radiusXl),
        topRight: Radius.circular(AppTheme.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
        child: Container(
          padding: EdgeInsets.only(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            top: AppTheme.spacingMd,
            bottom: keyboardHeight + bottomPadding + AppTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: AppTheme.liquidGlassBase,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXl),
              topRight: Radius.circular(AppTheme.radiusXl),
            ),
            border: Border(
              top: BorderSide(
                color: AppTheme.liquidGlassBorder,
                width: AppTheme.borderThin,
              ),
            ),
          ),
          child: Row(
            children: [
              // 麦克风按钮
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.liquidGlassLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.liquidGlassBorderSoft,
                    width: AppTheme.borderThin,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.mic,
                      color: AppTheme.inkText.withOpacity(0.8), size: 22),
                  onPressed: isEnabled ? () {} : null,
                ),
              ),

              SizedBox(width: AppTheme.spacingMd),

              // 输入框
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.liquidGlassLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: AppTheme.liquidGlassBorderSoft,
                      width: AppTheme.borderThin,
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
                    enabled: isEnabled,
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: _getInputHint(),
                      hintStyle: TextStyle(
                        color: AppTheme.inkText.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      isDense: true,
                    ),
                    maxLines: 1,
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
              ),

              SizedBox(width: AppTheme.spacingMd),

              // 发送按钮
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.fluorescentCyan, AppTheme.electricBlue],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.fluorescentCyan.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: _state == DivinationState.casting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: isEnabled ? _handleSubmit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInputHint() {
    switch (_state) {
      case DivinationState.welcome:
        return '请输入您想问卜的问题...';
      case DivinationState.casting:
        return '正在摇卦...';
      case DivinationState.showHexagram:
      case DivinationState.interpreting:
      case DivinationState.chatting:
        return '继续提问...';
    }
  }

  /// 处理提交
  void _handleSubmit() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _inputController.clear();

    if (_state == DivinationState.welcome) {
      _startDivination(text);
    } else if (_state == DivinationState.chatting) {
      _sendFollowUpQuestion(text);
    }
  }

  /// 开始问卜
  Future<void> _startDivination(String question) async {
    setState(() {
      _state = DivinationState.casting;
    });

    try {
      // 生成卦象
      final result = await _divinationService.generateHexagram(question);

      // 创建会话
      _currentSession = DivinationSession(
        id: result.id,
        result: result,
      );

      setState(() {
        _state = DivinationState.showHexagram;
      });

      // 延迟后开始解读
      await Future.delayed(const Duration(milliseconds: 1500));
      _startInterpretation();
    } catch (e) {
      debugPrint('问卜失败: $e');
      setState(() {
        _state = DivinationState.welcome;
      });
      _showError('问卜失败，请重试');
    }
  }

  /// 开始解读
  void _startInterpretation() {
    if (_currentSession == null) return;

    setState(() {
      _state = DivinationState.interpreting;
      _isTyping = true;
      _currentInterpretation = '';
    });

    final modelManager = context.read<ModelManagerService>();
    final fortuneData = modelManager.fortuneData;

    _interpretationSubscription?.cancel();
    _interpretationSubscription = _divinationService
        .getInterpretation(
      _currentSession!.result,
      _currentSession!.messages,
      fortuneData: fortuneData,
    )
        .listen(
      (chunk) {
        if (!mounted) return;
        setState(() {
          _currentInterpretation += chunk;
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        // 保存解读到消息列表
        _currentSession!.addMessage(DivinationMessage(
          text: _currentInterpretation,
          isUser: false,
        ));
        
        // 保存会话
        _divinationService.saveSession(_currentSession!);

        setState(() {
          _state = DivinationState.chatting;
          _isTyping = false;
          _currentInterpretation = '';
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        debugPrint('解读错误: $error');
        setState(() {
          _state = DivinationState.chatting;
          _isTyping = false;
        });
        _showError('解读失败，请重试');
      },
    );
  }

  /// 发送追问
  void _sendFollowUpQuestion(String question) {
    if (_currentSession == null) return;

    // 添加用户消息
    _currentSession!.addMessage(DivinationMessage(
      text: question,
      isUser: true,
    ));

    setState(() {
      _isTyping = true;
      _currentInterpretation = '';
    });
    _scrollToBottom();

    final modelManager = context.read<ModelManagerService>();
    final fortuneData = modelManager.fortuneData;

    _interpretationSubscription?.cancel();
    _interpretationSubscription = _divinationService
        .getInterpretation(
      _currentSession!.result,
      _currentSession!.messages,
      fortuneData: fortuneData,
    )
        .listen(
      (chunk) {
        if (!mounted) return;
        setState(() {
          _currentInterpretation += chunk;
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        _currentSession!.addMessage(DivinationMessage(
          text: _currentInterpretation,
          isUser: false,
        ));
        
        // 保存会话
        _divinationService.saveSession(_currentSession!);

        setState(() {
          _isTyping = false;
          _currentInterpretation = '';
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        debugPrint('追问错误: $error');
        setState(() {
          _isTyping = false;
        });
        _showError('回复失败，请重试');
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToHistory() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.divinationHistory,
    );
    
    // 如果从历史记录选择了会话，恢复它
    if (result != null && result is DivinationSession) {
      setState(() {
        _currentSession = result;
        _state = DivinationState.chatting;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
      ),
    );
  }
}
