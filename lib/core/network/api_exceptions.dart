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

  // User-friendly message for UI
  String get userFriendlyMessage {
    if (isNetworkError) {
      return 'No internet connection. Please check your network and try again.';
    } else if (isServerError) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (isTimeout) {
      return 'Request timeout. Please check your connection and try again.';
    } else {
      return message;
    }
  }

  bool get isNetworkError =>
      errorCode == 'NO_INTERNET' || errorCode == 'CONNECTION_ERROR';

  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600 ||
      errorCode == 'SERVER_ERROR' ||
      errorCode == 'SERVER_HTML_ERROR';

  bool get isTimeout =>
      errorCode == 'CONNECTION_TIMEOUT' ||
      errorCode == 'SEND_TIMEOUT' ||
      errorCode == 'RECEIVE_TIMEOUT';

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isRateLimited => statusCode == 429;
}
