import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class ConversationManager extends ChangeNotifier {
  static const _uuid = Uuid();
  
  Conversation? _currentConversation;
  final List<Conversation> _conversations = [];
  String? _selectedProductId;
  String? _selectedOrderId;
  String _currentScreen = 'home';
  String _userLanguage = 'en';

  Conversation? get currentConversation => _currentConversation;
  List<Conversation> get conversations => _conversations;
  String? get selectedProductId => _selectedProductId;
  String? get selectedOrderId => _selectedOrderId;
  String get currentScreen => _currentScreen;
  String get userLanguage => _userLanguage;

  Map<String, dynamic> get context {
    return {
      'conversation_id': _currentConversation?.id,
      'current_screen': _currentScreen,
      'selected_product_id': _selectedProductId,
      'selected_order_id': _selectedOrderId,
      'user_language': _userLanguage,
      'message_count': _currentConversation?.messages.length ?? 0,
    };
  }

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setUserLanguage(String language) {
    _userLanguage = language;
    notifyListeners();
  }

  void selectProduct(String? productId) {
    _selectedProductId = productId;
    notifyListeners();
  }

  void selectOrder(String? orderId) {
    _selectedOrderId = orderId;
    notifyListeners();
  }

  void startNewConversation() {
    _currentConversation = Conversation(
      id: _uuid.v4(),
      userId: '',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _conversations.insert(0, _currentConversation!);
    notifyListeners();
  }

  void addUserMessage(String content, {String? intent}) {
    if (_currentConversation == null) {
      startNewConversation();
    }

    final message = ConversationMessage(
      id: _uuid.v4(),
      role: 'user',
      content: content,
      intent: intent,
      timestamp: DateTime.now(),
    );

    _currentConversation!.messages.add(message);
    _currentConversation = _currentConversation!.copyWith(
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void addAssistantMessage(
    String content, {
    String? intent,
    Map<String, dynamic>? metadata,
  }) {
    if (_currentConversation == null) return;

    final message = ConversationMessage(
      id: _uuid.v4(),
      role: 'assistant',
      content: content,
      intent: intent,
      metadata: metadata,
      timestamp: DateTime.now(),
    );

    _currentConversation!.messages.add(message);
    _currentConversation = _currentConversation!.copyWith(
      updatedAt: DateTime.now(),
    );

    if (_currentConversation!.messages.length > AppConstants.maxConversationHistory) {
      _currentConversation!.messages.removeRange(
        0,
        _currentConversation!.messages.length - AppConstants.maxConversationHistory,
      );
    }

    notifyListeners();
  }

  List<ConversationMessage> get recentMessages {
    if (_currentConversation == null) return [];
    return _currentConversation!.messages.toList();
  }

  void clearContext() {
    _selectedProductId = null;
    _selectedOrderId = null;
    notifyListeners();
  }
}
