import 'package:flutter/material.dart';
import 'package:lapangin/landing/models/lapangan_entry.dart';
import 'package:lapangin/config.dart';
import 'package:lapangin_mobile/landing/models/lapangan_entry.dart';
import 'package:lapangin_mobile/config.dart';

class LapanganEntryCard extends StatelessWidget {
  final LapanganEntry lapangan;
  final VoidCallback onTap;

  const LapanganEntryCard({
    super.key,
    required this.lapangan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: lapangan.image.isNotEmpty
                    ? Image.network(
                      "${Config.localUrl}/proxy-image/?url=${Uri.encodeComponent(lapangan.image)}",
                      "${Config.localUrl}/proxy-image/?url=${Uri.encodeComponent(lapangan.image)}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.sports_soccer,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.sports_soccer,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),

            // Konten Card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height:44.0,
                    child:
                  // Nama Lapangan
                    Text(
                      lapangan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Harga per jam
                  Text(
                    'RP ${lapangan.price.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}/jam',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(195, 33, 33, 1),
                      color: Color.fromARGB(195, 33, 33, 1),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Rating & Lokasi
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lapangan.rating > 0
                            ? lapangan.rating.toStringAsFixed(1)
                            : '0',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(width: 4),
                      const Text(
                        '|',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Lokasi
                      Expanded(
                        child: Text(
                          lapangan.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            fontStyle: FontStyle.normal,
                            fontSize: 13,
                            color: Color(0xFF839556),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}