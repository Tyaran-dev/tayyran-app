// lib/core/network/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String errorCode;
  final dynamic responseData;
  final Exception? originalException;

  ApiException({
    required this.message,
    this.statusCode,
    required this.errorCode,
    this.responseData,
    this.originalException,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Code: $errorCode)';
  }

  bool get isNetworkError =>
      errorCode == 'NO_INTERNET' ||
      errorCode == 'CONNECTION_TIMEOUT' ||
      errorCode == 'CONNECTION_ERROR';

  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isRateLimited => statusCode == 429;
}
