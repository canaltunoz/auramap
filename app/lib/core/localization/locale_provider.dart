import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

class LocaleNotifier extends Notifier<Locale?> {
  static const _key = 'locale_code';

  @override
  Locale? build() {
    scheduleMicrotask(() async {
      final v = await SecureStorage.read(_key);
      switch (v) {
        case 'en':
          state = const Locale('en');
          break;
        case 'tr':
          state = const Locale('tr');
          break;
        default:
          state = null; // system
      }
    });
    return null; // system default
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final code = locale?.languageCode;
    await SecureStorage.write(_key, code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
