import 'ai_provider.dart';

/// Local AI Provider
/// 
/// Implementation of AI provider using local models (e.g., Ollama, local LLM)
/// Useful for offline functionality and privacy
/// TODO: Implement actual local model integration
class LocalProvider implements AIProvider {
  String _modelPath = '';
  String _host = 'localhost';
  int _port = 11434;
  String _defaultModel = 'llama2';
  
  @override
  String get name => 'Local';
  
  @override
  String get version => '1.0.0';
  
  @override
  bool get isConfigured => true;
  
  LocalProvider({
    required String modelPath,
    String host = 'localhost',
    int port = 11434,
    String defaultModel = 'llama2',
  }) {
    _modelPath = modelPath;
    _host = host;
    _port = port;
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
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (prompt.contains('proposal') || prompt.contains('Proposal')) {
      return '''
# BUSINESS PROPOSAL: PROJECT SERVICES (Local Mock)

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
    
    return 'Mock Local completion for: ${prompt.length > 60 ? prompt.substring(0, 60) + "..." : prompt}';
  }
  
  @override
  Future<String> completeChat({
    required List<Map<String, String>> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'This is a mock chat response from Local Provider. Let me know if you need help generating invoices!';
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
