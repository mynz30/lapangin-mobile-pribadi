// lib/community/screens/community_detail_page.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/community/models/community_models.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({Key? key, required this.community}) : super(key: key);

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  
  bool isJoined = false;
  final TextEditingController _postController = TextEditingController();
  String currentUsername = "Guest";

  // Fetch Posts
  Future<List<CommunityPost>> fetchPosts(CookieRequest request) async {
    // Endpoint: /community/api/community/<pk>/posts/
    final response = await request.get(
        'http://127.0.0.1:8000/community/api/community/${widget.community.pk}/posts/');

    // Response dari backend bentuknya: { 'community_pk': ..., 'posts': [...] }
    var postsData = response['posts']; 

    List<CommunityPost> listPosts = [];
    for (var d in postsData) {
      if (d != null) {
        listPosts.add(CommunityPost.fromJson(d));
      }
    }
    return listPosts;
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    // TODO: Cek status membership awal dari API jika tersedia
  }
  
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? "Guest";
    });
  }
  
  // Fungsi Join Community
  Future<void> joinCommunity(CookieRequest request) async {
    final response = await request.post(
      'http://127.0.0.1:8000/community/api/${widget.community.pk}/join-flutter/',
      {},
    );
    
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      setState(() {
        isJoined = true;
      }); 
      // Refresh Post
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Gagal join")),
      );
    }
  }

  // Fungsi Leave Community
  Future<void> leaveCommunity(CookieRequest request) async {
      // Endpoint leave: /community/api/<pk>/leave-flutter/ (Asumsi)
      final response = await request.post(
        'http://127.0.0.1:8000/community/api/${widget.community.pk}/leave-flutter/',
        {},
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil keluar dari komunitas")),
        );
        setState(() {
          isJoined = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Gagal keluar")),
        );
      }
  }

  // Fungsi Create Post
  Future<void> createPost(CookieRequest request) async {
      if (_postController.text.isEmpty) return;

      final response = await request.post(
        'http://127.0.0.1:8000/community/api/community/${widget.community.pk}/create-post-flutter/',
        {
          'content': _postController.text,
        },
      );

      if (response['status'] == 'success') {
         _postController.clear();
         setState(() {}); // Refresh posts
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Post berhasil dibuat!")),
         );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Gagal membuat post")),
         );
      }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // URL Handling for Image
    String baseUrl = "http://127.0.0.1:8000"; 
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('Hi, $currentUsername!', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(width: 8),
             const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
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
                            _buildInfoRow(Icons.people_outline, "${widget.community.memberCount}/${widget.community.maxMember} Anggota", Colors.green),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.person_outline, widget.community.contactPerson, Colors.blue),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                             _buildInfoRow(Icons.calendar_today_outlined, "Dibuat : -", Colors.blue), // Date not available in simplified model yet
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
                // Green "Joined" Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9), // Light Green
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(left: BorderSide(color: Color(0xFF556B2F), width: 4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF556B2F)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Anda adalah anggota komunitas ini",
                          style: TextStyle(height: 1.2, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => leaveCommunity(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                           child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Create Post Card
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
                           hintText: "Hai",
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
                // Blue "Join" Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Light Blue
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(left: BorderSide(color: Colors.blue, width: 4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Bergabunglah untuk\nberpartisipasi dalam forum",
                          style: TextStyle(height: 1.2, fontWeight: FontWeight.bold, fontSize: 13),
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
                          backgroundColor: const Color(0xFFC5E1A5), // Light Green
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
                             children: [
                               CircleAvatar(backgroundColor: Color(0xFFC5E1A5), radius: 18),
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
                           const SizedBox(height: 12),
                           Text(post.content),
                           const SizedBox(height: 12),
                           const Divider(),
                           Row(
                             children: [
                               const Icon(Icons.reply, color: Colors.grey, size: 20),
                               const SizedBox(width: 8),
                               Text("Komentar (${post.commentsCount})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                             ],
                           )
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