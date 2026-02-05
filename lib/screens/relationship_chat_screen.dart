// 合盘对话页面，基于合盘报告进行后续咨询。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/relationship_models.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

class RelationshipChatScreen extends StatefulWidget {
  final RelationshipReport report;

  const RelationshipChatScreen({super.key, required this.report});

  @override
  State<RelationshipChatScreen> createState() => _RelationshipChatScreenState();
}

class _RelationshipChatScreenState extends State<RelationshipChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final FortuneApiService _apiService = FortuneApiService();

  bool _isLoading = false;
  StreamSubscription<String>? _streamSubscription;
  late final String _chatSessionId;

  @override
  void initState() {
    super.initState();
    _chatSessionId = 'relationship_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages.add(
        _ChatMessage(
          text: context.l10n.relationshipSummaryMessage(widget.report.summary),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiService.cancelSSEConnection(_chatSessionId);
    _streamSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          context.l10n.relationshipChatTitle,
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ThemedBackground(
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: message.isUser
                  ? AppTheme.jadeGreen.withOpacity(0.18)
                  : AppTheme.spiritGlass.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: message.isUser
                    ? AppTheme.jadeGreen.withOpacity(0.35)
                    : AppTheme.amberGold.withOpacity(0.22),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.notoSerifSc(
                color: AppTheme.inkText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return GlassContainer(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: AppTheme.inkText),
                decoration: InputDecoration(
                  hintText: context.l10n.relationshipChatHint,
                  hintStyle: TextStyle(
                    color: AppTheme.inkText.withOpacity(0.55),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.send, color: AppTheme.warmYellow),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_isLoading) {
      _cancelCurrentRequest();
    }

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();
    _callRelationshipStream();
  }

  void _cancelCurrentRequest() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _apiService.cancelSSEConnection(_chatSessionId);
  }

  void _callRelationshipStream() {
    final history = _messages.map((message) {
      return RelationshipChatMessage(
        role: message.isUser ? 'user' : 'assistant',
        content: message.text,
      );
    }).toList();

    final request = RelationshipChatRequest(
      report: widget.report,
      messages: history,
      language: context.l10n.languageName,
    );

    final aiMessageIndex = _messages.length;
    setState(() {
      _messages.add(
        _ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
      );
    });

    _streamSubscription?.cancel();
    final stream = _apiService.relationshipStream(
      request,
      connectionId: _chatSessionId,
    );
    final buffer = StringBuffer();

    _streamSubscription = stream.listen(
      (chunk) {
        if (!mounted) return;
        buffer.write(chunk);
        setState(() {
          _messages[aiMessageIndex] = _ChatMessage(
            text: buffer.toString(),
            isUser: false,
            timestamp: DateTime.now(),
          );
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _scrollToBottom();
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _messages[aiMessageIndex] = _ChatMessage(
            text: context.l10n.relationshipChatUnavailable,
            isUser: false,
            timestamp: DateTime.now(),
          );
          _isLoading = false;
        });
        _scrollToBottom();
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
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

