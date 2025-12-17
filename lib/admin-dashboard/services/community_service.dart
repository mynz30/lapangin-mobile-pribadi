// lib/admin-dashboard/services/community_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lapangin/config.dart';

class AdminCommunityService {
  
  /// Get all communities with stats
  static Future<List<Map<String, dynamic>>> getAllCommunities(
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.localUrl}/community/api/communities/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      print('🔵 Get Communities Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      
      throw Exception('Gagal mengambil data komunitas');
      
    } catch (e) {
      print('❌ Get Communities Error: $e');
      rethrow;
    }
  }
  
  /// Get community detail
  static Future<Map<String, dynamic>> getCommunityDetail(
    int communityId,
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.localUrl}/community/api/$communityId/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      throw Exception('Gagal memuat detail komunitas');
      
    } catch (e) {
      print('❌ Get Community Detail Error: $e');
      rethrow;
    }
  }
  
  /// Get community posts
  static Future<List<Map<String, dynamic>>> getCommunityPosts(
    int communityId,
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.localUrl}/community/api/community/$communityId/posts/');
      
      final response = await http.get(
        url,
        headers: {
          'Cookie': sessionCookie,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['posts'] ?? []);
      }
      
      throw Exception('Gagal memuat posts komunitas');
      
    } catch (e) {
      print('❌ Get Community Posts Error: $e');
      rethrow;
    }
  }
  
  /// Delete community post (admin only)
  static Future<void> deletePost(
    int postId,
    String sessionCookie
  ) async {
    try {
      final url = Uri.parse('${Config.localUrl}/community/api/post/$postId/delete-flutter/');
      
      final response = await http.post(
        url,
        headers: {
          'Cookie': sessionCookie,
          'Content-Type': 'application/json',
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        return;
      }
      
      throw Exception(data['message'] ?? 'Gagal menghapus post');
      
    } catch (e) {
      print('❌ Delete Post Error: $e');
      rethrow;
    }
  }
  
  /// Get community statistics
  static Future<Map<String, dynamic>> getCommunityStats(
    String sessionCookie
  ) async {
    try {
      final communities = await getAllCommunities(sessionCookie);
      
      int totalCommunities = communities.length;
      int totalMembers = 0;
      int totalPosts = 0;
      
      for (var community in communities) {
        totalMembers += (community['member_count'] ?? 0) as int;
      }
      
      return {
        'total_communities': totalCommunities,
        'total_members': totalMembers,
        'total_posts': totalPosts,
        'avg_members_per_community': totalCommunities > 0 
            ? (totalMembers / totalCommunities).round() 
            : 0,
      };
      
    } catch (e) {
      print('❌ Get Community Stats Error: $e');
      rethrow;
    }
  }
}
