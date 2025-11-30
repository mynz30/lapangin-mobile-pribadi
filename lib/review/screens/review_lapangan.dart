import 'package:flutter/material.dart';
import 'package:lapangin/review/models/review_entry.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntry review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFD7E4B5),
                child: Text(
                  review.user[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // -------------------------
              // BUTTON EDIT / DELETE
              // -------------------------
              if (review.isOwner)
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 6),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, size: 18),
                          SizedBox(width: 6),
                          Text("Hapus"),
                        ],
                      ),
                    )
                  ],
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            review.content,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 8),

          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating
                    ? Icons.star
                    : Icons.star_border,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
