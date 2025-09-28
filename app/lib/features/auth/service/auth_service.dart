import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access != null && refresh != null) {
      await SecureStorage.saveTokens(access, refresh);
    }
    return data;
  }

  Future<Map<String, dynamic>> googleLogin(String serverAuthCode) async {
    final res = await _dio.post(
      '/auth/google',
      data: {'serverAuthCode': serverAuthCode},
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    final access = data['accessToken'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (access != null && refresh != null) {
      await SecureStorage.saveTokens(access, refresh);
    }
    return data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await SecureStorage.clear();
    }
  }
}
