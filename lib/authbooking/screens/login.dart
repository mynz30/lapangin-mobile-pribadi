// lib/authbooking/screens/login.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/authbooking/screens/register.dart';
import 'package:lapangin_mobile/landing/screens/menu.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_dashboard_screen.dart';
import 'package:lapangin_mobile/config.dart';

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      
      final response = await request.login(
        "${Config.localUrl}${Config.loginEndpoint}",
        {
          'username': _usernameController.text.trim(),
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
        final String? userRole = response['role'] ?? request.jsonData['role'];
        final String username = response['username'] ?? _usernameController.text.trim();

        print("🎯 User Role: $userRole");
        print("👤 Username: $username");

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selamat datang, $username!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate based on role
        if (userRole != null) {
          _navigateBasedOnRole(userRole, username, request);
        } else {
          // Fallback to user page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      } else {
        _showErrorDialog(response['message'] ?? "Login gagal");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Login Error: $e");
      _showErrorDialog("Tidak dapat terhubung ke server: $e");
    }
  }

  void _navigateBasedOnRole(String role, String username, CookieRequest request) {
    print("🚀 Navigating based on role: $role");

    if (role.toUpperCase() == 'PENYEWA') {
      // Navigate to user home
      print("✅ Navigate to MyHomePage (PENYEWA)");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else if (role.toUpperCase() == 'PEMILIK') {
      // Navigate to admin dashboard
      print("✅ Navigate to AdminDashboard (PEMILIK)");
      
      // Extract session cookie from request
      String sessionCookie = '';
      final cookie = request.cookies['sessionid'];
      if (cookie != null) {
        sessionCookie = 'sessionid=${cookie.value}';
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboardScreen(
            sessionCookie: sessionCookie,
            username: username,
          ),
        ),
      );
    } else {
      // Unknown role, fallback to user page
      print("⚠️ Unknown role: $role, navigate to MyHomePage");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Login Gagal",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo / Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4DA6B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: "Welcome back to ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "Lapang.in",
                          style: TextStyle(
                            color: Color(0xFF8DA35D),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Card
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                          // Username Field
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
                              hintText: "Masukkan username",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
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
                              hintText: "Masukkan password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC4DA6B),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
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
                  ),
                  const SizedBox(height: 16),

                  // Register Button
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
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
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info text
                  Text(
                    'Login sebagai PEMILIK untuk akses Admin Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}