import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../service/auth_service.dart';

class AuthState {
  final bool loading;
  final bool authenticated;
  final String? error;
  const AuthState({
    this.loading = false,
    this.authenticated = false,
    this.error,
  });
  AuthState copyWith({bool? loading, bool? authenticated, String? error}) =>
      AuthState(
        loading: loading ?? this.loading,
        authenticated: authenticated ?? this.authenticated,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _service;

  @override
  AuthState build() {
    _service = ref.read(authServiceProvider);
    // bootstrap asynchronously (Notifier.build must be sync)
    scheduleMicrotask(() async {
      final access = await SecureStorage.getAccess();
      if (access != null && access.isNotEmpty) {
        state = state.copyWith(authenticated: true);
      }
    });
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.login(email, password);
      state = state.copyWith(loading: false, authenticated: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Login failed');
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.register(email, password);
      await _service.login(email, password);
      state = state.copyWith(loading: false, authenticated: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Register failed');
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = state.copyWith(authenticated: false);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
