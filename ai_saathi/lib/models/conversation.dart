class Conversation {
  final String id;
  final String userId;
  final List<ConversationMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      userId: json['user_id'],
      messages: (json['messages'] as List?)
          ?.map((e) => ConversationMessage.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'messages': messages.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    List<ConversationMessage>? messages,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id,
      userId: userId,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ConversationMessage {
  final String id;
  final String role;
  final String content;
  final String? intent;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.metadata,
    required this.timestamp,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      intent: json['intent'],
      metadata: json['metadata'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'intent': intent,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
