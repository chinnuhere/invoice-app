import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _expenses = [];
  List<dynamic> _filteredExpenses = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categoryFilters = ['All', 'Office', 'Travel', 'Software', 'Hardware', 'Marketing', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _searchController.addListener(_filterExpenses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final expenses = await ApiService.getExpenses();
      setState(() {
        _expenses = expenses;
        _filteredExpenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterExpenses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        final matchesSearch = query.isEmpty ||
            (expense['description']?.toString().toLowerCase() ?? '').contains(query) ||
            (expense['category']?.toString().toLowerCase() ?? '').contains(query);

        final matchesCategory = _selectedCategory == 'All' ||
            (expense['category']?.toString().toLowerCase() ?? '') == _selectedCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onCategoryFilterChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterExpenses();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'office':
        return Colors.blue;
      case 'travel':
        return Colors.orange;
      case 'software':
        return Colors.purple;
      case 'hardware':
        return Colors.teal;
      case 'marketing':
        return Colors.pink;
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
                    'Expenses',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddExpenseScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchExpenses();
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
                  hintText: 'Search expenses...',
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

            // Category Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                itemCount: _categoryFilters.length,
                itemBuilder: (context, index) {
                  final category = _categoryFilters[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategoryFilterChanged(category),
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
                      : _filteredExpenses.isEmpty
                          ? _buildEmptyState(theme)
                          : RefreshIndicator(
                              onRefresh: _fetchExpenses,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing16,
                                  vertical: AppConstants.spacing8,
                                ),
                                itemCount: _filteredExpenses.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppConstants.spacing12),
                                itemBuilder: (context, index) {
                                  final expense = _filteredExpenses[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditExpenseScreen(expense: expense),
                                        ),
                                      );
                                      if (result == true) {
                                        _fetchExpenses();
                                      }
                                    },
                                    child: _buildExpenseCard(expense, theme),
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
            'Error loading expenses',
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
            onPressed: _fetchExpenses,
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
            _searchController.text.isNotEmpty || _selectedCategory != 'All'
                ? 'No expenses found'
                : 'No expenses yet',
            style: AppTextStyles.headlineSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            _searchController.text.isNotEmpty || _selectedCategory != 'All'
                ? 'Try different filters or search terms'
                : 'Add your first expense to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(dynamic expense, ThemeData theme) {
    final category = expense['category']?.toString() ?? 'Other';
    final categoryColor = _getCategoryColor(category);

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
              Expanded(
                child: Text(
                  expense['description']?.toString() ?? 'No description',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radius8),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            'Date: ${expense['expense_date']?.toString() ?? 'N/A'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${(expense['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.danger,
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
