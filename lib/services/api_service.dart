import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Signup failed');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/dashboard/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch dashboard data');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<List<dynamic>> getClients() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/clients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch clients');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> createClient(Map<String, dynamic> clientData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/clients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clientData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create client');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> updateClient(int id, Map<String, dynamic> clientData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/clients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(clientData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update client');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<void> deleteClient(int id) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/clients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to delete client');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<List<dynamic>> getInvoices() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch invoices');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getInvoiceById(int id) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/invoices/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch invoice');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(invoiceData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create invoice');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> updateInvoice(int id, Map<String, dynamic> invoiceData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/invoices/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(invoiceData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update invoice');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<void> deleteInvoice(int id) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/invoices/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to delete invoice');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<List<dynamic>> getExpenses() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch expenses');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getExpenseById(int id) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/expenses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch expense');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expenseData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create expense');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> updateExpense(int id, Map<String, dynamic> expenseData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/expenses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(expenseData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update expense');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<void> deleteExpense(int id) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/expenses/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to delete expense');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/monthly?year=$year&month=$month'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch monthly report');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getYearlyReport(int year) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/reports/yearly?year=$year'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch yearly report');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> getRevenueReport({String? startDate, String? endDate}) async {
    try {
      final token = await AuthService.getToken();
      
      String url = '${AppConfig.apiBaseUrl}/reports/revenue';
      if (startDate != null && endDate != null) {
        url += '?startDate=$startDate&endDate=$endDate';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch revenue report');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>?> getBusinessProfile() async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/business-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(data['error'] ?? 'Failed to fetch business profile');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> createBusinessProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/business-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create business profile');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }

  static Future<Map<String, dynamic>> updateBusinessProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await AuthService.getToken();
      
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/business-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(AppConfig.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update business profile');
      }
    } on http.ClientException {
      throw Exception("Unable to connect to server");
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Unable to connect to server");
      }
      throw Exception("Network error: $e");
    }
  }
}
