import '../core/constants/api_constants.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class VisionService {
  final ApiService _api = ApiService();

  /// Server-side MobileCLIP-S0 zero-shot classification.
  /// Returns just the label string (e.g. "pottery").
  Future<String> classifyImage(String imagePath) async {
    final result = await _api.uploadFile<Map<String, dynamic>>(
      ApiConstants.classifyImage,
      filePath: imagePath,
      fieldName: 'image',
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
    if (result.success && result.data != null) {
      final label = result.data!['label'];
      if (label is String && label.isNotEmpty) return label;
    }
    throw Exception(result.message ?? 'CLASSIFY_FAILED');
  }

  Future<ApiResponse<Map<String, dynamic>>> analyzeImage(String imagePath) async {
    try {
      final result = await _api.uploadFile<Map<String, dynamic>>(
        ApiConstants.analyzeImage,
        filePath: imagePath,
        fieldName: 'image',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('VISION_FAILED', 'Unable to analyze the image.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> analyzeImageForProduct(
    String imagePath, {
    String? description,
  }) async {
    try {
      final result = await _api.uploadFile<Map<String, dynamic>>(
        ApiConstants.analyzeImage,
        filePath: imagePath,
        fieldName: 'image',
        data: {
          'purpose': 'product_analysis',
          if (description != null) 'description': description,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('VISION_FAILED', 'Unable to analyze the product.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> enhanceImage(String imagePath) async {
    try {
      final result = await _api.uploadFile<Map<String, dynamic>>(
        ApiConstants.enhanceImage,
        filePath: imagePath,
        fieldName: 'image',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('ENHANCE_FAILED', 'Unable to enhance the image.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> removeBackground(
    String imagePath,
  ) async {
    try {
      final result = await _api.uploadFile<Map<String, dynamic>>(
        '${ApiConstants.enhanceImage}/remove-background',
        filePath: imagePath,
        fieldName: 'image',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );
      return result;
    } catch (e) {
      return ApiResponse.error('BG_REMOVE_FAILED', 'Unable to remove background.');
    }
  }
}
