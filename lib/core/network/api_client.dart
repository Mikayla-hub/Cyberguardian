import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phishguard_ai/core/config/env_config.dart';
import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final EnvConfig _config;

  ApiClient({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
    required EnvConfig config,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _config = config {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: _config.apiBaseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-App-Version': '1.0.0',
        'X-Platform': Platform.isAndroid ? 'android' : 'ios',
      },
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(secureStorage: _secureStorage, dio: _dio),
      _RequestSigningInterceptor(),
      if (_config.enableLogging) _LoggingInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  ServerException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(message: 'Connection timed out', statusCode: 408);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server error';
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'] as String;
        }
        if (statusCode == 401) {
          throw AuthException(message: message, statusCode: statusCode);
        }
        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.connectionError:
        throw const NetworkException();
      default:
        return ServerException(message: e.message ?? 'Unexpected error');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  _AuthInterceptor({required FlutterSecureStorage secureStorage, required Dio dio})
      : _secureStorage = secureStorage,
        _dio = dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final token = await _secureStorage.read(key: 'access_token');
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        }
      } catch (_) {
        await _secureStorage.deleteAll();
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${_dio.options.baseUrl}${ApiConstants.refreshTokenEndpoint}',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _secureStorage.write(key: 'access_token', value: data['access_token'] as String);
        await _secureStorage.write(key: 'refresh_token', value: data['refresh_token'] as String);
        return true;
      }
    } catch (_) {}
    return false;
  }
}

class _RequestSigningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    final payload = '${options.method}:${options.path}:$timestamp';
    final signature = sha256.convert(utf8.encode(payload)).toString();

    options.headers['X-Timestamp'] = timestamp;
    options.headers['X-Signature'] = signature;
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    SecureLogger.debug('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    SecureLogger.debug('[API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    SecureLogger.error('[API] Error: ${err.response?.statusCode} ${err.requestOptions.path}');
    handler.next(err);
  }
}
