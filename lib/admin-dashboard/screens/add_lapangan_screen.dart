import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _jenisController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _fasilitasController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  File? _foto1;
  File? _foto2;
  File? _foto3;
  
  String? _selectedJenis;
  final List<String> _jenisOptions = ['Futsal', 'Basket', 'Bulutangkis', 'Voli'];

  Future<void> _pickImage(int fotoNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        switch (fotoNumber) {
          case 1:
            _foto1 = File(pickedFile.path);
            break;
          case 2:
            _foto2 = File(pickedFile.path);
            break;
          case 3:
            _foto3 = File(pickedFile.path);
            break;
        }
      });
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
                onChanged: (value) => setState(() => _selectedJenis = value),
                validator: (value) => value == null ? 'Pilih jenis lapangan' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField('LOKASI', _lokasiController, 'Contoh: Jakarta Selatan'),
              const SizedBox(height: 16),
              
              // Foto Upload Sections (sesuai design)
              _buildPhotoUpload('FOTO LAPANGAN 1 (UTAMA)', 1, _foto1),
              const SizedBox(height: 16),
              _buildPhotoUpload('FOTO LAPANGAN 2', 2, _foto2),
              const SizedBox(height: 16),
              _buildPhotoUpload('FOTO LAPANGAN 3', 3, _foto3),
              const SizedBox(height: 16),
              
              _buildTextField('HARGA PER JAM', _hargaController, '150000', keyboardType: TextInputType.number, prefix: 'Rp'),
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7BF6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
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
          onTap: () => _pickImage(photoNumber),
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
                        onPressed: () => _pickImage(photoNumber),
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lapangan berhasil ditambahkan!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}