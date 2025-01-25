// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Import untuk file picker
// import '../services/api_service.dart';
// import 'dart:io' show File; // Menggunakan File untuk platform mobile
// import 'package:flutter/foundation.dart' as kIsWeb; // Menggunakan kIsWeb untuk platform web

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _birthDateController = TextEditingController();
//   final TextEditingController _genderController = TextEditingController();
//   final TextEditingController _photoController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _nohpController = TextEditingController();
//   final String _registrationDate = DateTime.now().toIso8601String(); // Tanggal registrasi otomatis
//   String? _status;
//   final ApiService _apiService = ApiService();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _idController.dispose();
//     _nameController.dispose();
//     _birthDateController.dispose();
//     _genderController.dispose();
//     _photoController.dispose();
//     _emailController.dispose();
//     _nohpController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await _apiService.register(
//         _idController.text,
//         _nameController.text,
//         _birthDateController.text,
//         _genderController.text,
//         _photoController.text,
//         _emailController.text,
//         _nohpController.text,
//         _status ?? 'Aktif', // Default status jika tidak dipilih
//       );

//       // Tampilkan pesan sukses
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Registrasi berhasil: ${response['message']}'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Reset form setelah registrasi
//       _idController.clear();
//       _nameController.clear();
//       _birthDateController.clear();
//       _genderController.clear();
//       _photoController.clear();
//       _emailController.clear();
//       _nohpController.clear();
//       setState(() {
//         _status = null;
//       });
//     } catch (e) {
//       // Tampilkan pesan kesalahan
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Registrasi gagal: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _photoController.text = image.path; // Menyimpan path gambar ke controller
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF2A2D3E),
//               Color(0xFF1E1E2C),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'Registrasi',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 30),
//                 
//                 // Profile photo picker
//                 _buildProfilePhotoPicker(),
//                 SizedBox(height: 24),
//
//                 // Form fields
//                 _buildTextField("Nama Lengkap", _nameController, Icons.person),
//                 SizedBox(height: 16),
//                 _buildTextField("Email", _emailController, Icons.email),
//                 SizedBox(height: 16),
//                 _buildPasswordField(),
//                 SizedBox(height: 16),
//                 _buildDatePicker(),
//                 SizedBox(height: 16),
//                 _buildGenderSelector(),
//                 SizedBox(height: 16),
//                 _buildTextField("No. HP", _phoneController, Icons.phone),
//                 SizedBox(height: 24),
//
//                 // Register button
//                 _buildPrimaryButton("Daftar", _handleRegister),
//                 SizedBox(height: 16),
//
//                 // Login link
//                 _buildTextButton("Sudah punya akun? Login", () {
//                   Navigator.pushReplacementNamed(context, '/login');
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfilePhotoPicker() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         width: 120,
//         height: 120,
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.1),
//           shape: BoxShape.circle,
//           border: Border.all(color: Color(0xFF6C63FF), width: 2),
//         ),
//         child: _imageFile != null
//             ? ClipOval(
//                 child: Image.file(_imageFile!, fit: BoxFit.cover),
//               )
//             : Icon(Icons.camera_alt, color: Colors.white70, size: 40),
//       ),
//     );
//   }

//   Widget _buildDatePicker() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: Icon(Icons.calendar_today, color: Colors.white70),
//         title: Text(
//           _selectedDate ?? 'Pilih Tanggal Lahir',
//           style: TextStyle(color: Colors.white70),
//         ),
//         onTap: _showDatePicker,
//       ),
//     );
//   }

//   Widget _buildGenderSelector() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedGender,
//           dropdownColor: Color(0xFF2A2D3E),
//           style: TextStyle(color: Colors.white),
//           icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
//           items: ['Laki-laki', 'Perempuan']
//               .map((String value) => DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   ))
//               .toList(),
//           onChanged: (newValue) {
//             setState(() {
//               _selectedGender = newValue;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }