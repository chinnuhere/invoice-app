import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;
  
  DateTime? _startDate;
  DateTime? _endDate;

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
      final startDate = _startDate?.toString().split(' ')[0];
      final endDate = _endDate?.toString().split(' ')[0];
      final report = await ApiService.getRevenueReport(
        startDate: startDate,
        endDate: endDate,
      );
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date Range Info
            if (_startDate != null && _endDate != null)
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                  ),
                  padding: const EdgeInsets.all(AppConstants.spacing12),
                  child: Row(
                    children: [
                      Icon(Icons.date_range, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppConstants.spacing8),
                      Text(
                        '${_startDate.toString().split(' ')[0]} - ${_endDate.toString().split(' ')[0]}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                          _fetchReport();
                        },
                        color: AppColors.primary,
                      ),
                    ],
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
                                    _buildRevenueTrendChart(theme),
                                    const SizedBox(height: AppConstants.spacing24),
                                    _buildTopClients(theme),
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
            'Revenue Summary',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Revenue',
                  '\$${(summary['totalRevenue'] as num).toStringAsFixed(2)}',
                  AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: _buildSummaryItem(
                  'Pending',
                  '\$${(summary['pendingRevenue'] as num).toStringAsFixed(2)}',
                  AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Avg Invoice',
                  '\$${(summary['avgInvoiceValue'] as num).toStringAsFixed(2)}',
                  AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: _buildSummaryItem(
                  'Paid Invoices',
                  summary['paidInvoiceCount'].toString(),
                  AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
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

  Widget _buildRevenueTrendChart(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
    final revenueByMonth = summary['revenueByMonth'] as Map<String, dynamic>? ?? {};
    
    if (revenueByMonth.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Center(
          child: Text(
            'No revenue data available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final sortedMonths = revenueByMonth.keys.toList()..sort();
    final revenueData = sortedMonths.map((month) {
      return revenueByMonth[month] as num;
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
            'Revenue Trend',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
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
                        if (index >= 0 && index < sortedMonths.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              sortedMonths[index],
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
                barGroups: List.generate(revenueData.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: revenueData[index].toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopClients(ThemeData theme) {
    final summary = _reportData!['summary'] as Map<String, dynamic>;
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
            'Top Clients by Revenue',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          if (topClients.isEmpty)
            Text(
              'No client data available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...topClients.asMap().entries.map((entry) {
              final client = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radius8),
                      ),
                      child: Center(
                        child: Text(
                          '#${entry.key + 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client['client']?.toString() ?? 'Unknown',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(client['revenue'] as num).toStringAsFixed(2)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
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
}
