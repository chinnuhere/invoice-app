import 'ai_provider.dart';

/// Claude Provider
/// 
/// Implementation of AI provider using Anthropic Claude API
/// TODO: Implement actual Claude API integration
class ClaudeProvider implements AIProvider {
  String _apiKey = '';
  String _baseUrl = 'https://api.anthropic.com/v1';
  String _defaultModel = 'claude-3-opus-20240229';
  
  @override
  String get name => 'Claude';
  
  @override
  String get version => '1.0.0';
  
  @override
  bool get isConfigured => true;
  
  ClaudeProvider({
    required String apiKey,
    String baseUrl = 'https://api.anthropic.com/v1',
    String defaultModel = 'claude-3-opus-20240229',
  }) {
    _apiKey = apiKey;
    _baseUrl = baseUrl;
    _defaultModel = defaultModel;
  }
  
  @override
  Future<void> initialize() async {
    // Mock initialization: always succeeds
  }
  
  @override
  Future<String> completeText({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network lag
    
    if (prompt.contains('proposal') || prompt.contains('Proposal')) {
      return '''
# BUSINESS PROPOSAL: PROJECT SERVICES (Claude Mock)

## 1. Executive Summary
This proposal outlines the professional services and deliverables required for the project. Our objective is to deliver high-quality, scalable results that align with your business goals.

## 2. Project Scope
The scope of work includes:
* Detailed analysis and planning
* Core development and integration
* Testing and quality assurance
* Deployment and post-launch support

## 3. Deliverables
* Fully functional application matching specifications
* Source code repository access
* Project documentation and guidelines
* 30 days of post-launch maintenance

## 4. Timeline
The estimated timeline for this project is 4-6 weeks from commencement.

## 5. Pricing
The total estimated cost for the defined scope of work is detailed in the pricing breakdown.

## 6. Terms and Conditions
Work will commence upon signing of this agreement and receipt of the initial deposit.
''';
    }
    
    if (prompt.contains('description') || prompt.contains('items') || prompt.contains('Expense')) {
      return 'Professional development services and consulting support.';
    }
    
    return 'Mock Claude completion for: ${prompt.length > 60 ? prompt.substring(0, 60) + "..." : prompt}';
  }
  
  @override
  Future<String> completeChat({
    required List<Map<String, String>> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'This is a mock chat response from Claude. Let me know if you need help generating invoices!';
  }
  
  @override
  Future<List<double>> embedText({
    required String text,
    String? model,
  }) async {
    return List<double>.filled(1536, 0.0);
  }
  
  @override
  Future<Map<String, dynamic>> callFunction({
    required String prompt,
    required List<Map<String, dynamic>> functions,
    String? model,
  }) async {
    return {
      'function': functions.isNotEmpty ? functions.first['name'] : 'mock_function',
      'arguments': <String, dynamic>{},
    };
  }
  
  @override
  Future<void> dispose() async {
    // Cleanup resources if needed
  }
}
