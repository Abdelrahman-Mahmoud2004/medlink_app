import 'package:dio/dio.dart';

final class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final DioException? originalException;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout. Please try again.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Send timeout. Please try again.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Receive timeout. Please try again.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Invalid security certificate.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.badResponse:
        return NetworkException(
          message: _handleBadResponse(error.response),
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection or server is unreachable.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Unexpected network error occurred.',
          statusCode: error.response?.statusCode,
          originalException: error,
        );
    }
  }

  static String _handleBadResponse(Response<dynamic>? response) {
    if (response == null) {
      return 'Unknown server error.';
    }

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
      case 422:
        return 'Validation failed. Please check your data.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return response.statusMessage ?? 'Something went wrong.';
    }
  }

  @override
  String toString() => message;
}
