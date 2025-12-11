// lib/community/screens/community_detail_page.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// Pastikan path import ini sesuai dengan struktur folder projekmu
import 'package:lapangin_mobile/community/models/community_models.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapangin_mobile/config.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({Key? key, required this.community}) : super(key: key);

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  
  // State variables
  bool isJoined = false;
  late int currentMemberCount; // Variabel lokal untuk jumlah member (biar bisa update realtime)
  String currentUsername = "Guest";

  // Controllers
  final TextEditingController _postController = TextEditingController();
  // Map untuk menyimpan controller input komentar setiap post secara terpisah
  final Map<int, TextEditingController> _commentControllers = {}; 

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi jumlah member awal dari data widget
    currentMemberCount = widget.community.memberCount;
    
    // 2. Load username lokal
    _loadUsername();
    
    // 3. Cek status membership terbaru ke server (agar sinkron)
    _checkMembershipStatus();
  }

  // --- FUNGSI UTILITAS ---

  Future<void> _loadUsername() async {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;
    
    const potentialKeys = ['username', 'first_name', 'name', 'fullname'];
    String? foundName;

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          break;
        }
      }
    }
    
    if (foundName != null) {
      if (mounted) {
        setState(() {
          currentUsername = foundName!;
        });
      }
    } else {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       if (mounted) {
         setState(() {
           currentUsername = prefs.getString('username') ?? "Guest";
         });
       }
    }
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

  // --- FUNGSI API CALLS ---

  // 1. Cek Status Member & Update Data
  Future<void> _checkMembershipStatus() async {
    final request = context.read<CookieRequest>();
    // Pastikan endpoint ini sudah dibuat di urls.py Django
    final url = '${Config.localUrl}/community/api/${widget.community.pk}/check-membership/';
    
    try {
      final response = await request.get(url);
      if (response['status'] == 'success') {
        if (mounted) {
          setState(() {
            isJoined = response['is_joined'];
            // Update jumlah member jika server mengirim data terbaru
            if (response['member_count'] != null) {
              currentMemberCount = response['member_count'];
            }
          });
        }
      }
    } catch (e) {
      print("Gagal cek membership: $e");
    }
  }

  // 2. Ambil Daftar Postingan
  Future<List<CommunityPost>> fetchPosts(CookieRequest request) async {
    try {
      final response = await request.get(
          '${Config.localUrl}/community/api/community/${widget.community.pk}/posts/');

      var postsData = response['posts']; 
      List<CommunityPost> listPosts = [];
      
      if (postsData != null) {
        for (var d in postsData) {
          if (d != null) {
            listPosts.add(CommunityPost.fromJson(d));
          }
        }
      }
      return listPosts;
    } catch (e) {
      print("Error fetching posts: $e");
      return [];
    }
  }

  // 3. Join Komunitas
  Future<void> joinCommunity(CookieRequest request) async {
    final url = '${Config.localUrl}/community/api/${widget.community.pk}/join-flutter/';
    
    try {
      final response = await request.post(url, {});
      String message = response['message']?.toString().toLowerCase() ?? "";
      String status = response['status']?.toString().toLowerCase() ?? "";

      if (status == 'success' || message.contains('sudah terdaftar') || message.contains('already')) {
        setState(() {
          isJoined = true;
          // Tambah counter member visual jika belum terdaftar sebelumnya
          if (!message.contains('sudah terdaftar')) {
             currentMemberCount++; 
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil bergabung!"), backgroundColor: Colors.green),
        );
        
        setState(() {}); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal join"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error koneksi: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 4. Leave Komunitas
  Future<void> leaveCommunity(CookieRequest request) async {
      final url = '${Config.localUrl}/community/api/${widget.community.pk}/leave-flutter/';

      try {
        final response = await request.post(url, {});

        if (response['status'] == 'success') {
          setState(() {
            isJoined = false;
            // Kurangi counter member visual
            if (currentMemberCount > 0) currentMemberCount--;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil keluar dari komunitas"), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Gagal keluar"), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
  }

  // 5. Buat Post Baru
  Future<void> createPost(CookieRequest request) async {
      if (_postController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Konten tidak boleh kosong"), backgroundColor: Colors.red),
         );
        return;
      }

      // URL FIX: api/<int:pk>/post/create-flutter/
      final url = '${Config.localUrl}/community/api/${widget.community.pk}/post/create-flutter/';

      try {
        final response = await request.post(url, {
            'content': _postController.text,
        });

        if (response['status'] == 'success') {
           _postController.clear();
           setState(() {}); // Refresh list post
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Post berhasil dibuat!"), backgroundColor: Colors.green),
           );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(response['message'] ?? "Gagal membuat post"), backgroundColor: Colors.red),
           );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
  }

  // 6. Hapus Post
  Future<void> deletePost(CookieRequest request, int postPk) async {
    final url = '${Config.localUrl}/community/api/post/$postPk/delete-flutter/';
    
    try {
      final response = await request.post(url, {});

      if (response['status'] == 'success') {
        setState(() {}); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post berhasil dihapus"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal menghapus post"), backgroundColor: Colors.red),
        );
      }
    } catch(e) {
      // Error handling
    }
  }

  // 7. Buat Komentar
  Future<void> createComment(CookieRequest request, int postPk, String content) async {
    if (content.trim().isEmpty) return;
    
    final url = '${Config.localUrl}/community/api/post/$postPk/comment-flutter/';
    
    try {
      final response = await request.post(url, {'content': content});

      if (response['status'] == 'success') {
        // Bersihkan textfield khusus untuk post tersebut
        _commentControllers[postPk]?.clear();
        
        setState(() {}); // Refresh UI agar komentar baru muncul
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar berhasil dikirim"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal mengirim komentar"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan koneksi"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    String firstName = currentUsername.split(' ').first;

    // URL Handling for Image
    String baseUrl = Config.localUrl; 
    String fullImageUrl = "";
    if (widget.community.imageUrl.isNotEmpty) {
      if (widget.community.imageUrl.startsWith("http")) {
        fullImageUrl = widget.community.imageUrl;
      } else {
        fullImageUrl = "$baseUrl${widget.community.imageUrl}";
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                _getInitials(currentUsername),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Image
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: fullImageUrl.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(fullImageUrl), fit: BoxFit.cover)
                  : null,
                color: fullImageUrl.isEmpty ? Colors.grey : null,
              ),
              child: Stack(
                children: [
                   Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(16),
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                       ),
                     ),
                   ),
                   Positioned(
                     bottom: 16,
                     left: 16,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           widget.community.name,
                           style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                         ),
                         Text(
                           "${widget.community.sportsType} • ${widget.community.location}",
                           style: const TextStyle(color: Colors.white70, fontSize: 14),
                         ),
                       ],
                     ),
                   )
                ],
              ),
            ),

            // 2. Tentang Komunitas Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tentang Komunitas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    widget.community.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // GUNAKAN currentMemberCount AGAR UPDATE REALTIME
                            _buildInfoRow(Icons.people_outline, "$currentMemberCount/${widget.community.maxMember} Anggota", Colors.green),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.person_outline, widget.community.contactPerson, Colors.blue),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                             _buildInfoRow(Icons.calendar_today_outlined, "Dibuat : -", Colors.blue),
                             const SizedBox(height: 12),
                             _buildInfoRow(Icons.phone_outlined, widget.community.contactPhone, Colors.red),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 3. Conditional Banner & Create Post
            if (isJoined) ...[
                // Banner Hijau (Member)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            "Anda adalah anggota komunitas ini",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => leaveCommunity(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                           child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Form Buat Post Baru
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                         BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8),
                    ],
                    border: Border.all(color: Colors.grey[200]!)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Buat Post Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextField(
                         controller: _postController,
                         maxLines: 4,
                         decoration: InputDecoration(
                           hintText: "Tulis sesuatu...",
                           hintStyle: TextStyle(color: Colors.grey[400]),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                         ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                               const Icon(Icons.image_outlined, color: Color(0xFF8B9E6D)),
                               const SizedBox(width: 4),
                               const Text("Upload Foto", style: TextStyle(color: Color(0xFF8B9E6D), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => createPost(request),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF8B9E6D),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             ),
                            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      )
                    ],
                  ),
                )
            ] else ...[
                // Banner Biru (Belum Member)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Bergabunglah untuk\nberpartisipasi dalam forum",
                          style: TextStyle(height: 1.2, fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                             if (!request.loggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Silakan login terlebih dahulu")),
                                );
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())); 
                             } else {
                                joinCommunity(request);
                             }
                        },
                        icon: const Icon(Icons.person_add_alt_1, size: 16, color: Color(0xFF556B2F)),
                        label: const Text("Gabung", style: TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC5E1A5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 24),
            
            // 4. Forum Diskusi Header
            const Padding(
               padding: EdgeInsets.symmetric(horizontal: 16),
               child: Row(
                 children: [
                   Icon(Icons.chat_bubble_outline, color: Color(0xFF8B9E6D)),
                   SizedBox(width: 8),
                   Text("Forum Diskusi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ],
               ),
            ),
            const SizedBox(height: 8),

            // 5. List Posts
            FutureBuilder(
              future: fetchPosts(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada postingan."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    CommunityPost post = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4),
                        ],
                        border: Border.all(color: Colors.grey[200]!)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Row(
                                 children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFC5E1A5), 
                                      radius: 18,
                                      child: Text(
                                        _getInitials(post.username),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF556B2F)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(post.createdAt, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    )
                                 ],
                               ),
                               if (post.username == currentUsername || currentUsername == "admin") 
                                 IconButton(
                                   icon: const Icon(Icons.delete_outline, color: Colors.red),
                                   onPressed: () => deletePost(request, post.pk),
                                 )
                             ],
                           ),
                           const SizedBox(height: 12),
                           Text(post.content),
                           if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Image.network(
                                  post.imageUrl!.startsWith('http') ? post.imageUrl! : '${Config.localUrl}${post.imageUrl}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                           const SizedBox(height: 12),
                           
                           // --- LIST KOMENTAR ---
                           if (post.comments.isNotEmpty) ...[
                              const Divider(),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: post.comments.length,
                                itemBuilder: (context, commentIndex) {
                                  final comment = post.comments[commentIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey[300],
                                          radius: 12,
                                          child: Text(
                                            _getInitials(comment.username),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  const SizedBox(width: 8),
                                                  Text(comment.createdAt, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                                ],
                                              ),
                                              Text(comment.content, style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                           ],

                           // --- INPUT KOMENTAR (Hanya jika join) ---
                           if (isJoined)
                             Padding(
                               padding: const EdgeInsets.only(top: 12.0),
                               child: Row(
                                 children: [
                                   Expanded(
                                     child: TextField(
                                       // Gunakan controller yang unik berdasarkan post PK
                                       controller: _commentControllers.putIfAbsent(post.pk, () => TextEditingController()),
                                       decoration: InputDecoration(
                                         hintText: "Tulis komentar...",
                                         hintStyle: const TextStyle(fontSize: 12),
                                         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                                       ),
                                       onSubmitted: (value) => createComment(request, post.pk, value),
                                     ),
                                   ),
                                   IconButton(
                                     icon: const Icon(Icons.send, color: Color(0xFF556B2F)),
                                     onPressed: () {
                                       String content = _commentControllers[post.pk]?.text ?? "";
                                       createComment(request, post.pk, content);
                                     },
                                   )
                                 ],
                               ),
                             ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}