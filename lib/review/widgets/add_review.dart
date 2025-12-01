import 'package:flutter/material.dart';

class AddReviewDialog extends StatefulWidget {
  final Function(int rating, String content) onSubmit;

  const AddReviewDialog({required this.onSubmit, super.key});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final TextEditingController _contentController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Tambah Review",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Rating",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: starIndex <= _rating ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
              );
            }),
          ),

          const SizedBox(height: 16),

          const Text(
            "Ulasan",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Tulis ulasan kamu...",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.grey,  
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(70, 0, 75, 21),  
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal", style: TextStyle(color: Color(0xFF4D5833),)),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4DA6B),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final content = _contentController.text.trim();
                  if (content.isEmpty) return;

                  widget.onSubmit(_rating, content);
                  
                  Navigator.pop(context);
                },
                child: const Text("Submit", style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
