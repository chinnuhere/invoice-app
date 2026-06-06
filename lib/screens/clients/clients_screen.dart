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
          final email = client['email']?.toString().toLowerCase() ?? '';
          final company = client['company']?.toString().toLowerCase() ?? '';
          return name.contains(query) ||
              email.contains(query) ||
              company.contains(query);
        }).toList();
      }
    });
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
                    'Clients',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
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
                  hintText: 'Search clients...',
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

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? _buildErrorState(theme)
                      : _filteredClients.isEmpty
                          ? _buildEmptyState(theme)
                          : RefreshIndicator(
                              onRefresh: _fetchClients,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing16,
                                  vertical: AppConstants.spacing8,
                                ),
                                itemCount: _filteredClients.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppConstants.spacing12),
                                itemBuilder: (context, index) {
                                  final client = _filteredClients[index];
                                  return GestureDetector(
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
                                    child: _buildClientCard(client, theme),
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
            'Error loading clients',
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radius24),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 60,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          Text(
            _searchController.text.isNotEmpty
                ? 'No clients found'
                : 'No clients yet',
            style: AppTextStyles.headlineSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Add your first client to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(dynamic client, ThemeData theme) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radius12),
            ),
            child: Center(
              child: Text(
                (client['name']?.toString()[0] ?? 'C').toUpperCase(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
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
                  client['name']?.toString() ?? 'Unknown',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  client['email']?.toString() ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (client['company'] != null && client['company'].toString().isNotEmpty)
                  Text(
                    client['company']?.toString() ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
