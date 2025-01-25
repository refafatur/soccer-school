import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/coach.dart';
import '../widgets/tiger_stripe_painter.dart';
import '../theme/app_theme.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Coach? _coachInfo;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _loadCoachInfo();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachInfo() async {
    try {
      final coach = await _apiService.getCoachProfile();
      setState(() {
        _coachInfo = coach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditScreen(coach: _coachInfo!),
      ),
    ).then((_) => _loadCoachInfo());
  }

  Widget _buildProfileAvatar() {
    return Hero(
      tag: 'profile',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppTheme.tigerOrange,
              AppTheme.goldAccent,
            ],
          ),
          border: Border.all(
            color: AppTheme.tigerOrange.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: _coachInfo?.photo != null
            ? ClipOval(
                child: Image.network(
                  'http://localhost:3000${_coachInfo!.photo!}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    );
                  },
                ),
              )
            : Icon(
                Icons.person,
                size: 50,
                color: Colors.white.withOpacity(0.8),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tigerBlack,
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tigerOrange),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCoachInfo,
              color: AppTheme.tigerOrange,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 80,
                  bottom: 16,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppTheme.tigerOrange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileAvatar(),
                            const SizedBox(height: 16),
                            Text(
                              _coachInfo?.nameCoach ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _coachInfo?.coachDepartment ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoSection(
                              'Informasi Pribadi',
                              [
                                _buildInfoItem('Email', _coachInfo?.email ?? '', Icons.email),
                                _buildInfoItem('No. HP', _coachInfo?.nohp ?? '', Icons.phone),
                                _buildInfoItem('Tahun Pengalaman', _coachInfo?.yearsCoach ?? '', Icons.calendar_today),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoSection(
                              'Informasi Profesional',
                              [
                                _buildInfoItem('Lisensi', _coachInfo?.license ?? '', Icons.card_membership),
                                _buildInfoItem('Pengalaman', _coachInfo?.experience ?? '', Icons.work),
                                _buildInfoItem('Prestasi', _coachInfo?.achievements ?? '', Icons.emoji_events),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.tigerOrange,
                                    AppTheme.goldAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.tigerOrange.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _navigateToEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'EDIT PROFIL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.tigerOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tigerOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.goldAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  final Coach coach;

  const ProfileEditScreen({super.key, required this.coach});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ApiService _apiService = ApiService();
  Uint8List? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _yearsCoachController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.coach.nameCoach ?? '';
    _emailController.text = widget.coach.email ?? '';
    _phoneController.text = widget.coach.nohp ?? '';
    _yearsCoachController.text = widget.coach.yearsCoach ?? '';
    _licenseController.text = widget.coach.license ?? '';
    _experienceController.text = widget.coach.experience ?? '';
    _achievementsController.text = widget.coach.achievements ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _yearsCoachController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedCoach = Coach(
        idCoach: widget.coach.idCoach,
        nameCoach: _nameController.text,
        coachDepartment: widget.coach.coachDepartment,
        yearsCoach: _yearsCoachController.text,
        email: _emailController.text,
        nohp: _phoneController.text,
        statusCoach: widget.coach.statusCoach,
        license: _licenseController.text,
        experience: _experienceController.text,
        achievements: _achievementsController.text,
        photo: widget.coach.photo,
      );

      await _apiService.updateCoach(
        widget.coach.idCoach!,
        updatedCoach,
        photoFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tigerOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.goldAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.tigerOrange),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.goldAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'profile',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.tigerOrange,
                    AppTheme.goldAccent,
                  ],
                ),
                border: Border.all(
                  color: AppTheme.tigerOrange.withOpacity(0.3),
                  width: 2,
                ),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: MemoryImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : widget.coach.photo != null
                        ? DecorationImage(
                            image: NetworkImage('http://localhost:3000${widget.coach.photo!}'),
                            fit: BoxFit.cover,
                          )
                        : null,
              ),
              child: (_selectedImage == null && widget.coach.photo == null)
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    )
                  : null,
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tigerBlack,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppTheme.tigerBlack,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildEditableAvatar(),
                  const SizedBox(height: 24),
                  _buildTextField(_nameController, 'Nama', Icons.person),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  _buildTextField(_phoneController, 'No. HP', Icons.phone),
                  _buildTextField(_yearsCoachController, 'Tahun Pengalaman', Icons.calendar_today),
                  _buildTextField(_licenseController, 'Lisensi', Icons.card_membership),
                  _buildTextField(_experienceController, 'Pengalaman', Icons.work, maxLines: 3),
                  _buildTextField(_achievementsController, 'Prestasi', Icons.emoji_events, maxLines: 3),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.tigerOrange,
                          AppTheme.goldAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'SIMPAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.tigerBlack,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}