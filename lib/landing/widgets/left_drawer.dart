import 'package:flutter/material.dart';
import 'package:lapangin/authbooking/screens/login.dart';
import 'package:lapangin/booking/screens/my_bookings_screen.dart';
import 'package:lapangin/landing/screens/menu.dart';
// ignore: unused_import
import 'package:pbp_django_auth/pbp_django_auth.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
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
  fontWeight: FontWeight.w400, // Semi-Bold
  height: 1.2, // line-height: 120% (12px / 10px)
);

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
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
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  'Cari lapangan, pilih jadwal, langsung main!',
                  textAlign: TextAlign.left, 
                  style: subheadingS9Style
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
              // Navigate langsung ke MyBookingsScreen tanpa parameter
              Navigator.push(
              // TODO: Redirect to My Booking page when available.
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingsScreen(),
                ),
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final request = context.read<CookieRequest>();
              try {
                final response = await request.logout(
                  "${Config.localUrl}${Config.logoutEndpoint}",
                );
                
                if (context.mounted) {
                   String message = response["message"];
                   if (request.loggedIn) {
                      message = "Logout failed";
                   } else {
                      message = "Logout successful";
                   }
                   
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(message)),
                   );
                   
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              } catch (e) {
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logout failed: $e")),
                    );
                     Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
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