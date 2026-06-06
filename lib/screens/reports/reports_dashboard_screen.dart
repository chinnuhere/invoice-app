import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Current month data
  Map<String, dynamic>? _monthlyReport;
  
  // Current year data
  Map<String, dynamic>? _yearlyReport;
  
  // Revenue data
  Map<String, dynamic>? _revenueReport;

  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

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
      final results = await Future.wait([
        ApiService.getMonthlyReport(_currentYear, _currentMonth),
        ApiService.getYearlyReport(_currentYear),
        ApiService.getRevenueReport(),
      ]);

      setState(() {
        _monthlyReport = results[0];
        _yearlyReport = results[1];
        _revenueReport = results[2];
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
        child: RefreshIndicator(
          onRefresh: _fetchDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Reports Dashboard',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Financial overview and analytics',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Content
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _buildErrorState(theme)
                        : Column(
                            children: [
                              _buildQuickStats(theme),
                              const SizedBox(height: AppConstants.spacing24),
                              _buildMonthlyOverview(theme),
                              const SizedBox(height: AppConstants.spacing24),
                              _buildYearlyTrend(theme),
                              const SizedBox(height: AppConstants.spacing24),
                              _buildRevenueOverview(theme),
                              const SizedBox(height: AppConstants.spacing24),
                              _buildExpensePieChart(theme),
                              const SizedBox(height: AppConstants.spacing24),
                              _buildInvoiceStatusPieChart(theme),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: AppConstants.spacing16),
          Text('Error loading dashboard', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spacing8),
          Text(_errorMessage!, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppConstants.spacing24),
          ElevatedButton(onPressed: _fetchDashboardData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final monthlySummary = _monthlyReport?['summary'] as Map<String, dynamic>? ?? {};
    final yearlySummary = _yearlyReport?['summary'] as Map<String, dynamic>? ?? {};
    final revenueSummary = _revenueReport?['summary'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Monthly Revenue',
                '\$${(monthlySummary['totalRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                Icons.trending_up,
                AppColors.success,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: _buildStatCard(
                'Monthly Expenses',
                '\$${(monthlySummary['totalExpenses'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                Icons.trending_down,
                AppColors.danger,
                theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Net Profit',
                '\$${(monthlySummary['netProfit'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                Icons.account_balance_wallet,
                AppColors.primary,
                theme,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: _buildStatCard(
                'Paid Invoices',
                (revenueSummary['paidInvoiceCount'] as int?)?.toString() ?? '0',
                Icons.receipt_long,
                AppColors.warning,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(ThemeData theme) {
    final summary = _monthlyReport?['summary'] as Map<String, dynamic>? ?? {};

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Revenue',
                  '\$${(summary['totalRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: _buildOverviewItem(
                  'Expenses',
                  '\$${(summary['totalExpenses'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Invoices',
                  (summary['invoiceCount'] as int?)?.toString() ?? '0',
                  AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: _buildOverviewItem(
                  'Expenses',
                  (summary['expenseCount'] as int?)?.toString() ?? '0',
                  AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyTrend(ThemeData theme) {
    final summary = _yearlyReport?['summary'] as Map<String, dynamic>? ?? {};
    final invoicesByMonth = summary['invoicesByMonth'] as Map<String, dynamic>? ?? {};
    final expensesByMonth = summary['expensesByMonth'] as Map<String, dynamic>? ?? {};
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yearly Trend - $_currentYear',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[index],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(12, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (invoicesByMonth[(index + 1).toString()] as num?)?.toDouble() ?? 0,
                      );
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(12, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (expensesByMonth[(index + 1).toString()] as num?)?.toDouble() ?? 0,
                      );
                    }),
                    isCurved: true,
                    color: AppColors.danger,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', AppColors.primary),
              const SizedBox(width: AppConstants.spacing16),
              _buildLegendItem('Expenses', AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRevenueOverview(ThemeData theme) {
    final summary = _revenueReport?['summary'] as Map<String, dynamic>? ?? {};
    final topClients = summary['topClients'] as List<dynamic>? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Overview',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildRevenueItem(
                  'Total Revenue',
                  '\$${(summary['totalRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  AppColors.success,
                  theme,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _buildRevenueItem(
                  'Pending',
                  '\$${(summary['pendingRevenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  AppColors.warning,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          if (topClients.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'Top Clients',
              style: AppTextStyles.titleSmall.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            ...topClients.take(3).map((client) {
              final clientData = client as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      clientData['client']?.toString() ?? 'Unknown',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${(clientData['revenue'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value, Color color, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensePieChart(ThemeData theme) {
    final monthlySummary = _monthlyReport?['summary'] as Map<String, dynamic>? ?? {};
    final expensesByCategory = monthlySummary['expensesByCategory'] as Map<String, dynamic>? ?? {};
    
    if (expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    final pieChartData = expensesByCategory.entries.map((entry) {
      return PieChartSectionData(
        value: (entry.value as num).toDouble(),
        title: '${entry.key}\n\$${(entry.value as num).toStringAsFixed(0)}',
        titleStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 80,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Distribution',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: pieChartData.asMap().entries.map((entry) {
                  return entry.value.copyWith(
                    color: colors[entry.key % colors.length],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Wrap(
            spacing: AppConstants.spacing12,
            runSpacing: AppConstants.spacing8,
            children: expensesByCategory.entries.map((entry) {
              final index = expensesByCategory.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceStatusPieChart(ThemeData theme) {
    final monthlySummary = _monthlyReport?['summary'] as Map<String, dynamic>? ?? {};
    final invoicesByStatus = monthlySummary['invoicesByStatus'] as Map<String, dynamic>? ?? {};
    
    if (invoicesByStatus.isEmpty) {
      return const SizedBox.shrink();
    }

    final statusColors = {
      'draft': Colors.grey,
      'sent': Colors.blue,
      'paid': AppColors.success,
      'overdue': AppColors.danger,
    };

    final pieChartData = invoicesByStatus.entries.map((entry) {
      return PieChartSectionData(
        value: (entry.value as num).toDouble(),
        title: '${entry.key.toUpperCase()}\n${entry.value}',
        titleStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 80,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius16),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Status Distribution',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: pieChartData.asMap().entries.map((entry) {
                  final status = invoicesByStatus.keys.toList()[entry.key];
                  return entry.value.copyWith(
                    color: statusColors[status.toLowerCase()] ?? Colors.grey,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Wrap(
            spacing: AppConstants.spacing12,
            runSpacing: AppConstants.spacing8,
            children: invoicesByStatus.entries.map((entry) {
              final status = entry.key;
              final color = statusColors[status.toLowerCase()] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.toUpperCase(),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
