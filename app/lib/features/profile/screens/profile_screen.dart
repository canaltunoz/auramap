import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Theme section (Light / Dark)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              t.theme,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, label: Text(t.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(t.themeDark)),
            ],
            selected: {
              themeMode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
            },
            onSelectionChanged: (s) =>
                ref.read(themeProvider.notifier).setTheme(s.first),
          ),

          const SizedBox(height: 24),

          // Language section (EN / TR)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              t.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text(t.languageEnglish)),
              ButtonSegment(value: 'tr', label: Text(t.languageTurkish)),
            ],
            selected: {locale?.languageCode ?? 'en'},
            onSelectionChanged: (s) {
              final code = s.first;
              ref.read(localeProvider.notifier).setLocale(Locale(code));
            },
          ),

          const SizedBox(height: 32),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: Text(t.logout),
            ),
          ),
        ],
      ),
    );
  }
}
