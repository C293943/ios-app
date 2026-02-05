import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/liquid_card.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

/// 聊天页面 - 带角色背景的沉浸式对话界面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FortuneApiService _apiService = FortuneApiService();

  bool _isLoading = false;
  StreamSubscription<String>? _streamSubscription;
  late AnimationController _typingIndicatorController;
  late Animation<double> _typingAnimation;

  /// 当前聊天会话的唯一ID，用于管理 SSE 连接
  String _currentChatSessionId = '';

  @override
  void initState() {
    super.initState();
    _currentChatSessionId = 'chat_${DateTime.now().millisecondsSinceEpoch}';

    // 打字动画
    _typingIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _typingAnimation = CurvedAnimation(
      parent: _typingIndicatorController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: context.l10n.chatWelcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _typingIndicatorController.dispose();
    // 取消 SSE 连接
    _apiService.cancelFortuneStream(connectionId: _currentChatSessionId);
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // 使用主题背景色，适配深/浅模式
      backgroundColor: AppTheme.voidBackground,
      body: Stack(
        children: [
          // 1. 背景层：高斯模糊的主界面形象
          Positioned.fill(
            child: Consumer<ModelManagerService>(
              builder: (context, modelManager, child) {
                final imageUrl = modelManager.image2dUrl;
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/back-1.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultBackground();
                        },
                      );
                    },
                  );
                }
                // 默认使用本地资源作为兜底，与首页保持一致
                return Image.asset(
                  'assets/images/back-1.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultBackground();
                  },
                );
              },
            ),
          ),

          // 2. 模糊和遮罩处理
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                // 适配遮罩颜色：深色模式用黑色遮罩，浅色模式用白色遮罩
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          ),

          // 3. 内容层
          Column(
            children: [
              // 自定义AppBar
              _buildCustomAppBar(context),

              // 聊天主体区域
              Expanded(
                child: Stack(
                  children: [
                    // 角色背景(元灵形象) - 保留前景角色，稍微调整透明度或混合模式? 
                    // 用户需求是前景更清晰，所以这里不用动，背景已经模糊了，前景自然清晰。
                    _buildCharacterBackground(isTablet),

                    // 消息列表
                    _buildMessageList(isSmallScreen),
                  ],
                ),
              ),

              // 输入框区域
              _buildInputArea(context, isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.voidDeeper,
            AppTheme.inkGreen.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  /// 自定义AppBar
  Widget _buildCustomAppBar(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final textColor = AppTheme.inkText;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusXl),
        bottomRight: Radius.circular(AppTheme.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurMd, sigmaY: AppTheme.blurMd),
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
              // 居中标题
              Text(
                context.l10n.spiritName,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          },
                          child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
                        ),
                      ),
                    ),
                  ),

                  // 元神档案按钮
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
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
                        child: GestureDetector(
                          onTap: () => _showSpiritArchive(context),
                          child: Icon(Icons.folder_open_outlined, color: textColor, size: 18),
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
    );
  }

  /// 显示元神档案
  void _showSpiritArchive(BuildContext context) {
    final modelManager = context.read<ModelManagerService>();
    final fortuneData = modelManager.fortuneData;
    final textColor = AppTheme.inkText;
    final labelColor = AppTheme.inkText.withOpacity(0.7);

    if (fortuneData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无档案数据')),
      );
      return;
    }

    final dayMaster = fortuneData.baziInfo.dayMaster ?? '未知';
    final now = DateTime.now();
    final awakeningDate = fortuneData.calculatedAt;
    final guardedDays = now.difference(awakeningDate).inDays + 1;
    final totalChats = 1000 + (guardedDays * 5); 
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
                child: Container(
                  width: 320,
                  padding: EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.liquidGlassBase,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppTheme.amberGold, size: 22),
                              SizedBox(width: AppTheme.spacingSm),
                              Text(
                                '元神档案',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.all(AppTheme.spacingXs),
                              decoration: BoxDecoration(
                                color: AppTheme.liquidGlassLight,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Icon(Icons.close, color: textColor.withOpacity(0.7), size: 18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingLg),
                      
                      // 内容列表
                      _buildArchiveItem('元神名', '元神', labelColor, textColor),
                      _buildArchiveItem('元神属性', dayMaster, labelColor, textColor),
                      _buildArchiveItem('觉醒时间', '${awakeningDate.year}年${awakeningDate.month}月${awakeningDate.day}日', labelColor, textColor),
                      _buildArchiveItem('已守护时间', '$guardedDays天', labelColor, textColor),
                      _buildArchiveItem('累计对话次数', '$totalChats次', labelColor, textColor),
                      SizedBox(height: AppTheme.spacingMd),
                      LiquidDivider(),
                      SizedBox(height: AppTheme.spacingMd),
                      _buildArchiveItem('元神性格', '善解人意、温和睿智', labelColor, textColor, isMultiLine: true),
                      _buildArchiveItem('元神寄语', '愿为你照亮前行的道路，指引人生方向', labelColor, textColor, isMultiLine: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveItem(String label, String value, Color labelColor, Color valueColor, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            '$label：',
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: isMultiLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 角色背景(元灵形象) - 已移除前景层，只保留背景模糊层
  Widget _buildCharacterBackground(bool isTablet) {
    return const SizedBox.shrink();
  }


  /// 消息列表
  Widget _buildMessageList(bool isSmallScreen) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100, // 底部留出空间给输入框
      ),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message, isSmallScreen);
      },
    );
  }

  /// 打字指示器
  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingLg, left: 54),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                child: AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final opacity = ((_typingAnimation.value - delay) % 1.0).clamp(0.0, 1.0);
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.jadeGreen.withOpacity(0.25 + opacity * 0.6),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 输入框区域
  Widget _buildInputArea(BuildContext context, bool isSmallScreen) {
    // 获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final iconColor = AppTheme.inkText.withOpacity(0.8);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppTheme.radiusXl),
        topRight: Radius.circular(AppTheme.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
        child: Container(
          padding: EdgeInsets.only(
            left: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            top: AppTheme.spacingMd,
            bottom: MediaQuery.of(context).viewInsets.bottom + bottomPadding + AppTheme.spacingMd,
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
              // 语音按钮
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
                  icon: Icon(Icons.mic, color: iconColor, size: 22),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),

              SizedBox(width: AppTheme.spacingMd),

              // 文本输入框
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
                    controller: _messageController,
                    style: TextStyle(
                      color: AppTheme.inkText,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.chatInputHint,
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
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: AppTheme.borderThin,
                  ),
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
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 消息气泡
  Widget _buildMessageBubble(ChatMessage message, bool isSmallScreen) {
    final isUser = message.isUser;
    final markdownText = message.text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n');

    // 气泡样式配置 - 液态玻璃风格
    final accentColor = isUser ? AppTheme.electricBlue : AppTheme.jadeGreen;

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 气泡内容
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                topRight: Radius.circular(AppTheme.radiusMd),
                bottomLeft: Radius.circular(isUser ? AppTheme.radiusMd : AppTheme.radiusXs),
                bottomRight: Radius.circular(isUser ? AppTheme.radiusXs : AppTheme.radiusMd),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? 260 : 300,
                  ),
                  padding: EdgeInsets.only(
                    left: AppTheme.spacingMd,
                    right: AppTheme.spacingMd,
                    top: 0,
                    bottom: 2,
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
                      bottomLeft: Radius.circular(isUser ? AppTheme.radiusMd : AppTheme.radiusXs),
                      bottomRight: Radius.circular(isUser ? AppTheme.radiusXs : AppTheme.radiusMd),
                    ),
                    border: Border.all(
                      color: accentColor.withOpacity(0.4),
                      width: AppTheme.borderThin,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: MarkdownWidget(
                    data: markdownText,
                    selectable: true,
                    shrinkWrap: true,
                    config: _buildMarkdownConfig(isUser),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 头像组件
  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? LinearGradient(
                colors: [AppTheme.jadeGreen, AppTheme.electricBlue],
              )
            : LinearGradient(
                colors: [AppTheme.amberGold, AppTheme.bronzeGold],
              ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? AppTheme.jadeGreen : AppTheme.amberGold).withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 如果正在加载，先取消当前请求
    if (_isLoading) {
      _cancelCurrentRequest();
    }

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // 获取命盘数据
    final modelManager = context.read<ModelManagerService>();
    final fortuneData = modelManager.fortuneData;

    if (fortuneData != null) {
      // 有命盘数据，调用流式API
      _callFortuneStreamApi(text, fortuneData);
    } else {
      // 没有命盘数据，使用模拟回复
      _mockResponse(text);
    }
  }

  /// 取消当前请求
  void _cancelCurrentRequest() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _apiService.cancelFortuneStream(connectionId: _currentChatSessionId);

    // 如果最后一条消息是空的 AI 消息，更新为取消提示
    if (_messages.isNotEmpty && !_messages.last.isUser && _messages.last.text.isEmpty) {
      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          text: context.l10n.chatCanceled,
          isUser: false,
          timestamp: DateTime.now(),
        );
      });
    }
  }

  /// 调用流式算命API
  void _callFortuneStreamApi(String userMessage, FortuneData fortuneData) {
    // 构建消息历史
    final messages = <ChatMessageModel>[];
    for (final msg in _messages) {
      messages.add(ChatMessageModel(
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.text,
      ));
    }

    // 构建请求
    final request = FortuneRequest(
      birthInfo: fortuneData.birthInfo,
      baziInfo: fortuneData.baziInfo,
      ziweiInfo: fortuneData.ziweiInfo,
      messages: messages,
      language: context.l10n.languageName,
    );

    // 添加一个空的AI消息用于流式填充
    final aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    // 先取消之前的订阅（防止内存泄漏）
    _streamSubscription?.cancel();

    // 调用流式API，使用会话ID作为连接ID
    final stream = _apiService.fortuneStream(
      request,
      connectionId: _currentChatSessionId,
    );
    final buffer = StringBuffer();

    _streamSubscription = stream.listen(
      (chunk) {
        if (!mounted) return;
        buffer.write(chunk);
        setState(() {
          _messages[aiMessageIndex] = ChatMessage(
            text: buffer.toString(),
            isUser: false,
            timestamp: DateTime.now(),
          );
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _messages[aiMessageIndex] = ChatMessage(
            text: context.l10n.chatErrorResponse,
            isUser: false,
            timestamp: DateTime.now(),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      },
    );
  }

  /// 模拟回复（当没有命盘数据时使用）
  void _mockResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _generateAIResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
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

  MarkdownConfig _buildMarkdownConfig(bool isUser) {
    final textColor = AppTheme.inkText;
    final codeBackground = AppTheme.pureBlack.withOpacity(0.1);
    
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 15,
      height: 1.5,
    );

    return MarkdownConfig.darkConfig.copy(
      configs: [
        PConfig(textStyle: textStyle),
        H1Config(style: textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
        H2Config(style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        H3Config(style: textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        CodeConfig(style: TextStyle(
          color: textColor,
          backgroundColor: codeBackground,
          fontFamily: 'monospace',
          fontSize: 14,
        )),
        PreConfig(
          decoration: BoxDecoration(
            color: codeBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: textColor,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          language: '',
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    final textColor = AppTheme.inkText;
    final iconColor = AppTheme.warmYellow;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXl),
          topRight: Radius.circular(AppTheme.radiusXl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppTheme.blurLg, sigmaY: AppTheme.blurLg),
          child: Container(
            padding: EdgeInsets.all(AppTheme.spacingLg),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.inkText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildOptionTile(
                  icon: Icons.cleaning_services,
                  iconColor: iconColor,
                  title: context.l10n.chatClear,
                  textColor: textColor,
                  onTap: () {
                    setState(() {
                      _messages.clear();
                      _messages.add(ChatMessage(
                        text: context.l10n.chatWelcomeMessage,
                        isUser: false,
                        timestamp: DateTime.now(),
                      ));
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.history,
                  iconColor: iconColor,
                  title: context.l10n.chatHistory,
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.settings,
                  iconColor: iconColor,
                  title: context.l10n.settingsTitle,
                  textColor: textColor,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        margin: EdgeInsets.only(bottom: AppTheme.spacingSm),
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
            Icon(icon, color: iconColor, size: 22),
            SizedBox(width: AppTheme.spacingMd),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateAIResponse(String userMessage) {
    final responses = [
      context.l10n.chatMockReply1,
      context.l10n.chatMockReply2,
      context.l10n.chatMockReply3,
      context.l10n.chatMockReply4,
      context.l10n.chatMockReply5,
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return context.l10n.timeJustNow;
    } else if (difference.inHours < 1) {
      return context.l10n.timeMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return context.l10n.timeHourMinute(
        time.hour,
        time.minute.toString().padLeft(2, '0'),
      );
    } else {
      return context.l10n.timeMonthDay(time.month, time.day);
    }
  }
}

/// 聊天消息模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
