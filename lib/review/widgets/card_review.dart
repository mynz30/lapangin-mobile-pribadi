import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/review/models/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntry review;
  final VoidCallback? onRefresh;

  const ReviewCard({
    required this.review,
    this.onRefresh,
    super.key,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase();
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController contentC = 
        TextEditingController(text: review.content);
    int rating = review.rating;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: contentC,
                    decoration: const InputDecoration(
                      labelText: "Konten",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  const Text("Rating"),
                  Row(
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = i + 1;
                          });
                        },
                        icon: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final response = await _editReview(context, contentC.text, rating);

                    if (!dialogContext.mounted) return;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response["message"] ?? "Updated")),
                    );

                    if (onRefresh != null) onRefresh!();
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _editReview(BuildContext context, String content, int rating) async {
    final request = context.read<CookieRequest>();
    final url = "http://localhost:8000/review/edit/${review.id}/";

    print("Sending POST to: $url");
    final response = await request.post(url, {
      "content": content,
      "rating": rating.toString(),}
    );

    print("Response from server: $response");
    return response;
  }


  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Hapus Review"),
          content: const Text("Yakin ingin menghapus review ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final res = await _deleteReview(context);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Review berhasil dihapus")),
                );

                if (onRefresh != null) onRefresh!();
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _deleteReview(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final url = "http://localhost:8000/review/delete/${review.id}/";

    print("Sending POST to: $url");
    final response = await request.post(url, {});

    print("Response from server: $response");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFC7E0C0), 
                child: Text(
                  _getInitial(review.user),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),

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
                    review.createdAt, 
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const Spacer(),
              if (review.isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context);
                    } else if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text("Edit"),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text("Hapus"),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            review.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),

          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border, 
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }
}