import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../services/pdf_service.dart';
import 'edit_invoice_screen.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _invoiceDetails;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await ApiService.getInvoiceById(widget.invoice['id']);
      setState(() {
        _invoiceDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: const Text('Invoice Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              if (_invoiceDetails != null) {
                await PdfService.downloadInvoice(_invoiceDetails!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF downloaded successfully')),
                  );
                }
              }
            },
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              if (_invoiceDetails != null) {
                await PdfService.generateAndShareInvoice(_invoiceDetails!);
              }
            },
            tooltip: 'Share PDF',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditInvoiceScreen(invoice: widget.invoice),
                ),
              );
              if (result == true) {
                _fetchInvoiceDetails();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState(theme)
                : _invoiceDetails == null
                    ? const Center(child: Text('No invoice data'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Invoice Header
                            _buildInvoiceHeader(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Status Badge
                            _buildStatusBadge(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Client Information
                            _buildClientInfo(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Invoice Details
                            _buildInvoiceDetails(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Items Section
                            _buildItemsSection(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Totals Section
                            _buildTotalsSection(theme),
                            const SizedBox(height: AppConstants.spacing24),

                            // Notes Section
                            if (_invoiceDetails!['notes'] != null &&
                                _invoiceDetails!['notes'].toString().isNotEmpty)
                              _buildNotesSection(theme),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildInvoiceHeader(ThemeData theme) {
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
          Text(
            _invoiceDetails!['invoice_number']?.toString() ?? 'INV-000',
            style: AppTextStyles.headlineMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Created: ${_invoiceDetails!['created_at']?.toString().split(' ')[0] ?? 'N/A'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final status = _invoiceDetails!['status']?.toString() ?? 'Draft';
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing24,
        vertical: AppConstants.spacing12,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacing12),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.titleMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(ThemeData theme) {
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
          Text(
            'Bill To',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            _invoiceDetails!['client_name']?.toString() ?? 'Unknown Client',
            style: AppTextStyles.titleLarge.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_invoiceDetails!['client_email'] != null &&
              _invoiceDetails!['client_email'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacing4),
              child: Text(
                _invoiceDetails!['client_email']?.toString() ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (_invoiceDetails!['client_phone'] != null &&
              _invoiceDetails!['client_phone'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacing4),
              child: Text(
                _invoiceDetails!['client_phone']?.toString() ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (_invoiceDetails!['client_company'] != null &&
              _invoiceDetails!['client_company'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacing4),
              child: Text(
                _invoiceDetails!['client_company']?.toString() ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (_invoiceDetails!['client_address'] != null &&
              _invoiceDetails!['client_address'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spacing4),
              child: Text(
                _invoiceDetails!['client_address']?.toString() ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(ThemeData theme) {
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
          Text(
            'Invoice Details',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildDetailRow('Issue Date', _invoiceDetails!['issue_date']?.toString() ?? 'N/A', theme),
          const SizedBox(height: AppConstants.spacing8),
          _buildDetailRow('Due Date', _invoiceDetails!['due_date']?.toString() ?? 'N/A', theme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(ThemeData theme) {
    final items = _invoiceDetails!['items'] as List<dynamic>? ?? [];

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
          Text(
            'Items',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCard(item, index + 1, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item, int itemNumber, ThemeData theme) {
    final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
    final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0;
    final total = quantity * unitPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item $itemNumber',
                style: AppTextStyles.titleSmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            item['description']?.toString() ?? 'No description',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Row(
            children: [
              Text(
                'Qty: $quantity',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Text(
                'Price: \$${unitPrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(ThemeData theme) {
    final subtotal = (_invoiceDetails!['subtotal'] as num?)?.toDouble() ?? 0;
    final tax = (_invoiceDetails!['tax'] as num?)?.toDouble() ?? 0;
    final total = (_invoiceDetails!['total'] as num?)?.toDouble() ?? 0;

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
        children: [
          _buildTotalRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme),
          const Divider(),
          _buildTotalRow('Tax', '\$${tax.toStringAsFixed(2)}', theme),
          const Divider(height: AppConstants.spacing24),
          _buildTotalRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            theme,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, ThemeData theme, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
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
          Text(
            'Notes',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            _invoiceDetails!['notes']?.toString() ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
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
            'Error loading invoice',
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
            onPressed: _fetchInvoiceDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Invoice'),
          content: const Text('Are you sure you want to delete this invoice?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteInvoice();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteInvoice() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final invoiceId = _invoiceDetails!['id'];
      await ApiService.deleteInvoice(invoiceId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice deleted successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
