class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final List<dynamic>? details;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic dataJson)? fromDataJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromDataJson != null
          ? fromDataJson(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      details: json['details'] as List<dynamic>?,
    );
  }
}
