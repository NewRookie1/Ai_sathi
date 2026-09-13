import '../core/constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/agent_action.dart';
import 'api_service.dart';

class AgentService {
  final ApiService _api = ApiService();

  Future<ApiResponse<AgentResponse>> processVoice({
    required String audioPath,
    String? currentScreen,
    String? conversationId,
    String? userLanguage,
    String? imagePath,
  }) async {
    try {
      final result = await _api.uploadFile<AgentResponse>(
        ApiConstants.voiceChat,
        filePath: audioPath,
        fieldName: 'audio',
        data: {
          if (currentScreen != null) 'current_screen': currentScreen,
          if (conversationId != null) 'conversation_id': conversationId,
          if (userLanguage != null) 'user_language': userLanguage,
        },
        fromJson: (data) => AgentResponse.fromJson(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error(
        'AGENT_FAILED',
        'Unable to process your request.',
      );
    }
  }

  Future<ApiResponse<AgentResponse>> processText({
    required String text,
    String? currentScreen,
    String? conversationId,
    String? userLanguage,
    String? imagePath,
  }) async {
    try {
      final result = await _api.post<AgentResponse>(
        ApiConstants.agentExecute,
        data: {
          'text': text,
          if (currentScreen != null) 'current_screen': currentScreen,
          if (conversationId != null) 'conversation_id': conversationId,
          if (userLanguage != null) 'user_language': userLanguage,
          if (imagePath != null) 'image_path': imagePath,
        },
        fromJson: (data) => AgentResponse.fromJson(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error(
        'AGENT_FAILED',
        'Unable to process your request.',
      );
    }
  }

  Future<ApiResponse<AgentResponse>> processVoiceAndImage({
    required String audioPath,
    required String imagePath,
    String? currentScreen,
    String? conversationId,
    String? userLanguage,
  }) async {
    try {
      final result = await _api.uploadFile<AgentResponse>(
        ApiConstants.voiceChat,
        filePath: audioPath,
        fieldName: 'audio',
        data: {
          'image_path': imagePath,
          if (currentScreen != null) 'current_screen': currentScreen,
          if (conversationId != null) 'conversation_id': conversationId,
          if (userLanguage != null) 'user_language': userLanguage,
        },
        fromJson: (data) => AgentResponse.fromJson(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error(
        'AGENT_FAILED',
        'Unable to process your request.',
      );
    }
  }
}
