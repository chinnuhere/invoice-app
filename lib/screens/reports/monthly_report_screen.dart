import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;
  
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  
  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await ApiService.getMonthlyReport(_selectedYear, _selectedMonth);
      setState(() {
        _reportData = report;
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
      appBar: AppBar(
        title: const Text('Monthly Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month/Year Selector
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing16,
                        vertical: AppConstants.spacing4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          isExpanded: true,
                          items: _months.asMap().entries.map((entry) {
                            return DropdownMenuItem<int>(
                              value: entry.key + 1,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth = value!;
                            });
                            _fetchReport();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing16,
                        vertical: AppConstants.spacing4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          isExpanded: true,
                          items: _years.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                            _fetchReport();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState(theme)
                      : _reportData == null
                          ? const Center(child: Text('No data available'))
                          : RefreshIndicator(
                              onRefresh: _fetchReport,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(AppConstants.spacing16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSummaryCard(theme),
                                    const SizedBox(height: AppConstants.spacing24),
                                    _buildInvoicesByStatus(theme),
                                    const SizedBox(height: AppConstants.spacing24),
                                    _buildExpensesByCategory(theme),
                                    const SizedBox(height: AppConstants.spacing24),
                                    _buildExpensePieChart(theme),
                                    const SizedBox(height: AppConstants.spacing24),
                                    _buildInvoiceStatusPieChart(theme),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
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
          Text('Error loading report', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spacing8),
          Text(_errorMessage!, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppConstants.spacing24),
          ElevatedButton(onPressed: _fetchReport, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    
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
            '${_months[_selectedMonth - 1]} $_selectedYear',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Revenue',
                  '\$${(summary['totalRevenue'] as num).toStringAsFixed(2)}',
                  AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: _buildSummaryItem(
                  'Expenses',
                  '\$${(summary['totalExpenses'] as num).toStringAsFixed(2)}',
                  AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          _buildSummaryItem(
            'Net Profit',
            '\$${(summary['netProfit'] as num).toStringAsFixed(2)}',
            AppColors.white,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {bool isLarge = false}) {
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
            fontSize: isLarge ? 28 : 20,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesByStatus(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final invoicesByStatus = summary['invoicesByStatus'] as Map<String, dynamic>? ?? {};
    
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
            'Invoices by Status',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...invoicesByStatus.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpensesByCategory(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final expensesByCategory = summary['expensesByCategory'] as Map<String, dynamic>? ?? {};
    
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
            'Expenses by Category',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...expensesByCategory.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${(entry.value as num).toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpensePieChart(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final expensesByCategory = summary['expensesByCategory'] as Map<String, dynamic>? ?? {};
    
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
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final invoicesByStatus = summary['invoicesByStatus'] as Map<String, dynamic>? ?? {};
    
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
