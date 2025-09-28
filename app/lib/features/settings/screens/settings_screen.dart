import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          ListTile(title: Text(t.theme)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(t.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(t.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(t.themeDark)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeProvider.notifier).setTheme(s.first),
            ),
          ),
          const Divider(height: 32),
          ListTile(title: Text(t.language)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'system', label: Text(t.languageSystem)),
                ButtonSegment(value: 'en', label: Text(t.languageEnglish)),
                ButtonSegment(value: 'tr', label: Text(t.languageTurkish)),
              ],
              selected: {locale?.languageCode ?? 'system'},
              onSelectionChanged: (s) {
                final v = s.first;
                if (v == 'system') {
                  ref.read(localeProvider.notifier).setLocale(null);
                } else {
                  ref.read(localeProvider.notifier).setLocale(Locale(v));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
