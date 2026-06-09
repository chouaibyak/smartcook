import 'package:flutter/material.dart';

import '../services/chatbot_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ChatbotScreen extends StatefulWidget {
  final String? token;
  final int selectedBottomNavIndex;

  const ChatbotScreen({
    super.key,
    this.token,
    this.selectedBottomNavIndex = 0,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  int? _conversationId;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello, I am Chef AI. Ask me anything about your profile, meals, nutrition, inventory or shopping list.',
      isUser: false,
      time: '12:43 PM',
    ),
  ];

  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF006C4A);
  static const Color paleGreen = Color(0xFFEFFFF7);
  static const Color borderGreen = Color(0xFFC8F6DE);
  static const Color mutedText = Color(0xFF6D6F7A);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: _formattedTime()),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await _chatbotService.sendMessage(
      message: text,
      conversationId: _conversationId,
      token: widget.token,
      context: const {
        'source': 'smartcook_mobile',
        'feature': 'chef_ai_chatbot',
      },
    );

    if (!mounted) return;

    setState(() {
      _conversationId = response.conversationId ?? _conversationId;
      _messages.add(
        ChatMessage(text: response.reply, isUser: false, time: _formattedTime()),
      );
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void onBottomNavTap(int index) {
    Navigator.pop(context, index);
  }

  Future<void> openHistory() async {
    try {
      final conversations = await _chatbotService.getConversations(
        token: widget.token,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          if (conversations.isEmpty) {
            return const SizedBox(
              height: 180,
              child: Center(child: Text('No conversation history yet.')),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              return ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline,
                  color: _ChatbotScreenState.primaryGreen,
                ),
                title: Text(
                  conversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  conversation.lastMessage ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  loadConversation(conversation.id);
                },
              );
            },
          );
        },
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load chat history')),
      );
    }
  }

  Future<void> loadConversation(int conversationId) async {
    try {
      final loaded = await _chatbotService.getConversationMessages(
        conversationId: conversationId,
        token: widget.token,
      );

      if (!mounted) return;

      setState(() {
        _conversationId = loaded.conversation.id;
        _messages
          ..clear()
          ..addAll(
            loaded.messages.map(
              (message) => ChatMessage(
                text: message.content,
                isUser: message.role == 'user',
                time: _formatDateLabel(message.createdAt),
              ),
            ),
          );
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this conversation')),
      );
    }
  }

  String _formattedTime() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDateLabel(String? value) {
    if (value == null) return '';

    final date = DateTime.tryParse(value);
    if (date == null) return '';

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(onHistoryTap: openHistory),
            const Divider(height: 1, color: Color(0xFFEFF5F1)),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                children: [
                  for (final message in _messages) ...[
                    ChatBubble(message: message),
                    const SizedBox(height: 8),
                  ],
                  if (_isLoading) const TypingIndicator(),
                ],
              ),
            ),
            QuickSuggestions(
              onSelected: (value) {
                _controller.text = value;
                sendMessage();
              },
            ),
            ChatInputBar(controller: _controller, onSend: sendMessage),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: widget.selectedBottomNavIndex,
        onTap: onBottomNavTap,
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.78,
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFF1F6F3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.time,
                style: const TextStyle(
                  color: Color(0xFF42424A),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChefAvatar(size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _ChatbotScreenState.borderGreen),
              boxShadow: [
                BoxShadow(
                  color: _ChatbotScreenState.primaryGreen.withOpacity(0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.time,
                  style: const TextStyle(
                    color: Color(0xFF9DA0A9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChatHeader extends StatelessWidget {
  final VoidCallback onHistoryTap;

  const ChatHeader({super.key, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 18, 14),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD8EFE5)),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/chef.jpg'),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartCook',
                  style: TextStyle(
                    color: _ChatbotScreenState.primaryGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF22B989),
                      size: 12,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Chef AI is online',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _ChatbotScreenState.primaryGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onHistoryTap,
            icon: const Icon(Icons.history, size: 30),
            color: const Color(0xFF6E707A),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, size: 30),
            color: _ChatbotScreenState.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class EmptyUserBubble extends StatelessWidget {
  const EmptyUserBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        height: 134,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFF5F8F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(right: 12, bottom: 6),
        child: const Text(
          '12:42 PM',
          style: TextStyle(color: Color(0xFF42424A), fontSize: 16),
        ),
      ),
    );
  }
}

class ChefMessageBubble extends StatelessWidget {
  const ChefMessageBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChefAvatar(size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 2, 10, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _ChatbotScreenState.borderGreen),
              boxShadow: [
                BoxShadow(
                  color: _ChatbotScreenState.primaryGreen.withOpacity(0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      height: 1.42,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Great choices! I see you have\nchicken and rice. Here is a low-\ncalorie Mediterranean recipe you\ncan whip up in 20 minutes.\nI recommend a ',
                      ),
                      TextSpan(
                        text: 'Lemon-Garlic\nChicken Bowl',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: ' with sauteed spinach\nand rice.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '12:43 PM',
                  style: TextStyle(
                    color: Color(0xFF9DA0A9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ChefAvatar(size: 52, faded: true),
        const SizedBox(width: 22),
        Row(
          children: List.generate(
            3,
            (index) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFA4A5AD),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class QuickSuggestions extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const QuickSuggestions({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.auto_awesome, 'Suggest dessert'),
      (Icons.ramen_dining, 'Low carb options'),
      (Icons.shopping_cart_outlined, 'Add to list'),
    ];

    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => onSelected(item.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _ChatbotScreenState.paleGreen,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _ChatbotScreenState.borderGreen),
                boxShadow: [
                  BoxShadow(
                    color: _ChatbotScreenState.primaryGreen.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    item.$1,
                    color: _ChatbotScreenState.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.$2,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemCount: items.length,
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 18),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFE3E5E9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: _ChatbotScreenState.primaryGreen,
              size: 30,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: TextStyle(
                    color: Color(0xFFA2A3AC),
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChefAvatar extends StatelessWidget {
  final double size;
  final bool faded;

  const ChefAvatar({
    super.key,
    required this.size,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.55 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/chef.jpg'),
        ),
      ),
    );
  }
}
