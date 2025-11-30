class UserProfile {
  final String username;
  final String role;
  final String? nomorWhatsapp;
  final String? nomorRekening;

  UserProfile({
    required this.username,
    required this.role,
    this.nomorWhatsapp,
    this.nomorRekening,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      role: json['role'],
      nomorWhatsapp: json['nomor_whatsapp'],
      nomorRekening: json['nomor_rekening'],
    );
  }

  String get roleDisplay {
    switch (role) {
      case 'PENYEWA':
        return 'Penyewa Lapangan';
      case 'PEMILIK':
        return 'Pemilik Lapangan';
      default:
        return role;
    }
  }

  bool get isPemilik => role == 'PEMILIK';
  bool get isPenyewa => role == 'PENYEWA';
}