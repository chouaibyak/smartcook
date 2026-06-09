import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_constants.dart';

class ChatbotService {
  static const bool useMockBackend = false;

  Future<ChatbotResponse> sendMessage({
    required String message,
    int? conversationId,
    Map<String, dynamic>? context,
    String? token,
  }) async {
    if (useMockBackend) {
      await Future.delayed(const Duration(milliseconds: 700));
      return ChatbotResponse(reply: _mockReply(message));
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/chatbot');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'message': message,
              'conversationId': conversationId,
              'context': context ?? {},
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatbotResponse(
          reply: data['reply']?.toString() ??
              data['message']?.toString() ??
              _mockReply(message),
          conversationId: _parseConversationId(data['conversationId']),
        );
      }
    } catch (_) {
      return ChatbotResponse(reply: _mockReply(message));
    }

    return ChatbotResponse(reply: _mockReply(message));
  }

   

  Future<List<ChatConversationSummary>> getConversations({
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/chatbot/conversations');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load chat history');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final conversations = data['conversations'] as List<dynamic>? ?? [];

    return conversations
        .map((item) => ChatConversationSummary.fromJson(item))
        .toList();
  }

  Future<LoadedChatConversation> getConversationMessages({
    required int conversationId,
    String? token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/chatbot/conversations/$conversationId/messages',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load chat messages');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return LoadedChatConversation.fromJson(data);
  }

  int? _parseConversationId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _mockReply(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('dessert')) {
      return 'Je peux te proposer un dessert leger selon ton profil. Par exemple: yaourt grec, fruits rouges, un peu de miel et quelques noix. Si tu me donnes tes ingredients, je te fais une recette precise.';
    }

    if (normalized.contains('low carb') || normalized.contains('carb')) {
      return 'Pour une option low carb, vise une base proteinee avec beaucoup de legumes: poulet grille, oeufs, thon ou tofu avec salade, courgettes, epinards ou brocoli. Je pourrai adapter selon ton inventaire.';
    }

    if (normalized.contains('calorie') || normalized.contains('healthy')) {
      return 'Pour rester healthy, je vais privilegier les recettes riches en proteines, avec peu de sucre ajoute et une cuisson simple. Quand le backend sera branche, je tiendrai compte de ton profil, allergies, objectifs et ingredients.';
    }

    if (normalized.contains('recette') ||
        normalized.contains('cook') ||
        normalized.contains('cuisin')) {
      return 'Oui. Donne-moi les ingredients disponibles ou choisis une categorie, et je peux te proposer une recette adaptee a ton profil SmartCook avec temps, calories, difficulte et ingredients manquants.';
    }

    return 'Je suis Chef AI. Je peux t aider avec tes recettes, ton profil alimentaire, tes objectifs nutrition, ton inventaire et ta liste de courses. Pour l instant je reponds en mode demo; le backend me donnera bientot tout ton contexte SmartCook.';
  }
}

class ChatbotResponse {
  final String reply;
  final int? conversationId;

  const ChatbotResponse({
    required this.reply,
    this.conversationId,
  });
}

class ChatConversationSummary {
  final int id;
  final String title;
  final String? lastMessage;
  final String? lastMessageAt;

  const ChatConversationSummary({
    required this.id,
    required this.title,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatConversationSummary.fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;

    return ChatConversationSummary(
      id: data['id'] as int,
      title: data['title']?.toString() ?? 'Conversation Chef AI',
      lastMessage: data['lastMessage']?.toString(),
      lastMessageAt: data['lastMessageAt']?.toString(),
    );
  }
}

class LoadedChatConversation {
  final ChatConversationSummary conversation;
  final List<LoadedChatMessage> messages;

  const LoadedChatConversation({
    required this.conversation,
    required this.messages,
  });

  factory LoadedChatConversation.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List<dynamic>? ?? [];

    return LoadedChatConversation(
      conversation: ChatConversationSummary.fromJson(json['conversation']),
      messages: messages
          .map((item) => LoadedChatMessage.fromJson(item))
          .toList(),
    );
  }
}


class LoadedChatMessage {
  final String role;
  final String content;
  final String? createdAt;

  const LoadedChatMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });


  factory LoadedChatMessage.fromJson(dynamic json) {
    final data = json as Map<String, dynamic>;

    return LoadedChatMessage(
      role: data['role']?.toString() ?? 'assistant',
      content: data['content']?.toString() ?? '',
      createdAt: data['createdAt']?.toString(),
    );
  }
}



