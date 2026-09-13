import 'dart:io';
import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../core/constants/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AppConfig.authToken;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /// Wraps a raw HTTP response body into an [ApiResponse].
  ///
  /// The backend is inconsistent: some routes return a
  /// `{"success": ..., "data": ...}` envelope, some return a flat payload
  /// (`{"success": true, ...fields}`), some return a bare object (auth
  /// token) and some return a raw list (products/orders). HTTP 2xx already
  /// implies success, so anything without an explicit `"success": false`
  /// is parsed as the payload itself.
  /// Fire-and-forget backend warm-up. Render's free tier sleeps after
  /// ~15 min idle and the first request wakes it (~30-60s), so ping early
  /// while the user is still navigating.
  Future<void> warmup() async {
    try {
      final root = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/api/?$'), '');
      await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 60),
      )).get('$root/health');
    } catch (_) {
      // Warm-up is best-effort by design.
    }
  }

  ApiResponse<T> _wrapResponse<T>(dynamic body, T Function(dynamic)? fromJson) {
    if (body is Map && (body.containsKey('data') || body['success'] == false)) {
      return ApiResponse.fromJson(Map<String, dynamic>.from(body), fromJson);
    }
    try {
      final data = fromJson != null ? fromJson(body) : body as T?;
      return ApiResponse.success(data as T);
    } catch (_) {
      return ApiResponse.error('PARSE_ERROR', 'Unexpected response format.');
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _wrapResponse(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _wrapResponse(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _wrapResponse(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _wrapResponse(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final contentType = _getContentType(fileName);
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        fieldName: multipartFile,
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            ...?headers,
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: ApiConstants.uploadTimeout,
          receiveTimeout: ApiConstants.uploadTimeout,
        ),
      );

      return _wrapResponse(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  String? _getContentType(String fileName) {
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      return 'image/png';
    } else if (fileName.endsWith('.webp')) {
      return 'image/webp';
    } else if (fileName.endsWith('.mp3')) {
      return 'audio/mpeg';
    } else if (fileName.endsWith('.wav')) {
      return 'audio/wav';
    } else if (fileName.endsWith('.m4a')) {
      return 'audio/mp4';
    }
    return null;
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String code = 'UNKNOWN_ERROR';
    String message = 'Something went wrong. Please try again.';

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        code = data['error']?['code'] ?? code;
        // FastAPI errors come as {"detail": "..."} — surface them instead
        // of the generic message so users (and we) know what failed.
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] is String) {
            message = first['msg'] as String;
          }
        }
        if (data['error']?['message'] is String) {
          message = data['error']['message'] as String;
        }
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      code = 'TIMEOUT';
      message = 'Connection timed out. Please check your internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      code = 'NO_CONNECTION';
      message = 'No internet connection.';
    }

    return ApiResponse.error(code, message);
  }
}
