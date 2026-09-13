class AppException implements Exception {
  final String code;
  final String message;
  final int statusCode;

  AppException(this.code, this.message, [this.statusCode = 400]);

  @override
  String toString() => 'AppException: $code - $message';
}

class AuthenticationError extends AppException {
  AuthenticationError([String message = 'Authentication failed'])
      : super('AUTH_ERROR', message, 401);
}

class NotFoundError extends AppException {
  NotFoundError([String resource = 'Resource'])
      : super('NOT_FOUND', '$resource not found', 404);
}

class ValidationError extends AppException {
  ValidationError([String message = 'Validation failed'])
      : super('VALIDATION_ERROR', message, 400);
}

class AIProviderError extends AppException {
  AIProviderError(String provider, [String message = 'AI provider error'])
      : super('AI_PROVIDER_ERROR', '$provider: $message', 500);
}

class SpeechRecognitionError extends AppException {
  SpeechRecognitionError([String message = 'Speech recognition failed'])
      : super('STT_FAILED', message, 500);
}

class TranslationError extends AppException {
  TranslationError([String message = 'Translation failed'])
      : super('TRANSLATION_FAILED', message, 500);
}

class VisionError extends AppException {
  VisionError([String message = 'Image analysis failed'])
      : super('VISION_FAILED', message, 500);
}
