import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/glass_container.dart';
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
      backgroundColor: Colors.transparent,
      body: ThemedBackground(
        child: Column(
          children: [
            // 自定义AppBar
            _buildCustomAppBar(context),

            // 聊天主体区域
            Expanded(
              child: Stack(
                children: [
                  // 角色背景(元灵形象)
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
      ),
    );
  }

  /// 自定义AppBar
  Widget _buildCustomAppBar(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GlassContainer(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: statusBarHeight + 8, // 状态栏高度 + 上边距
          bottom: 8,
        ),
        child: Row(
          children: [
            // 返回按钮
            Container(
              decoration: BoxDecoration(
                color: AppTheme.spiritGlass.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppTheme.warmYellow),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(width: 12),

            // 角色信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                        Text(
                          context.l10n.spiritName,
                          style: TextStyle(
                            color: AppTheme.warmYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.jadeGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.jadeGreen.withOpacity(0.55),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            context.l10n.chatStatusOnline,
                            style: TextStyle(
                              color: AppTheme.jadeGreen,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.chatSubtitle,
                    style: TextStyle(
                      color: AppTheme.inkText.withOpacity(0.72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // 更多选项
            Container(
              decoration: BoxDecoration(
                color: AppTheme.spiritGlass.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.more_vert, color: AppTheme.warmYellow),
                onPressed: () {
                  _showMoreOptions(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 角色背景(元灵形象)
  Widget _buildCharacterBackground(bool isTablet) {
    return Positioned(
      right: isTablet ? -100 : -50,
      top: 100,
      bottom: 200,
      width: isTablet ? 400 : 300,
      child: Opacity(
        opacity: 0.3,
        child: Consumer<ModelManagerService>(
          builder: (context, modelManager, child) {
            // 显示2D/3D角色形象
            final imageUrl = modelManager.image2dUrl;

            if (imageUrl != null && imageUrl.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultCharacter();
                  },
                ),
              );
            }

            return _buildDefaultCharacter();
          },
        ),
      ),
    );
  }

  /// 默认角色形象
  Widget _buildDefaultCharacter() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.jadeGreen.withOpacity(0.12),
            AppTheme.electricBlue.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 100,
          color: AppTheme.inkText,
        ),
      ),
    );
  }

  /// 消息列表
  Widget _buildMessageList(bool isSmallScreen) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        isSmallScreen ? 16 : 32, // 右侧留出空间给角色背景
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
      padding: const EdgeInsets.only(bottom: 20, left: 54),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.spiritGlass.withOpacity(0.55),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: AppTheme.amberGold.withOpacity(0.18), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 2),
                ),
              ],
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
                      margin: const EdgeInsets.symmetric(horizontal: 3),
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
        ],
      ),
    );
  }

  /// 输入框区域
  Widget _buildInputArea(BuildContext context, bool isSmallScreen) {
    // 获取底部安全区域高度(主要是手势条/导航栏)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GlassContainer(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + bottomPadding + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 更多功能按钮
                _buildFunctionButton(
                  icon: Icons.add_circle_outline,
                  onPressed: () {
                    // TODO: 显示更多功能
                    HapticFeedback.lightImpact();
                  },
                ),

                const SizedBox(width: 8),

                // 文本输入框
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.spiritGlass.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.amberGold.withOpacity(0.22),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: AppTheme.inkText),
                      decoration: InputDecoration(
                        hintText: context.l10n.chatInputHint,
                        hintStyle: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.55),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 发送按钮
                _buildSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 功能按钮
  Widget _buildFunctionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.spiritGlass.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.warmYellow),
        onPressed: onPressed,
      ),
    );
  }

  /// 发送按钮
  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.spiritStoneGradient(intensity: 1.0),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.jadeGreen.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.warmYellow),
                ),
              )
            : Icon(Icons.send, color: AppTheme.warmYellow),
        onPressed: _isLoading ? null : _sendMessage,
      ),
    );
  }

  /// 消息气泡
  Widget _buildMessageBubble(ChatMessage message, bool isSmallScreen) {
    final markdownConfig = _buildMarkdownConfig(message.isUser);
    final isUser = message.isUser;
    final markdownText = message.text
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? 240 : 280,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.jadeGreen.withOpacity(0.14)
                        : AppTheme.spiritGlass.withOpacity(0.55),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppTheme.jadeGreen.withOpacity(0.28)
                          : AppTheme.amberGold.withOpacity(0.22),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownWidget(
                        data: markdownText,
                        selectable: true,
                        shrinkWrap: true,
                        config: markdownConfig,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: AppTheme.inkText.withOpacity(0.55),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(isUser: true),
          ],
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
    final codeBackground = AppTheme.pureBlack.withOpacity(isUser ? 0.22 : 0.18);
    final quoteBorderColor = isUser
        ? AppTheme.jadeGreen.withOpacity(0.65)
        : AppTheme.amberGold.withOpacity(0.55);
    final linkColor = AppTheme.fluorescentCyan;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 15,
      height: 1.45,
    );

    // 使用 darkConfig 或 defaultConfig 作为基础，确保所有行内样式正确渲染
    final baseConfig = MarkdownConfig.darkConfig;

    return baseConfig.copy(
      configs: [
        // 段落样式 (p) - 包含行内元素的基础样式
        PConfig(textStyle: textStyle),
        // 标题样式 (# ~ ######)
        H1Config(style: textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
        H2Config(style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        H3Config(style: textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        H4Config(style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        H5Config(style: textStyle.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
        H6Config(style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
        // 行内代码样式 (`code`)
        CodeConfig(style: TextStyle(
          color: textColor,
          backgroundColor: codeBackground,
          fontFamily: 'monospace',
          fontSize: 14,
        )),
        // 代码块样式 (```code```)
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
        // 引用块样式 (> quote)
        BlockquoteConfig(
          sideColor: quoteBorderColor,
          textColor: textColor,
        ),
        // 列表样式 (- item 或 1. item)
        ListConfig(
          marker: (isOrdered, depth, index) {
            if (isOrdered) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  '${index + 1}.',
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              );
            } else {
              final markers = ['•', '◦', '▪'];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  markers[depth % markers.length],
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              );
            }
          },
        ),
        // 链接样式 ([text](url))
        LinkConfig(
          style: TextStyle(
            color: linkColor,
            decoration: TextDecoration.underline,
          ),
        ),
        // 图片样式 (![alt](url))
        ImgConfig(
          builder: (url, attributes) {
            return Image.network(
              url,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: codeBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, color: textColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.chatImageLoadFailed,
                        style: TextStyle(color: textColor, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        // 表格样式 (| col1 | col2 |)
        TableConfig(
          headerStyle: textStyle.copyWith(fontWeight: FontWeight.bold),
          bodyStyle: textStyle,
          border: TableBorder.all(
            color: textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        // 分割线样式 (--- 或 ***)
        HrConfig(color: textColor.withValues(alpha: 0.3)),
        // 任务列表样式 (- [ ] 或 - [x])
        CheckBoxConfig(
          builder: (checked) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Icon(
                checked ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: checked ? (isUser ? Colors.lightGreenAccent : Colors.green) : textColor,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    Icon(Icons.cleaning_services, color: AppTheme.warmYellow),
                title: Text(context.l10n.chatClear),
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
              ListTile(
                leading: Icon(Icons.history, color: AppTheme.warmYellow),
                title: Text(context.l10n.chatHistory),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 显示对话历史
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: AppTheme.warmYellow),
                title: Text(context.l10n.settingsTitle),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
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


