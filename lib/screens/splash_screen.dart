import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkAuthAndNavigate();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      const storage = FlutterSecureStorage();
      final onboardingCompleted = await storage.read(key: 'onboarding_completed');
      
      if (onboardingCompleted == null) {
        // Show onboarding for first-time users
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
        return;
      }

      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        // Validate session
        final isValid = await AuthService.validateSession();
        
        if (mounted) {
          if (isValid) {
            // Navigate to dashboard
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            // Session invalid, navigate to login
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        // Not logged in, navigate to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      // On error, navigate to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.light
                ? [AppColors.lightPrimary, AppColors.lightSecondary]
                : [AppColors.darkPrimary, AppColors.darkSecondary],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.radius24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing32),
                  
                  // App Name
                  Text(
                    'Invoice App',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  
                  // Tagline
                  Text(
                    'Simplify your invoicing',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing48),
                  
                  // Loading Indicator
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
