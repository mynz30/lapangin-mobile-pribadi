// lib/main.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Auth & Booking
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:lapangin_mobile/landing/screens/menu.dart';

// Admin Dashboard
import 'package:lapangin_mobile/admin-dashboard/screens/admin_dashboard_screen.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/booking_pending_screen.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/lapangan_list_screen.dart';

// Community
import 'package:lapangin_mobile/community/screens/community_page.dart';

// Booking
import 'package:lapangin_mobile/booking/screens/my_bookings_screen.dart';

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
        title: 'Lapang.in',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFA7BF6E),
            primary: const Color(0xFFA7BF6E),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        
        // ✅ Initial route adalah login (semua user masuk dari sini)
        home: const LoginPage(),
        
        // ✅ Define semua routes
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const MyHomePage(),
          '/community': (context) => const CommunityPage(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          
          // Admin routes - akan di-handle di login.dart
          // Tidak perlu route terpisah karena navigation dilakukan manual
        },
      ),
    );
  }
}