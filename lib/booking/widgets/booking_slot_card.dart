// lib/booking/widgets/booking_slot_card.dart

import 'package:flutter/material.dart';
import '../models/booking_models.dart';
import 'package:intl/intl.dart';

class BookingSlotCard extends StatelessWidget {
  final BookingSlot slot;
  final DateTime tanggal;
  final bool isSelected;
  final VoidCallback? onTap;

  const BookingSlotCard({
    super.key,
    required this.slot,
    required this.tanggal,
    this.isSelected = false,
    this.onTap,
  });

  // Fungsi untuk format tanggal
  String _formatTanggal(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  // Fungsi untuk menentukan warna background berdasarkan status
  Color _getBackgroundColor() {
    if (slot.isAvailable) {
      return isSelected
          ? const Color.fromARGB(255, 243, 255, 244)
          : Colors.white;
    } else if (slot.isPending) {
      return const Color.fromARGB(255, 255, 252, 230); // Kuning muda
    } else {
      return const Color.fromARGB(255, 255, 240, 241); // Merah muda
    }
  }

  // Fungsi untuk menentukan warna border berdasarkan status
  Color _getBorderColor() {
    if (slot.isAvailable && isSelected) {
      return const Color(0xFF81C784);
    } else if (slot.isAvailable) {
      return Colors.grey.shade300;
    } else if (slot.isPending) {
      return const Color(0xFFFFD54F); // Kuning
    } else {
      return const Color(0xFFE57373); // Merah
    }
  }

  // Fungsi untuk menentukan warna background badge status
  Color _getBadgeBackgroundColor() {
    if (slot.isAvailable) {
      return const Color(0xFFE8F5E9); // Hijau muda
    } else if (slot.isPending) {
      return const Color(0xFFFFF9C4); // Kuning muda
    } else {
      return const Color(0xFFFFCDD2); // Merah muda
    }
  }

  // Fungsi untuk menentukan warna text status
  Color _getStatusTextColor() {
    if (slot.isAvailable) {
      return const Color.fromARGB(255, 81, 126, 83); // Hijau
    } else if (slot.isPending) {
      return const Color.fromARGB(255, 187, 131, 0); // Kuning
    } else {
      return const Color.fromARGB(255, 149, 75, 75); // Merah
    }
  }

  // Fungsi untuk format currency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tanggal di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: Text(
                _formatTanggal(tanggal),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: slot.isAvailable
                      ? Colors.grey.shade700
                      : Colors.grey.shade500,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Waktu
            Text(
              '${slot.jamMulai}-${slot.jamAkhir}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: slot.isAvailable
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 6),

            // Harga
            Text(
              slot.isAvailable
                  ? _formatCurrency(slot.harga)
                  : _formatCurrency(slot.harga),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: slot.isAvailable ? Colors.black87 : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 6),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _getBadgeBackgroundColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.status == 'AVAILABLE'
                    ? 'Available'
                    : slot.status == 'PENDING'
                    ? 'Pending'
                    : 'Booked',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
