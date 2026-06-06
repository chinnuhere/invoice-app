/// AI Response Models
/// 
/// Standardized response models for AI features

/// Base AI Response
class AIResponse {
  final String content;
  final String? model;
  final int? tokensUsed;
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  AIResponse({
    required this.content,
    this.model,
    this.tokensUsed,
    required this.success,
    this.error,
    this.metadata,
  });

  factory AIResponse.success({
    required String content,
    String? model,
    int? tokensUsed,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponse(
      content: content,
      model: model,
      tokensUsed: tokensUsed,
      success: true,
      metadata: metadata,
    );
  }

  factory AIResponse.failure({
    required String error,
    Map<String, dynamic>? metadata,
  }) {
    return AIResponse(
      content: '',
      success: false,
      error: error,
      metadata: metadata,
    );
  }
}

/// Chat Response
class ChatResponse extends AIResponse {
  final List<ChatMessage>? messages;

  ChatResponse({
    required String content,
    String? model,
    int? tokensUsed,
    required bool success,
    String? error,
    this.messages,
    Map<String, dynamic>? metadata,
  }) : super(
          content: content,
          model: model,
          tokensUsed: tokensUsed,
          success: success,
          error: error,
          metadata: metadata,
        );

  factory ChatResponse.success({
    required String content,
    String? model,
    int? tokensUsed,
    List<ChatMessage>? messages,
    Map<String, dynamic>? metadata,
  }) {
    return ChatResponse(
      content: content,
      model: model,
      tokensUsed: tokensUsed,
      success: true,
      messages: messages,
      metadata: metadata,
    );
  }
}

/// Embedding Response
class EmbeddingResponse {
  final List<double> embedding;
  final String? model;
  final int? dimensions;
  final bool success;
  final String? error;

  EmbeddingResponse({
    required this.embedding,
    this.model,
    this.dimensions,
    required this.success,
    this.error,
  });

  factory EmbeddingResponse.success({
    required List<double> embedding,
    String? model,
    int? dimensions,
  }) {
    return EmbeddingResponse(
      embedding: embedding,
      model: model,
      dimensions: dimensions,
      success: true,
    );
  }

  factory EmbeddingResponse.failure({
    required String error,
  }) {
    return EmbeddingResponse(
      embedding: [],
      success: false,
      error: error,
    );
  }
}

/// Function Call Response
class FunctionCallResponse {
  final String? functionName;
  final Map<String, dynamic>? functionArgs;
  final String? content;
  final String? model;
  final bool success;
  final String? error;

  FunctionCallResponse({
    this.functionName,
    this.functionArgs,
    this.content,
    this.model,
    required this.success,
    this.error,
  });

  factory FunctionCallResponse.success({
    String? functionName,
    Map<String, dynamic>? functionArgs,
    String? content,
    String? model,
  }) {
    return FunctionCallResponse(
      functionName: functionName,
      functionArgs: functionArgs,
      content: content,
      model: model,
      success: true,
    );
  }

  factory FunctionCallResponse.failure({
    required String error,
  }) {
    return FunctionCallResponse(
      success: false,
      error: error,
    );
  }
}
