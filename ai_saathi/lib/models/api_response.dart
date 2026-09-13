class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      errorCode: json['error']?['code'],
      metadata: json['metadata'],
    );
  }

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String code, String message) {
    return ApiResponse(
      success: false,
      errorCode: code,
      message: message,
    );
  }
}
