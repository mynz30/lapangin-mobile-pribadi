import 'package:flutter/material.dart';
import 'package:lapangin/authbooking/screens/login.dart';

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
  color: Color(0xFFFFFFFF), // #FFF (Putih)
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontStyle: FontStyle.normal,
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
            title: const Text('Booking'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Community'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          ListTile(
            title: const Text('My Booking'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),

        ],
      ),
    );
  }
}