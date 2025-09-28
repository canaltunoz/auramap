import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../../core/storage/secure_storage.dart';
import '../charts/service/charts_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Wait a bit more to show the splash
    await Future.delayed(const Duration(milliseconds: 1000));

    _navigate();
  }

  Future<void> _navigate() async {
    final seen = await SecureStorage.read('onboarding_seen');
    final isAuthed = (await SecureStorage.getAccess())?.isNotEmpty == true;

    if (!mounted) return;

    if (seen != 'true') {
      Navigator.of(context).pushReplacementNamed('/onboarding');
      return;
    }

    if (isAuthed) {
      // Check if user has existing charts
      try {
        final chartsService = ChartsService();
        bool hasCharts;
        try {
          final result = await chartsService.hasCharts();
          final dynamic v =
              (result['hasCharts'] ??
              result['count'] ??
              result['total'] ??
              result['length']);
          if (v is bool) {
            hasCharts = v;
          } else if (v is num) {
            hasCharts = v > 0;
          } else if (v is String) {
            final lower = v.toLowerCase().trim();
            hasCharts = lower == 'true' || int.tryParse(lower) != 0;
          } else {
            hasCharts = false;
          }
        } catch (_) {
          try {
            final list = await chartsService.listMine();
            hasCharts = list.isNotEmpty;
          } catch (_) {
            hasCharts = false;
          }
        }

        if (!mounted) return;

        if (hasCharts) {
          Navigator.of(context).pushReplacementNamed('/charts');
        } else {
          Navigator.of(context).pushReplacementNamed('/chart-creation');
        }
      } catch (e) {
        // If there's an error checking charts, go to charts screen anyway
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/charts');
        }
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background - clean white/light gray
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                    : [const Color(0xFFFAFAFA), Colors.white],
              ),
            ),
          ),

          // Human silhouette PNG - full screen height, positioned on the right edge
          Positioned(
            right: -MediaQuery.of(context).size.width * 0.15,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 1.0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.5,
                  child: Image.asset(
                    'assets/images/human.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    color: const Color(0xFFD4AF37), // Gold color
                    colorBlendMode: BlendMode.srcATop,
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main title - Human Design
                        Text(
                          AppLocalizations.of(context)!.humanDesign,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.85,
                            ),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.0,
                            fontSize: 32,
                          ),
                        ),

                        const SizedBox(height: 64),

                        // Loading indicator
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD4AF37), // Gold color
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
