import 'package:flutter/material.dart';
import 'package:lapangin/authbooking/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
        
        // Gunakan LoginPage sebagai initial route
        home: const LoginPage(),
        
        // Routes untuk navigasi
        routes: {
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}