// lib/admin-dashboard/screens/edit_lapangan_screen.dart - NEW FILE
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lapangin/admin-dashboard/services/lapangan_service.dart';
import 'package:lapangin/config.dart';

class EditLapanganScreen extends StatefulWidget {
  final int lapanganId;
  final String sessionCookie;
  final String username;

  const EditLapanganScreen({
    super.key,
    required this.lapanganId,
    required this.sessionCookie,
    required this.username,
  });

  @override
  State<EditLapanganScreen> createState() => _EditLapanganScreenState();
}

class _EditLapanganScreenState extends State<EditLapanganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _fasilitasController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  File? _foto1;
  File? _foto2;
  File? _foto3;
  
  String? _existingFoto1Url;
  String? _existingFoto2Url;
  String? _existingFoto3Url;
  
  String? _selectedJenis;
  final List<String> _jenisOptions = ['Futsal', 'Basket', 'Bulutangkis', 'Voli'];

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLapanganData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _fasilitasController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadLapanganData() async {
    try {
      final data = await AdminLapanganService.getLapanganDetail(
        widget.lapanganId,
        widget.sessionCookie,
      );
      
      setState(() {
        _namaController.text = data['nama_lapangan'] ?? '';
        _lokasiController.text = data['lokasi'] ?? '';
        _hargaController.text = data['harga_per_jam']?.toString() ?? '';
        _fasilitasController.text = data['fasilitas'] ?? '';
        _deskripsiController.text = data['deskripsi'] ?? '';
        _selectedJenis = data['jenis_olahraga'];
        
        _existingFoto1Url = data['foto_utama'];
        _existingFoto2Url = data['foto_2'];
        _existingFoto3Url = data['foto_3'];
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
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
      
      if (fileSize > Config.maxImageSizeBytes) {
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
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFA7BF6E)),
      ),
    );
    
    try {
      await AdminLapanganService.updateLapangan(
        lapanganId: widget.lapanganId,
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
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Lapangan berhasil diupdate!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context, true);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
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
        title: const Text('Edit Lapangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA7BF6E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('NAMA LAPANGAN', _namaController, 'Nama lapangan'),
                    const SizedBox(height: 16),
                    
                    const Text('JENIS LAPANGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7A8450))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedJenis,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _jenisOptions.map((jenis) {
                        return DropdownMenuItem(value: jenis, child: Text(jenis));
                      }).toList(),
                      onChanged: _isSubmitting ? null : (value) => setState(() => _selectedJenis = value),
                      validator: (value) => value == null ? 'Pilih jenis lapangan' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField('LOKASI', _lokasiController, 'Lokasi'),
                    const SizedBox(height: 16),
                    
                    _buildPhotoUpload('FOTO LAPANGAN 1 (UTAMA)', 1, _foto1, _existingFoto1Url),
                    const SizedBox(height: 16),
                    _buildPhotoUpload('FOTO LAPANGAN 2', 2, _foto2, _existingFoto2Url),
                    const SizedBox(height: 16),
                    _buildPhotoUpload('FOTO LAPANGAN 3', 3, _foto3, _existingFoto3Url),
                    const SizedBox(height: 16),
                    
                    _buildTextField('HARGA PER JAM', _hargaController, 'Harga', keyboardType: TextInputType.number, prefix: 'Rp '),
                    const SizedBox(height: 16),
                    
                    _buildTextField('FASILITAS', _fasilitasController, 'Fasilitas', maxLines: 3),
                    const SizedBox(height: 16),
                    
                    _buildTextField('DESKRIPSI', _deskripsiController, 'Deskripsi', maxLines: 4),
                    const SizedBox(height: 24),
                    
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
                            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Update Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildPhotoUpload(String label, int photoNumber, File? newPhoto, String? existingUrl) {
    final bool hasExisting = existingUrl != null && existingUrl.isNotEmpty;
    final bool hasNew = newPhoto != null;
    
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
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: hasNew
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(newPhoto, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
                                    case 1: _foto1 = null; break;
                                    case 2: _foto2 = null; break;
                                    case 3: _foto3 = null; break;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  )
                : hasExisting
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              Config.getProxyImageUrl(existingUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error));
                              },
                            ),
                          ),
                          if (!_isSubmitting)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(photoNumber),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Ganti'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA7BF6E),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Column(
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
                      ),
          ),
        ),
      ],
    );
  }
}