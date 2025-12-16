import 'dart:convert';

// Model untuk Data Komunitas
class Community {
  final int pk;
  final String name;
  final String description;
  final String location;
  final String sportsType;
  final int memberCount;
  final int maxMember;
  final String imageUrl;
  final String contactPerson;
  final String contactPhone;
  final String createdBy;

  Community({
    required this.pk,
    required this.name,
    required this.description,
    required this.location,
    required this.sportsType,
    required this.memberCount,
    required this.maxMember,
    required this.imageUrl,
    required this.contactPerson,
    required this.contactPhone,
    required this.createdBy,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      pk: json['pk'],
      name: json['community_name'] ?? 'Tanpa Nama',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      sportsType: json['sports_type'] ?? 'Lainnya',
      memberCount: json['member_count'] ?? 0,
      maxMember: json['max_member'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      createdBy: json['created_by'] ?? '',
    );
  }
}

// Model untuk Komentar
class CommunityComment {
  final String username;
  final String content;
  final String createdAt;

  CommunityComment({
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      // Sesuai views.py: 'username' dikirim sebagai string langsung
      username: json['username'] ?? "Anonymous", 
      content: json['content'] ?? "",
      createdAt: json['created_at'] ?? "-",
    );
  }
}

// Model untuk Postingan Komunitas
class CommunityPost {
  final int pk;
  final String username;
  final String content;
  final String createdAt;
  final String? imageUrl;
  final int commentsCount;
  final List<CommunityComment> comments; // List untuk menampung komentar

  CommunityPost({
    required this.pk,
    required this.username,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    required this.commentsCount,
    required this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      pk: json['pk'],
      
      // ✅ PERUBAHAN 1: Username sekarang diambil langsung (Flat)
      // Karena di views.py kita ubah jadi: 'username': post.user.username
      username: json['username'] ?? 'Anonymous', 
      
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] ?? "-",
      commentsCount: json['comments_count'] ?? 0,
      
      // ✅ PERUBAHAN 2: Parsing List Komentar
      // Kita membaca array 'comments' dari JSON backend
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((i) => CommunityComment.fromJson(i))
              .toList()
          : [],
    );
  }
}