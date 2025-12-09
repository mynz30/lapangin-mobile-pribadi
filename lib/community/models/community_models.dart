// lib/community/models/community_models.dart

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

  // Factory method untuk membuat instance dari JSON
  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      pk: json['pk'],
      name: json['community_name'] ?? 'Tanpa Nama', // Sesuaikan key dengan views.py
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

// Model untuk Postingan Komunitas
class CommunityPost {
  final int pk;
  final String username;
  final int userId;
  final String content;
  final String? imageUrl;
  final String createdAt;
  final int commentsCount;

  CommunityPost({
    required this.pk,
    required this.username,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.commentsCount,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      pk: json['pk'],
      username: json['user']['username'] ?? 'Anonymous', // Nested JSON
      userId: json['user']['id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] ?? '',
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}