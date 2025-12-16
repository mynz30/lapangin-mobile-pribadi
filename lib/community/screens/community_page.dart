// lib/community/screens/community_page.dart

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/community/models/community_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapangin_mobile/community/screens/community_detail_page.dart';
import 'package:lapangin_mobile/community/widgets/community_card.dart'; // Pastikan widget ini ada
import 'package:lapangin_mobile/landing/widgets/left_drawer.dart';
import 'package:lapangin_mobile/config.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // State variables
  String _searchQuery = "";
  String currentUsername = "Guest";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;
    
    // Logic from menu.dart to enable consistent username retrieval
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
      if (mounted) {
        setState(() {
          currentUsername = foundName!;
        });
      }
    } else {
       // Fallback to SharedPreferences if CookieRequest is empty (e.g. after refresh)
       SharedPreferences prefs = await SharedPreferences.getInstance();
       if (mounted) {
         setState(() {
           currentUsername = prefs.getString('username') ?? "Guest";
         });
       }
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
  String _selectedCategory = "Jenis Olahraga";
  String _selectedLocation = "Filter Lokasi";
  
  // Options for filters
  final List<String> _categories = ["Jenis Olahraga", "Futsal", "Bulutangkis", "Basket", "Renang"];
  final List<String> _locations = ["Filter Lokasi", "Depok", "Jakarta", "Bogor", "Tangerang", "Bekasi"];

  // Fungsi fetch data
  Future<List<Community>> fetchCommunities(CookieRequest request) async {
    // GANTI URL SESUAI IP KOMPUTER MU (JANGAN LOCALHOST JIKA PAKAI EMULATOR)
    // Contoh Android Emulator: http://10.0.2.2:8000/community/api/communities/
    // GANTI URL SESUAI IP KOMPUTER MU (JANGAN LOCALHOST JIKA PAKAI EMULATOR)
    // Contoh Android Emulator: http://10.0.2.2:8000/community/api/communities/
    final response = await request.get('${Config.localUrl}/community/api/communities/');

    List<Community> listCommunity = [];
    for (var d in response) {
      if (d != null) {
        listCommunity.add(Community.fromJson(d));
      }
    }
    return listCommunity;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    String firstName = currentUsername.split(' ').first;

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
                _getInitials(currentUsername),
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
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header removed (moved to AppBar)

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Hero Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1517649763962-0c623066013b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.5)],
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Bergabung dengan Komunitas\nOlahraga Terdekatmu!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Main Bareng, Kenalan, dan Bangun Semangat Baru di Lapang.in",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Search & Filter Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cari Komunitas",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B9E6D), // Olive green
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Ketikkan nama komunitas..',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDropdown(_selectedCategory, _categories, (val) {
                                setState(() => _selectedCategory = val!);
                              }),
                              const SizedBox(width: 12),
                              _buildDropdown(_selectedLocation, _locations, (val) {
                                setState(() => _selectedLocation = val!);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. Community List
                    FutureBuilder(
                      future: fetchCommunities(request),
                      builder: (context, AsyncSnapshot<List<Community>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                             padding: EdgeInsets.all(20),
                             child: CircularProgressIndicator()
                          ));
                        } else if (snapshot.hasError) {
                          return Center(child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SelectableText("Error: ${snapshot.error}"),
                          ));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Tidak ada data komunitas."),
                          ));
                        } else {
                          List<Community> communities = snapshot.data!;
                          List<Community> filteredCommunities = communities.where((c) {
                            bool matchCategory = _selectedCategory == "Jenis Olahraga" || 
                                                 c.sportsType.toLowerCase() == _selectedCategory.toLowerCase();
                            bool matchLocation = _selectedLocation == "Filter Lokasi" ||
                                                 c.location.toLowerCase().contains(_selectedLocation.toLowerCase());
                            bool matchSearch = c.name.toLowerCase().contains(_searchQuery);
                            
                            return matchCategory && matchLocation && matchSearch;
                          }).toList();

                          if (filteredCommunities.isEmpty) {
                             return const Center(child: Padding(
                               padding: EdgeInsets.all(20.0),
                               child: Text("Komunitas tidak ditemukan."),
                             ));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // No horizontal padding on Listview, card handles it
                            padding: EdgeInsets.zero,
                            itemCount: filteredCommunities.length,
                            itemBuilder: (_, index) {
                              final community = filteredCommunities[index];
                              return CommunityCard(
                                community: community, 
                                onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: community)));
                                }
                              );
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}