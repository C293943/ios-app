import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:video_player/video_player.dart';

class ChatOverlay extends StatefulWidget {
  final VoidCallback onBack;
  final List<String> animations;
  final String? currentAnimation;
  final Function(String)? onAnimationSelected;

  const ChatOverlay({
    super.key,
    required this.onBack,
    this.animations = const [],
    this.currentAnimation,
    this.onAnimationSelected,
  });

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FortuneApiService _apiService = FortuneApiService();

  bool _isLoading = false;
  StreamSubscription<String>? _streamSubscription;

  /// 当前聊天会话的唯一ID，用于管理 SSE 连接
  String _currentChatSessionId = '';

  VideoPlayerController? _backgroundVideoController;
  Future<void>? _backgroundVideoInitialize;
  String? _backgroundVideoUrl;

  @override
  void initState() {
    super.initState();
    _currentChatSessionId =
        'overlay_chat_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(
      ChatMessage(
        text: '在存亮透过的瞬息，谢谢结缘的距离？\n元神的经过的瞬息，意不如型诚语...',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelManager = context.watch<ModelManagerService>();
    final imageUrl = modelManager.image2dUrl;
    final videoUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? modelManager.getMotionVideoUrl(imageUrl)
        : null;

    _scheduleBackgroundVideoUpdate(videoUrl);

    return Stack(
      children: [
        Positioned.fill(child: _buildDynamicBackground(imageUrl: imageUrl)),
        Positioned.fill(child: _buildBackgroundScrim()),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              // 动画选择器（在输入框上方）
              if (widget.animations.isNotEmpty) _buildAnimationSelector(),
              _buildInputArea(),
            ],
          ),
        ),
      ],
    );
  }

  void _scheduleBackgroundVideoUpdate(String? nextUrl) {
    final normalized = (nextUrl != null && nextUrl.isNotEmpty) ? nextUrl : null;
    if (normalized == _backgroundVideoUrl) return;

    _backgroundVideoUrl = normalized;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_setBackgroundVideo(normalized));
    });
  }

  Future<void> _setBackgroundVideo(String? url) async {
    if (url == null) {
      await _disposeBackgroundVideoController();
      if (mounted) {
        setState(() {
          _backgroundVideoInitialize = null;
        });
      }
      return;
    }

    // 先销毁旧 controller，避免同时占用解码资源。
    await _disposeBackgroundVideoController();

    VideoPlayerController controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
    } catch (_) {
      // URL 不合法时直接回退到图片背景
      if (mounted) {
        setState(() {
          _backgroundVideoUrl = null;
          _backgroundVideoInitialize = null;
        });
      }
      return;
    }

    controller
      ..setLooping(true)
      ..setVolume(0);

    final initialize = controller.initialize();
    setState(() {
      _backgroundVideoController = controller;
      _backgroundVideoInitialize = initialize;
    });

    try {
      await initialize;
      if (!mounted) return;
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      // 初始化/播放失败回退到图片背景
      await _disposeBackgroundVideoController();
      setState(() {
        _backgroundVideoUrl = null;
        _backgroundVideoInitialize = null;
      });
    }
  }

  Future<void> _disposeBackgroundVideoController() async {
    final controller = _backgroundVideoController;
    _backgroundVideoController = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Widget _buildDynamicBackground({required String? imageUrl}) {
    if (_backgroundVideoController != null &&
        _backgroundVideoInitialize != null) {
      final controller = _backgroundVideoController!;
      return FutureBuilder<void>(
        future: _backgroundVideoInitialize,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !controller.value.isInitialized) {
            return _buildImageBackground(imageUrl);
          }

          final size = controller.value.size;
          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(controller),
            ),
          );
        },
      );
    }

    return _buildImageBackground(imageUrl);
  }

  Widget _buildImageBackground(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackBackground();
        },
      );
    }
    return _buildFallbackBackground();
  }

  Widget _buildFallbackBackground() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.deepVoidBlue.withValues(alpha: 1.0),
            AppTheme.inkGreen.withValues(alpha: 1.0),
            AppTheme.deepVoidBlue.withValues(alpha: 1.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundScrim() {
    // 让前景内容可读：对视频/图片背景做暗化渐变。
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.deepVoidBlue.withValues(alpha: 0.70),
            AppTheme.deepVoidBlue.withValues(alpha: 0.82),
            AppTheme.deepVoidBlue.withValues(alpha: 0.92),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          // Minimalist Back Button
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.deepVoidBlue,
                size: 28,
              ),
            ),
          ),
          const Spacer(),
          // Optional: Subtle indicator or title if absolutely needed, otherwise keep clean
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    // Organic shapes: "Water Drop" feel
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(4), // Point of origin
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(4), // Point of origin
            bottomRight: Radius.circular(24),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Avatar placeholder or small dot if needed, currently just bubble
            const SizedBox(width: 0),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 280,
              ), // Limit width for readability
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.jadeGreen.withOpacity(0.2)
                    : Colors.white.withOpacity(0.25),
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepVoidBlue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                message.text,
                style: GoogleFonts.notoSerifSc(
                  color: AppTheme.deepVoidBlue,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动画选择器
  Widget _buildAnimationSelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.animations.length,
          itemBuilder: (context, index) {
            final anim = widget.animations[index];
            final isSelected = anim == widget.currentAnimation;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onAnimationSelected?.call(anim);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.jadeGreen
                        : AppTheme.deepVoidBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.deepVoidBlue.withOpacity(0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatAnimationName(anim),
                    style: GoogleFonts.notoSerifSc(
                      color: isSelected ? Colors.white : AppTheme.deepVoidBlue,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 格式化动画名称
  String _formatAnimationName(String name) {
    if (name.contains('|')) {
      name = name.split('|').last;
    }
    return name.replaceAll('_', ' ');
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.mic_none, color: AppTheme.deepVoidBlue.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.notoSerifSc(color: AppTheme.deepVoidBlue),
                cursorColor: AppTheme.deepVoidBlue,
                decoration: InputDecoration(
                  hintText: '向元灵倾诉...',
                  hintStyle: GoogleFonts.notoSerifSc(
                    color: AppTheme.deepVoidBlue.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.deepVoidBlue.withOpacity(0.1),
                child: Icon(
                  Icons.arrow_upward,
                  color: AppTheme.deepVoidBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
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
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
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
      _mockResponse();
    }
  }

  /// 取消当前请求
  void _cancelCurrentRequest() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _apiService.cancelFortuneStream(connectionId: _currentChatSessionId);

    // 如果最后一条消息是空的 AI 消息，更新为取消提示
    if (_messages.isNotEmpty &&
        !_messages.last.isUser &&
        _messages.last.text.isEmpty) {
      setState(() {
        _messages[_messages.length - 1] = ChatMessage(
          text: '[已取消]',
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
      messages.add(
        ChatMessageModel(
          role: msg.isUser ? 'user' : 'assistant',
          content: msg.text,
        ),
      );
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
      _messages.add(
        ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
      );
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
  void _mockResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text: '我听到了你的心声... \n风起于青萍之末，浪成于微澜之间。此刻的迷茫，或许是觉醒的前奏。',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
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

  @override
  void dispose() {
    // 取消 SSE 连接
    _apiService.cancelFortuneStream(connectionId: _currentChatSessionId);
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_disposeBackgroundVideoController());
    super.dispose();
  }
}

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
