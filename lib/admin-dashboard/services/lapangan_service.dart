// lib/admin-dashboard/services/lapangan_service.dart - NEW FILE
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lapangin/config.dart';

class AdminLapanganService {
  
  /// Create new lapangan
  static Future<Map<String, dynamic>> createLapangan({
    required String sessionCookie,
    required String nama,
    required String jenis,
    required String lokasi,
    required int harga,
    required String fasilitas,
    required String deskripsi,
    File? foto1,
    File? foto2,
    File? foto3,
  }) async {
    try {
      final url = Uri.parse(Config.getUrl(Config.adminLapanganCreateEndpoint));
      
      // Convert images to base64
      String? foto1Base64;
      String? foto2Base64;
      String? foto3Base64;
      
      if (foto1 != null) {
        final bytes = await foto1.readAsBytes();
        foto1Base64 = base64Encode(bytes);
      }
      
      if (foto2 != null) {
        final bytes = await foto2.readAsBytes();
        foto2Base64 = base64Encode(bytes);
      }
      
      if (foto3 != null) {
        final bytes = await foto3.readAsBytes();
        foto3Base64 = base64Encode(bytes);
      }
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie,
        },
        body: jsonEncode({
          'nama_lapangan': nama,
          'jenis_olahraga': jenis,
          'lokasi': lokasi,
          'harga_per_jam': harga,
          'fasilitas': fasilitas,
          'deskripsi': deskripsi,
          if (foto1Base64 != null) 'foto_utama': foto1Base64,
          if (foto2Base64 != null) 'foto_2': foto2Base64,
          if (foto3Base64 != null) 'foto_3': foto3Base64,
        }),
      );
      
      print('Create Lapangan Response: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 && data['status'] == 'success') {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat lapangan');
      }
      
    } catch (e) {
      print('Error createLapangan: $e');
      throw Exception('Error: $e');
    }
  }
  
  /// Update existing lapangan
  static Future<Map<String, dynamic>> updateLapangan({
    required int lapanganId,
    required String sessionCookie,
    required String nama,
    required String jenis,
    required String lokasi,
    required int harga,
    required String fasilitas,
    required String deskripsi,
    File? foto1,
    File? foto2,
    File? foto3,
  }) async {
    try {
      final url = Uri.parse(
        Config.getUrl('${Config.adminLapanganUpdateEndpoint}$lapanganId/update/')
      );
      
      // Convert images to base64 if provided
      String? foto1Base64;
      String? foto2Base64;
      String? foto3Base64;
      
      if (foto1 != null) {
        final bytes = await foto1.readAsBytes();
        foto1Base64 = base64Encode(bytes);
      }
      
      if (foto2 != null) {
        final bytes = await foto2.readAsBytes();
        foto2Base64 = base64Encode(bytes);
      }
      
      if (foto3 != null) {
        final bytes = await foto3.readAsBytes();
        foto3Base64 = base64Encode(bytes);
      }
      
      final Map<String, dynamic> body = {
        'nama_lapangan': nama,
        'jenis_olahraga': jenis,
        'lokasi': lokasi,
        'harga_per_jam': harga,
        'fasilitas': fasilitas,
        'deskripsi': deskripsi,
      };
      
      if (foto1Base64 != null) body['foto_utama'] = foto1Base64;
      if (foto2Base64 != null) body['foto_2'] = foto2Base64;
      if (foto3Base64 != null) body['foto_3'] = foto3Base64;
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie,
        },
        body: jsonEncode(body),
      );
      
      print('Update Lapangan Response: ${response.statusCode}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Gagal update lapangan');
      }
      
    } catch (e) {
      print('Error updateLapangan: $e');
      throw Exception('Error: $e');
    }
  }
  
  /// Delete lapangan
  static Future<void> deleteLapangan(
    int lapanganId,
    String sessionCookie,
  ) async {
    try {
      final url = Uri.parse(
        Config.getUrl('${Config.adminLapanganDeleteEndpoint}$lapanganId/delete/')
      );
      
      final response = await http.post(
        url,
        headers: {
          'Cookie': sessionCookie,
        },
      );
      
      print('Delete Lapangan Response: ${response.statusCode}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        return;
      } else {
        throw Exception(data['message'] ?? 'Gagal menghapus lapangan');
      }
      
    } catch (e) {
      print('Error deleteLapangan: $e');
      throw Exception('Error: $e');
    }
  }
  
  /// Get lapangan detail for editing
  static Future<Map<String, dynamic>> getLapanganDetail(
    int lapanganId,
    String sessionCookie,
  ) async {
    try {
      final url = Uri.parse(
        Config.getUrl('${Config.adminLapanganDetailEndpoint}$lapanganId/detail/')
      );
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
        },
      );
      
      print('Get Lapangan Detail Response: ${response.statusCode}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat detail lapangan');
      }
      
    } catch (e) {
      print('Error getLapanganDetail: $e');
      throw Exception('Error: $e');
    }
  }
}