/// Custom exception representing API and network errors with user-friendly messages.
class ApiException implements Exception {
  final int statusCode;
  final String rawMessage;
  final String userMessage;
  final String? error;
  final List<dynamic>? details;

  const ApiException({
    required this.statusCode,
    required this.rawMessage,
    required this.userMessage,
    this.error,
    this.details,
  });

  @override
  String toString() => userMessage;
}
