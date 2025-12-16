import 'package:flutter/material.dart';

class ReviewFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const ReviewFilterChips({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = {
      "all": "Semua",
      "terbaru": "Terbaru",
      "5": "5★",
      "4": "4★",
      "3": "3★",
      "2": "2★",
      "1": "1★",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final bool isSelected = selectedFilter == entry.key;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(90),
              onTap: () => onFilterChanged(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),

                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF383838)   // selected
                        : const Color(0xFF657443),  // default
                  ),

                  color: isSelected
                      ? const Color(0xFF383838)      // selected
                      : const Color(0xFFCFE1A5),     // default
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,

                    color: isSelected
                        ? Colors.white               // selected
                        : const Color(0xFF657443),   // default
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
