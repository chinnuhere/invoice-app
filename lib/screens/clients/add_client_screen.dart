import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addClient() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final company = _companyController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter client name')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter client email')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter client phone')),
      );
      return;
    }

    createClient(name, email, phone, company, address);
  }

  Future<void> createClient(
    String name,
    String email,
    String phone,
    String company,
    String address,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientData = {
        'name': name,
        'email': email,
        'phone': phone,
        if (company.isNotEmpty) 'company': company,
        if (address.isNotEmpty) 'address': address,
      };

      await ApiService.createClient(clientData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client added successfully!')),
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Client'),
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
                'New Client',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Fill in the client details below',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Name Field
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: 'Enter client name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Email Field
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter client email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Phone Field
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone',
                hintText: 'Enter client phone',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Company Field
              CustomTextField(
                controller: _companyController,
                labelText: 'Company',
                hintText: 'Enter company name (optional)',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.business_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Address Field
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                hintText: 'Enter client address (optional)',
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Add Button
              CustomButton(
                text: 'Add Client',
                onPressed: _addClient,
                isLoading: _isLoading,
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
