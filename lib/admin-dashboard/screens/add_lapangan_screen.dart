// lib/admin-dashboard/screens/add_lapangan_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lapangin_mobile/admin-dashboard/services/lapangan_service.dart';

class AddLapanganScreen extends StatefulWidget {
  final String sessionCookie;
  final String username;

  const AddLapanganScreen({
    super.key,
    required this.sessionCookie,
    required this.username,
  });

  @override
  State<AddLapanganScreen> createState() => _AddLapanganScreenState();
}

class _AddLapanganScreenState extends State<AddLapanganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _fasilitasController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  File? _foto1;
  File? _foto2;
  File? _foto3;
  
  String? _selectedJenis;
  final List<String> _jenisOptions = ['Futsal', 'Basket', 'Bulutangkis', 'Voli'];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _fasilitasController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int fotoNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      
      // Check file size (max 5MB) - FIXED
      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran foto terlalu besar (max 5MB)'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      setState(() {
        switch (fotoNumber) {
          case 1:
            _foto1 = file;
            break;
          case 2:
            _foto2 = file;
            break;
          case 3:
            _foto3 = file;
            break;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedJenis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis lapangan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFA7BF6E)),
      ),
    );
    
    try {
      await AdminLapanganService.createLapangan(
        sessionCookie: widget.sessionCookie,
        nama: _namaController.text.trim(),
        jenis: _selectedJenis!,
        lokasi: _lokasiController.text.trim(),
        harga: int.parse(_hargaController.text.trim()),
        fasilitas: _fasilitasController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        foto1: _foto1,
        foto2: _foto2,
        foto3: _foto3,
      );
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Lapangan berhasil ditambahkan!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate back
      Navigator.pop(context, true); // Return true to indicate success
      
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA7BF6E),
        elevation: 0,
        title: const Text('Tambah Lapangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('NAMA LAPANGAN', _namaController, 'Contoh: Futsal Arena Senayan'),
              const SizedBox(height: 16),
              
              // Jenis Lapangan Dropdown
              const Text('JENIS LAPANGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A8450))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJenis,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                hint: const Text('Pilih Jenis'),
                items: _jenisOptions.map((jenis) {
                  return DropdownMenuItem(value: jenis, child: Text(jenis));
                }).toList(),
                onChanged: _isSubmitting ? null : (value) => setState(() => _selectedJenis = value),
                validator: (value) => value == null ? 'Pilih jenis lapangan' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField('LOKASI', _lokasiController, 'Contoh: Jakarta Selatan'),
              const SizedBox(height: 16),
              
              // Foto Upload Sections
              _buildPhotoUpload('FOTO LAPANGAN 1 (UTAMA)', 1, _foto1),
              const SizedBox(height: 16),
              _buildPhotoUpload('FOTO LAPANGAN 2', 2, _foto2),
              const SizedBox(height: 16),
              _buildPhotoUpload('FOTO LAPANGAN 3', 3, _foto3),
              const SizedBox(height: 16),
              
              _buildTextField('HARGA PER JAM', _hargaController, '150000', keyboardType: TextInputType.number, prefix: 'Rp '),
              const SizedBox(height: 16),
              
              _buildTextField('FASILITAS', _fasilitasController, 'Contoh: Musholla, Cafe, Parkir luas, AC, Toilet bersih', maxLines: 3),
              const SizedBox(height: 4),
              const Text('Pisahkan dengan koma (,)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              
              _buildTextField('DESKRIPSI', _deskripsiController, 'Deskripsi lengkap tentang lapangan...', maxLines: 4),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back),
                          SizedBox(width: 8),
                          Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7BF6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 8),
                                Text('Simpan Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, 
      {int maxLines = 1, TextInputType? keyboardType, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A8450))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Field tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildPhotoUpload(String label, int photoNumber, File? photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A8450))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isSubmitting ? null : () => _pickImage(photoNumber),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _pickImage(photoNumber),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA7BF6E),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Upload Foto $photoNumber'),
                      ),
                      const SizedBox(height: 8),
                      const Text('Format: JPG, PNG (Max 5MB)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(photo, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      ),
                      if (!_isSubmitting)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  switch (photoNumber) {
                                    case 1:
                                      _foto1 = null;
                                      break;
                                    case 2:
                                      _foto2 = null;
                                      break;
                                    case 3:
                                      _foto3 = null;
                                      break;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}