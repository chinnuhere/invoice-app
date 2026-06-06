import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../ai/services/description_generation_service.dart';
import '../../ai/providers/ai_provider.dart';
import '../../ai/providers/openai_provider.dart';

class EditInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> invoice;

  const EditInvoiceScreen({super.key, required this.invoice});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  // Client selection
  List<dynamic> _clients = [];
  dynamic _selectedClient;
  bool _isLoadingClients = false;

  // Invoice details
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _issueDateController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _notesController;

  // Tax and discount
  late final TextEditingController _taxRateController;
  late final TextEditingController _discountController;

  // Items
  List<Map<String, dynamic>> _items = [];
  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _priceControllers = [];

  // Calculated totals
  double _subtotal = 0;
  double _taxAmount = 0;
  double _discountAmount = 0;
  double _total = 0;

  bool _isSubmitting = false;
  bool _isGeneratingDescription = false;
  DescriptionGenerationService? _descriptionService;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController = TextEditingController(text: widget.invoice['invoice_number']?.toString() ?? '');
    _issueDateController = TextEditingController(text: widget.invoice['issue_date']?.toString() ?? '');
    _dueDateController = TextEditingController(text: widget.invoice['due_date']?.toString() ?? '');
    _notesController = TextEditingController(text: widget.invoice['notes']?.toString() ?? '');
    _taxRateController = TextEditingController(text: '0');
    _discountController = TextEditingController(text: '0');
    
    _selectedClient = {
      'id': widget.invoice['client_id'],
      'name': widget.invoice['client_name'],
    };
    
    _fetchClients();
    _loadItems();
    _initializeAIService();
  }

  void _initializeAIService() {
    // TODO: Initialize with actual API key from secure storage or config
    // For now, this is a placeholder
    try {
      final provider = OpenAIProvider(
        apiKey: '', // Replace with actual API key
      );
      _descriptionService = DescriptionGenerationService(provider);
    } catch (e) {
      // AI service not configured, will handle gracefully
      _descriptionService = null;
    }
  }

  Future<void> _generateDescription() async {
    if (_descriptionService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not configured')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items before generating description')),
      );
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    try {
      final description = await _descriptionService!.generateInvoiceDescription(
        items: _items,
        clientName: _selectedClient?['name']?.toString(),
      );

      if (mounted) {
        setState(() {
          _notesController.text = description;
          _isGeneratingDescription = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Description generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingDescription = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate description: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _issueDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadItems() {
    final items = widget.invoice['items'] as List<dynamic>? ?? [];
    setState(() {
      _items = items.map((item) {
        return {
          'description': item['description']?.toString() ?? '',
          'quantity': (item['quantity'] as num?)?.toDouble() ?? 1,
          'unitPrice': (item['unit_price'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
      
      // Initialize controllers for loaded items
      _descriptionControllers.clear();
      _quantityControllers.clear();
      _priceControllers.clear();
      for (var item in _items) {
        _descriptionControllers.add(TextEditingController(text: item['description']?.toString() ?? ''));
        _quantityControllers.add(TextEditingController(text: (item['quantity'] as num?)?.toString() ?? '1'));
        _priceControllers.add(TextEditingController(text: (item['unitPrice'] as num?)?.toStringAsFixed(2) ?? '0.00'));
      }
      
      _calculateTotals();
    });
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoadingClients = true;
    });

    try {
      final clients = await ApiService.getClients();
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _addItem() {
    setState(() {
      _items.add({
        'description': '',
        'quantity': 1,
        'unitPrice': 0.0,
      });
      _descriptionControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController(text: '1'));
      _priceControllers.add(TextEditingController(text: '0.00'));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
        _descriptionControllers[index].dispose();
        _descriptionControllers.removeAt(index);
        _quantityControllers[index].dispose();
        _quantityControllers.removeAt(index);
        _priceControllers[index].dispose();
        _priceControllers.removeAt(index);
        _calculateTotals();
      });
    }
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _items[index][field] = value;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = 0;
    for (var item in _items) {
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
      _subtotal += quantity * unitPrice;
    }

    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    _taxAmount = _subtotal * (taxRate / 100);

    final discount = double.tryParse(_discountController.text) ?? 0;
    _discountAmount = _subtotal * (discount / 100);

    _total = _subtotal + _taxAmount - _discountAmount;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
    }
  }

  void _submitInvoice() {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a client')),
      );
      return;
    }

    if (_invoiceNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter invoice number')),
      );
      return;
    }

    if (_issueDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select issue date')),
      );
      return;
    }

    if (_dueDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select due date')),
      );
      return;
    }

    // Validate items
    for (var item in _items) {
      if (item['description'].toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all item descriptions')),
        );
        return;
      }
    }

    _updateInvoice();
  }

  Future<void> _updateInvoice() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final invoiceData = {
        'client_id': _selectedClient['id'],
        'invoice_number': _invoiceNumberController.text.trim(),
        'issue_date': _issueDateController.text.trim(),
        'due_date': _dueDateController.text.trim(),
        'status': widget.invoice['status'] ?? 'draft',
        'notes': _notesController.text.trim(),
        'items': _items.map((item) {
          return {
            'description': item['description'],
            'quantity': item['quantity'],
            'unit_price': item['unitPrice'],
          };
        }).toList(),
      };

      final invoiceId = widget.invoice['id'];
      await ApiService.updateInvoice(invoiceId, invoiceData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice updated successfully!')),
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Invoice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Selector
              Text(
                'Client',
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              _isLoadingClients
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
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
                        child: DropdownButton<dynamic>(
                          hint: Text(
                            'Select a client',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: _selectedClient,
                          isExpanded: true,
                          items: _clients.map((client) {
                            return DropdownMenuItem<dynamic>(
                              value: client,
                              child: Text(
                                client['name']?.toString() ?? 'Unknown',
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClient = value;
                            });
                          },
                        ),
                      ),
                    ),
              const SizedBox(height: AppConstants.spacing24),

              // Invoice Details
              Text(
                'Invoice Details',
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Invoice Number
              CustomTextField(
                controller: _invoiceNumberController,
                labelText: 'Invoice Number',
                hintText: 'INV-001',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Issue Date
              GestureDetector(
                onTap: () => _selectDate(context, _issueDateController),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _issueDateController,
                    labelText: 'Issue Date',
                    hintText: 'Select date',
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Due Date
              GestureDetector(
                onTap: () => _selectDate(context, _dueDateController),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _dueDateController,
                    labelText: 'Due Date',
                    hintText: 'Select date',
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icon(
                      Icons.event,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Items List
              ...List.generate(_items.length, (index) {
                return _buildItemCard(index, theme);
              }),
              const SizedBox(height: AppConstants.spacing24),

              // Tax and Discount
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _taxRateController,
                      labelText: 'Tax Rate (%)',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.percent,
                        color: theme.colorScheme.primary,
                      ),
                      onChanged: (_) => _calculateTotals(),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: CustomTextField(
                      controller: _discountController,
                      labelText: 'Discount (%)',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.local_offer,
                        color: theme.colorScheme.primary,
                      ),
                      onChanged: (_) => _calculateTotals(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Totals Summary
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}', theme),
                    const Divider(),
                    _buildTotalRow('Tax', '\$${_taxAmount.toStringAsFixed(2)}', theme),
                    _buildTotalRow('Discount', '-\$${_discountAmount.toStringAsFixed(2)}', theme),
                    const Divider(height: AppConstants.spacing24),
                    _buildTotalRow(
                      'Total',
                      '\$${_total.toStringAsFixed(2)}',
                      theme,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Notes
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _notesController,
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any notes...',
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      prefixIcon: Icon(
                        Icons.note,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  if (_descriptionService != null)
                    IconButton(
                      icon: _isGeneratingDescription
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      onPressed: _isGeneratingDescription ? null : _generateDescription,
                      tooltip: 'Generate with AI',
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Submit Button
              CustomButton(
                text: 'Update Invoice',
                onPressed: _submitInvoice,
                isLoading: _isSubmitting,
                isFullWidth: true,
                buttonType: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(int index, ThemeData theme) {
    final item = _items[index];
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${index + 1}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeItem(index),
                  color: AppColors.danger,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          TextField(
            controller: _descriptionControllers[index],
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Item description',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing12,
                vertical: AppConstants.spacing12,
              ),
            ),
            style: AppTextStyles.bodyMedium,
            onChanged: (value) => _updateItem(index, 'description', value),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: '1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    _updateItem(index, 'quantity', int.tryParse(value) ?? 1);
                  },
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: TextField(
                  controller: _priceControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    hintText: '0.00',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radius8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    _updateItem(index, 'unitPrice', double.tryParse(value) ?? 0.0);
                  },
                ),
              ),
            ],
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
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
