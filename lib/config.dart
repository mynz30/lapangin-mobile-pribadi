// lapangin/lib/config.dart
class Config {
  static const String baseUrl = "http://localhost:8000";
  static const String loginEndpoint = "/accounts/login-flutter/";
  static const String registerEndpoint = "/accounts/register-flutter/";
  static const String logoutEndpoint = "/accounts/logout-flutter/";
  
  // Untuk development
  static const String localUrl = "http://10.0.2.2:8000"; // Android emulator
  // static const String localUrl = "http://localhost:8000"; // Chrome
}