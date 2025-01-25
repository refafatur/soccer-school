import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  _CoachPageState createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final String baseUrl = 'http://hayy.my.id/api/register_coach';
  List<dynamic> coaches = [];
  bool isLoading = true;
  String searchQuery = '';
  String filterDepartment = 'Semua';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCoaches();
  }

  Future<void> fetchCoaches() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data'); // Debug response
        setState(() {
          coaches = data;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to fetch coaches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during GET request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data pelatih: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> addCoach(Map<String, dynamic> newCoach) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Tambahkan semua field ke form data
      request.fields['name_coach'] = newCoach['name_coach'];
      request.fields['coach_department'] = newCoach['coach_department'];
      request.fields['email'] = newCoach['email'];
      request.fields['nohp'] = newCoach['nohp'];
      request.fields['status_coach'] = newCoach['status_coach'].toString();
      request.fields['license'] = newCoach['license'] ?? '';
      request.fields['experience'] = newCoach['experience'] ?? '';
      request.fields['achievements'] = newCoach['achievements'] ?? '';
      request.fields['years_coach'] = newCoach['years_coach'].toString();

      // Tambahkan foto jika ada
      if (_imageFile != null) {
        try {
          // Baca file sebagai bytes
          List<int> imageBytes = await _imageFile!.readAsBytes();

          // Tambahkan file ke request
          request.files.add(
            http.MultipartFile.fromBytes(
              'photo',
              imageBytes,
              filename: path.basename(_imageFile!.path),
              contentType:
                  MediaType('image', 'jpeg'), // Sesuaikan dengan tipe file
            ),
          );
        } catch (e) {
          print('Error adding photo to request: $e');
          throw Exception('Gagal memproses foto: $e');
        }
      }

      print('Sending request...'); // Debug log
      var streamedResponse = await request.send();
      print('Response status: ${streamedResponse.statusCode}'); // Debug log

      var response = await http.Response.fromStream(streamedResponse);
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        fetchCoaches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pelatih berhasil ditambahkan!')),
          );
        }
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      print('Error in addCoach: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pelatih: $e')),
        );
      }
    }
  }

  Future<void> editCoach(int idCoach, Map<String, dynamic> updatedCoach) async {
    try {
      // Validate required fields
      if (updatedCoach['name_coach'].isEmpty ||
          updatedCoach['coach_department'].isEmpty ||
          updatedCoach['email'].isEmpty ||
          updatedCoach['nohp'].isEmpty) {
        throw Exception('Semua field wajib harus diisi');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$idCoach'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedCoach),
      );

      if (response.statusCode == 200) {
        fetchCoaches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pelatih berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update coach');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui pelatih: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteCoach(int idCoach) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$idCoach'));
      if (response.statusCode == 200) {
        fetchCoaches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pelatih berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete coach');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus pelatih: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        // Validasi ekstensi file
        final String ext = path.extension(pickedFile.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.gif'].contains(ext)) {
          // Baca file langsung setelah dipilih
          final File file = File(pickedFile.path);
          if (await file.exists()) {
            setState(() {
              _imageFile = file;
            });
          } else {
            throw Exception('File tidak ditemukan');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Hanya file JPG, JPEG, PNG, atau GIF yang diperbolehkan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showCoachDialog({Map<String, dynamic>? coach}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController experienceController = TextEditingController();
    final TextEditingController achievementsController =
        TextEditingController();
    final TextEditingController yearsCoachController = TextEditingController();

    String? selectedLicense;
    String? selectedDepartment;
    String? selectedStatus;

    final List<String> licenses = [
      'UEFA A',
      'UEFA B',
      'UEFA C',
      'AFC Pro',
      'AFC A',
      'AFC B',
      'AFC C'
    ];

    final List<String> departments = [
      'U-8',
      'U-10',
      'U-12',
      'U-14',
      'U-16',
      'U-18',
      'Senior'
    ];

    final List<String> statuses = ['Aktif', 'Tidak Aktif'];

    if (coach != null) {
      nameController.text = coach['name_coach'];
      selectedDepartment = coach['coach_department'];
      emailController.text = coach['email'];
      phoneController.text = coach['nohp'];
      selectedStatus = coach['status_coach'] == 1 ? 'Aktif' : 'Tidak Aktif';
      experienceController.text = coach['experience'] ?? '';
      achievementsController.text = coach['achievements'] ?? '';
      selectedLicense = coach['license'];
      yearsCoachController.text = coach['years_coach']?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(
              coach == null ? Icons.person_add : Icons.edit_note,
              color: const Color(0xFF2B4865),
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              coach == null ? 'Tambah Pelatih Baru' : 'Edit Data Pelatih',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B4865),
                fontSize: 24,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: nameController,
                label: 'Nama Pelatih',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              buildDropdownField(
                value: selectedLicense,
                items: licenses,
                label: 'Lisensi Kepelatihan',
                icon: Icons.card_membership,
                onChanged: (value) => selectedLicense = value,
              ),
              const SizedBox(height: 16),
              buildDropdownField(
                value: selectedDepartment,
                items: departments,
                label: 'Departemen/Tim',
                icon: Icons.sports_soccer,
                onChanged: (value) => selectedDepartment = value,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: experienceController,
                label: 'Pengalaman Melatih',
                icon: Icons.work_history,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: achievementsController,
                label: 'Prestasi',
                icon: Icons.emoji_events,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: yearsCoachController,
                label: 'Umur Pelatih (Tahun)',
                icon: Icons.timer,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildDropdownField(
                value: selectedStatus,
                items: statuses,
                label: 'Status',
                icon: Icons.toggle_on,
                onChanged: (value) => selectedStatus = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Batal', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newCoach = {
                'name_coach': nameController.text,
                'coach_department': selectedDepartment,
                'email': emailController.text,
                'nohp': phoneController.text,
                'status_coach': selectedStatus == 'Aktif' ? 1 : 0,
                'license': selectedLicense,
                'experience': experienceController.text,
                'achievements': achievementsController.text,
                'years_coach': int.tryParse(yearsCoachController.text),
              };

              if (coach == null) {
                addCoach(newCoach);
              } else {
                editCoach(coach['id_coach'], newCoach);
              }

              Navigator.pop(context);
            },
            icon: Icon(coach == null ? Icons.add_circle : Icons.save),
            label: Text(coach == null ? 'Tambah' : 'Simpan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4865),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87), // Added text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87), // Added label color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon:
            Icon(icon, color: const Color(0xFF2B4865)), // Added icon color
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          // Added border color
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          // Added focused border color
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B4865)),
        ),
      ),
    );
  }

  Widget buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(color: Colors.black87), // Added text color
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87), // Added label color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon:
            Icon(icon, color: const Color(0xFF2B4865)), // Added icon color
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          // Added border color
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          // Added focused border color
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B4865)),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item,
              style: const TextStyle(
                  color: Colors.black87)), // Added item text color
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white, // Added dropdown background color
    );
  }

  List<dynamic> getFilteredCoaches() {
    return coaches.where((coach) {
      final nameMatch = coach['name_coach']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final departmentMatch = filterDepartment == 'Semua' ||
          coach['coach_department'] == filterDepartment;
      return nameMatch && departmentMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCoaches = getFilteredCoaches();
    final departments = [
      'Semua',
      ...coaches.map((c) => c['coach_department'].toString()).toSet().toList()
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2B4865),
              Color(0xFF256D85),
              Color(0xFF8FE3CF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              buildHeader(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      buildSearchBar(),
                      buildDepartmentFilter(departments),
                      const SizedBox(height: 16),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredCoaches.isEmpty
                                ? buildEmptyState()
                                : buildCoachesList(filteredCoaches),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCoachDialog(),
        backgroundColor: const Color(0xFF2B4865),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelatih'),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIGER SOCCER SCHOOL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Manajemen Pelatih',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      style: const TextStyle(color: Colors.black87), // Added text color
      decoration: InputDecoration(
        hintText: 'Cari pelatih...',
        hintStyle: TextStyle(color: Colors.grey[600]), // Added hint color
        prefixIcon:
            Icon(Icons.search, color: Colors.grey[600]), // Added icon color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          // Added border color
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          // Added focused border color
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B4865)),
        ),
      ),
    );
  }

  Widget buildDepartmentFilter(List<String> departments) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final department = departments[index];
          final isSelected = filterDepartment == department;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                department,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black87, // Added text colors
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => filterDepartment = department);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF2B4865),
            ),
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data pelatih',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCoachesList(List<dynamic> filteredCoaches) {
    return ListView.builder(
      itemCount: filteredCoaches.length,
      itemBuilder: (context, index) {
        final coach = filteredCoaches[index];
        return buildCoachCard(coach);
      },
    );
  }

  Widget buildCoachCard(dynamic coach) {
    // Debug untuk melihat data foto yang diterima
    print('Photo URL: ${coach['photo']}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8FE3CF).withOpacity(0.2),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[200],
          backgroundImage: coach['photo'] != null &&
                  coach['photo'].toString().isNotEmpty
              ? NetworkImage(
                  'http://hayy.my.id/uploads/${coach['photo']}') // URL diperbarui
              : null,
          child: (coach['photo'] == null || coach['photo'].toString().isEmpty)
              ? Text(
                  coach['name_coach'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFF2B4865),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          coach['name_coach'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B4865),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.sports_soccer,
                    size: 16, color: Color(0xFF256D85)),
                const SizedBox(width: 8),
                Text(
                  coach['coach_department'],
                  style: const TextStyle(
                      color: Colors.black87), // Added text color
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(Icons.card_membership, 'Lisensi',
                    coach['license'] ?? 'Belum ada'),
                buildInfoRow(Icons.email, 'Email', coach['email']),
                buildInfoRow(Icons.phone, 'Telepon', coach['nohp']),
                buildInfoRow(Icons.work_history, 'Pengalaman',
                    coach['experience'] ?? 'Belum ada'),
                buildInfoRow(Icons.emoji_events, 'Prestasi',
                    coach['achievements'] ?? 'Belum ada'),
                buildInfoRow(Icons.timer, 'Umur Pelatih',
                    '${coach['years_coach'] ?? 0} tahun'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showCoachDialog(coach: coach),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showDeleteConfirmation(coach),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF256D85)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Added text color
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87), // Added text color
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(dynamic coach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi',
          style: TextStyle(color: Colors.black87), // Added text color
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pelatih ini?',
          style: TextStyle(color: Colors.black87), // Added text color
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteCoach(coach['id_coach']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
