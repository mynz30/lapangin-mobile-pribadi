import 'package:flutter/material.dart';
import 'package:lapangin/config.dart';
import 'package:lapangin/admin-dashboard/screens/admin_booking_pending_screen.dart';
import 'package:lapangin/admin-dashboard/screens/admin_lapangan_list_screen.dart';
import 'package:lapangin/authbooking/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  String username = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  void _loadUserData() {
    final request = context.read<CookieRequest>();
    if (request.jsonData.containsKey('username')) {
      setState(() {
        username = request.jsonData['username'];
      });
    }
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        "${Config.localUrl}${Config.adminDashboardStatsEndpoint}",
        // "${Config.baseUrl}${Config.adminDashboardStatsEndpoint}", // Production
      );
      if (mounted) {
        setState(() {
          stats = response;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading stats: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final request = context.read<CookieRequest>();
    try {
      await request.logout(
        "${Config.localUrl}${Config.logoutEndpoint}",
        // "${Config.baseUrl}${Config.logoutEndpoint}", // Production
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8DA35D),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Color(0xFF8DA35D)),
            ),
            const SizedBox(width: 12),
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF8DA35D),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF8DA35D)),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions, color: Color(0xFF8DA35D)),
              title: const Text('Booking Pending'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AdminBookingPendingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_tennis, color: Color(0xFF8DA35D)),
              title: const Text('Kelola Lapangan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AdminLapanganListScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8DA35D)))
          : RefreshIndicator(
              color: const Color(0xFF8DA35D),
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildStatCard(
                      'Total',
                      stats?['total_lapangan']?.toString() ?? '100',
                      'Lapangan Terdaftar',
                      Icons.sports_tennis,
                      const Color(0xFF8DA35D),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const AdminLapanganListScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStatCard(
                      'Total',
                      stats?['booking_menunggu']?.toString() ?? '3',
                      'Booking Menunggu',
                      Icons.pending_actions,
                      Colors.orange,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const AdminBookingPendingScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStatCard(
                      'Total',
                      stats?['komunitas_aktif']?.toString() ?? '3',
                      'Komunitas Aktif',
                      Icons.group,
                      Colors.blue,
                      null,
                    ),
                    const SizedBox(height: 24),
                    
                    if ((stats?['booking_menunggu'] ?? 3) > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orange, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ada ${stats?['booking_menunggu'] ?? 3} Booking Menunggu Approval!',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Segera approve atau tolak booking untuk menghindari pembatalan otomatis.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => const AdminBookingPendingScreen(),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Lihat Sekarang'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          'Tambah\nLapangan',
                          Icons.add_circle,
                          const Color(0xFF8DA35D),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur tambah lapangan belum tersedia')),
                            );
                          },
                        ),
                        _buildActionCard(
                          'Approve\nBooking',
                          Icons.check_circle,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const AdminBookingPendingScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'Lihat\nTransaksi',
                          Icons.receipt_long,
                          Colors.purple,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur transaksi belum tersedia')),
                            );
                          },
                        ),
                        _buildActionCard(
                          'Buat\nKomunitas',
                          Icons.group_add,
                          Colors.teal,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur komunitas belum tersedia')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}