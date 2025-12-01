// lib/admin-dashboard/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapangin/config.dart';

class AdminApiService {
  // Base URL dari config
  static String get baseUrl => Config.baseUrl;
  
  /// Login Admin
  /// 
  /// POST /dashboard/api/login/
  /// 
  /// Returns:
  /// - Map dengan key 'status', 'message', 'data'
  /// - Throws Exception jika gagal
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/dashboard/api/login/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('🔵 Login Response Status: ${response.statusCode}');
      print('🔵 Login Response Body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      // Handle error responses
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
      
      // Check status from response
      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
      
      return responseData;
      
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }
  
  /// Logout Admin
  /// 
  /// Untuk saat ini hanya clear local data
  /// Bisa ditambahkan endpoint logout di backend jika diperlukan
  static Future<void> logout() async {
    // TODO: Implement logout logic (clear session, etc)
    return Future.value();
  }
}