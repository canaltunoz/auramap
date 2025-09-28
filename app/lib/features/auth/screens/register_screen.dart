import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.register)),
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
                          .register(_email.text, _password.text);
                      if (!context.mounted) return;
                      if (ref.read(authProvider).authenticated) {
                        Navigator.of(context).pushReplacementNamed('/charts');
                      }
                    },
              child: auth.loading
                  ? const CircularProgressIndicator()
                  : Text(t.createAccount),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              child: Text(t.haveAccountLogin),
            ),
          ],
        ),
      ),
    );
  }
}
