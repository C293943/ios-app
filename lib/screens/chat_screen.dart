import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';

/// 聊天页面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FortuneApiService _apiService = FortuneApiService();

  bool _isLoading = false;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    // 添加欢迎消息
    _messages.add(ChatMessage(
      text: '你好,我是你的专属元灵。我会陪伴你,倾听你的心声,也会在需要时给你一些人生的建议。',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '元灵',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '在线',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 显示更多选项
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // 输入框区域
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    // 更多功能按钮
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.grey.shade600),
                      onPressed: () {
                        // TODO: 显示更多功能
                      },
                    ),
                    
                    // 文本输入框
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: '说点什么...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),
                    
                    // 发送按钮
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.purple.shade700,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final markdownStyle = _buildMarkdownStyle(context, message.isUser);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.auto_awesome, color: Colors.purple.shade700, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.purple.shade700
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: markdownStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: Colors.blue.shade700, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

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
      language: AppConfig.defaultLanguage,
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

    // 调用流式API
    final stream = _apiService.fortuneStream(request);
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
            text: '抱歉，我暂时无法回应。请稍后再试。',
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

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context, bool isUser) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final textColor = isUser ? Colors.white : Colors.black87;
    final codeBackground =
        isUser ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04);
    final quoteBackground =
        isUser ? Colors.white.withValues(alpha: 0.08) : Colors.purple.shade50;
    final quoteBorderColor =
        isUser ? Colors.white.withValues(alpha: 0.5) : Colors.purple.shade200;

    return base.copyWith(
      p: (base.p ?? const TextStyle()).copyWith(
        color: textColor,
        fontSize: 15,
        height: 1.45,
      ),
      h1: (base.h1 ?? const TextStyle()).copyWith(color: textColor),
      h2: (base.h2 ?? const TextStyle()).copyWith(color: textColor),
      h3: (base.h3 ?? const TextStyle()).copyWith(color: textColor),
      h4: (base.h4 ?? const TextStyle()).copyWith(color: textColor),
      h5: (base.h5 ?? const TextStyle()).copyWith(color: textColor),
      h6: (base.h6 ?? const TextStyle()).copyWith(color: textColor),
      strong: (base.strong ?? const TextStyle(fontWeight: FontWeight.w600))
          .copyWith(color: textColor),
      em: (base.em ?? const TextStyle(fontStyle: FontStyle.italic))
          .copyWith(color: textColor),
      code: (base.code ?? const TextStyle(fontFamily: 'monospace'))
          .copyWith(color: textColor),
      listBullet: TextStyle(color: textColor, fontSize: 15),
      blockquoteDecoration: BoxDecoration(
        color: quoteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: quoteBorderColor, width: 3),
        ),
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: textColor.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  String _generateAIResponse(String userMessage) {
    // 这里是临时的模拟回复,后续会接入真实的AI API
    final responses = [
      '我理解你的感受,让我们一起来探讨一下这个问题。',
      '从你的八字来看,这个阶段确实需要更多的耐心和坚持。',
      '我一直在这里陪伴你,无论什么时候你都可以和我分享你的想法。',
      '根据你的命理,现在是一个适合思考和规划的时期。',
      '每个人都会遇到困难,重要的是如何面对它们。你做得很好。',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
