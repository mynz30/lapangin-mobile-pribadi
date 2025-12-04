import 'package:flutter/material.dart';
import 'package:lapangin/landing/widgets/left_drawer.dart'; 
import 'package:lapangin/landing/widgets/card_lapangan.dart'; 
import 'package:lapangin/landing/models/lapangan_entry.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart'; 
import 'package:provider/provider.dart';
import 'package:lapangin/booking/screens/booking_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LapanganEntry> _lapangans = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final String apiUrl = "http://localhost:8000/api/booking/"; 
  final String _baseServerUrl = "http://localhost:8000"; 

  String _userName = "User"; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUserName(); // Panggil fungsi untuk mengatur nama
      fetchLapanganData();
    });
  }

  void _setUserName() {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;

    print("--- Data User Tersimpan di CookieRequest (lapangin) ---");
    print(userData);
    print("-------------------------------------------------------");

    const potentialKeys = ['username', 'first_name', 'name', 'fullname'];

    String? foundName;

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          print("Ditemukan nama pengguna dengan kunci: $key. Nilai: $foundName");
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
    if (name.isEmpty) return "U"; // Default 'U' untuk 'User'
    final parts = name.trim().split(' ');
    String initials = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initials += parts.last[0].toUpperCase();
    }
    return initials;
  }
  // ---------------------------------------------


  Future<void> fetchLapanganData() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await request.get(apiUrl);
      
      List<LapanganEntry> fetchedLapangans = [];
      
      if (response is List) {
        for (var item in response) {
          
          final id = item['id'];
          final name = item['name'];
          final typeString = item['type'];
          final location = item['location'];
          final price = item['price'];
          final rating = item['rating'];
          final reviewCount = item['review_count'];
          String imageUrl = item['image'] ?? ""; // Ambil gambar
          if (id != null && name != null && typeString != null) { 
            
            fetchedLapangans.add(LapanganEntry(
              id: id,
              name: name,
              type: typeValues.map[typeString]!, // Ganti sementara karena typeValues tidak ada
              location: location ?? "N/A",
              price: price ?? 0,
              rating: (rating is num) ? rating.toDouble() : 0.0,
              reviewCount: reviewCount ?? 0,
              image: imageUrl, 
            ));

          } else {
            print('Peringatan: Item data tidak valid (ID, Name, Type hilang, atau Tipe tidak dikenali): $item');
          }
        }

        setState(() {
          _lapangans = fetchedLapangans;
          _isLoading = false;
        });
      } else {
        throw Exception("API response is not a valid list format. Did you return a single object instead of a list?");
      }


    } catch (e) {
      String errorDetail = e.toString().contains('FormatException') 
          ? 'Respons bukan JSON (mungkin HTML/halaman login/404). Cek URL Django.'
          : e.toString();
          
      setState(() {
        _errorMessage = 'Gagal mengambil data: $errorDetail. Pastikan URL server ($_baseServerUrl) dan server Django aktif.';
        _isLoading = false;
      });
      print('Error fetching data: $e'); // Log error untuk debugging
    }
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _userName.split(' ').first;
    
    return Scaffold(
      backgroundColor: Colors.white, 
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black), 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Konten rata kanan
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
      
      drawer: const LeftDrawer(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1551958219-acbc608c6377?q=80&w=2070&auto=format&fit=crop"), 
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black38, 
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking Lapangan Gak\nPake Drama!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Cari lapangan, pilih jadwal, langsung main!",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Cari Lapangan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8E23), 
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Ketikkan nama lapangan..",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildFilterChip("Jenis Lapangan"),
                  const SizedBox(width: 12),
                  _buildFilterChip("Filter Ulasan"),
                ],
              ),

              const SizedBox(height: 20),

              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_errorMessage.isNotEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: fetchLapanganData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ))
              else if (_lapangans.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text("Tidak ada data lapangan ditemukan."),
                ))
              else
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _lapangans.length,
                  itemBuilder: (context, index) {
                    return LapanganEntryCard(
                      lapangan: _lapangans[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(
                              lapanganId: _lapangans[index].id,
                              sessionCookie: 'auto',
                              username: _userName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
      
      
    );
  }
}