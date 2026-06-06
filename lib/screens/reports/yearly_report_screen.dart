import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';

class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;
  
  int _selectedYear = DateTime.now().year;
  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
      final report = await ApiService.getYearlyReport(_selectedYear);
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
        title: const Text('Yearly Report'),
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
            // Year Selector
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
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
                                    _buildMonthlyTrendChart(theme),
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
            'Year $_selectedYear',
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

  Widget _buildMonthlyTrendChart(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final invoicesByMonth = summary['invoicesByMonth'] as Map<String, dynamic>? ?? {};
    final expensesByMonth = summary['expensesByMonth'] as Map<String, dynamic>? ?? {};
    
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
            'Monthly Trends',
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
                        if (index >= 0 && index < _months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _months[index],
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
