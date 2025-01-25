// Import statements untuk library yang dibutuhkan
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Halaman Utama Daftar Pemain
class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

// State untuk halaman daftar pemain
class _StudentPageState extends State<StudentPage> {
  // Variabel untuk API endpoint
  final String baseUrl = 'http://hayy.my.id/api/register_student';
  final String imageBaseUrl = 'http://hayy.my.id';

  // Variabel untuk menyimpan data
  List<dynamic> students = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _searchQuery = '';

  // Controller untuk input field
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateBirthController = TextEditingController();

  // Variabel untuk dropdown
  String _selectedGender = 'M';
  String _status = '1';

  @override
  void initState() {
    super.initState();
    fetchStudents(); // Ambil data pemain saat halaman dibuka
  }

  // Fungsi untuk memfilter pemain berdasarkan pencarian
  List<dynamic> get filteredStudents {
    if (_searchQuery.isEmpty) {
      return students;
    }
    return students.where((student) {
      return student['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          student['id_student']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Fungsi untuk berbagi data pemain via share
  void shareStudentData(Map<String, dynamic> student) {
    String shareText = '''
Info Pemain SSB Tiger:
Nama: ${student['name']}
No. Punggung: ${student['id_student']}
Email: ${student['email']}
No HP: ${student['nohp']}
Status: ${student['status'] == 1 ? 'Aktif' : 'Non-Aktif'}
    ''';
    Share.share(shareText);
  }

  // Fungsi untuk menghubungi pemain via WhatsApp
  void contactViaWhatsApp(String phone) async {
    try {
      // Membersihkan format nomor telepon
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Format nomor dengan benar untuk kode negara Indonesia
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '62${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('62') &&
          !cleanPhone.startsWith('+62')) {
        cleanPhone = '62$cleanPhone';
      }

      // Hapus tanda + jika ada
      cleanPhone = cleanPhone.replaceAll('+', '');

      // Pesan default
      String message = 'Halo, saya dari SSB Tiger';

      // Gunakan URL universal yang bekerja di Android dan iOS
      final uri = Uri.parse(
          'https://wa.me/$cleanPhone/?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Tidak dapat membuka WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Gagal membuka WhatsApp: Pastikan WhatsApp terinstall di perangkat Anda'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fungsi untuk menampilkan QR Code data pemain
  void showQRCode(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: jsonEncode(student),
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 20),
              Text(student['name'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk mengambil data pemain dari API
  Future<void> fetchStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          students = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Fungsi untuk menambah data pemain baru
  Future<void> addStudent() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['id_student'] = _idController.text;
      request.fields['name'] = _nameController.text;
      request.fields['date_birth'] = _dateBirthController.text;
      request.fields['gender'] = _selectedGender;
      request.fields['email'] = _emailController.text;
      request.fields['nohp'] = _phoneController.text;
      request.fields['status'] = _status;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          _selectedImage!.path,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        await fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menambah data pemain')),
          );
        }
      } else {
        throw Exception('Failed to add student');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Fungsi untuk mengupdate data pemain
  Future<void> updateStudent(String id) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));

      request.fields['id_student'] = _idController.text;
      request.fields['name'] = _nameController.text;
      request.fields['date_birth'] = _dateBirthController.text;
      request.fields['gender'] = _selectedGender;
      request.fields['email'] = _emailController.text;
      request.fields['nohp'] = _phoneController.text;
      request.fields['status'] = _status;
      request.fields['reg_id_student'] = id;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          _selectedImage!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil mengupdate data pemain')),
          );
        }
      } else {
        throw Exception('Failed to update student: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Fungsi untuk menghapus data pemain
  Future<void> deleteStudent(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/${id.toString()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menghapus data pemain')),
          );
        }
      } else {
        throw Exception('Failed to delete student: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Fungsi untuk menampilkan dialog tambah/edit pemain
  Future<void> showStudentDialog({Map<String, dynamic>? student}) async {
    final isEditing = student != null;

    if (isEditing) {
      _nameController.text = student['name'];
      _idController.text = student['id_student'];
      _emailController.text = student['email'];
      _phoneController.text = student['nohp'];
      _dateBirthController.text = student['date_birth'];
      _selectedGender = student['gender'];
      _status = student['status'].toString();
    } else {
      _nameController.clear();
      _idController.clear();
      _emailController.clear();
      _phoneController.clear();
      _dateBirthController.clear();
      _selectedGender = 'M';
      _status = '1';
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Pemain' : 'Tambah Pemain Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'No. Punggung'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No HP'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _dateBirthController,
                decoration: const InputDecoration(labelText: 'Tanggal Lahir'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateBirthController.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'F', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Aktif')),
                  DropdownMenuItem(value: '0', child: Text('Non-Aktif')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: const Text('Pilih Foto'),
                onPressed: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (isEditing) {
                updateStudent(student['reg_id_student']);
              } else {
                addStudent();
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Pemain',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implementasi filter berdasarkan status/umur/dll
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showStudentDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // Implementasi scan QR code
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari pemain...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Stats Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Total Pemain',
                            students.length.toString(), Icons.people),
                        _buildStatColumn(
                            'Aktif',
                            students
                                .where((s) => s['status'] == 1)
                                .length
                                .toString(),
                            Icons.check_circle),
                        _buildStatColumn(
                            'Non-Aktif',
                            students
                                .where((s) => s['status'] == 0)
                                .length
                                .toString(),
                            Icons.cancel),
                      ],
                    ),
                  ),
                ),
              ),

              // List Pemain
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Lottie.network(
                          'https://assets3.lottiefiles.com/packages/lf20_p8bfn5to.json',
                          width: 200,
                          height: 200,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              leading: Hero(
                                tag: 'player-${student['reg_id_student']}',
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: student['photo'].isNotEmpty
                                      ? NetworkImage(
                                          '$imageBaseUrl/${student['photo']}')
                                      : null,
                                  backgroundColor: Colors.grey[200],
                                  child: student['photo'].isEmpty
                                      ? Icon(Icons.person,
                                          color: Colors.green[700], size: 30)
                                      : null,
                                ),
                              ),
                              title: Text(
                                student['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('No. ${student['id_student']}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: student['status'] == 1
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  student['status'] == 1
                                      ? 'Aktif'
                                      : 'Non-Aktif',
                                  style: TextStyle(
                                    color: student['status'] == 1
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildActionButton(
                                        Icons.edit,
                                        'Edit',
                                        Colors.orange,
                                        () =>
                                            showStudentDialog(student: student),
                                      ),
                                      _buildActionButton(
                                        Icons.share,
                                        'Bagikan',
                                        Colors.blue,
                                        () => shareStudentData(student),
                                      ),
                                      _buildActionButton(
                                        FontAwesomeIcons.whatsapp,
                                        'WhatsApp',
                                        Colors.green,
                                        () =>
                                            contactViaWhatsApp(student['nohp']),
                                      ),
                                      _buildActionButton(
                                        Icons.qr_code,
                                        'QR Code',
                                        Colors.purple,
                                        () => showQRCode(student),
                                      ),
                                      _buildActionButton(
                                        Icons.delete,
                                        'Hapus',
                                        Colors.red,
                                        () => _confirmDelete(student),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan statistik
  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget untuk tombol aksi
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk konfirmasi penghapusan
  void _confirmDelete(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content:
            const Text('Apakah Anda yakin ingin menghapus data pemain ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteStudent(student['reg_id_student']);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
