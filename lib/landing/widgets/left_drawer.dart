// lib/landing/widgets/left_drawer.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:lapangin_mobile/booking/screens/my_bookings_screen.dart';
import 'package:lapangin_mobile/landing/screens/menu.dart';
import 'package:lapangin_mobile/community/screens/community_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/config.dart';

const TextStyle darkHeadingStyle = TextStyle(
  color: Color(0xFF4D5833),
  fontFamily: 'Montserrat',
  fontSize: 20,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: 0.4,
);

const TextStyle lightStyle = TextStyle(
  color: Color(0xFFF8FBF2),
  fontFamily: 'Montserrat',
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.normal,
);

const TextStyle subheadingS9Style = TextStyle(
  color: Color(0xFFFFFFFF),
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.w600,
  height: 1.2,
);

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFA7BF6E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Lapang',
                        style: lightStyle.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '.in',
                        style: darkHeadingStyle.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const Text(
                  'Cari lapangan, pilih jadwal, langsung main!',
                  textAlign: TextAlign.left,
                  style: subheadingS9Style,
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Booking'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Community'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CommunityPage()),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('My Booking'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingsScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                final response = await request.logout(
                  "${Config.localUrl}${Config.logoutEndpoint}",
                );

                if (context.mounted) {
                  String message = "Logout berhasil";
                  
                  if (request.loggedIn) {
                    message = "Logout gagal";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: request.loggedIn ? Colors.red : Colors.green,
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error logout: $e")),
                  );
                  
                  // Force logout even if error
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}