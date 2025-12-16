import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';

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
    return Container(
      color: Colors.black.withOpacity(0.3), 
      child: SafeArea(
        child: Column(
          children: [
             _buildHeader(context),
             Expanded(
               child: ListView.builder(
                 controller: _scrollController,
                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: widget.onBack,
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                '深度对话',
                style: TextStyle(
                  color: AppTheme.accentJade,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              Container(
                 margin: const EdgeInsets.only(top: 4),
                 width: 120,
                 height: 4,
                 decoration: BoxDecoration(
                   color: Colors.white24,
                   borderRadius: BorderRadius.circular(2),
                 ),
                 child: Row(
                   children: [
                     Container(
                       width: 80,
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [AppTheme.primaryDeepIndigo, AppTheme.accentJade],
                         ),
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),
                   ],
                 ),
              ),
              const SizedBox(height: 2),
               Text(
                '元神羁绊值',
                 style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
               )
            ],
          ),
          // const Spacer(), // Removed right action
          // Model Switch Button
          // IconButton(
          //   icon: const Icon(Icons.change_circle_outlined, color: Colors.white70),
          //   tooltip: '切换元灵',
          //   onPressed: () => _showModelSelectionDialog(context),
          // ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
           Flexible(
            child: Container(
              margin: isUser 
                  ? const EdgeInsets.only(left: 60) 
                  : const EdgeInsets.only(right: 60),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Enhanced Glass effect
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isUser 
                      ? [AppTheme.accentJade.withOpacity(0.2), AppTheme.accentJade.withOpacity(0.05)]
                      : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser 
                      ? AppTheme.accentJade.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 15,
                  height: 1.4,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
        ]
      ),
      child: Row(
        children: [
           Icon(Icons.edit, color: Colors.white.withOpacity(0.6)),
           const SizedBox(width: 12),
           Expanded(
             child: TextField(
               controller: _messageController,
               style: const TextStyle(color: Colors.white),
               cursorColor: AppTheme.accentJade,
               decoration: InputDecoration(
                 hintText: '支持文字输入与语音输入',
                 hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                 border: InputBorder.none,
                 isDense: true,
               ),
               onSubmitted: (_) => _sendMessage(),
             ),
           ),
           Container(
             height: 24,
             width: 1, 
             color: Colors.white24,
             margin: const EdgeInsets.symmetric(horizontal: 8),
           ),
           Icon(Icons.grid_view, color: Colors.white.withOpacity(0.6)),
           const SizedBox(width: 8),
           GestureDetector(
             onTap: _sendMessage,
             child: Icon(Icons.mic, color: Colors.white.withOpacity(0.6)),
           ),
        ],
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
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '元神的经过的瞬息，意不如型诚语...', 
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
