// test/admin_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lapangin/admin-dashboard/services/api_service.dart';

void main() {
  group('Admin API Tests', () {
    test('Login dengan credentials yang benar', () async {
      // GANTI dengan username dan password admin yang valid
      final response = await AdminApiService.login(
        username: 'juragan01',  // Sesuaikan dengan data Anda
        password: 'juragan123', // Sesuaikan dengan data Anda
      );

      expect(response['status'], true);
      expect(response['data']['role'], 'PEMILIK');
      expect(response['data']['username'], 'juragan01');
    });

    test('Login dengan credentials yang salah', () async {
      expect(
        () => AdminApiService.login(
          username: 'wrong_user',
          password: 'wrong_pass',
        ),
        throwsException,
      );
    });

    test('Login dengan user PENYEWA (bukan admin)', () async {
      // GANTI dengan username penyewa yang valid jika ada
      expect(
        () => AdminApiService.login(
          username: 'penyewa_user',  // User dengan role PENYEWA
          password: 'password123',
        ),
        throwsException,
      );
    });
  });
}