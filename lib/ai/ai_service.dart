/// AI Service - Main entry point for AI features
/// 
/// This module provides AI-powered features for the invoice application including:
/// - Invoice data extraction from documents/images
/// - Smart categorization and tagging
/// - Revenue forecasting
/// - Expense prediction
/// - Anomaly detection
/// - Natural language queries
/// 
/// Architecture:
/// - Provider-agnostic design (can switch between OpenAI, Claude, local models, etc.)
/// - Modular feature services
/// - Configurable and extensible
/// - No actual AI implementation yet - architecture only

export 'providers/ai_provider.dart';
export 'providers/openai_provider.dart';
export 'providers/claude_provider.dart';
export 'providers/local_provider.dart';
export 'services/invoice_extraction_service.dart';
export 'services/categorization_service.dart';
export 'services/forecasting_service.dart';
export 'services/anomaly_detection_service.dart';
export 'services/natural_language_service.dart';
export 'models/ai_request.dart';
export 'models/ai_response.dart';
export 'models/ai_config.dart';
