import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Alanlar: temel profil + server auth code.
/// (serverAuthCode'u backend'te ID/Access/Refresh token'a exchange edin.)
class GoogleAuthResult {
  final String email;
  final String? displayName;
  final String? id; // Google userId
  final String serverAuthCode;

  GoogleAuthResult({
    required this.email,
    required this.serverAuthCode,
    this.displayName,
    this.id,
  });
}

class GoogleAuthException implements Exception {
  final String message;
  GoogleAuthException(this.message);
  @override
  String toString() => 'GoogleAuthException: $message';
}

class GoogleAuthService {
  GoogleAuthService({
    required String serverClientId,
    String?
    clientId, // iOS/web için gerekebilir; Android'de çoğu zaman şart değil
    Duration authenticateTimeout = const Duration(seconds: 15),
  }) : _serverClientId = serverClientId,
       _clientId = clientId,
       _authenticateTimeout = authenticateTimeout;

  static final GoogleSignIn _gsi = GoogleSignIn.instance;

  final String _serverClientId;
  final String? _clientId;
  final Duration _authenticateTimeout;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // v7: initialize üzerinden kimlikler
    await _gsi.initialize(clientId: _clientId, serverClientId: _serverClientId);

    // v7 API mobilde çalışır. Web/desktop ise desteklemeyebilir.
    if (!_gsi.supportsAuthenticate()) {
      throw GoogleAuthException(
        'google_sign_in v7 authenticate() bu platformda desteklenmiyor. '
        'Android/iOS çalıştırdığından emin ol veya v6 API kullan.',
      );
    }
    _initialized = true;
  }

  /// Google ile giriş yap ve serverAuthCode döndür.
  /// Not: ID token’a mobilde doğrudan güvenmeyin; backend’te exchange en doğru yol.
  Future<GoogleAuthResult> signIn({
    List<String> scopes = const ['email', 'profile', 'openid'],
  }) async {
    await initialize();

    try {
      // Event listener'ı kur
      final completer = Completer<GoogleSignInAccount?>();
      StreamSubscription<GoogleSignInAuthenticationEvent>? subscription;

      subscription = _gsi.authenticationEvents.listen(
        (event) {
          debugPrint('🔔 Authentication event: ${event.runtimeType}');

          if (event is GoogleSignInAuthenticationEventSignIn) {
            debugPrint('✅ Sign-in event received for: ${event.user.email}');
            completer.complete(event.user);
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            debugPrint('❌ Sign-out event received');
            completer.complete(null);
          }
        },
        onError: (error) {
          debugPrint('❌ Authentication event error: $error');
          completer.completeError(error);
        },
      );

      // Şimdi authenticate'i çağır
      debugPrint('🚀 Starting authentication...');
      await _gsi.authenticate();

      // Event'i bekle
      final account = await completer.future.timeout(
        _authenticateTimeout,
        onTimeout: () {
          debugPrint('⏰ Authentication timeout');
          return null;
        },
      );

      // Subscription'ı temizle
      await subscription.cancel();

      if (account == null) {
        throw GoogleAuthException('Kullanıcı iptal etti veya giriş başarısız.');
      }

      debugPrint('✅ Google account alındı: ${account.email}');

      // Authentication client'ı al
      final client = account.authorizationClient;

      // Scopes'ları authorize et
      await client.authorizeScopes(scopes);
      debugPrint('✅ Scopes authorized: $scopes');

      // Server authorization al
      final serverAuth = await client.authorizeServer(scopes);
      final code = serverAuth?.serverAuthCode;

      if (code == null || code.isEmpty) {
        throw GoogleAuthException('Server authorization başarısız (code boş).');
      }

      debugPrint('🔑 serverAuthCode alındı (uzunluğu: ${code.length})');

      return GoogleAuthResult(
        email: account.email,
        displayName: account.displayName,
        id: account.id,
        serverAuthCode: code,
      );
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      if (e is GoogleAuthException) {
        rethrow;
      }
      throw GoogleAuthException('Google Sign-In başarısız: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _gsi.signOut();
    } catch (e) {
      debugPrint('Google sign-out error: $e');
    }
  }

  /// Opsiyonel: Auth durum değişimlerini dinlemek istersen.
  Stream<GoogleSignInAuthenticationEvent> get authEvents =>
      _gsi.authenticationEvents;
}
