import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lapangin/review/widgets/add_review.dart';
import 'package:lapangin/review/widgets/card_review.dart'; 
import 'package:lapangin/review/widgets/statistik.dart'; 
import 'package:lapangin/review/models/review_entry.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart'; 
import 'package:provider/provider.dart';
import 'package:lapangin/landing/widgets/left_drawer.dart'; 

class ReviewPage extends StatefulWidget{
  final int fieldId;
  const ReviewPage({required this.fieldId, super.key});

  @override
  State<ReviewPage> createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  List<ReviewEntry> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';

  late final String apiUrl;
  String _userName = "User"; 

  @override
  void initState() {
    super.initState();

    apiUrl = "http://localhost:8000/review/api/${widget.fieldId}";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;  
      _setUserName();

      if (!mounted) return;
      fetchReviewData();
    });
  }

  void _setUserName() {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;

    print("--- Data User Tersimpan di CookieRequest (lapangin) ---");
    print(userData);
    print("-------------------------------------------------------");

    const potentialKeys = ['user','username', 'first_name', 'name', 'fullname'];
    
    String foundName = "User";

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          print("Ditemukan nama pengguna dengan kunci: $key. Nilai: $foundName");
          break;
        }
      }
    }
    
    if (!mounted) return;
    setState(() {
      _userName = foundName!;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    String initials = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initials += parts.last[0].toUpperCase();
    }
    return initials;
  }

  Future<void> fetchReviewData() async {
    if(!mounted) return;
    final request = context.read<CookieRequest>();
    setState((){
      _isLoading = true;
      _errorMessage = '';

    });

    try{
      final response = await request.get(apiUrl);
      if(!mounted) return;

      List<ReviewEntry> fetchedReviews = [];

      if(response is List){
        for (var item in response){
          final id = item['id'];
          final fieldId = item['field_id'];
          final fieldName = item['fieldName'];
          final name = item['user'];
          final content = item['content'];
          final rating = item['rating'];
          final createdAt = item['created_at'];
          final isOwner = item['is_owner'];

          fetchedReviews.add(ReviewEntry(id: id, field_id: fieldId, fieldName: fieldName,user: name, content: content, rating: rating, createdAt: createdAt, isOwner: isOwner));
        }

        setState((){
          _reviews = fetchedReviews;
          _isLoading = false;
        });

      } else {
        Exception("API response is not a valid list format. Did you return a single object instead of a list?");
      }
    } catch (e) {
      if(!mounted) return;

      String errorDetail = e.toString().contains('FormatException') 
          ? 'Respons bukan JSON (mungkin HTML/halaman login/404). Cek URL Django.'
          : e.toString();
          
      setState(() {
        _errorMessage = 'Gagal mengambil data: $errorDetail. Pastikan URL server ($apiUrl) dan server Django aktif.';
        _isLoading = false;
      });
      print('Error fetching data: $e');

    }
  }

  @override
  Widget build(BuildContext context){
    String firstName = _userName.split(' ').first;
    final request = context.watch<CookieRequest>();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black), 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, 
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Hi, $firstName!",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20, 
              backgroundColor: const Color(0xFF6B8E23),
              child: Text(
                _getInitials(_userName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ulasan untuk ${_reviews.isNotEmpty ? _reviews.first.fieldName : 'Lapangan'}",
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.2,   // line-height 120%
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ReviewStats(reviews: _reviews),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (_errorMessage.isNotEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: fetchReviewData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                )
                else if (_reviews.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text("Belum ada review"), 
                  )
                )
                else
                  ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ReviewCard(review: _reviews[index], onRefresh: fetchReviewData,);
                  },
                ),
                const SizedBox(height: 200),
              ],
          )
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white, 
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8D279),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            onPressed: () {
              final request = context.read<CookieRequest>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 360,  
                        minWidth: 300,  
                      ),
                      child: AddReviewDialog(
                        onSubmit: (rating, content) async {
                          print("Rating: $rating");
                          print("Content: $content");

                          try {
                            final response = await request.post(
                              "http://localhost:8000/review/api/add/${widget.fieldId}/",
                              jsonEncode({
                                "rating": rating.toString(),
                                "content": content,
                              })
                            );

                            if (mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (response["success"] == true) {
                              // Berhasil
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text("Review berhasil ditambahkan!"),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                              if (mounted) {
                                final newReview = ReviewEntry.fromJson(response["review"]);
                                setState(() {
                                  _reviews.insert(0, newReview);
                                });
                              }
                              
                            } else {
                              // Gagal
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(response["message"] ?? "Gagal menambahkan review"),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Error adding review: $e");
                            
                            if (mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text("Terjadi kesalahan: ${e.toString()}"),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Color(0xFF4D5833), size: 20),
                SizedBox(width: 12),
                Text(
                  "Tambah Review",
                  style: TextStyle(
                    color: Color(0xFF4D5833),
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}