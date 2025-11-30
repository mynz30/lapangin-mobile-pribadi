import 'package:flutter/material.dart';

// Import model ReviewEntry yang sudah Anda definisikan (asumsi path sudah benar)
// import 'path/to/review_entry.dart'; 

// --- Dummy Model (Untuk Testing jika Anda belum mengimport) ---
class ReviewEntry {
  final String user;
  final String content;
  final int rating;
  final String createdAt;
  final bool isOwner;

  ReviewEntry({
    required this.user,
    required this.content,
    required this.rating,
    required this.createdAt,
    required this.isOwner,
  });
}
// -----------------------------------------------------------------

class ReviewCard extends StatelessWidget {
  final ReviewEntry review;

  const ReviewCard({
    required this.review,
    super.key,
  });

  // Fungsi helper untuk mendapatkan inisial
  String _getInitial(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Memberikan padding/margin di sekitar card
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Baris Avatar, Nama, dan Tanggal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Pengguna
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFC7E0C0), // Warna avatar hijau muda
                child: Text(
                  _getInitial(review.user),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Nama Pengguna dan Tanggal Ulasan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.user,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    review.createdAt, // Menggunakan data createdAt dari model
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Opsi Tambahan (misalnya, tombol Edit/Hapus jika isOwner = true)
              const Spacer(),
              if (review.isOwner) 
                const Icon(
                  Icons.more_vert, 
                  color: Colors.grey, 
                  size: 20
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Teks Ulasan (Konten)
          Text(
            review.content, // Menggunakan data content dari model
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),

          // 3. Rating Bintang
          Row(
            children: List.generate(5, (index) {
              return Icon(
                // Bintang penuh jika index kurang dari rating, sisanya bintang kosong
                index < review.rating ? Icons.star : Icons.star_border, 
                color: Colors.amber, // Warna bintang kuning
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}

