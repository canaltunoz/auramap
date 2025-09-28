import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.login)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: t.email),
            ),
            TextField(
              controller: _password,
              decoration: InputDecoration(labelText: t.password),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (auth.error != null)
              Text(auth.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: auth.loading
                  ? null
                  : () async {
                      await ref
                          .read(authProvider.notifier)
                          .login(_email.text, _password.text);
                      if (!context.mounted) return;
                      if (ref.read(authProvider).authenticated) {
                        Navigator.of(context).pushReplacementNamed('/charts');
                      }
                    },
              child: auth.loading
                  ? const CircularProgressIndicator()
                  : Text(t.login),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/register'),
              child: Text(t.noAccountRegister),
            ),
          ],
        ),
      ),
    );
  }
}
