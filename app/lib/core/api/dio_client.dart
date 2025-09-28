import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: false,
      compact: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await SecureStorage.getAccess();
        if (access != null && access.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Try refresh once if 401
        if (e.response?.statusCode == 401 && !_isRefreshing) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // retry original
            final cloneReq = await _retryRequest(e.requestOptions);
            return handler.resolve(cloneReq);
          }
        }
        handler.next(e);
      },
    ));
  }

  late final Dio _dio;
  bool _isRefreshing = false;

  Dio get dio => _dio;

  Future<Response<dynamic>> _retryRequest(RequestOptions req) async {
    final opts = Options(
      method: req.method,
      headers: req.headers,
      contentType: req.contentType,
      responseType: req.responseType,
    );
    return _dio.request<dynamic>(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: opts,
    );
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refresh = await SecureStorage.getRefresh();
      if (refresh == null || refresh.isEmpty) return false;
      final res = await _dio.post('/auth/refresh', data: {
        'refreshToken': refresh,
      });
      final accessToken = res.data['accessToken'] as String?;
      final refreshToken = res.data['refreshToken'] as String?;
      if (accessToken == null || refreshToken == null) return false;
      await SecureStorage.saveTokens(accessToken, refreshToken);
      return true;
    } catch (_) {
      await SecureStorage.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}

