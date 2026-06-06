import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import 'add_invoice_screen.dart';
import 'invoice_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _invoices = [];
  List<dynamic> _filteredInvoices = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  final List<String> _statusFilters = ['All', 'Draft', 'Sent', 'Paid', 'Overdue'];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invoices = await ApiService.getInvoices();
      setState(() {
        _invoices = invoices;
        _filteredInvoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInvoices = _invoices.where((invoice) {
        final matchesSearch = query.isEmpty ||
            (invoice['invoice_number']?.toString().toLowerCase() ?? '').contains(query) ||
            (invoice['client_name']?.toString().toLowerCase() ?? '').contains(query);

        final matchesStatus = _selectedStatus == 'All' ||
            (invoice['status']?.toString().toLowerCase() ?? '') == _selectedStatus.toLowerCase();

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _filterInvoices();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return AppColors.success;
      case 'overdue':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoices',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddInvoiceScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchInvoices();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search invoices...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Status Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                itemCount: _statusFilters.length,
                itemBuilder: (context, index) {
                  final status = _statusFilters[index];
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) => _onStatusFilterChanged(status),
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? _buildErrorState(theme)
                      : _filteredInvoices.isEmpty
                          ? _buildEmptyState(theme)
                          : RefreshIndicator(
                              onRefresh: _fetchInvoices,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing16,
                                  vertical: AppConstants.spacing8,
                                ),
                                itemCount: _filteredInvoices.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppConstants.spacing12),
                                itemBuilder: (context, index) {
                                  final invoice = _filteredInvoices[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InvoiceDetailsScreen(invoice: invoice),
                                        ),
                                      );
                                      if (result == true) {
                                        _fetchInvoices();
                                      }
                                    },
                                    child: _buildInvoiceCard(invoice, theme),
                                  );
                                },
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Error loading invoices',
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
            onPressed: _fetchInvoices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radius24),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Text(
            _searchController.text.isNotEmpty || _selectedStatus != 'All'
                ? 'No invoices found'
                : 'No invoices yet',
            style: AppTextStyles.headlineSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            _searchController.text.isNotEmpty || _selectedStatus != 'All'
                ? 'Try different filters or search terms'
                : 'Create your first invoice to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(dynamic invoice, ThemeData theme) {
    final status = invoice['status']?.toString() ?? 'Draft';
    final statusColor = _getStatusColor(status);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice['invoice_number']?.toString() ?? 'INV-000',
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            invoice['client_name']?.toString() ?? 'Unknown Client',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            'Due: ${invoice['due_date']?.toString() ?? 'N/A'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${invoice['total']?.toStringAsFixed(2) ?? '0.00'}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
