import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _selectedCategory = 'Office';
  final List<String> _categories = ['Office', 'Travel', 'Software', 'Hardware', 'Marketing', 'Other'];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
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

    _createExpense(description, amount, date, notes);
  }

  Future<void> _createExpense(String description, String amount, String date, String notes) async {
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

      await ApiService.createExpense(expenseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
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
        title: const Text('Add Expense'),
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
              // Header
              Text(
                'New Expense',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Enter the expense details below',
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
                text: 'Add Expense',
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
