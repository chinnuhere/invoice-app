import 'package:flutter/foundation.dart';
import 'app_config.dart';

/// Environment Configuration
/// 
/// This file controls which environment the app runs in.
/// Change the environment below to switch between development, staging, and production.
class EnvConfig {
  static void init() {
    // Auto-detect environment based on build mode (release -> production, profile -> staging, debug -> development)
    autoDetectEnvironment();
    
    // Log the current environment
    AppConfig.log('Environment initialized: ${AppConfig.environmentName}');
    AppConfig.log('API Base URL: ${AppConfig.apiBaseUrl}');
    AppConfig.log('API Timeout: ${AppConfig.apiTimeout.inSeconds} seconds');
  }
  
  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;
  
  /// Check if running in profile mode
  static bool get isProfileMode => kProfileMode;
  
  /// Check if running in release mode
  static bool get isReleaseMode => kReleaseMode;
  
  /// Auto-detect environment based on build mode
  static void autoDetectEnvironment() {
    if (kReleaseMode) {
      AppConfig.setEnvironment(Environment.production);
    } else if (kProfileMode) {
      AppConfig.setEnvironment(Environment.staging);
    } else {
      AppConfig.setEnvironment(Environment.development);
    }
    
    AppConfig.log('Auto-detected environment: ${AppConfig.environmentName}');
  }
}
