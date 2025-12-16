import 'package:flutter/material.dart';
import 'package:lapangin_mobile/review/models/review_entry.dart';

class ReviewStats extends StatelessWidget {
  final List<ReviewEntry> reviews;

  const ReviewStats({super.key, required this.reviews});

  double get average {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  Map<int, int> get starCounts {
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var r in reviews) {
      counts[r.rating] = counts[r.rating]! + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = starCounts;
    final total = reviews.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < average.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  Text("$total ulasan"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            children: [5, 4, 3, 2, 1].map((star) {
              final count = counts[star]!;
              final double ratio = total == 0 ? 0 : count / total;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 26, child: Text("$star")),
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),

                    Expanded(
                      child: LinearProgressIndicator(
                        value: ratio,
                        backgroundColor: Color(0xFF212121),
                        color: Color(0xFFB8D279),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Text(count.toString()),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
