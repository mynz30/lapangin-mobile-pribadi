// lib/booking/services/booking_service.dart - COMPLETE FIXED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/booking_models.dart';
import '../../config.dart';

class BookingService {
  // ============================================================
  // 1. Get All Lapangan
  // ============================================================
  static Future<List<Lapangan>> getLapanganList() async {
    try {
      final response = await http.get(
        Uri.parse(Config.getUrl(Config.lapanganListEndpoint)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => Lapangan.fromJson(json))
              .toList();
        }
      }
      throw Exception('Gagal memuat daftar lapangan');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 2. Get Lapangan Detail
  // ============================================================
  static Future<Lapangan> getLapanganDetail(int lapanganId) async {
    try {
      final response = await http.get(
        Uri.parse(Config.getUrl('${Config.lapanganDetailEndpoint}$lapanganId/')),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return Lapangan.fromJson(data['data']);
        }
      }
      throw Exception('Gagal memuat detail lapangan');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 3. Get Available Slots
  // ============================================================
  static Future<BookingSlotsResponse> getAvailableSlots(
    int lapanganId, {
    String? date,
    int days = 7,
  }) async {
    try {
      String url = '${Config.getUrl(Config.availableSlotsEndpoint)}$lapanganId/?days=$days';
      if (date != null) {
        url += '&date=$date';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return BookingSlotsResponse.fromJson(data['data']);
        }
      }
      throw Exception('Gagal memuat slot booking');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 4. Create Booking (Legacy - with session cookie string)
  // ============================================================
  static Future<Map<String, dynamic>> createBooking(
    int slotId,
    String sessionCookie,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Config.getUrl(Config.createBookingEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie,
        },
        body: json.encode({'slot_id': slotId}),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['status'] == 'success') {
        return data['data'];
      } else if (response.statusCode == 401) {
        throw Exception('Anda harus login terlebih dahulu');
      } else if (response.statusCode == 400) {
        throw Exception(data['message'] ?? 'Slot tidak tersedia');
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat booking');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 5. Get Booking Detail (Legacy)
  // ============================================================
  static Future<Booking> getBookingDetail(
    int bookingId,
    String sessionCookie,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(Config.getUrl('${Config.bookingDetailEndpoint}$bookingId/')),
        headers: {
          'Cookie': sessionCookie,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return Booking.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Anda harus login terlebih dahulu');
      } else if (response.statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke booking ini');
      }
      throw Exception('Gagal memuat detail booking');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 6. Get My Bookings (Legacy)
  // ============================================================
  static Future<List<Booking>> getMyBookings(String sessionCookie) async {
    try {
      final response = await http.get(
        Uri.parse(Config.getUrl(Config.myBookingsEndpoint)),
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Anda harus login terlebih dahulu');
      }
      
      throw Exception('Gagal memuat daftar booking: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 7. Cancel Booking
  // ============================================================
  static Future<void> cancelBooking(
    int bookingId,
    String sessionCookie,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Config.getUrl('${Config.cancelBookingEndpoint}$bookingId/cancel/')),
        headers: {
          'Cookie': sessionCookie,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Anda harus login terlebih dahulu');
      } else if (response.statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke booking ini');
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal membatalkan booking');
      }
      
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Gagal membatalkan booking');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // 8. Get My Bookings using CookieRequest (RECOMMENDED)
  // ============================================================
  static Future<List<Booking>> getMyBookingsWithRequest(CookieRequest request) async {
    try {
      final response = await request.get(
        Config.getUrl(Config.myBookingsEndpoint)
      );

      if (response is Map && response['status'] == 'success') {
        return (response['data'] as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      } else if (response is Map && response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Gagal memuat daftar booking');
      } else {
        throw Exception('Format response tidak dikenali');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 9. Create Booking using CookieRequest (RECOMMENDED)
  // ============================================================
  static Future<Map<String, dynamic>> createBookingWithRequest(
    CookieRequest request, 
    int slotId
  ) async {
    try {
      final response = await request.postJson(
        Config.getUrl(Config.createBookingEndpoint),
        jsonEncode({
          'slot_id': slotId,
        }),
      );

      if (response is Map && response['status'] == 'success') {
        return {
          'success': true,
          'booking_id': response['data']['booking_id'],
          'message': response['message'] ?? 'Booking berhasil',
          'data': response['data'],
        };
      } else if (response is Map && response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Gagal membuat booking');
      } else {
        throw Exception('Format response tidak dikenali');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // 10. Get Booking Detail using CookieRequest (RECOMMENDED)
  // ============================================================
  static Future<Booking> getBookingDetailWithRequest(
    CookieRequest request,
    int bookingId,
  ) async {
    try {
      final response = await request.get(
        Config.getUrl('${Config.bookingDetailEndpoint}$bookingId/')
      );

      if (response is Map && response['status'] == 'success') {
        return Booking.fromJson(response['data']);
      } else if (response is Map && response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Gagal memuat detail booking');
      } else {
        throw Exception('Format response tidak dikenali');
      }
    } catch (e) {
      rethrow;
    }
  }
}