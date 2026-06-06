import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/signature_pad.dart';
import '../../providers/theme_provider.dart';
import 'business_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userEmail = 'anandnamkeenandsweets@gmail.com';
  String _signatureData = '';
  String _dueInDays = 'None';
  bool _sendMeCopy = true;
  bool _passcodeEnabled = false;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _businessProfile;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user details
      final email = await _storage.read(key: 'email');
      if (email != null && email.isNotEmpty) {
        _userEmail = email;
      }

      // Load settings from secure storage
      final dueIn = await _storage.read(key: 'settings_due_in') ?? 'None';
      final copy = await _storage.read(key: 'settings_send_copy') ?? 'true';
      final passcode = await _storage.read(key: 'settings_passcode') ?? 'false';

      // Load profile (which has signature)
      final profile = await ApiService.getBusinessProfile();

      setState(() {
        _dueInDays = dueIn;
        _sendMeCopy = copy == 'true';
        _passcodeEnabled = passcode == 'true';
        _businessProfile = profile;
        if (profile != null) {
          _signatureData = profile['signature_data']?.toString() ?? '';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSignature(String serializedSignature) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _signatureData = serializedSignature;
      final profileData = Map<String, dynamic>.from(_businessProfile ?? {
        'business_name': 'My Business',
        'email': _userEmail,
      });
      profileData['signature_data'] = serializedSignature;

      if (_businessProfile == null) {
        await ApiService.createBusinessProfile(profileData);
      } else {
        await ApiService.updateBusinessProfile(profileData);
      }

      // Reload
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signature saved successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save signature: $e')),
        );
      }
    }
  }

  Future<void> _savePreference(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  void _showDueInSelector() {
    final options = ['None', '7 Days', '15 Days', '30 Days', '45 Days'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Due in (days)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _dueInDays,
              onChanged: (value) async {
                setState(() {
                  _dueInDays = value!;
                });
                await _savePreference('settings_due_in', value!);
                if (mounted) Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPasscodeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_passcodeEnabled ? 'Change Passcode' : 'Enable Passcode'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await _savePreference('settings_passcode_pin', controller.text);
                await _savePreference('settings_passcode', 'true');
                setState(() {
                  _passcodeEnabled = true;
                });
                if (mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN must be 4 digits')),
                );
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
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
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          children: [
            // Username Section
            const SizedBox(height: AppConstants.spacing12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('USERNAME', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          _userEmail,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Account Option
            _buildChevronItem(
              'User Account',
              null,
              Icons.account_circle_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Company Title Section
            _buildSectionTitle('Company'),
            const SizedBox(height: AppConstants.spacing8),
            
            // Signature Row
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radius12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  Icon(Icons.draw, color: theme.colorScheme.primary),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Text(
                      'Signature',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Signature Preview', textAlign: TextAlign.center),
                          content: SizedBox(
                            width: 250,
                            height: 150,
                            child: _signatureData.isEmpty
                                ? const Center(child: Text('No signature set.'))
                                : SignaturePreview(
                                    serializedStrokes: _signatureData,
                                    strokeColor: theme.colorScheme.onSurface,
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignaturePad(
                                      initialSignature: _signatureData,
                                      onSave: _updateSignature,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),

            _buildChevronItem(
              'Customer payment option',
              null,
              Icons.payment_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Invoice Settings Card
            _buildSectionTitle('Invoice'),
            const SizedBox(height: AppConstants.spacing8),
            _buildChevronItem(
              'Overdue Reminder',
              null,
              Icons.notifications_active_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildChevronItem(
              'Due in (days)',
              _dueInDays,
              Icons.date_range_outlined,
              _showDueInSelector,
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildChevronItem(
              'Tax',
              null,
              Icons.percent_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildChevronItem(
              'Default note',
              null,
              Icons.note_alt_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildChevronItem(
              'Default email message',
              null,
              Icons.mail_outline,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildSwitchItem(
              'Send me a copy',
              _sendMeCopy,
              Icons.copy_outlined,
              (val) async {
                setState(() {
                  _sendMeCopy = val;
                });
                await _savePreference('settings_send_copy', val.toString());
              },
              theme,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Customization Section
            _buildSectionTitle('Customization'),
            const SizedBox(height: AppConstants.spacing8),
            _buildChevronItem(
              'Rename title and number',
              null,
              Icons.edit_note,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildChevronItem(
              'Rename fields',
              null,
              Icons.drive_file_rename_outline,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Transactions Section
            _buildSectionTitle('Transactions'),
            const SizedBox(height: AppConstants.spacing8),
            _buildChevronItem(
              'Transaction Accounts',
              null,
              Icons.account_balance_wallet_outlined,
              () {},
              theme,
            ),
            const SizedBox(height: AppConstants.spacing24),

            // General Section
            _buildSectionTitle('General'),
            const SizedBox(height: AppConstants.spacing8),
            _buildSwitchItem(
              'Passcode',
              _passcodeEnabled,
              Icons.lock_outline,
              (val) async {
                if (val) {
                  _showPasscodeDialog();
                } else {
                  setState(() {
                    _passcodeEnabled = false;
                  });
                  await _savePreference('settings_passcode', 'false');
                }
              },
              theme,
            ),
            const SizedBox(height: AppConstants.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildChevronItem(
    String title,
    String? value,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radius12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.danger : theme.colorScheme.primary),
            const SizedBox(width: AppConstants.spacing16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.danger : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    bool val,
    IconData icon,
    Function(bool) onChanged,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radius12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: val,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
