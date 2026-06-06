/// AI Configuration
/// 
/// Configuration settings for AI features
class AIConfig {
  /// Provider type (openai, claude, local)
  final String provider;
  
  /// API key for cloud providers
  final String? apiKey;
  
  /// Base URL for API calls
  final String? baseUrl;
  
  /// Default model to use
  final String? defaultModel;
  
  /// Temperature for text generation (0.0 to 1.0)
  final double temperature;
  
  /// Maximum tokens to generate
  final int maxTokens;
  
  /// Timeout for API calls in seconds
  final int timeout;
  
  /// Enable caching
  final bool enableCache;
  
  /// Cache duration in minutes
  final int cacheDuration;
  
  /// Enable offline mode
  final bool enableOffline;
  
  /// Custom configuration parameters
  final Map<String, dynamic> customParams;

  AIConfig({
    required this.provider,
    this.apiKey,
    this.baseUrl,
    this.defaultModel,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.timeout = 30,
    this.enableCache = true,
    this.cacheDuration = 60,
    this.enableOffline = false,
    this.customParams = const {},
  });

  /// Create from JSON
  factory AIConfig.fromJson(Map<String, dynamic> json) {
    return AIConfig(
      provider: json['provider'] as String,
      apiKey: json['apiKey'] as String?,
      baseUrl: json['baseUrl'] as String?,
      defaultModel: json['defaultModel'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 1000,
      timeout: json['timeout'] as int? ?? 30,
      enableCache: json['enableCache'] as bool? ?? true,
      cacheDuration: json['cacheDuration'] as int? ?? 60,
      enableOffline: json['enableOffline'] as bool? ?? false,
      customParams: json['customParams'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'defaultModel': defaultModel,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'timeout': timeout,
      'enableCache': enableCache,
      'cacheDuration': cacheDuration,
      'enableOffline': enableOffline,
      'customParams': customParams,
    };
  }

  /// Copy with modifications
  AIConfig copyWith({
    String? provider,
    String? apiKey,
    String? baseUrl,
    String? defaultModel,
    double? temperature,
    int? maxTokens,
    int? timeout,
    bool? enableCache,
    int? cacheDuration,
    bool? enableOffline,
    Map<String, dynamic>? customParams,
  }) {
    return AIConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      timeout: timeout ?? this.timeout,
      enableCache: enableCache ?? this.enableCache,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      enableOffline: enableOffline ?? this.enableOffline,
      customParams: customParams ?? this.customParams,
    );
  }
}
