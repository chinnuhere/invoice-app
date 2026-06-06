import '../providers/ai_provider.dart';

/// Business Proposal Generation Service
/// 
/// Uses AI to generate professional business proposals
class ProposalGenerationService {
  final AIProvider _provider;

  ProposalGenerationService(this._provider);

  /// Generate a business proposal
  /// 
  /// [clientName] - Name of the client
  /// [projectDescription] - Description of the project/services
  /// [budget] - Optional budget range
  /// [timeline] - Optional timeline
  /// [additionalDetails] - Any additional details
  /// Returns generated proposal
  Future<String> generateProposal({
    required String clientName,
    required String projectDescription,
    String? budget,
    String? timeline,
    String? additionalDetails,
  }) async {
    final prompt = _buildProposalPrompt(
      clientName,
      projectDescription,
      budget,
      timeline,
      additionalDetails,
    );
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.7,
      maxTokens: 2000,
    );
    
    return response;
  }

  /// Generate proposal sections
  /// 
  /// [proposalData] - Existing proposal data
  /// [section] - Section to generate (executive summary, scope, timeline, pricing, etc.)
  /// Returns generated section
  Future<String> generateProposalSection({
    required Map<String, dynamic> proposalData,
    required String section,
  }) async {
    final prompt = _buildSectionPrompt(proposalData, section);
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.7,
      maxTokens: 1000,
    );
    
    return response;
  }

  /// Improve existing proposal
  /// 
  /// [currentProposal] - Current proposal text
  /// [feedback] - Optional feedback for improvements
  /// Returns improved proposal
  Future<String> improveProposal({
    required String currentProposal,
    String? feedback,
  }) async {
    final prompt = _buildImprovementPrompt(currentProposal, feedback);
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.6,
      maxTokens: 2000,
    );
    
    return response;
  }

  /// Generate proposal pricing breakdown
  /// 
  /// [services] - List of services with descriptions
  /// [hours] - Estimated hours for each service
  /// [hourlyRate] - Hourly rate
  /// Returns pricing breakdown
  Future<String> generatePricingBreakdown({
    required List<Map<String, dynamic>> services,
    required List<int> hours,
    required double hourlyRate,
  }) async {
    final prompt = _buildPricingPrompt(services, hours, hourlyRate);
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.5,
      maxTokens: 1000,
    );
    
    return response;
  }

  String _buildProposalPrompt(
    String clientName,
    String projectDescription,
    String? budget,
    String? timeline,
    String? additionalDetails,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate a professional business proposal with the following details:');
    buffer.writeln('');
    buffer.writeln('Client: $clientName');
    buffer.writeln('Project Description: $projectDescription');
    
    if (budget != null && budget.isNotEmpty) {
      buffer.writeln('Budget: $budget');
    }
    
    if (timeline != null && timeline.isNotEmpty) {
      buffer.writeln('Timeline: $timeline');
    }
    
    if (additionalDetails != null && additionalDetails.isNotEmpty) {
      buffer.writeln('Additional Details: $additionalDetails');
    }
    
    buffer.writeln('');
    buffer.writeln('The proposal should include:');
    buffer.writeln('1. Executive Summary');
    buffer.writeln('2. Project Scope');
    buffer.writeln('3. Deliverables');
    buffer.writeln('4. Timeline');
    buffer.writeln('5. Pricing');
    buffer.writeln('6. Terms and Conditions');
    buffer.writeln('');
    buffer.writeln('Make it professional, clear, and persuasive.');
    buffer.writeln('Use proper formatting with sections and bullet points.');
    
    return buffer.toString();
  }

  String _buildSectionPrompt(Map<String, dynamic> proposalData, String section) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate the "$section" section for a business proposal.');
    buffer.writeln('');
    buffer.writeln('Proposal Context:');
    buffer.writeln('Client: ${proposalData['clientName'] ?? 'N/A'}');
    buffer.writeln('Project: ${proposalData['projectDescription'] ?? 'N/A'}');
    
    if (proposalData['budget'] != null) {
      buffer.writeln('Budget: ${proposalData['budget']}');
    }
    
    if (proposalData['timeline'] != null) {
      buffer.writeln('Timeline: ${proposalData['timeline']}');
    }
    
    buffer.writeln('');
    buffer.writeln('Generate a professional and detailed $section section.');
    buffer.writeln('Make it specific to the project context.');
    
    return buffer.toString();
  }

  String _buildImprovementPrompt(String currentProposal, String? feedback) {
    final buffer = StringBuffer();
    
    buffer.writeln('Improve the following business proposal:');
    buffer.writeln('');
    buffer.writeln(currentProposal);
    buffer.writeln('');
    
    if (feedback != null && feedback.isNotEmpty) {
      buffer.writeln('Feedback/Requirements for improvement:');
      buffer.writeln(feedback);
      buffer.writeln('');
    }
    
    buffer.writeln('Improve the proposal to be:');
    buffer.writeln('- More professional and polished');
    buffer.writeln('- Clearer and more persuasive');
    buffer.writeln('- Better structured');
    buffer.writeln('- More specific and detailed');
    buffer.writeln('Maintain the original content and intent while enhancing quality.');
    
    return buffer.toString();
  }

  String _buildPricingPrompt(
    List<Map<String, dynamic>> services,
    List<int> hours,
    double hourlyRate,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate a professional pricing breakdown for:');
    buffer.writeln('');
    buffer.writeln('Hourly Rate: \$${hourlyRate.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Services:');
    
    for (var i = 0; i < services.length; i++) {
      final service = services[i];
      final description = service['description']?.toString() ?? 'Service';
      final estimatedHours = hours.length > i ? hours[i] : 0;
      final cost = estimatedHours * hourlyRate;
      
      buffer.writeln('${i + 1}. $description - $estimatedHours hours = \$${cost.toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('Generate a professional pricing breakdown section that includes:');
    buffer.writeln('- Itemized list of services');
    buffer.writeln('- Hours and costs for each');
    buffer.writeln('- Total cost');
    buffer.writeln('- Payment terms');
    buffer.writeln('Make it clear and professional.');
    
    return buffer.toString();
  }
}
