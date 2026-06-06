import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../config/app_text_styles.dart';
import '../services/api_service.dart';
import '../screens/clients/add_client_screen.dart';

class CustomerPickerSheet extends StatefulWidget {
  const CustomerPickerSheet({super.key});

  @override
  State<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<CustomerPickerSheet> {
  List<dynamic> _clients = [];
  List<dynamic> _filteredClients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clients = await ApiService.getClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        _filteredClients = _clients.where((client) {
          final name = client['name']?.toString().toLowerCase() ?? '';
          final company = client['company']?.toString().toLowerCase() ?? '';
          return name.contains(query) || company.contains(query);
        }).toList();
      }
    });
  }

  void _importFromContacts() {
    // Show a beautiful mock contacts dialog
    final mockContacts = [
      {'name': 'Hema s bengaluru', 'company': 'Bengaluru Sweets'},
      {'name': 'Ashokji Mali Viratnagar', 'company': 'Viratnagar Namkeen'},
      {'name': 'Kesaramji Viratnagar', 'company': 'Mali Sweets'},
      {'name': 'Krishna jewellers viratanagar', 'company': 'Krishna Jewellers'},
      {'name': 'Rajaramji Viratnagar', 'company': 'Rajaram Sweets'},
      {'name': 'Ramesh reddy viratanagar', 'company': 'Ramesh Sweets'},
      {'name': 'Shankarlalji mali hongasandra', 'company': 'Shankar Namkeen'},
      {'name': 'Sohanji pawna viratanagar', 'company': 'Sohan Sweets'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Contacts'),
        content: SizedBox(
          width: 300,
          height: 350,
          child: ListView.separated(
            itemCount: mockContacts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final contact = mockContacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(contact['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(contact['company']!),
                trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onTap: () async {
                  Navigator.pop(context); // Close dialog
                  // Save to cloud database automatically!
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final savedClient = await ApiService.createClient({
                      'name': contact['name'],
                      'company': contact['company'],
                      'email': '${contact['name']!.replaceAll(' ', '').toLowerCase()}@gmail.com',
                      'phone': '9876543210',
                      'address': 'Bengaluru, India',
                    });
                    // Close picker sheet returning the saved client
                    if (mounted) {
                      Navigator.pop(context, savedClient);
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to import contact: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    'Add customer',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance back button
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create new customer'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddClientScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchClients();
                      }
                    },
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.contacts, size: 20),
                    label: const Text('Import from your contacts'),
                    onPressed: _importFromContacts,
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
                hintText: 'Search customer',
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

          // Clients list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? const Center(child: Text('No customers found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: 8),
                        itemCount: _filteredClients.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final client = _filteredClients[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                (client['name']?[0] ?? 'C').toUpperCase(),
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              client['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(client['company'] ?? 'Individual'),
                            onTap: () {
                              Navigator.pop(context, client);
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
