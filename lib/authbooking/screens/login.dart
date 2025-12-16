// lapangin/lib/authbooking/screens/login.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/authbooking/screens/register.dart';
import 'package:lapangin/landing/screens/menu.dart';
// import 'package:lapangin/landing/screens/menu_admin.dart'; // TODO: Import halaman admin setelah dibuat
import 'package:lapangin/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // TITLE — CENTERED
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: "Welcome back to ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "Lapangin",
                          style: TextStyle(
                            color: Color(0xFF8DA35D),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // FORM CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A8450),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: "Enter your username here",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter your username" : null,
                      ),

                      const SizedBox(height: 22),

                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A8450),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Enter your password here",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter your password" : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await _loginUser(request);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4DA6B),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F2F2F),
                      foregroundColor: const Color(0xFFC4DA6B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser(CookieRequest request) async {
    setState(() => _isLoading = true);

    try {
      final response = await request.login(
        "${Config.localUrl}${Config.loginEndpoint}",
        // "${Config.baseUrl}${Config.loginEndpoint}", // Uncomment untuk production
        {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      setState(() => _isLoading = false);

      print("=== 🔐 LOGIN RESPONSE DEBUG ===");
      print("Response: $response");
      print("Status: ${response['status']}");
      print("Logged In: ${request.loggedIn}");
      print("User Data: ${request.jsonData}");
      print("================================");

      if (request.loggedIn && response['status'] == true) {
        // Ambil role dari response
        final String? userRole = response['role'] ?? request.jsonData['role'];
        final String username = response['username'] ?? _usernameController.text;

        print("🎯 User Role: $userRole");
        print("👤 Username: $username");

        // Navigate berdasarkan role
        if (userRole != null) {
          _navigateBasedOnRole(userRole, username);
        } else {
          // Fallback jika role tidak ditemukan
          print("⚠️ Role tidak ditemukan, navigate ke MyHomePage (default)");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome, $username!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog(response['message'] ?? "Login failed");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Login Error: $e");
      _showErrorDialog("Cannot connect to server: $e");
    }
  }

  void _navigateBasedOnRole(String role, String username) {
    print("🚀 Navigating based on role: $role");

    if (role.toUpperCase() == 'PENYEWA') {
      // Navigate ke halaman penyewa (user biasa)
      print("✅ Navigate to MyHomePage (PENYEWA)");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else if (role.toUpperCase() == 'PEMILIK') {
      // Navigate ke halaman admin/pemilik
      print("✅ Navigate to MyHomePageAdmin (PEMILIK)");
      
      // TODO: Ganti ini dengan halaman admin yang sudah dibuat
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => MyHomePageAdmin()),
      // );
      
      // SEMENTARA: Tampilkan dialog placeholder
      _showAdminPagePlaceholder(username);
    } else {
      // Fallback untuk role yang tidak dikenali
      print("⚠️ Unknown role: $role, navigate ke MyHomePage");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  // TODO: Hapus fungsi ini setelah MyHomePageAdmin dibuat
  void _showAdminPagePlaceholder(String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Admin Page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $username!"),
            const SizedBox(height: 8),
            const Text("Role: PEMILIK (Admin)"),
            const SizedBox(height: 16),
            const Text(
              "Halaman admin belum tersedia.\nSementara akan diarahkan ke halaman user.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Login Failed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}