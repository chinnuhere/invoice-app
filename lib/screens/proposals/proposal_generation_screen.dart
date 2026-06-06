import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../ai/services/proposal_generation_service.dart';
import '../../ai/providers/ai_provider.dart';
import '../../ai/providers/openai_provider.dart';

class ProposalGenerationScreen extends StatefulWidget {
  const ProposalGenerationScreen({super.key});

  @override
  State<ProposalGenerationScreen> createState() => _ProposalGenerationScreenState();
}

class _ProposalGenerationScreenState extends State<ProposalGenerationScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _projectDescriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _additionalDetailsController = TextEditingController();
  
  bool _isGenerating = false;
  bool _isImproving = false;
  String _generatedProposal = '';
  ProposalGenerationService? _proposalService;

  @override
  void initState() {
    super.initState();
    _initializeAIService();
  }

  void _initializeAIService() {
    try {
      final provider = OpenAIProvider(
        apiKey: '', // Replace with actual API key
      );
      _proposalService = ProposalGenerationService(provider);
    } catch (e) {
      _proposalService = null;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectDescriptionController.dispose();
    _budgetController.dispose();
    _timelineController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _generateProposal() async {
    final clientName = _clientNameController.text.trim();
    final projectDescription = _projectDescriptionController.text.trim();

    if (clientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter client name')),
      );
      return;
    }

    if (projectDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter project description')),
      );
      return;
    }

    if (_proposalService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not configured')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final proposal = await _proposalService!.generateProposal(
        clientName: clientName,
        projectDescription: projectDescription,
        budget: _budgetController.text.trim(),
        timeline: _timelineController.text.trim(),
        additionalDetails: _additionalDetailsController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _generatedProposal = proposal;
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate proposal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _improveProposal() async {
    if (_generatedProposal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a proposal first')),
      );
      return;
    }

    if (_proposalService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not configured')),
      );
      return;
    }

    setState(() {
      _isImproving = true;
    });

    try {
      final improvedProposal = await _proposalService!.improveProposal(
        currentProposal: _generatedProposal,
        feedback: _additionalDetailsController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _generatedProposal = improvedProposal;
          _isImproving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal improved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImproving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to improve proposal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Proposal'),
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
                'Business Proposal Generator',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Generate professional business proposals using AI',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing32),

              // Form
              CustomTextField(
                controller: _clientNameController,
                labelText: 'Client Name',
                hintText: 'Enter client name',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.business,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              CustomTextField(
                controller: _projectDescriptionController,
                labelText: 'Project Description',
                hintText: 'Describe the project or services',
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              CustomTextField(
                controller: _budgetController,
                labelText: 'Budget (Optional)',
                hintText: 'e.g., \$5,000 - \$10,000',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              CustomTextField(
                controller: _timelineController,
                labelText: 'Timeline (Optional)',
                hintText: 'e.g., 4-6 weeks',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),

              CustomTextField(
                controller: _additionalDetailsController,
                labelText: 'Additional Details (Optional)',
                hintText: 'Any additional context or requirements',
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                prefixIcon: Icon(
                  Icons.note_add,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Generate Button
              CustomButton(
                text: 'Generate Proposal',
                onPressed: _isGenerating ? null : _generateProposal,
                isLoading: _isGenerating,
                isFullWidth: true,
                buttonType: ButtonType.primary,
              ),

              if (_generatedProposal.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spacing32),

                // Generated Proposal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generated Proposal',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: _isImproving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_fix_high),
                          onPressed: _isImproving ? null : _improveProposal,
                          tooltip: 'Improve with AI',
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _generatedProposal));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing12),

                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radius12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Text(
                    _generatedProposal,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
