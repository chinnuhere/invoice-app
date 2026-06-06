import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditClientScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client['name']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.client['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.client['phone']?.toString() ?? '');
    _companyController = TextEditingController(text: widget.client['company']?.toString() ?? '');
    _addressController = TextEditingController(text: widget.client['address']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _updateClient() {
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

    updateClient(name, email, phone, company, address);
  }

  Future<void> updateClient(
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
      final clientId = widget.client['id'];
      final clientData = {
        'name': name,
        'email': email,
        'phone': phone,
        if (company.isNotEmpty) 'company': company,
        if (address.isNotEmpty) 'address': address,
      };

      await ApiService.updateClient(clientId, clientData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client updated successfully!')),
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
        title: const Text('Edit Client'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Edit Client',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Update the client details below',
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

              // Update Button
              CustomButton(
                text: 'Update Client',
                onPressed: _updateClient,
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: const Text('Are you sure you want to delete this client?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteClient();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientId = widget.client['id'];
      await ApiService.deleteClient(clientId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client deleted successfully!')),
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
}
