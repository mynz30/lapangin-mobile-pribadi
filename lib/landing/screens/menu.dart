import 'package:flutter/material.dart';
import 'package:lapangin_mobile/landing/widgets/left_drawer.dart'; 
import 'package:lapangin_mobile/landing/widgets/card_lapangan.dart'; 
import 'package:lapangin_mobile/landing/models/lapangan_entry.dart'; 
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
  List<LapanganEntry> _filteredLapangans = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final String apiUrl = "http://localhost:8000/api/booking/"; 
  final String _baseServerUrl = "http://localhost:8000"; 

  String _userName = "User";
  
  final TextEditingController _searchController = TextEditingController();
  FieldType? _selectedType;
  double? _selectedMinRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUserName();
      fetchLapanganData();
    });
    
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    String initials = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initials += parts.last[0].toUpperCase();
    }
    return initials;
  }

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
          String imageUrl = item['image'] ?? "";
          
          if (id != null && name != null && typeString != null) { 
            
            fetchedLapangans.add(LapanganEntry(
              id: id,
              name: name,
              type: typeValues.map[typeString]!,
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
          _filteredLapangans = fetchedLapangans;
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
      print('Error fetching data: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLapangans = _lapangans.where((lapangan) {
        final matchesSearch = lapangan.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        
        final matchesType = _selectedType == null || lapangan.type == _selectedType;
        
        final matchesRating = _selectedMinRating == null || lapangan.rating >= _selectedMinRating!;
        
        return matchesSearch && matchesType && matchesRating;
      }).toList();
    });
  }

  void _showTypeFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Jenis Lapangan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Semua Jenis'),
                leading: Radio<FieldType?>(
                  value: null,
                  groupValue: _selectedType,
                  onChanged: (FieldType? value) {
                    setState(() {
                      _selectedType = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Futsal'),
                leading: Radio<FieldType?>(
                  value: FieldType.FUTSAL,
                  groupValue: _selectedType,
                  onChanged: (FieldType? value) {
                    setState(() {
                      _selectedType = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Basket'),
                leading: Radio<FieldType?>(
                  value: FieldType.BASKET,
                  groupValue: _selectedType,
                  onChanged: (FieldType? value) {
                    setState(() {
                      _selectedType = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Bulutangkis'),
                leading: Radio<FieldType?>(
                  value: FieldType.BULUTANGKIS,
                  groupValue: _selectedType,
                  onChanged: (FieldType? value) {
                    setState(() {
                      _selectedType = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Berdasarkan Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Semua Rating'),
                leading: Radio<double?>(
                  value: null,
                  groupValue: _selectedMinRating,
                  onChanged: (double? value) {
                    setState(() {
                      _selectedMinRating = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    SizedBox(width: 4),
                    Text('4.5 ke atas'),
                  ],
                ),
                leading: Radio<double?>(
                  value: 4.5,
                  groupValue: _selectedMinRating,
                  onChanged: (double? value) {
                    setState(() {
                      _selectedMinRating = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    SizedBox(width: 4),
                    Text('4.0 ke atas'),
                  ],
                ),
                leading: Radio<double?>(
                  value: 4.0,
                  groupValue: _selectedMinRating,
                  onChanged: (double? value) {
                    setState(() {
                      _selectedMinRating = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    SizedBox(width: 4),
                    Text('3.5 ke atas'),
                  ],
                ),
                leading: Radio<double?>(
                  value: 3.5,
                  groupValue: _selectedMinRating,
                  onChanged: (double? value) {
                    setState(() {
                      _selectedMinRating = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    SizedBox(width: 4),
                    Text('3.0 ke atas'),
                  ],
                ),
                leading: Radio<double?>(
                  value: 3.0,
                  groupValue: _selectedMinRating,
                  onChanged: (double? value) {
                    setState(() {
                      _selectedMinRating = value;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel() {
    if (_selectedType == null) return "Jenis Lapangan";
    switch (_selectedType!) {
      case FieldType.FUTSAL:
        return "Futsal";
      case FieldType.BASKET:
        return "Basket";
      case FieldType.BULUTANGKIS:
        return "Bulutangkis";
    }
  }

  String _getRatingLabel() {
    if (_selectedMinRating == null) return "Filter Ulasan";
    return "Rating ≥ ${_selectedMinRating!.toStringAsFixed(1)}";
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, {bool isTypeFilter = false, bool isRatingFilter = false}) {
    String displayLabel = label;
    if (isTypeFilter) {
      displayLabel = _getTypeLabel();
    } else if (isRatingFilter) {
      displayLabel = _getRatingLabel();
    }

    bool isActive = false;
    if (isTypeFilter && _selectedType != null) {
      isActive = true;
    } else if (isRatingFilter && _selectedMinRating != null) {
      isActive = true;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF4D5833),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF4D5833),
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              displayLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF4D5833),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF4D5833),
            ),
          ],
        ),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Ketikkan nama lapangan..",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF6B8E23)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildFilterChip("Jenis Lapangan", _showTypeFilterDialog, isTypeFilter: true),
                  const SizedBox(width: 12),
                  _buildFilterChip("Filter Ulasan", _showRatingFilterDialog, isRatingFilter: true),
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
              else if (_filteredLapangans.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _lapangans.isEmpty 
                            ? "Tidak ada data lapangan ditemukan."
                            : "Tidak ada lapangan yang sesuai dengan filter.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ))
              else
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Ditemukan ${_filteredLapangans.length} lapangan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filteredLapangans.length,
                      itemBuilder: (context, index) {
                        return LapanganEntryCard(
                          lapangan: _filteredLapangans[index],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Kamu memilih ${_filteredLapangans[index].name}")),
                            );
                          },
                        );
                      },
                    ),
                  ],
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