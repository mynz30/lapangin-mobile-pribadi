// lib/admin-dashboard/screens/admin_dashboard_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:lapangin/admin-dashboard/services/dashboard_service.dart';
import 'package:lapangin/authbooking/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'booking_pending_screen.dart';
import 'lapangan_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String sessionCookie;
  final String username;

  const AdminDashboardScreen({
    super.key,
    required this.sessionCookie,
    required this.username,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminDashboardService.getDashboardStats(widget.sessionCookie);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final request = context.read<CookieRequest>();
      
      try {
        await request.logout("${widget.sessionCookie}/accounts/logout-flutter/");
      } catch (e) {
        print("Logout error: $e");
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const Text('Lapang.', style: TextStyle(color: Color(0xFF4F4F4F), fontWeight: FontWeight.bold)),
            const Text('in', style: TextStyle(color: Color(0xFFA7BF6E), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black),
                if (_stats != null && _stats!['pending_bookings'] > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          '${_stats!['pending_bookings']}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPendingScreen(
                    sessionCookie: widget.sessionCookie,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFA7BF6E),
              child: Text(
                widget.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Text(widget.username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFA7BF6E))) 
        : _buildContent(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF5A6B4A),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            _buildMenuItem(Icons.home, 'Dashboard', true, () => Navigator.pop(context)),
            
            _buildMenuItem(Icons.sports_soccer, 'Lapangan', false, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LapanganListScreen(
                    sessionCookie: widget.sessionCookie,
                    username: widget.username,
                  ),
                ),
              );
            }),
            
            _buildMenuItemWithBadge(
              Icons.access_time,
              'Booking Masuk',
              _stats?['pending_bookings'] ?? 0,
              false,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingPendingScreen(
                      sessionCookie: widget.sessionCookie,
                      username: widget.username,
                    ),
                  ),
                );
              },
            ),
            
            _buildMenuItem(Icons.history, 'Riwayat Transaksi', false, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur belum tersedia')),
              );
            }),
            
            const Spacer(),
            
            const Divider(color: Colors.white30),
            
            _buildMenuItem(Icons.logout, 'Logout', false, _handleLogout),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      tileColor: isActive ? const Color(0xFFA7BF6E) : null,
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithBadge(IconData icon, String title, int count, bool isActive, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          : null,
      tileColor: isActive ? const Color(0xFFA7BF6E) : null,
      onTap: onTap,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatCard(
            'Total\n${_stats?['total_lapangan'] ?? 0}',
            'Lapangan Terdaftar',
            Icons.sports_soccer,
            const Color(0xFFA7BF6E),
            const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            'Pending\n${_stats?['pending_bookings'] ?? 0}',
            'Booking Menunggu',
            Icons.access_time,
            Colors.orange,
            const Color(0xFFFFF3E0),
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            'Total\n${_stats?['total_komunitas'] ?? 0}',
            'Komunitas Aktif',
            Icons.people,
            Colors.blue,
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 24),
          
          // Alert if pending bookings
          if (_stats != null && _stats!['pending_bookings'] > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ada ${_stats!['pending_bookings']} Booking Menunggu Approval!',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        const Text('Segera approve atau tolak booking.',
                            style: TextStyle(fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPendingScreen(
                            sessionCookie: widget.sessionCookie,
                            username: widget.username,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Lihat'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard('Kelola Lapangan', Icons.sports_soccer, const Color(0xFFA7BF6E), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LapanganListScreen(
                        sessionCookie: widget.sessionCookie,
                        username: widget.username,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard('Approve Booking', Icons.check_circle, Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPendingScreen(
                        sessionCookie: widget.sessionCookie,
                        username: widget.username,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value.split('\n')[0], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(value.split('\n')[1], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}