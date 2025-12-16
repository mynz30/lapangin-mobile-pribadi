// lib/admin-dashboard/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapangin/config.dart';

class AdminApiService {
  static String get baseUrl => Config.baseUrl;
  
  /// Login Admin dengan extract session cookie
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
      
      // Extract session cookie
      final setCookie = response.headers['set-cookie'];
      String? sessionCookie;
      if (setCookie != null) {
        sessionCookie = setCookie.split(';')[0];
      }
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
      
      if (responseData['status'] != true) {
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
      
      // Add session cookie to response
      responseData['session_cookie'] = sessionCookie ?? '';
      
      return responseData;
      
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }
  
  /// Logout Admin
  static Future<void> logout() async {
    return Future.value();
  }
}