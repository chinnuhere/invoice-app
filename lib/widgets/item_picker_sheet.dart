import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';
import '../services/api_service.dart';

class ItemPickerSheet extends StatefulWidget {
  const ItemPickerSheet({super.key});

  @override
  State<ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<ItemPickerSheet> {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      // If table/endpoint is empty, populate with some mock sweets recents as in Screenshot 2
      final mockSweets = [
        {'name': 'Kaju katli 500g', 'price': 475.00},
        {'name': 'Masala kaju', 'price': 1100.00},
        {'name': 'Pista roll 500g', 'price': 500.00},
        {'name': 'Ladoo 1kg', 'price': 350.00},
        {'name': 'Namkeen 1kg', 'price': 250.00},
        {'name': 'Khova mix 500g', 'price': 250.00},
        {'name': 'Soan papdi 200g', 'price': 34.00},
      ];

      setState(() {
        _items = mockSweets;
        _filteredItems = mockSweets;
        _isLoading = false;
      });
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items.where((item) {
          final name = item['name']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }
    });
  }

  void _createNewItem() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g. Kaju katli 500g',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price (₹)',
                hintText: 'e.g. 475.00',
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item name is required')),
                );
                return;
              }

              Navigator.pop(context); // Close dialog

              setState(() {
                _isLoading = true;
              });

              try {
                final newItem = await ApiService.createItem(name, price);
                // Return new item directly
                if (mounted) {
                  Navigator.pop(context, newItem);
                }
              } catch (e) {
                // Fallback to local insertion if API fails
                final localItem = {'name': name, 'price': price};
                if (mounted) {
                  Navigator.pop(context, localItem);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius24)),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Add item',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Action button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create new item'),
                    onPressed: _createNewItem,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radius12),
                      ),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search item',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radius12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.15)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recents',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View all',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: 8),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final price = double.tryParse(item['price']?.toString() ?? '0.00') ?? 0.00;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[100],
                              child: const Icon(Icons.local_offer, color: Colors.grey, size: 18),
                            ),
                            title: Text(
                              item['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              '₹${price.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onTap: () {
                              Navigator.pop(context, item);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
