import 'package:flutter/material.dart';
import 'package:lapangin/community/models/community_models.dart'; // Ensure this matches your file structure
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/authbooking/screens/login.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  bool isJoined = true; // Default to true based on user request

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Date formatting helper
    String formattedDate = "${widget.community.fields.dateAdded.day.toString().padLeft(2, '0')} ${_getMonthName(widget.community.fields.dateAdded.month)} ${widget.community.fields.dateAdded.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const Center(
            child: Text(
              "Username  ", // Simplified as per image
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"), // Placeholder avatar
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(widget.community.fields.communityImage.isNotEmpty 
                      ? widget.community.fields.communityImage 
                      : "https://via.placeholder.com/400x200"),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Stack(
                children: [
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  
                  // Text Content
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.fields.communityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.community.fields.sportsType} • ${widget.community.fields.location}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tentang Komunitas Card
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tentang Komunitas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.community.fields.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 18, color: Color(0xFF8B9E6D)),
                                const SizedBox(width: 8),
                                Text(
                                  "${widget.community.fields.memberCount}/${widget.community.fields.maxMember} Anggota",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.community.fields.contactPersonName,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Column 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Dibuat : $formattedDate",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  widget.community.fields.contactPhone,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. User Status Banner (Toggleable)
            if (isJoined)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEDC8), // Light Green
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF556B2F), width: 4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced vertical padding
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF33691E), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Anda adalah anggota komunitas ini",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                          // TODO: Implement Logic
                          setState(() => isJoined = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350), // Red
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: Size.zero, 
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // Light blue
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF1565C0), width: 4),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Bergabunglah untuk\nberpartisipasi dalam forum",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                          if (!request.loggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Silakan login terlebih dahulu untuk bergabung."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          } else {
                            setState(() => isJoined = true);
                          }
                      },
                      icon: const Icon(Icons.person_add_alt_1, size: 18, color: Color(0xFF556B2F)), // Dark olive
                      label: const Text("Gabung", style: TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC5E1A5), // Light green
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Create Post Section (Only if joined)
            if (isJoined)
                Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                            ),
                        ],
                        border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                                "Buat Post Baru",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                                decoration: InputDecoration(
                                    hintText: "Hai",
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    contentPadding: const EdgeInsets.all(12),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!)
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!)
                                    ),
                                ),
                                maxLines: 3,
                                minLines: 3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.image_outlined, size: 20, color: Color(0xFF8B9E6D)),
                                        label: const Text("Upload Foto", 
                                            style: TextStyle(color: Color(0xFF8B9E6D), fontWeight: FontWeight.bold, fontSize: 12)
                                        ),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFC5E1A5), // Light Green
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text("Kirim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    )
                                ],
                            )
                        ],
                    ),
                )
            else 
                const SizedBox(height: 24), // Spacer if not create post

             if (!isJoined) const SizedBox(height: 24), // Extra space if join banner is showing

            // 5. Forum Diskusi Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: Color(0xFF8B9E6D), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Forum Diskusi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // 6. Forum List (Static Mockup)
            _buildForumCard("Budiono", "03 Nov 2025, 12:09", "Hai"),
            _buildForumCard("Budiono", "03 Nov 2025, 12:09", "Hai"),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildForumCard(String name, String date, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
            )
        ],
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
                children: [
                    CircleAvatar(
                        backgroundColor: const Color(0xFFC5E1A5), // Light Green
                        radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                    )
                ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
             Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
                children: [
                    const Icon(Icons.reply, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Komentar (0)", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ],
            )
        ],
      )
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}
