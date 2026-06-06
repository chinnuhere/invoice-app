/// AI Request Models
/// 
/// Standardized request models for AI features

/// Base AI Request
class AIRequest {
  final String prompt;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final Map<String, dynamic>? metadata;

  AIRequest({
    required this.prompt,
    this.model,
    this.temperature,
    this.maxTokens,
    this.metadata,
  });
}

/// Chat Message
class ChatMessage {
  final String role; // system, user, assistant
  final String content;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.role,
    required this.content,
    this.metadata,
  });

  Map<String, String> toMap() {
    return {
      'role': role,
      'content': content,
    };
  }
}

/// Chat Request
class ChatRequest {
  final List<ChatMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final Map<String, dynamic>? metadata;

  ChatRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
    this.metadata,
  });

  List<Map<String, String>> toMessageMaps() {
    return messages.map((m) => m.toMap()).toList();
  }
}

/// Embedding Request
class EmbeddingRequest {
  final String text;
  final String? model;
  final Map<String, dynamic>? metadata;

  EmbeddingRequest({
    required this.text,
    this.model,
    this.metadata,
  });
}

/// Function Definition
class FunctionDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  FunctionDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'parameters': parameters,
    };
  }
}

/// Function Calling Request
class FunctionCallRequest {
  final String prompt;
  final List<FunctionDefinition> functions;
  final String? model;
  final Map<String, dynamic>? metadata;

  FunctionCallRequest({
    required this.prompt,
    required this.functions,
    this.model,
    this.metadata,
  });

  List<Map<String, dynamic>> toFunctionMaps() {
    return functions.map((f) => f.toMap()).toList();
  }
}
