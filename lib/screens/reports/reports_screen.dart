import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import 'reports_dashboard_screen.dart';
import 'monthly_report_screen.dart';
import 'yearly_report_screen.dart';
import 'revenue_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Reports',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'View detailed financial reports',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Report Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildReportCard(
                      context,
                      'Dashboard',
                      'View overall financial overview and key metrics',
                      Icons.dashboard,
                      AppColors.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsDashboardScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    _buildReportCard(
                      context,
                      'Monthly Report',
                      'View invoices and expenses for a specific month',
                      Icons.calendar_month,
                      AppColors.success,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MonthlyReportScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    _buildReportCard(
                      context,
                      'Yearly Report',
                      'View annual financial overview and trends',
                      Icons.calendar_today,
                      AppColors.warning,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YearlyReportScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing16),
                    _buildReportCard(
                      context,
                      'Revenue Report',
                      'Track paid invoices and revenue trends',
                      Icons.trending_up,
                      AppColors.danger,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RevenueReportScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
