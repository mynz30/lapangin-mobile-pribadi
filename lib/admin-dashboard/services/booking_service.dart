// lib/admin-dashboard/services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapangin_mobile/config.dart';

class AdminBookingService {
  /// Get Pending Bookings
  /// 
  /// GET /dashboard/api/booking/pending/
  /// 
  /// Returns list of pending bookings
  static Future<List<Map<String, dynamic>>> getPendingBookings(
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.baseUrl}/dashboard/api/booking/pending/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('🔵 Get Pending Bookings Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data booking');
      }
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data booking');
      }
      
      return List<Map<String, dynamic>>.from(responseData['data']);
      
    } catch (e) {
      print('❌ Get Pending Bookings Error: $e');
      rethrow;
    }
  }
  
  /// Approve Booking
  /// 
  /// POST /dashboard/api/booking/{id}/approve/
  static Future<void> approveBooking(
    int bookingId,
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse(
        '${Config.baseUrl}/dashboard/api/booking/$bookingId/approve/'
      );
      
      final response = await http.post(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('🔵 Approve Booking Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal approve booking');
      }
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal approve booking');
      }
      
    } catch (e) {
      print('❌ Approve Booking Error: $e');
      rethrow;
    }
  }
  
  /// Reject Booking
  /// 
  /// POST /dashboard/api/booking/{id}/reject/
  static Future<void> rejectBooking(
    int bookingId,
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse(
        '${Config.baseUrl}/dashboard/api/booking/$bookingId/reject/'
      );
      
      final response = await http.post(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('🔵 Reject Booking Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal reject booking');
      }
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal reject booking');
      }
      
    } catch (e) {
      print('❌ Reject Booking Error: $e');
      rethrow;
    }
  }
  
  /// Get Lapangan List
  /// 
  /// GET /dashboard/api/lapangan/list/
  static Future<List<Map<String, dynamic>>> getLapanganList(
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.baseUrl}/dashboard/api/lapangan/list/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('🔵 Get Lapangan List Response Status: ${response.statusCode}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data lapangan');
      }
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data lapangan');
      }
      
      return List<Map<String, dynamic>>.from(responseData['data']);
      
    } catch (e) {
      print('❌ Get Lapangan List Error: $e');
      rethrow;
    }
  }
}