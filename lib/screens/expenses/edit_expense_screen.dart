import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;
  late final TextEditingController _notesController;
  
  late String _selectedCategory;
  final List<String> _categories = ['Office', 'Travel', 'Software', 'Hardware', 'Marketing', 'Other'];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense['description']?.toString() ?? '');
    _amountController = TextEditingController(text: (widget.expense['amount'] as num?)?.toStringAsFixed(2) ?? '0.00');
    _dateController = TextEditingController(text: widget.expense['expense_date']?.toString() ?? '');
    _notesController = TextEditingController(text: widget.expense['notes']?.toString() ?? '');
    _selectedCategory = widget.expense['category']?.toString() ?? 'Office';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _dateController.text = picked.toString().split(' ')[0];
    }
  }

  void _submitExpense() {
    final description = _descriptionController.text.trim();
    final amount = _amountController.text.trim();
    final date = _dateController.text.trim();
    final notes = _notesController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter expense description')),
      );
      return;
    }

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter expense amount')),
      );
      return;
    }

    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select expense date')),
      );
      return;
    }

    _updateExpense(description, amount, date, notes);
  }

  Future<void> _updateExpense(String description, String amount, String date, String notes) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final expenseData = {
        'description': description,
        'amount': double.parse(amount),
        'category': _selectedCategory,
        'expense_date': date,
        'notes': notes.isNotEmpty ? notes : null,
      };

      final expenseId = widget.expense['id'];
      await ApiService.updateExpense(expenseId, expenseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully!')),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteExpense();
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

  Future<void> _deleteExpense() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final expenseId = widget.expense['id'];
      await ApiService.deleteExpense(expenseId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted successfully!')),
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
        title: const Text('Edit Expense'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Edit Expense',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Update the expense details below',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Description Field
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter expense description',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Amount Field
              CustomTextField(
                controller: _amountController,
                labelText: 'Amount',
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: theme.colorScheme.primary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Category Dropdown
              Text(
                'Category',
                style: AppTextStyles.titleMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Container(
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
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Date Field
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _dateController,
                    labelText: 'Date',
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

              // Notes Field
              CustomTextField(
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
              const SizedBox(height: AppConstants.spacing32),

              // Submit Button
              CustomButton(
                text: 'Update Expense',
                onPressed: _submitExpense,
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
}
