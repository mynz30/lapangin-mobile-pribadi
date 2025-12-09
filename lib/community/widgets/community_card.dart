// lib/community/widgets/community_card.dart

import 'package:flutter/material.dart';
import 'package:lapangin_mobile/community/models/community_models.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap; // Aksi saat kartu ditekan

  const CommunityCard({
    Key? key,
    required this.community,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GANTI URL INI SESUAI IP SERVER KAMU (sama seperti di community_page.dart)
    // Gunakan 10.0.2.2 untuk Android Emulator, atau localhost untuk Web/iOS Simulator
    String baseUrl = "http://127.0.0.1:8000"; 
    
    // Logika untuk URL Gambar: Jika URL dari API tidak kosong, gabungkan dengan baseUrl
    // (Karena Django biasanya hanya mengirim 'media/community_images/...', bukan full URL)
    String fullImageUrl = "";
    if (community.imageUrl.isNotEmpty) {
      if (community.imageUrl.startsWith("http")) {
        fullImageUrl = community.imageUrl;
      } else {
        fullImageUrl = "$baseUrl${community.imageUrl}";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Image Section (Left 1/3)
              Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  image: fullImageUrl.isNotEmpty 
                    ? DecorationImage(
                        image: NetworkImage(fullImageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      )
                    : null,
                  color: fullImageUrl.isEmpty ? Colors.grey[200] : null,
                ),
                child: fullImageUrl.isEmpty 
                  ? Center(
                      child: Icon(
                        _getIconForSport(community.sportsType),
                        size: 40,
                        color: Colors.grey,
                      ),
                    ) 
                  : null,
              ),
              
              // Content Section (Right 2/3)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 12.0, 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Content (Left)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      community.sportsType,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7B904B), // Olive Green
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: Text("•", style: TextStyle(color: Color(0xFF7B904B), fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: Text(
                                        community.location,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFC5A027), // Gold
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Description
                            Text(
                              community.description.isNotEmpty ? community.description : "Join kuy",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            // Link
                             const Text(
                               "Cek Komunitas \u2192", 
                               style: TextStyle(
                                 fontSize: 13,
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF7B904B),
                                 decoration: TextDecoration.underline,
                                 decorationColor: Color(0xFF7B904B),
                               ),
                             ),
                          ],
                        ),
                      ),

                      // Member Count (Right Center)
                      Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                             const Icon(Icons.person, size: 24, color: Color(0xFF7B904B)),
                             const SizedBox(width: 4),
                             Text(
                               community.memberCount.toString(),
                               style: const TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.black54,
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk icon default berdasarkan jenis olahraga
  IconData _getIconForSport(String type) {
    switch (type.toLowerCase()) {
      case 'futsal':
        return Icons.sports_soccer;
      case 'basket':
        return Icons.sports_basketball;
      case 'bulutangkis':
      case 'badminton':
        return Icons.sports_tennis; // Tidak ada icon badminton spesifik di Material Icons default
      default:
        return Icons.groups;
    }
  }
}