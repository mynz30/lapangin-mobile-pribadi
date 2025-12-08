class Config {
  static const String baseUrl = "https://zibeon-jonriano-lapangin2.pbp.cs.ui.ac.id";
  
  // Authbooking endpoints
  static const String loginEndpoint = "/accounts/login-flutter/";
  static const String registerEndpoint = "/accounts/register-flutter/";
  static const String logoutEndpoint = "/accounts/logout-flutter/";

  // Booking endpoints
  static const String lapanganListEndpoint = "/booking/api/lapangan/";
  static const String lapanganDetailEndpoint = "/booking/api/lapangan/";
  static const String availableSlotsEndpoint = "/booking/api/slots/";
  static const String createBookingEndpoint = "/booking/api/create/";
  static const String bookingDetailEndpoint = "/booking/api/booking_detail/"; 
  static const String myBookingsEndpoint = "/booking/api/my-bookings/";
  static const String cancelBookingEndpoint = "/booking/api/booking/";
  
  // Admin Dashboard endpoints
  static const String adminLoginEndpoint = "/dashboard/api/login/";
  static const String adminDashboardStatsEndpoint = "/dashboard/api/dashboard/stats/";
  static const String adminPendingBookingsEndpoint = "/dashboard/api/booking/pending/";
  static const String adminApproveBookingEndpoint = "/dashboard/api/booking/"; // + {id}/approve/
  static const String adminRejectBookingEndpoint = "/dashboard/api/booking/"; // + {id}/reject/
  static const String adminLapanganListEndpoint = "/dashboard/api/lapangan/list/";
  
  // Untuk development
  // static const String localUrl = "http://10.0.2.2:8000"; // Android emulator
  static const String localUrl = "http://localhost:8000"; // Chrome
}