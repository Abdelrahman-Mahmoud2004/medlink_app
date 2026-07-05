import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/constants.dart';
import '../../config/environment.dart';
import 'network_exception.dart';

typedef TokenProvider = FutureOr<String?> Function();

final class ApiClient {
  final TokenProvider? tokenProvider;

  late final Dio _dio;

  ApiClient({
    this.tokenProvider,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        sendTimeout: Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.call();

          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }

          if (Environment.enableLogs && kDebugMode) {
            debugPrint('➡️ ${options.method} ${options.uri}');
            debugPrint('Headers: ${options.headers}');
            if (options.data != null) {
              debugPrint('Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (Environment.enableLogs && kDebugMode) {
            debugPrint(
              '✅ ${response.statusCode} ${response.requestOptions.uri}',
            );
          }

          handler.next(response);
        },
        onError: (error, handler) {
          if (Environment.enableLogs && kDebugMode) {
            debugPrint(
              '❌ ${error.response?.statusCode} ${error.requestOptions.uri}',
            );
            debugPrint('Error: ${error.message}');
            debugPrint('Response: ${error.response?.data}');
          }

          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException(
        message: error.toString(),
      );
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException(
        message: error.toString(),
      );
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException(
        message: error.toString(),
      );
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException(
        message: error.toString(),
      );
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return fromJson(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioException(error);
    } catch (error) {
      throw NetworkException(
        message: error.toString(),
      );
    }
  }
}