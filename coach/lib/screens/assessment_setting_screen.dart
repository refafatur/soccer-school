import 'package:flutter/material.dart';
import '../models/assessment_setting.dart';
import '../models/aspect_sub.dart';
import '../services/api_service.dart';
import '../styles/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({super.key});

  @override
  State<AssessmentSettingScreen> createState() => _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  final ApiService _apiService = ApiService();
  List<AssessmentSetting> _settings = [];
  bool _isLoading = true;
  bool _mounted = true;
  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;
    
    try {
      final data = await _apiService.getAssessmentSettings();
      if (_mounted) {
        setState(() {
          _settings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tigerBlack,
      body: Column(
        children: [
          // Header dengan arrow back
          Container(
            padding: const EdgeInsets.only(top: 32, bottom: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppTheme.tigerOrange,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Pengaturan Penilaian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Konten assessment setting
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.tigerOrange))
                : RefreshIndicator(
                    onRefresh: _loadSettings,
                    color: AppTheme.tigerOrange,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _settings.length,
                      itemBuilder: (context, index) {
                        final setting = _settings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppTheme.tigerOrange.withOpacity(0.5),
                            ),
                          ),
                          color: Colors.white.withOpacity(0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tahun: ${setting.yearAcademic}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.tigerOrange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Bobot: ${setting.bobot}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tahun Assessment: ${setting.yearAssessment}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  'ID Aspect: ${setting.idAspectSub}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppTheme.tigerOrange,
                                      ),
                                      onPressed: () => _showSettingDialog(setting),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(setting),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSettingDialog(null),
        backgroundColor: AppTheme.tigerOrange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showSettingDialog(AssessmentSetting? setting) async {
    final yearAcademicController = TextEditingController(text: setting?.yearAcademic);
    final yearAssessmentController = TextEditingController(text: setting?.yearAssessment);
    final bobotController = TextEditingController(text: setting?.bobot.toString());
    AspectSub? selectedAspect;
    List<AspectSub> aspectSubs = [];

    // Load aspect subs
    try {
      aspectSubs = await _apiService.getAspectSubs();
    } catch (e) {
      print('Error loading aspects: $e');
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.tigerBlack,
          title: Text(
            setting == null ? 'Tambah Pengaturan' : 'Edit Pengaturan',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tahun Akademik
                TextField(
                  controller: yearAcademicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tahun Akademik',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tahun Assessment
                TextField(
                  controller: yearAssessmentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tahun Assessment',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Aspect Sub Dropdown
                DropdownButtonFormField<AspectSub>(
                  value: selectedAspect,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                  items: aspectSubs.map((aspect) {
                    return DropdownMenuItem(
                      value: aspect,
                      child: Text(
                        aspect.nameAspectSub,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedAspect = value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih Aspek',
                    labelStyle: const TextStyle(color: Colors.white70),
                    fillColor: Colors.white.withOpacity(0.1),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bobot
                TextField(
                  controller: bobotController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Bobot',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.tigerOrange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: AppTheme.tigerOrange),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tigerOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (selectedAspect == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pilih aspek terlebih dahulu')),
                  );
                  return;
                }

                final coach = Provider.of<AuthProvider>(context, listen: false).coach;
                
                try {
                  final newSetting = AssessmentSetting(
                    idAssessmentSetting: setting?.idAssessmentSetting,
                    yearAcademic: yearAcademicController.text,
                    yearAssessment: yearAssessmentController.text,
                    idCoach: coach!.idCoach!,
                    idAspectSub: selectedAspect!.idAspectSub!,
                    bobot: int.parse(bobotController.text),
                  );

                  if (setting == null) {
                    await _apiService.createAssessmentSetting(newSetting);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil menambahkan pengaturan')),
                    );
                  } else {
                    await _apiService.updateAssessmentSetting(newSetting.idAssessmentSetting!, newSetting);
                  }

                  Navigator.pop(context);
                  _loadSettings();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(AssessmentSetting setting) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.tigerBlack,
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengaturan ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: AppTheme.tigerOrange),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.deleteAssessmentSetting(setting.idAssessmentSetting!);
                Navigator.pop(context);
                _loadSettings();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}