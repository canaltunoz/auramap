import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  // Generic helpers
  static Future<void> write(String key, String? value) =>
      _storage.write(key: key, value: value);
  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _keyAccess, value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  static Future<String?> getAccess() => _storage.read(key: _keyAccess);
  static Future<String?> getRefresh() => _storage.read(key: _keyRefresh);

  static Future<void> clear() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }
}
