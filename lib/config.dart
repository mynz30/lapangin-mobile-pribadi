// lib/config.dart - FIXED VERSION
import 'package:flutter/material.dart';

class Config {
  // ============================================
  // 🌐 BASE URL CONFIGURATION
  // ============================================
  
  // Production URL (PWS deployment)
  static const String baseUrl = "https://zibeon-jonriano-lapangin2.pbp.cs.ui.ac.id";
  
  // Development URLs
  static const String localUrl = "http://localhost:8000";
  // static const String localUrl = "http://10.0.2.2:8000";     // Android Emulator
  // static const String localUrl = "http://127.0.0.1:8000";    // iOS Simulator
  
  // Active URL - Change for deployment
  static String get activeUrl => localUrl;  // Development
  // static String get activeUrl => baseUrl; // Production
  
  
  // ============================================
  // 🔐 AUTHENTICATION ENDPOINTS
  // ============================================
  static const String loginEndpoint = "/accounts/login-flutter/";
  static const String registerEndpoint = "/accounts/register-flutter/";
  static const String logoutEndpoint = "/accounts/logout-flutter/";
  
  
  // ============================================
  // 📅 BOOKING ENDPOINTS (User Side)
  // ============================================
  static const String lapanganListEndpoint = "/booking/api/lapangan/";
  static const String lapanganDetailEndpoint = "/booking/api/lapangan/";
  static const String availableSlotsEndpoint = "/booking/api/slots/";
  static const String createBookingEndpoint = "/booking/api/create/";
  static const String bookingDetailEndpoint = "/booking/api/booking_detail/";
  static const String myBookingsEndpoint = "/booking/api/my-bookings/";
  static const String cancelBookingEndpoint = "/booking/api/booking/";
  static const String proxyImageEndpoint = "/booking/proxy-image/";
  
  
  // ============================================
  // 👨‍💼 ADMIN DASHBOARD ENDPOINTS
  // ============================================
  static const String adminDashboardStatsEndpoint = "/dashboard/api/dashboard/stats/";
  static const String adminPendingBookingsEndpoint = "/dashboard/api/booking/pending/";
  static const String adminApproveBookingEndpoint = "/dashboard/api/booking/";
  static const String adminRejectBookingEndpoint = "/dashboard/api/booking/";
  static const String adminLapanganListEndpoint = "/dashboard/api/lapangan/list/";
  static const String adminLapanganCreateEndpoint = "/dashboard/api/lapangan/create/";
  static const String adminLapanganDetailEndpoint = "/dashboard/api/lapangan/";
  static const String adminLapanganUpdateEndpoint = "/dashboard/api/lapangan/";
  static const String adminLapanganDeleteEndpoint = "/dashboard/api/lapangan/";
  static const String adminTransaksiListEndpoint = "/dashboard/api/transaksi/list/";
  static const String adminBookingSessionsEndpoint = "/dashboard/api/booking-sessions/list/";
  static const String adminBookingSessionCreateEndpoint = "/dashboard/api/booking-sessions/create/";
  static const String adminBookingSessionDeleteEndpoint = "/dashboard/api/booking-sessions/";
  
  
  // ============================================
  // 👥 COMMUNITY ENDPOINTS
  // ============================================
  static const String communityListEndpoint = "/community/api/communities/";
  static const String communityDetailEndpoint = "/community/api/";
  static const String communityJoinEndpoint = "/community/api/";
  static const String communityLeaveEndpoint = "/community/api/";
  static const String communityPostsEndpoint = "/community/api/community/";
  static const String communityCreatePostEndpoint = "/community/api/";
  static const String communityDeletePostEndpoint = "/community/api/post/";
  static const String communityCreateCommentEndpoint = "/community/api/post/";
  
  
  // ============================================
  // ⭐ REVIEW ENDPOINTS
  // ============================================
  static const String reviewListEndpoint = "/review/api/";
  static const String reviewAddEndpoint = "/review/api/add/";
  static const String reviewEditEndpoint = "/review/edit/";
  static const String reviewDeleteEndpoint = "/review/delete/";
  
  
  // ============================================
  // 🛠️ UTILITY METHODS
  // ============================================
  
  /// Get full URL for endpoint
  static String getUrl(String endpoint, {bool useProduction = false}) {
    final base = useProduction ? baseUrl : activeUrl;
    return '$base$endpoint';
  }
  
  /// Get proxy image URL
  static String getProxyImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) {
      return '$activeUrl$proxyImageEndpoint?url=${Uri.encodeComponent(imageUrl)}';
    }
    return '$activeUrl$imageUrl';
  }
  
  /// Build URL with path parameters
  static String buildUrl(String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return getUrl(url);
  }
  
  
  // ============================================
  // 🎨 APP CONSTANTS
  // ============================================
  
  // Colors
  static const Color primaryColor = Color(0xFFA7BF6E);
  static const Color secondaryColor = Color(0xFF8DA35D);
  static const Color accentColor = Color(0xFFC4DA6B);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  
  // File Upload
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Pagination
  static const int itemsPerPage = 20;
  
  
  // ============================================
  // 🔍 DEBUG HELPERS
  // ============================================
  
  static void printConfig() {
    debugPrint('═══════════════════════════════════════');
    debugPrint('📱 LAPANG.IN CONFIG');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🌐 Active URL: $activeUrl');
    debugPrint('🔐 Login: ${getUrl(loginEndpoint)}');
    debugPrint('📅 Booking: ${getUrl(createBookingEndpoint)}');
    debugPrint('👨‍💼 Admin: ${getUrl(adminDashboardStatsEndpoint)}');
    debugPrint('═══════════════════════════════════════');
  }
}