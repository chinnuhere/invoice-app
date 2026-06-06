import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _clients = [];
  List<dynamic> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
      _errorMessage = null;
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
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
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

  void _openChatDialog(String clientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.chat_bubble, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('Message $clientName')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send quick message:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Hi! Just checking in on your outstanding invoice.'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );
              },
            ),
            ListTile(
              title: const Text('Hello, I sent you the proposal. Let me know your thoughts!'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );
              },
            ),
          ],
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

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Redirect to Dashboard tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Returning to Dashboard'), duration: Duration(milliseconds: 500)),
              );
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search customer...',
                  border: InputBorder.none,
                ),
                style: AppTextStyles.titleMedium,
              )
            : const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState(theme)
                : _filteredClients.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _fetchClients,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: 8),
                          itemCount: _filteredClients.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final client = _filteredClients[index];
                            final name = client['name']?.toString() ?? 'Unknown';
                            final hasChat = name.contains('Hema') || index % 3 == 1; // Simulate specific users with chat shortcuts as in screenshot

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              title: Text(
                                name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              trailing: hasChat
                                  ? IconButton(
                                      icon: const Icon(Icons.chat_bubble, color: Colors.blue),
                                      onPressed: () => _openChatDialog(name),
                                    )
                                  : null,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditClientScreen(client: client),
                                  ),
                                );
                                if (result == true) {
                                  _fetchClients();
                                }
                              },
                            );
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
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
          const Text('Error loading customers', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.spacing8),
          Text(_errorMessage!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacing24),
          ElevatedButton(
            onPressed: _fetchClients,
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
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: AppConstants.spacing24),
          Text(
            _searchController.text.isNotEmpty ? 'No customers found' : 'No customers yet',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            _searchController.text.isNotEmpty ? 'Try another query' : 'Create your first customer to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
