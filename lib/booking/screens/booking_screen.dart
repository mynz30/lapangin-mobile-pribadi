// lib/booking/screens/booking_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';
import '../widgets/booking_slot_card.dart';
import 'payment_detail_screen.dart';

class BookingScreen extends StatefulWidget {
  final int lapanganId;
  final String sessionCookie;
  final String username;

  const BookingScreen({
    super.key,
    required this.lapanganId,
    required this.sessionCookie,
    required this.username,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Lapangan? _lapangan;
  BookingSlotsResponse? _slotsResponse;
  bool _isLoading = true;
  String? _errorMessage;
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedSlotId;

  String _userName = "User";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUserName();
      _debugAuthStatus();
      _loadData();
    });
  }

  void _debugAuthStatus() {
    final request = context.read<CookieRequest>();
    print("=== 🔐 AUTH STATUS DEBUG ===");
    print("Logged in: ${request.loggedIn}");
    print("User data: ${request.jsonData}");
    print("================================");
  }

  void _setUserName() {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;

    const potentialKeys = ['username', 'first_name', 'name', 'fullname'];
    String? foundName;

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          break;
        }
      }
    }
    
    if (foundName != null) {
      setState(() {
        _userName = foundName!;
      });
    }
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lapangan = await BookingService.getLapanganDetail(widget.lapanganId);
      final slots = await BookingService.getAvailableSlots(
        widget.lapanganId,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        days: 7,
      );

      setState(() {
        _lapangan = lapangan;
        _slotsResponse = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _getShortDayName(DateTime date) {
    final shortNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return shortNames[date.weekday % 7];
  }

  void _selectSlot(BookingSlot slot) {
    if (slot.isAvailable) {
      setState(() {
        _selectedSlotId = slot.id;
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih slot terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFA7BF6E)),
      ),
    );

    try {
      final request = context.read<CookieRequest>();
      
      final result = await BookingService.createBookingWithRequest(
        request, 
        _selectedSlotId!
      );

      if (result['success'] == true) {
        Navigator.pop(context);
        
        final bookingId = result['booking_id'];
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailScreen(
              bookingId: bookingId,
              sessionCookie: 'auto',
              username: _userName,
            ),
          ),
        ).then((_) {
          _loadData();
        });
      } else {
        throw Exception(result['message'] ?? 'Gagal membuat booking');
      }
      
    } catch (e) {
      Navigator.pop(context);
      _handlePaymentError(e);
    }
  }

  void _handlePaymentError(dynamic error) {
    String errorMessage = 'Gagal membuat booking';
    
    if (error.toString().contains('login') || 
        error.toString().contains('authenticated') ||
        error.toString().contains('session')) {
      errorMessage = 'Session login telah berakhir. Silakan login ulang.';
    } else if (error.toString().contains('sudah dibooking') || 
               error.toString().contains('tidak tersedia')) {
      errorMessage = 'Slot sudah tidak tersedia. Silakan pilih slot lain.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _userName.split(' ').first;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                _getInitials(_userName),
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
      bottomNavigationBar: !_isLoading && _errorMessage == null
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
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
    return Column(
      children: [
        // Header Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                Config.getProxyImageUrl(_lapangan?.fotoUtama ?? ''),
              ),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {},
            ),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  _lapangan?.namaLapangan ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildDatePicker(),
                  _buildSlotsList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Tanggal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Harga/jam:  ${_formatCurrency(_lapangan?.hargaPerJam ?? 0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA7BF6E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 90));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B7A3E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedSlotId = null;
      });

      await _loadData();
    }
  }

  Widget _buildDatePicker() {
    if (_slotsResponse == null) return const SizedBox();

    final dates = _slotsResponse!.slotsByDate.keys.toList()..sort();
    final displayDates = dates.length > 7 ? dates.sublist(0, 7) : dates;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Tanggal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayDates.length,
              itemBuilder: (context, index) {
                final dateStr = displayDates[index];
                final date = DateTime.parse(dateStr);
                final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate);

                return Container(
                  width: 70,
                  margin: EdgeInsets.only(
                    right: index == displayDates.length - 1 ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6B7A3E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6B7A3E)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          _selectedSlotId = null;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getShortDayName(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? const Color(0xFFE8C900)
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList() {
    if (_slotsResponse == null) return const SizedBox();

    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final slots = _slotsResponse!.slotsByDate[dateKey] ?? [];

    if (slots.isEmpty) {
      return Container(
        height: 200,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Tidak ada slot tersedia untuk tanggal ${DateFormat('d MMM yyyy').format(_selectedDate)}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Slot Tersedia - ${DateFormat('EEEE, d MMM yyyy').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return BookingSlotCard(
                slot: slot,
                tanggal: _selectedDate,
                isSelected: _selectedSlotId == slot.id,
                onTap: () => _selectSlot(slot),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _selectedSlotId != null ? _proceedToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA7BF6E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: const Text(
            'Lanjut Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}