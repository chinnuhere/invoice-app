/// Base AI Provider Interface
/// 
/// Abstract base class for all AI providers (OpenAI, Claude, Local, etc.)
/// Allows switching between different AI backends without changing application code

abstract class AIProvider {
  /// Provider name
  String get name;
  
  /// Provider version
  String get version;
  
  /// Check if provider is configured and ready
  bool get isConfigured;
  
  /// Initialize the provider
  Future<void> initialize();
  
  /// Send a text completion request
  /// 
  /// [prompt] - The input prompt
  /// [model] - Optional model identifier
  /// [temperature] - Optional temperature (0.0 to 1.0)
  /// [maxTokens] - Optional maximum tokens to generate
  Future<String> completeText({
    required String prompt,
    String? model,
    double? temperature,
    int? maxTokens,
  });
  
  /// Send a chat completion request
  /// 
  /// [messages] - List of message objects with role and content
  /// [model] - Optional model identifier
  /// [temperature] - Optional temperature (0.0 to 1.0)
  /// [maxTokens] - Optional maximum tokens to generate
  Future<String> completeChat({
    required List<Map<String, String>> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  });
  
  /// Send an embedding request
  /// 
  /// [text] - Text to embed
  /// [model] - Optional model identifier
  Future<List<double>> embedText({
    required String text,
    String? model,
  });
  
  /// Send a function calling request
  /// 
  /// [prompt] - The input prompt
  /// [functions] - List of available functions
  /// [model] - Optional model identifier
  Future<Map<String, dynamic>> callFunction({
    required String prompt,
    required List<Map<String, dynamic>> functions,
    String? model,
  });
  
  /// Cleanup resources
  Future<void> dispose();
}

/// AI Provider Factory
/// 
/// Factory for creating AI provider instances based on configuration
class AIProviderFactory {
  static AIProvider? _instance;
  
  /// Get the current AI provider instance
  static AIProvider getInstance() {
    if (_instance == null) {
      throw Exception('AI Provider not initialized. Call initialize() first.');
    }
    return _instance!;
  }
  
  /// Initialize AI provider with configuration
  static Future<void> initialize(AIProvider provider) async {
    _instance = provider;
    await _instance!.initialize();
  }
  
  /// Reset the provider instance
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}
