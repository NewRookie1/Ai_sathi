import '../core/constants/api_constants.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class TranslationService {
  final ApiService _api = ApiService();

  Future<ApiResponse<Map<String, dynamic>>> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    try {
      final result = await _api.post<Map<String, dynamic>>(
        ApiConstants.translate,
        data: {
          'text': text,
          'target_language': targetLanguage,
          if (sourceLanguage != null) 'source_language': sourceLanguage,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('TRANSLATION_FAILED', 'Translation failed.');
    }
  }

  Future<String> normalizeToEnglish(String text, String sourceLanguage) async {
    if (sourceLanguage == 'en') return text;

    final result = await translate(
      text: text,
      targetLanguage: 'en',
      sourceLanguage: sourceLanguage,
    );

    if (result.success && result.data != null) {
      return result.data!['translated_text'] ?? text;
    }
    return text;
  }

  Future<String> translateResponse(String text, String targetLanguage) async {
    if (targetLanguage == 'en') return text;

    final result = await translate(
      text: text,
      targetLanguage: targetLanguage,
      sourceLanguage: 'en',
    );

    if (result.success && result.data != null) {
      return result.data!['translated_text'] ?? text;
    }
    return text;
  }
}
