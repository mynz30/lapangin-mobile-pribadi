// lib/admin-dashboard/models/admin_user.dart

class AdminUser {
  final String username;
  final String role;
  final String nomorWhatsapp;
  final String nomorRekening;

  AdminUser({
    required this.username,
    required this.role,
    required this.nomorWhatsapp,
    required this.nomorRekening,
  });

  /// Create AdminUser from JSON (dari API response)
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      username: json['username'] ?? '',
      role: json['role'] ?? 'PEMILIK',
      nomorWhatsapp: json['nomor_whatsapp'] ?? '',
      nomorRekening: json['nomor_rekening'] ?? '',
    );
  }

  /// Convert AdminUser to JSON (untuk simpan ke storage)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'nomor_whatsapp': nomorWhatsapp,
      'nomor_rekening': nomorRekening,
    };
  }

  /// Check apakah user adalah PEMILIK
  bool get isPemilik => role == 'PEMILIK';
  
  /// Get display name untuk role
  String get roleDisplay {
    switch (role) {
      case 'PEMILIK':
        return 'Pemilik Lapangan';
      case 'PENYEWA':
        return 'Penyewa Lapangan';
      default:
        return role;
    }
  }
}