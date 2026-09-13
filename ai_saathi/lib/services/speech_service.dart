import '../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/voice_command.dart';
import 'api_service.dart';

class SpeechService {
  final ApiService _api = ApiService();

  Future<ApiResponse<VoiceCommand>> transcribe(String audioPath) async {
    try {
      final result = await _api.uploadFile<VoiceCommand>(
        ApiConstants.transcribe,
        filePath: audioPath,
        fieldName: 'audio',
        fromJson: (data) => VoiceCommand.fromJson(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('STT_FAILED', 'Unable to understand the audio.');
    }
  }

  Future<ApiResponse<VoiceCommand>> transcribeWithContext({
    required String audioPath,
    String? currentScreen,
    String? conversationId,
  }) async {
    try {
      final result = await _api.uploadFile<VoiceCommand>(
        ApiConstants.transcribe,
        filePath: audioPath,
        fieldName: 'audio',
        data: {
          if (currentScreen != null) 'current_screen': currentScreen,
          if (conversationId != null) 'conversation_id': conversationId,
        },
        fromJson: (data) => VoiceCommand.fromJson(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('STT_FAILED', 'Unable to understand the audio.');
    }
  }
}
