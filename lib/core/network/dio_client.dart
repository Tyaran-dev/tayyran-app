// lib/core/network/dio_client.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'api_exceptions.dart';

class DioClient {
  final Dio _dio;
  String _currentLanguage = 'en'; // Default language

  DioClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'lng': 'en', // Default language
          },
        ),
      ) {
    // Add interceptors
    _setupInterceptors();
  }

  // Method to update language
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    _dio.options.headers['lng'] = languageCode;
  }

  String get currentLanguage => _currentLanguage;

  void _setupInterceptors() {
    // Logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token logic here
          // options.headers['Authorization'] = 'Bearer $token';

          // Ensure language header is always set
          options.headers['lng'] = _currentLanguage;
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // GET method
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST method
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT method
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE method
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH method (optional addition)
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Optional: Add methods for file uploads/downloads
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    print('DioError Type: ${e.type}');
    print('DioError Message: ${e.message}');
    print('DioError Response: ${e.response}');
    print('DioError Error: ${e.error}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          errorCode: 'CONNECTION_TIMEOUT',
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Send timeout. Please try again.',
          statusCode: 408,
          errorCode: 'SEND_TIMEOUT',
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Receive timeout. Server is taking too long to respond.',
          statusCode: 408,
          errorCode: 'RECEIVE_TIMEOUT',
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate error. Please try again later.',
          statusCode: 495,
          errorCode: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(e);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: 0,
          errorCode: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        // This is the key fix - connectionError doesn't always mean no internet
        if (e.message?.contains('Failed host lookup') == true ||
            e.message?.contains('Network is unreachable') == true) {
          return ApiException(
            message:
                'No internet connection. Please check your network settings.',
            statusCode: 0,
            errorCode: 'NO_INTERNET',
          );
        } else {
          return ApiException(
            message: 'Connection error: ${e.message ?? "Unknown error"}',
            statusCode: 0,
            errorCode: 'CONNECTION_ERROR',
            originalException: e,
          );
        }

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return ApiException(
            message:
                'No internet connection. Please check your network settings.',
            statusCode: 0,
            errorCode: 'NO_INTERNET',
          );
        } else if (e.error is HandshakeException) {
          return ApiException(
            message: 'SSL handshake error. Please try again later.',
            statusCode: 525,
            errorCode: 'SSL_HANDSHAKE_ERROR',
          );
        } else {
          // Handle other unknown errors more gracefully
          final errorMessage = e.message ?? 'Unknown network error';
          return ApiException(
            message: 'Network error: $errorMessage',
            statusCode: 0,
            errorCode: 'UNKNOWN_ERROR',
            originalException: e,
          );
        }
    }
  }

  ApiException _handleResponseError(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return ApiException(
          message: _getErrorMessage(
            data,
            'Bad request. Please check your input.',
          ),
          statusCode: statusCode,
          errorCode: 'BAD_REQUEST',
          responseData: data,
        );

      case 401:
        return ApiException(
          message: _getErrorMessage(data, 'Unauthorized. Please login again.'),
          statusCode: statusCode,
          errorCode: 'UNAUTHORIZED',
          responseData: data,
        );

      case 403:
        return ApiException(
          message: _getErrorMessage(
            data,
            'Forbidden. You don\'t have permission.',
          ),
          statusCode: statusCode,
          errorCode: 'FORBIDDEN',
          responseData: data,
        );

      case 404:
        return ApiException(
          message: _getErrorMessage(data, 'Resource not found.'),
          statusCode: statusCode,
          errorCode: 'NOT_FOUND',
          responseData: data,
        );

      case 429:
        return ApiException(
          message: 'Too many requests. Please try again later.',
          statusCode: statusCode,
          errorCode: 'RATE_LIMITED',
          responseData: data,
        );

      case 500:
        return ApiException(
          message: _getErrorMessage(
            data,
            'Internal server error. Please try again later.',
          ),
          statusCode: statusCode,
          errorCode: 'SERVER_ERROR',
          responseData: data,
        );

      default:
        return ApiException(
          message: _getErrorMessage(
            data,
            'An error occurred. Please try again.',
          ),
          statusCode: statusCode,
          errorCode: 'HTTP_ERROR',
          responseData: data,
        );
    }
  }

  String _getErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          defaultMessage;
    } else if (responseData is String) {
      return responseData;
    }
    return defaultMessage;
  }
}
