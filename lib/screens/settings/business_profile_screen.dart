import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _routingNumberController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await ApiService.getBusinessProfile();
      
      if (profile != null && mounted) {
        setState(() {
          _businessNameController.text = profile['business_name']?.toString() ?? '';
          _emailController.text = profile['email']?.toString() ?? '';
          _phoneController.text = profile['phone']?.toString() ?? '';
          _addressController.text = profile['address']?.toString() ?? '';
          _cityController.text = profile['city']?.toString() ?? '';
          _stateController.text = profile['state']?.toString() ?? '';
          _zipController.text = profile['zip']?.toString() ?? '';
          _countryController.text = profile['country']?.toString() ?? '';
          _taxIdController.text = profile['tax_id']?.toString() ?? '';
          _registrationNumberController.text = profile['registration_number']?.toString() ?? '';
          _bankNameController.text = profile['bank_name']?.toString() ?? '';
          _accountNumberController.text = profile['account_number']?.toString() ?? '';
          _routingNumberController.text = profile['routing_number']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Don't show error on load, just start with empty form
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final businessName = _businessNameController.text.trim();
    final email = _emailController.text.trim();

    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter business name')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter business email')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profileData = {
        'business_name': businessName,
        'email': email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip': _zipController.text.trim(),
        'country': _countryController.text.trim(),
        'tax_id': _taxIdController.text.trim(),
        'registration_number': _registrationNumberController.text.trim(),
        'bank_name': _bankNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'routing_number': _routingNumberController.text.trim(),
      };

      // Try to update first, if it doesn't exist then create
      try {
        await ApiService.updateBusinessProfile(profileData);
      } catch (e) {
        // If update fails (404), try to create
        await ApiService.createBusinessProfile(profileData);
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Header
              Text(
                'Business Information',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Enter your business details for invoices and proposals',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Business Details Section
              _buildSectionHeader('Business Details', theme),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _businessNameController,
                labelText: 'Business Name',
                hintText: 'Enter business name',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.business,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Business Email',
                hintText: 'Enter business email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.email,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.phone,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Address Section
              _buildSectionHeader('Business Address', theme),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Street Address',
                hintText: 'Enter street address',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: 'City',
                      hintText: 'City',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      labelText: 'State',
                      hintText: 'State',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.map,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _zipController,
                      labelText: 'ZIP Code',
                      hintText: 'ZIP',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.markunread_mailbox,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: CustomTextField(
                      controller: _countryController,
                      labelText: 'Country',
                      hintText: 'Country',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.public,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Tax & Registration Section
              _buildSectionHeader('Tax & Registration', theme),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _taxIdController,
                labelText: 'Tax ID / VAT Number',
                hintText: 'Enter tax ID',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.receipt_long,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _registrationNumberController,
                labelText: 'Registration Number',
                hintText: 'Enter registration number',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.assignment,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Banking Section
              _buildSectionHeader('Banking Details', theme),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _bankNameController,
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.account_balance,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _accountNumberController,
                labelText: 'Account Number',
                hintText: 'Enter account number',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.credit_card,
                  color: theme.colorScheme.primary,
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _routingNumberController,
                labelText: 'Routing Number',
                hintText: 'Enter routing number',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                prefixIcon: Icon(
                  Icons.numbers,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Save Button
              CustomButton(
                text: 'Save Profile',
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
                isFullWidth: true,
                buttonType: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
