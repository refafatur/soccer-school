import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  EditProfilePage({required this.profileData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _selectedImageName;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nohpController;
  late TextEditingController _dateBirthController;
  DateTime? _selectedDate;

  // Tambahkan konstanta warna di awal class
  final Color tigerOrange = const Color(0xFFFF5722); // Warna harimau
  final Color tigerBlack = const Color(0xFF212121); // Warna strip harimau
  final Color jungleGreen = const Color(0xFF2E7D32); // Warna lapangan
  final Color goldAccent = const Color(0xFFFFD700); // Warna aksen prestasi

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.profileData['name']?.toString() ?? '');
    _emailController = TextEditingController(
        text: widget.profileData['email']?.toString() ?? '');
    _nohpController = TextEditingController(
        text: widget.profileData['nohp']?.toString() ?? '');
    _dateBirthController = TextEditingController(
        text: widget.profileData['date_birth']?.toString() ?? '');

    if (widget.profileData['date_birth'] != null) {
      _selectedDate =
          DateTime.parse(widget.profileData['date_birth'].toString());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<String> _processImageFile(XFile file) async {
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64.encode(imageBytes);
    return base64Image;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Validasi ukuran file (maksimal 5MB)
        final fileSize = await image.length();
        if (fileSize > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ukuran file terlalu besar (maksimal 5MB)')),
          );
          return;
        }

        setState(() {
          _selectedImage = image;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memilih gambar: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'nohp': _nohpController.text,
        'date_birth': _dateBirthController.text,
      };

      if (_selectedImage != null) {
        try {
          String base64Image = await _processImageFile(_selectedImage!);

          // Batasi ukuran base64 string
          if (base64Image.length > 2000000) {
            // ~2MB dalam base64
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Gambar terlalu besar setelah kompresi. Silakan pilih gambar yang lebih kecil.')),
              );
            }
            setState(() => _isLoading = false);
            return;
          }

          formData['photo'] = base64Image;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saat memproses foto: $e')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      final regIdStudent = widget.profileData['reg_id_student'].toString();
      await _apiService.updateProfile(regIdStudent, formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tigerBlack,
                  tigerBlack.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Tiger stripe pattern
          Positioned.fill(
            child: CustomPaint(
              painter: TigerStripePainter(),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Edit Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Photo picker
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        child: _selectedImage != null
                                            ? FutureBuilder<String>(
                                                future: _processImageFile(
                                                    _selectedImage!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Image.memory(
                                                      base64.decode(snapshot
                                                          .data!), // Gunakan base64.decode
                                                      fit: BoxFit.cover,
                                                    );
                                                  }
                                                  return _buildDefaultPhoto();
                                                },
                                              )
                                            : _buildDefaultPhoto(),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            tigerOrange,
                                            goldAccent,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.camera_alt,
                                            color: Colors.white, size: 20),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            // Form fields
                            _buildFormField(
                              controller: _nameController,
                              label: 'Nama',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildFormField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!value.contains('@')) {
                                  return 'Email tidak valid';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildFormField(
                              controller: _nohpController,
                              label: 'No. HP',
                              icon: Icons.phone_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'No. HP tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            _buildDateField(context),
                            SizedBox(height: 40),
                            // Submit button
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tigerOrange,
                                    goldAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: tigerOrange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPhoto() {
    return widget.profileData['photo'] != null
        ? Image.network(
            'https://hayy.my.id/${widget.profileData['photo']}',
            fit: BoxFit.cover,
          )
        : Container(
            color: Colors.white.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white38),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return _buildFormField(
      controller: _dateBirthController,
      label: 'Tanggal Lahir',
      icon: Icons.calendar_today_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tanggal lahir tidak boleh kosong';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nohpController.dispose();
    _dateBirthController.dispose();
    super.dispose();
  }
}

class TigerStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 40) {
      final path = Path();
      path.moveTo(0, i.toDouble());

      for (var x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          i + 10 * math.sin(x * 0.1),
          x + 20,
          i.toDouble(),
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TigerStripePainter oldDelegate) => false;
}