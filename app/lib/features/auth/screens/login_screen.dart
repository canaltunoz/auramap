import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/ui/themed_image.dart';
import 'package:auramap_app/l10n/app_localizations.dart';
import '../../../core/services/google_auth_service.dart';
import '../providers/auth_provider.dart';
import '../../charts/service/charts_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  Future<void> _navigateAfterLogin() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, // 6% of screen width
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top section with logo
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Image
                    ThemedImage(
                      baseName: 'Login',
                      height: isSmallScreen
                          ? screenHeight * 0.25
                          : screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              // Middle section with title - exactly centered between logo and buttons
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.loginTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: isSmallScreen ? 20 : 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Bottom section with buttons
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bottom section with buttons - positioned just above safe area
                    // Apple Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Apple login implementation
                        },
                        icon: Image.asset(
                          'assets/icons/apple.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.continueWithApple,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          try {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.signingInWithGoogle,
                                ),
                              ),
                            );

                            // Create Google Auth Service instance
                            final googleAuthService = GoogleAuthService(
                              serverClientId:
                                  dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '',
                            );

                            // Sign in with Google
                            final result = await googleAuthService.signIn();

                            // Send server auth code to backend
                            await ref
                                .read(authProvider.notifier)
                                .googleLogin(result.serverAuthCode);

                            // Navigate after successful login
                            await _navigateAfterLogin();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ ${AppLocalizations.of(context)!.googleLoginSuccess}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (error) {
                            print('❌ Google login error: $error');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '❌ ${AppLocalizations.of(context)!.googleLoginFailed}: $error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Image.asset(
                          'assets/icons/google.png',
                          width: 20,
                          height: 20,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.continueWithGoogle,
                        ),
                      ),
                    ),
                    // Bottom padding to position buttons just above safe area
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
