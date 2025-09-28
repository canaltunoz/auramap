import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/ui/themed_image.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_navigate);
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final seen = await SecureStorage.read('onboarding_seen');
    final isAuthed = (await SecureStorage.getAccess())?.isNotEmpty == true;

    if (!mounted) return;
    if (seen != 'true') {
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }
    if (isAuthed) {
      Navigator.of(context).pushReplacementNamed('/charts');
    } else {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ThemedImage(
              baseName: 'Login',
              width: 160,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text('Human Design', style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
