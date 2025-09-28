import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/ui/themed_image.dart';
import '../../../core/services/google_auth_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    'Giriş Yapın',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                        label: const Text('Apple ile Devam Et'),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
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
                              const SnackBar(
                                content: Text('Google ile giriş yapılıyor...'),
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

                            // Navigate to charts screen on success
                            if (mounted) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/charts');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Google ile giriş başarılı!'),
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
                                    '❌ Google girişi başarısız: $error',
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
                        label: const Text('Google ile Devam Et'),
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
