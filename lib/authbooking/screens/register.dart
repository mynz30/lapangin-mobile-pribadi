// lapangin/lib/authbooking/screens/register.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomorWhatsappController = TextEditingController();
  final _nomorRekeningController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedRole = 'PENYEWA';

  // visibility toggles for password fields
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<Map<String, String>> _roles = [
    {'value': 'PENYEWA', 'label': 'Penyewa Lapangan'},
    {'value': 'PEMILIK', 'label': 'Pemilik Lapangan'},
  ];

  // Validasi nomor WhatsApp - HANYA WAJIB untuk PEMILIK
  String? _validateWhatsApp(String? value, String role) {
    if (role == 'PEMILIK') {
      if (value == null || value.isEmpty) {
        return 'Nomor WhatsApp wajib untuk Pemilik Lapangan';
      }

      String cleanedValue = value.trim();
      if (cleanedValue.startsWith('0')) {
        cleanedValue = '+62' + cleanedValue.substring(1);
      } else if (!cleanedValue.startsWith('+62')) {
        cleanedValue = '+62' + cleanedValue;
      }

      final digitsOnly = cleanedValue.substring(1).replaceAll('+', '');
      if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly)) {
        return 'Hanya angka yang diperbolehkan setelah tanda +';
      }

      if (cleanedValue.length < 10 || cleanedValue.length > 15) {
        return 'Nomor WhatsApp harus 10-15 digit';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    const Color primaryGreen = Color(0xFFC4DA6B);
    const Color darkButton = Color(0xFF2F2F2F);
    const Color headerText = Color(0xFF333333);
    const double cardMaxWidth = 520;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                // Header (centered)
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: headerText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Create your ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    children: [
                      TextSpan(
                        text: 'Lapangin',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' account',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Card container
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: cardMaxWidth,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 20.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Username Field
                            const Text(
                              'Username *',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F7C00),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your username here',
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username is required';
                                }
                                if (value.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Password Field
                            const Text(
                              'Password *',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F7C00),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password (minimum 8 characters)',
                                prefixIcon: const Icon(Icons.lock),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Confirm Password Field
                            const Text(
                              'Password Confirmation *',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F7C00),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                hintText: 'Enter your password again',
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password confirmation is required';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18.0),

                            // Role Selection
                            const Text(
                              'Role *',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F7C00),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.people),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role['value'],
                                  child: Text(role['label']!),
                                );
                              }).toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        _selectedRole = newValue!;
                                        if (_selectedRole == 'PENYEWA') {
                                          _nomorWhatsappController.clear();
                                          _nomorRekeningController.clear();
                                        }
                                        _formKey.currentState?.validate();
                                      });
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // Nomor WhatsApp & Rekening - hanya untuk PEMILIK
                            if (_selectedRole == 'PEMILIK') ...[
                              const Text(
                                'Account Number *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6F7C00),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _nomorRekeningController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Example: 1234567890 - a.n. Budi Santoso',
                                  prefixIcon: const Icon(Icons.credit_card),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (_selectedRole == 'PEMILIK' &&
                                      (value == null || value.isEmpty)) {
                                    return 'Account number is required for Field Owners';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'WhatsApp Number *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6F7C00),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: _nomorWhatsappController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText:
                                      'Example: 081234567890 or +6281234567890',
                                  prefixIcon: const Icon(Icons.phone),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) =>
                                    _validateWhatsApp(value, _selectedRole),
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // REGISTER BUTTON
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _registerUser(request);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 16),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkButton,
                      foregroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser(CookieRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestData = {
        "username": _usernameController.text.trim(),
        "password1": _passwordController.text,
        "password2": _confirmPasswordController.text,
        "role": _selectedRole,
      };

      if (_selectedRole == 'PEMILIK') {
        String whatsappNumber = _nomorWhatsappController.text.trim();

        if (whatsappNumber.isNotEmpty) {
          whatsappNumber = whatsappNumber.replaceAll(RegExp(r'[^\d+]'), '');

          if (whatsappNumber.startsWith('0')) {
            whatsappNumber = '+62${whatsappNumber.substring(1)}';
          } else if (whatsappNumber.startsWith('62')) {
            whatsappNumber = '+$whatsappNumber';
          } else if (!whatsappNumber.startsWith('+62')) {
            whatsappNumber = '+62$whatsappNumber';
          }
        }

        requestData["nomor_whatsapp"] = whatsappNumber;
        requestData["nomor_rekening"] = _nomorRekeningController.text.trim();
      }

      print("🔵 Sending registration data: $requestData");

      final response = await request.postJson(
        //kalo udah deploy di pws, pake yang baseUrl
        // "${Config.baseUrl}${Config.registerEndpoint}",
        "${Config.localUrl}${Config.registerEndpoint}",
        jsonEncode(requestData),
      );

      print("Registration response: $response");
      print("Response status: ${response['status']}");
      print("Response message: ${response['message']}");

      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;

      final status = response['status'];
      bool isSuccess = false;

      if (status is bool) {
        isSuccess = status == true;
      } else if (status is String) {
        isSuccess = status.toLowerCase() == 'true' ||
            status.toLowerCase() == 'success';
      }

      print("isSuccess: $isSuccess");

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Registration successful!"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 2000));

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        String errorMessage = response['message'] ?? 'Registration failed!';

        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            errorMessage = errors.values.first.toString();
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Registration error: $e");
      print("Stack trace: $stackTrace");

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}