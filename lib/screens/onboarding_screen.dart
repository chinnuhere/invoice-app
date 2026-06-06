import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _storage = FlutterSecureStorage();

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      icon: Icons.receipt_long,
      title: 'Create Invoices',
      description: 'Generate professional invoices in seconds with our easy-to-use templates.',
    ),
    OnboardingData(
      icon: Icons.track_changes,
      title: 'Track Payments',
      description: 'Monitor your invoice status and get paid faster with payment tracking.',
    ),
    OnboardingData(
      icon: Icons.analytics,
      title: 'Analytics & Reports',
      description: 'Get insights into your business with detailed analytics and reports.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
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
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      _onboardingData[index],
                      theme,
                    );
                  },
                ),
              ),

              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                  vertical: AppConstants.spacing20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => _buildPageIndicator(index, theme),
                  ),
                ),
              ),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing24),
                child: SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: AppConstants.elevation2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radius16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: AppTextStyles.buttonText.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radius32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing48),

          // Title
          Text(
            data.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Description
          Text(
            data.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
      height: AppConstants.spacing8,
      width: _currentPage == index ? AppConstants.spacing24 : AppConstants.spacing8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.white
            : AppColors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.radius4),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
