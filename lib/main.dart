import 'package:flutter/material.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:lapangin/authbooking/screens/login.dart';
import 'package:lapangin/admin-dashboard/screens/admin_login_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/landing/screens/menu.dart';
import 'package:lapangin_mobile/community/screens/community_page.dart';
import 'package:lapangin/admin-dashboard/screens/booking_pending_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Lapangin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blueAccent[400]),
          useMaterial3: true,
        ),
        
        // TEMPORARY: Set initial route ke AdminLoginScreen untuk testing
        // Ganti kembali ke LoginPage() setelah testing selesai
        home: const AdminLoginScreen(), // <-- UBAH INI UNTUK TESTING ADMIN LOGIN
        // home: const LoginPage(), // <-- Uncomment ini setelah testing
        
        // Atau bisa gunakan routes untuk navigasi lebih fleksibel
        routes: {
          '/login': (context) => const LoginPage(),
          '/admin-login': (context) => const AdminLoginScreen(),
        },
      ),
    );
  }
}