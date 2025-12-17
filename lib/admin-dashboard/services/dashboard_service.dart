import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapangin_mobile/config.dart';

class AdminDashboardService {
  static Future<Map<String, dynamic>> getDashboardStats(String sessionCookie) async {
    try {
      final url = Uri.parse('${Config.baseUrl}/dashboard/api/dashboard/stats/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('Dashboard Stats Response: ${response.statusCode}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data dashboard');
      }
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data dashboard');
      }
      
      return responseData['data'];
      
    } catch (e) {
      print('Dashboard Stats Error: $e');
      rethrow;
    }
  }
}