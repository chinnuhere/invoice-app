import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getDashboardSummary();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.danger,
                        ),
                        const SizedBox(height: AppConstants.spacing16),
                        Text(
                          'Error loading dashboard',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.spacing8),
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacing24),
                        ElevatedButton(
                          onPressed: _fetchDashboardData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchDashboardData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacing4),
                                  Text(
                                    'Dashboard',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing24),

                          // Stats Cards Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: AppConstants.spacing16,
                            crossAxisSpacing: AppConstants.spacing16,
                            childAspectRatio: 0.95,
                            children: [
                              _buildStatCard(
                                context,
                                icon: Icons.attach_money,
                                title: 'Revenue',
                                value: '\$${_dashboardData!['revenue']?.toStringAsFixed(2) ?? '0.00'}',
                                subtitle: 'Total revenue',
                                color: AppColors.success,
                                theme: theme,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.people,
                                title: 'Clients',
                                value: '${_dashboardData!['totalClients'] ?? 0}',
                                subtitle: 'Total clients',
                                color: AppColors.info,
                                theme: theme,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.receipt_long,
                                title: 'Invoices',
                                value: '${_dashboardData!['totalInvoices'] ?? 0}',
                                subtitle: 'Total invoices',
                                color: AppColors.warning,
                                theme: theme,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.trending_down,
                                title: 'Expenses',
                                value: '\$${_dashboardData!['expenses']?.toStringAsFixed(2) ?? '0.00'}',
                                subtitle: 'Total expenses',
                                color: AppColors.danger,
                                theme: theme,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing24),

                          // Recent Activity Section
                          Text(
                            'Recent Activity',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          _buildActivityCard(
                            context,
                            icon: Icons.check_circle,
                            iconColor: AppColors.success,
                            title: 'Invoice #1234 Paid',
                            subtitle: 'John Doe - \$2,500',
                            time: '2 hours ago',
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spacing12),
                          _buildActivityCard(
                            context,
                            icon: Icons.person_add,
                            iconColor: AppColors.info,
                            title: 'New Client Added',
                            subtitle: 'Acme Corporation',
                            time: '5 hours ago',
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spacing12),
                          _buildActivityCard(
                            context,
                            icon: Icons.receipt_long,
                            iconColor: AppColors.warning,
                            title: 'Invoice #1233 Sent',
                            subtitle: 'Jane Smith - \$1,200',
                            time: '1 day ago',
                            theme: theme,
                          ),
                          const SizedBox(height: AppConstants.spacing12),
                          _buildActivityCard(
                            context,
                            icon: Icons.shopping_cart,
                            iconColor: AppColors.danger,
                            title: 'Expense Added',
                            subtitle: 'Office Supplies - \$150',
                            time: '2 days ago',
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radius8),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppConstants.iconSize20,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppConstants.iconSize24,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
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
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
