import 'package:flutter/material.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';
import 'add_lapangan_screen.dart';

class LapanganListScreen extends StatefulWidget {
  final String sessionCookie;
  final String username;

  const LapanganListScreen({
    super.key,
    required this.sessionCookie,
    required this.username,
  });

  @override
  State<LapanganListScreen> createState() => _LapanganListScreenState();
}

class _LapanganListScreenState extends State<LapanganListScreen> {
  List<Map<String, dynamic>> _lapanganList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLapangan();
  }

  Future<void> _loadLapangan() async {
    setState(() => _isLoading = true);
    try {
      final lapangan = await AdminBookingService.getLapanganList(widget.sessionCookie);
      setState(() {
        _lapanganList = lapangan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA7BF6E),
        elevation: 0,
        title: const Text('Kelola Lapangan Anda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLapanganScreen(
                    sessionCookie: widget.sessionCookie,
                    username: widget.username,
                  ),
                ),
              ).then((_) => _loadLapangan());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA7BF6E)))
          : _lapanganList.isEmpty
              ? _buildEmptyState()
              : _buildLapanganGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum Ada Lapangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tambahkan lapangan pertama Anda', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddLapanganScreen(
                    sessionCookie: widget.sessionCookie,
                    username: widget.username,
                  ),
                ),
              ).then((_) => _loadLapangan());
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Lapangan Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA7BF6E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLapanganGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _lapanganList.length,
      itemBuilder: (context, index) {
        final lapangan = _lapanganList[index];
        return _buildLapanganCard(lapangan);
      },
    );
  }

  Widget _buildLapanganCard(Map<String, dynamic> lapangan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.image, size: 40, color: Colors.white)),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7BF6E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lapangan['jenis_olahraga'].toString().toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lapangan['nama_lapangan'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lapangan['lokasi'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${lapangan['harga_per_jam']}/jam',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${lapangan['rating']}', style: const TextStyle(fontSize: 12)),
                      Text(' (${lapangan['jumlah_ulasan']})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => _showDeleteDialog(lapangan['id']),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Hapus', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lapangan'),
        content: const Text('Yakin ingin menghapus lapangan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur hapus belum diimplementasi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}