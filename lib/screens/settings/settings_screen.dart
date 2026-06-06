import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/auth_service.dart';
import 'business_profile_screen.dart';
import '../../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _aiProvider = 'None';
  String _aiApiKey = '';
  bool _isLoading = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Portuguese'];
  final List<String> _providers = ['None', 'OpenAI', 'Claude', 'Local'];
  final TextEditingController _apiKeyController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await _storage.read(key: 'language');
    final provider = await _storage.read(key: 'ai_provider');
    final apiKey = await _storage.read(key: 'ai_api_key');

    setState(() {
      _selectedLanguage = language ?? 'English';
      _aiProvider = provider ?? 'None';
      _aiApiKey = apiKey ?? '';
      _apiKeyController.text = _aiApiKey;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _storage.write(key: 'language', value: _selectedLanguage);
      await _storage.write(key: 'ai_provider', value: _aiProvider);
      await _storage.write(key: 'ai_api_key', value: _apiKeyController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: ${e.toString()}')),
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
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
                    'Settings',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveSettings,
                      tooltip: 'Save Settings',
                    ),
                  if (_isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const Divider(),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                children: [
                  // AI Configuration Section
                  _buildSectionHeader('AI Configuration', theme),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'AI Provider',
                    _aiProvider,
                    Icons.psychology,
                    () => _showProviderSelector(),
                    theme,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  if (_aiProvider != 'None')
                    _buildSettingCard(
                      'API Key',
                      _aiApiKey.isEmpty ? 'Not set' : '••••••••',
                      Icons.key,
                      () => _showApiKeyDialog(),
                      theme,
                    ),
                  const SizedBox(height: AppConstants.spacing24),

                  // App Preferences Section
                  _buildSectionHeader('App Preferences', theme),
                  const SizedBox(height: AppConstants.spacing12),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSwitchSetting(
                        'Dark Mode',
                        'Enable dark theme',
                        themeProvider.isDarkMode,
                        (value) => themeProvider.toggleDarkMode(),
                        theme,
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'Language',
                    _selectedLanguage,
                    Icons.language,
                    () => _showLanguageSelector(),
                    theme,
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // Account Section
                  _buildSectionHeader('Account', theme),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'Business Profile',
                    'Manage your business information',
                    Icons.business,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusinessProfileScreen(),
                      ),
                    ),
                    theme,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'Logout',
                    'Sign out of your account',
                    Icons.logout,
                    _logout,
                    theme,
                    isDestructive: true,
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // About Section
                  _buildSectionHeader('About', theme),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'App Version',
                    '1.0.0',
                    Icons.info,
                    null,
                    theme,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'Terms of Service',
                    'View terms',
                    Icons.description,
                    null,
                    theme,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  _buildSettingCard(
                    'Privacy Policy',
                    'View privacy policy',
                    Icons.privacy_tip,
                    null,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingCard(
    String title,
    String value,
    IconData icon,
    VoidCallback? onTap,
    ThemeData theme, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.danger : theme.colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showProviderSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select AI Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _providers.map((provider) {
            return RadioListTile<String>(
              title: Text(provider),
              value: provider,
              groupValue: _aiProvider,
              onChanged: (value) {
                setState(() {
                  _aiProvider = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showApiKeyDialog() {
    _apiKeyController.text = _aiApiKey;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter API Key'),
        content: TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            hintText: 'Enter your API key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _aiApiKey = _apiKeyController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
