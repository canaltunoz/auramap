import 'package:flutter/material.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../../../core/ui/themed_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = [
    _OnbPage(
      baseName: 'Onboard1',
      title: (t) => t.onb1Title,
      body: (t) => t.onb1Body,
    ),
    _OnbPage(
      baseName: 'Onboard2',
      title: (t) => t.onb2Title,
      body: (t) => t.onb2Body,
    ),
    _OnbPage(
      baseName: 'Onboard3',
      title: (t) => t.onb3Title,
      body: (t) => t.onb3Body,
    ),
  ];

  Future<void> _markSeen() async {
    await SecureStorage.write('onboarding_seen', 'true');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _pages[i],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: active ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFD4AF37)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 8.0,
              bottom: 32.0,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (_index < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      } else {
                        await _markSeen();
                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    child: Text(
                      _index < _pages.length - 1 ? t.continueLabel : t.startNow,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none, // Remove border
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await _markSeen();
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(t.skip),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef LGetter = String Function(AppLocalizations t);

class _OnbPage extends StatelessWidget {
  const _OnbPage({
    required this.baseName,
    required this.title,
    required this.body,
  });
  final String baseName;
  final LGetter title;
  final LGetter body;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titleText = title(t);
    final bodyText = body(t);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThemedImage(baseName: baseName, height: 280, fit: BoxFit.contain),
          const SizedBox(height: 32),
          Text(
            titleText,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            bodyText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
