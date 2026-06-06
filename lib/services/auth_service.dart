import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Clear auth data (logout)
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Validate session by calling protected endpoint
  static Future<bool> validateSession() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      return response.statusCode == 200;
    } catch (e) {
      // If session validation fails, clear the token
      await clearAuthData();
      return false;
    }
  }

  // Auto login - validate session and return user data if valid
  static Future<Map<String, dynamic>?> autoLogin() async {
    try {
      final isValid = await validateSession();
      if (isValid) {
        final userData = await getUserData();
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    await clearAuthData();
  }
}
