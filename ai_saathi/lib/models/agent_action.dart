class AgentAction {
  final String tool;
  final Map<String, dynamic> parameters;
  final bool requiresConfirmation;
  final String? confirmationMessage;

  AgentAction({
    required this.tool,
    this.parameters = const {},
    this.requiresConfirmation = false,
    this.confirmationMessage,
  });

  factory AgentAction.fromJson(Map<String, dynamic> json) {
    return AgentAction(
      tool: json['tool'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      requiresConfirmation: json['requires_confirmation'] ?? false,
      confirmationMessage: json['confirmation_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tool': tool,
      'parameters': parameters,
      'requires_confirmation': requiresConfirmation,
      'confirmation_message': confirmationMessage,
    };
  }
}

class AgentResponse {
  final String intent;
  final List<AgentAction> actions;
  final Map<String, dynamic> entities;
  final double confidence;
  final bool requiresConfirmation;
  final String response;
  final String? detailedResponse;
  final String? detectedLanguage;
  final String? originalText;
  final String? normalizedText;

  AgentResponse({
    required this.intent,
    required this.actions,
    this.entities = const {},
    required this.confidence,
    this.requiresConfirmation = false,
    required this.response,
    this.detailedResponse,
    this.detectedLanguage,
    this.originalText,
    this.normalizedText,
  });

  /// Chat bubble text: rich formatted detail when the backend provides it,
  /// otherwise the short voice reply. Voice output always uses [response].
  String get chatText => (detailedResponse != null &&
          detailedResponse!.trim().isNotEmpty)
      ? detailedResponse!.trim()
      : response;

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      intent: json['intent'],
      actions: (json['actions'] as List?)
          ?.map((e) => AgentAction.fromJson(e))
          .toList() ?? [],
      entities: Map<String, dynamic>.from(json['entities'] ?? {}),
      confidence: (json['confidence'] ?? 0).toDouble(),
      requiresConfirmation: json['requires_confirmation'] ?? false,
      response: json['response'],
      detailedResponse: json['detailed_response'],
      detectedLanguage: json['detected_language'],
      originalText: json['original_text'],
      normalizedText: json['normalized_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intent': intent,
      'actions': actions.map((e) => e.toJson()).toList(),
      'entities': entities,
      'confidence': confidence,
      'requires_confirmation': requiresConfirmation,
      'response': response,
      'detailed_response': detailedResponse,
      'detected_language': detectedLanguage,
      'original_text': originalText,
      'normalized_text': normalizedText,
    };
  }
}
