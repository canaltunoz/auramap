import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../../../core/ui/themed_image.dart';

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ThemedImage(
              baseName: 'Login',
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: Text(t.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
