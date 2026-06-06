import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
  
  // API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://127.0.0.1:8000';
      case Environment.staging:
        return 'https://staging-api.invoiceapp.com';
      case Environment.production:
        return 'https://invoice-app-backend-o8wp.onrender.com';
    }
  }
  
  static Duration get apiTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
  
  // Feature Flags
  static bool get enableDebugLogging {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  // AI Configuration
  static String get aiProvider {
    switch (_environment) {
      case Environment.development:
        return 'None';
      case Environment.staging:
        return 'OpenAI';
      case Environment.production:
        return 'OpenAI';
    }
  }
  
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  
  static void log(String message) {
    if (enableDebugLogging) {
      debugPrint('[$environmentName] $message');
    }
  }
}
