// lib/config.dart - FIXED & COMPLETE VERSION
class Config {
  // ============================================
  // 🌐 BASE URL CONFIGURATION
  // ============================================
  
  // Production URL (PWS deployment)
  static const String baseUrl = "https://zibeon-jonriano-lapangin2.pbp.cs.ui.ac.id";
  
  // Development URLs (pilih salah satu sesuai environment)
  static const String localUrl = "http://localhost:8000";       // Chrome/Web
  // static const String localUrl = "http://10.0.2.2:8000";     // Android Emulator
  // static const String localUrl = "http://127.0.0.1:8000";    // iOS Simulator
  
  // Active URL - GANTI INI SAAT DEPLOYMENT
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
  
  // Dashboard Stats
  static const String adminDashboardStatsEndpoint = "/dashboard/api/dashboard/stats/";
  
  // Booking Management
  static const String adminPendingBookingsEndpoint = "/dashboard/api/booking/pending/";
  static const String adminApproveBookingEndpoint = "/dashboard/api/booking/"; // + {id}/approve/
  static const String adminRejectBookingEndpoint = "/dashboard/api/booking/";  // + {id}/reject/
  
  // Lapangan Management
  static const String adminLapanganListEndpoint = "/dashboard/api/lapangan/list/";
  static const String adminLapanganCreateEndpoint = "/dashboard/api/lapangan/create/";
  static const String adminLapanganDetailEndpoint = "/dashboard/api/lapangan/"; // + {id}/detail/
  static const String adminLapanganUpdateEndpoint = "/dashboard/api/lapangan/"; // + {id}/update/
  static const String adminLapanganDeleteEndpoint = "/dashboard/api/lapangan/"; // + {id}/delete/
  
  // Transaksi & Booking Sessions (Week 5)
  static const String adminTransaksiListEndpoint = "/dashboard/api/transaksi/list/";
  static const String adminBookingSessionsEndpoint = "/dashboard/api/booking-sessions/list/";
  static const String adminBookingSessionCreateEndpoint = "/dashboard/api/booking-sessions/create/";
  static const String adminBookingSessionDeleteEndpoint = "/dashboard/api/booking-sessions/"; // + {id}/delete/
  
  
  // ============================================
  // 👥 COMMUNITY ENDPOINTS
  // ============================================
  static const String communityListEndpoint = "/community/api/communities/";
  static const String communityDetailEndpoint = "/community/api/"; // + {id}/
  static const String communityJoinEndpoint = "/community/api/"; // + {id}/join-flutter/
  static const String communityLeaveEndpoint = "/community/api/"; // + {id}/leave-flutter/
  static const String communityPostsEndpoint = "/community/api/community/"; // + {id}/posts/
  static const String communityCreatePostEndpoint = "/community/api/"; // + {id}/post/create-flutter/
  static const String communityDeletePostEndpoint = "/community/api/post/"; // + {post_id}/delete-flutter/
  static const String communityCreateCommentEndpoint = "/community/api/post/"; // + {post_id}/comment-flutter/
  
  
  // ============================================
  // ⭐ REVIEW ENDPOINTS
  // ============================================
  static const String reviewListEndpoint = "/review/api/"; // + {field_id}
  static const String reviewAddEndpoint = "/review/api/add/"; // + {field_id}/
  static const String reviewEditEndpoint = "/review/edit/"; // + {review_id}/
  static const String reviewDeleteEndpoint = "/review/delete/"; // + {review_id}/
  
  
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
  /// Example: buildUrl('/api/lapangan/{id}/', {'id': '123'})
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
  static const int primaryColorValue = 0xFFA7BF6E;
  static const int secondaryColorValue = 0xFF8DA35D;
  static const int accentColorValue = 0xFFC4DA6B;
  
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
    print('═══════════════════════════════════════');
    print('📱 LAPANG.IN CONFIG');
    print('═══════════════════════════════════════');
    print('🌐 Active URL: $activeUrl');
    print('🔐 Login: ${getUrl(loginEndpoint)}');
    print('📅 Booking: ${getUrl(createBookingEndpoint)}');
    print('👨‍💼 Admin: ${getUrl(adminDashboardStatsEndpoint)}');
    print('═══════════════════════════════════════');
  }
}