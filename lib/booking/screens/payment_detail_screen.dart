// lib/booking/screens/payment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lapangin/landing/screens/menu.dart';
import 'package:lapangin/booking/screens/my_bookings_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final int bookingId;
  final String sessionCookie; // Not used anymore, kept for compatibility
  final String username;

  const PaymentDetailScreen({
    Key? key,
    required this.bookingId,
    required this.sessionCookie,
    required this.username,
  }) : super(key: key);

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  Booking? _booking;
  bool _isLoading = true;
  String? _errorMessage;
  
  Timer? _countdownTimer;
  Timer? _pollingTimer; // Tambahkan timer untuk polling
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadBookingDetail();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel(); // Jangan lupa cancel polling
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    String initials = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initials += parts.last[0].toUpperCase();
    }
    return initials;
  }

  Future<void> _loadBookingDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = context.read<CookieRequest>();
      
      print("=== DEBUG Payment Detail Screen ===");
      print("Booking ID: ${widget.bookingId}");
      print("Request logged in: ${request.loggedIn}");
      
      // Gunakan getBookingDetailWithRequest
      final booking = await BookingService.getBookingDetailWithRequest(
        request,
        widget.bookingId,
      );

      setState(() {
        _booking = booking;
        _isLoading = false;
        
        if (booking.isPending && booking.timeRemainingSeconds != null) {
          _remainingSeconds = booking.timeRemainingSeconds!;
          _startCountdown();
          _startPolling(); // Mulai polling status
        } else if (booking.isPaid) {
          // Jika sudah PAID, langsung navigate ke My Bookings
          _navigateToMyBookings();
        } else if (booking.isCancelled) {
          // Jika sudah CANCELLED, langsung navigate ke Menu
          _navigateToMenu();
        }
      });
    } catch (e) {
      print("Error loading booking detail: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  void _startPolling() {
    // Polling setiap 3 detik untuk cek status booking
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final request = context.read<CookieRequest>();
        final booking = await BookingService.getBookingDetailWithRequest(
          request,
          widget.bookingId,
        );

        print("=== Polling Status ===");
        print("Current status: ${booking.statusPembayaran}");

        if (booking.isPaid) {
          // Status berubah jadi BOOKED (di-ACC oleh pemilik)
          timer.cancel();
          _countdownTimer?.cancel();
          _navigateToMyBookings();
        } else if (booking.isCancelled) {
          // Status berubah jadi CANCELLED (ditolak oleh pemilik)
          timer.cancel();
          _countdownTimer?.cancel();
          _navigateToMenu();
        }
      } catch (e) {
        print("Polling error: $e");
      }
    });
  }

  void _navigateToMyBookings() {
    // Tampilkan dialog sukses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ Pembayaran Dikonfirmasi!'),
        content: const Text(
          'Pembayaran Anda telah dikonfirmasi oleh pemilik lapangan. Booking Anda sudah berhasil!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate ke My Bookings SCREEN langsung
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBookingsScreen(), // <-- Langsung ke MyBookingsScreen
                ),
              );
            },
            child: const Text('Lihat Pesanan Saya'),
          ),
        ],
      ),
    );
  }

  void _navigateToMenu() {
    // Tampilkan dialog ditolak
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('❌ Booking Ditolak'),
        content: const Text(
          'Maaf, booking Anda ditolak oleh pemilik lapangan. Silakan pilih slot lain atau lapangan lain.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Navigasi langsung tanpa route name
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(), // Langsung panggil widget
                ),
                (route) => false,
              );
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Habis'),
        content: const Text(
          'Waktu pembayaran (5 menit) telah habis. Pemesanan dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _confirmPayment() async {
    if (_booking == null) return;

    final whatsapp = _booking!.pemilik?.nomorWhatsapp;
    if (whatsapp == null || whatsapp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor WhatsApp tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final message = Uri.encodeComponent(
      'Halo Admin, saya *${widget.username}* telah melakukan pembayaran untuk booking ID #${_booking!.id}. Mohon validasi bukti transfer.',
    );
    
    final url = 'https://wa.me/$whatsapp?text=$message';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = widget.username.split(' ').first;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Hi, $firstName!",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B8E23),
              child: Text(
                _getInitials(widget.username),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFA7BF6E)),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBookingDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA7BF6E),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_booking == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSuccessHeader(),
          const SizedBox(height: 16),
          
          if (_booking!.isPending) ...[
            _buildCountdownBox(),
            const SizedBox(height: 16),
          ],
          
          _buildDetailSection(),
          const SizedBox(height: 16),
          
          _buildTransferInfoSection(),
          const SizedBox(height: 16),
          
          _buildInstructionSection(),
          const SizedBox(height: 24),
          
          _buildActionButtons(),
          const SizedBox(height: 16),
          
          _buildWarningText(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFA7BF6E),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Permintaan Booking\nBerhasil Dibuat!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mohon segera lakukan pembayaran untuk\nmengamankan slot Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        border: Border.all(color: const Color(0xFFE8C900), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Segera lakukan pembayaran dalam waktu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB59D00),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatCountdown(_remainingSeconds),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB59D00),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jika waktu habis, pesanan akan dibatalkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFB59D00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pemesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Lapangan:', _booking!.lapangan.nama),
          const SizedBox(height: 8),
          _buildDetailRow('Tanggal:', _formatDate(_booking!.slot.tanggal)),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Waktu:',
            '${_booking!.slot.jamMulai} - ${_booking!.slot.jamAkhir}',
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${_formatCurrency(_booking!.totalBayar)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE8C900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Transfer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2196F3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomor Rekening:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _booking!.pemilik?.nomorRekening ?? '0123456789',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pastikan transfer sesuai jumlah total di atas.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Langkah Terakhir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Setelah melakukan transfer, **wajib** konfirmasi dengan mengklik tombol di bawah ini.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

Widget _buildActionButtons() {
  return Column(
    children: [
      // Tombol Utama (Hijau)
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _confirmPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B8E23), // Hijau lebih gelap
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF6B8E23).withOpacity(0.3),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message, size: 22),
              SizedBox(width: 10),
              Text('Konfirmasi Pembayaran'),
            ],
          ),
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Tombol Sekunder (Outlined)
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Color(0xFF6B8E23),
              width: 2,
            ),
            foregroundColor: const Color(0xFF6B8E23),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 22),
              SizedBox(width: 10),
              Text('Kembali ke Daftar Lapangan'),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildWarningText() {
    return const Text(
      'Perhatian: Sesi yang sudah berhasil di booking (pembayaran berhasil) tidak dapat dibatalkan dengan alasan apapun.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }
}