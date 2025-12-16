import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

class ChatOverlay extends StatefulWidget {
  final VoidCallback onBack;

  const ChatOverlay({super.key, required this.onBack});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: '在存亮透过的瞬息，谢谢结缘的距离？\n元神的经过的瞬息，意不如型诚语...',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Transparent background, relying on HomeScreen's MysticBackground
    return SafeArea(
      child: Column(
        children: [
           _buildHeader(context),
           Expanded(
             child: ListView.builder(
               controller: _scrollController,
               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
               itemCount: _messages.length,
               itemBuilder: (context, index) {
                 final message = _messages[index];
                 return _buildMessageBubble(message);
               },
             ),
           ),
           _buildInputArea(),
        ],
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
              child: const Icon(Icons.keyboard_arrow_down, color: AppTheme.deepVoidBlue, size: 28),
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
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
           if (!isUser) ...[
             // Avatar placeholder or small dot if needed, currently just bubble
             const SizedBox(width: 0), 
           ],
           Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280), // Limit width for readability
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
                   hintStyle: GoogleFonts.notoSerifSc(color: AppTheme.deepVoidBlue.withOpacity(0.4)),
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
                 child: Icon(Icons.arrow_upward, color: AppTheme.deepVoidBlue, size: 20),
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

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Mock AI Response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '我听到了你的心声... \n风起于青萍之末，浪成于微澜之间。此刻的迷茫，或许是觉醒的前奏。', 
            isUser: false,
            timestamp: DateTime.now(),
          ));
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
    _messageController.dispose();
    _scrollController.dispose();
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
