import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';
import '../config/app_config.dart';

class GlobalErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const GlobalErrorScreen({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error Warning Icon Card
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 54,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  
                  // Title
                  Text(
                    'Something went wrong',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  
                  // Description
                  Text(
                    'We encountered an unexpected error. Your data is safe. Please try restarting the app.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // Technical details section (Hidden in production)
                  if (!AppConfig.isProduction) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Technical Details (Staging/Dev only):',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacing12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(AppConstants.radius8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          details.toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing24),
                  ],

                  // Restart App Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate back to the initial splash screen and clear stack
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    icon: const Icon(Icons.refresh, color: AppColors.white),
                    label: Text(
                      'Restart App',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing32,
                        vertical: AppConstants.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                      ),
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
