import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/review/widgets/add_review.dart';
import 'package:lapangin_mobile/review/widgets/card_review.dart';
import 'package:lapangin_mobile/review/widgets/statistik.dart';
import 'package:lapangin_mobile/review/models/review_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/landing/widgets/left_drawer.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/review/widgets/chip.dart';

class ReviewPage extends StatefulWidget {
  final int fieldId;
  const ReviewPage({required this.fieldId, super.key});

  @override
  State<ReviewPage> createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  List<ReviewEntry> _reviews = []; 
  List<ReviewEntry> _allReviews = []; 
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'all'; 

  late final String apiUrl;
  String _userName = "User";

  @override
  void initState() {
    super.initState();

    apiUrl = "${Config.localUrl}/review/api/${widget.fieldId}";

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

    const potentialKeys = [
      'user',
      'username',
      'first_name',
      'name',
      'fullname'
    ];

    String foundName = "User";

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          break;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _userName = foundName;
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

  void _applyLocalFilter() {
    List<ReviewEntry> filtered = List.from(_allReviews);

    final formatter = DateFormat('dd MMM yyyy HH:mm');

    if (_selectedFilter == "terbaru") {
      filtered.sort((a, b) {
        final dateA = formatter.parse(a.createdAt);
        final dateB = formatter.parse(b.createdAt);
        return dateB.compareTo(dateA);
      });
    } 
    else if (_selectedFilter != "all") {
      int rating = int.parse(_selectedFilter);
      filtered = filtered.where((r) => r.rating == rating).toList();
    }

    setState(() {
      _reviews = filtered;  
    });
  }

  Future<void> fetchReviewData() async {
    if (!mounted) return;
    final request = context.read<CookieRequest>();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await request.get(apiUrl);

      if (!mounted) return;

      List<ReviewEntry> fetchedReviews = [];

      if (response is List) {
        for (var item in response) {
          fetchedReviews.add(ReviewEntry(
            id: item['id'],
            field_id: item['field_id'],
            fieldName: item['fieldName'],
            user: item['user'],
            content: item['content'],
            rating: item['rating'],
            createdAt: item['created_at'],
            isOwner: item['is_owner'],
          ));
        }

        _allReviews = fetchedReviews;

        _applyLocalFilter();

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception("API response invalid");
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Gagal mengambil data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _userName.split(' ').first;

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
          child: Column(
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
                    height: 1.2,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ReviewStats(reviews: _allReviews),
              const SizedBox(height: 20),

              /// === CHIP FILTER (LOKAL) ===
              Align(
                alignment: Alignment.centerLeft,
                child: ReviewFilterChips(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (newFilter) {
                    setState(() => _selectedFilter = newFilter);
                    _applyLocalFilter();
                  },
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 40),
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
                  ),
                )
              else if (_reviews.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text("Belum ada review"),
                  ),
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ReviewCard(
                      review: _reviews[index],
                      onRefresh: fetchReviewData,
                    );
                  },
                ),

              const SizedBox(height: 200),
            ],
          ),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                          try {
                            final response = await request.post(
                              "http://localhost:8000/review/api/add/${widget.fieldId}/",
                              jsonEncode({
                                "rating": rating.toString(),
                                "content": content,
                              }),
                            );

                            if (mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (response["success"] == true) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                            "Review berhasil ditambahkan!"),
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
                                final newReview =
                                    ReviewEntry.fromJson(response["review"]);
                                _allReviews.insert(0, newReview);
                                _applyLocalFilter();
                              }
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error,
                                          color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(response["message"] ??
                                            "Gagal menambahkan review"),
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
                            if (mounted && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error,
                                        color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                          "Terjadi kesalahan: ${e.toString()}"),
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
