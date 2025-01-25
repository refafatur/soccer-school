import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/assessment.dart';
import '../models/student.dart';
import '../styles/app_theme.dart';
import 'assessment_setting_screen.dart';
import 'assessment_form_screen.dart';
import '../models/aspect_sub.dart';
import '../widgets/assessment_card.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final ApiService _apiService = ApiService();
  List<Assessment> _assessments = [];
  List<Student> _students = [];
  List<AspectSub> _aspects = [];
  bool _isLoading = true;
  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color goldAccent = const Color(0xFFFFD700);
  String? _selectedYear;
  String? _selectedAspect;
  List<Assessment> _filteredAssessments = [];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAssessments(),
        _loadStudents(),
        _loadAspects(),
      ]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    try {
      print('Mulai mengambil data siswa');
      final students = await _apiService.getStudents();
      print('Jumlah siswa ditemukan: ${students.length}');
      setState(() {
        _students = students;
      });
    } catch (e) {
      print('Error loading students: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data siswa: $e')),
        );
      }
    }
  }

Future<void> _loadAssessments() async {
  if (!mounted) return;
  setState(() => _isLoading = true);
  try {
    final assessments = await _apiService.getAssessments();
    if (mounted) {
      setState(() {
        _assessments = assessments;
        _filteredAssessments = assessments;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  Future<void> _loadAspects() async {
    try {
      final aspects = await _apiService.getAspectSubs();
      setState(() {
        _aspects = aspects;
      });
    } catch (e) {
      print('Error loading aspects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data aspek: $e')),
        );
      }
    }
  }

  double _calculateAverage() {
    if (_assessments.isEmpty) return 0;
    final total = _assessments.fold(0, (sum, item) => sum + item.point);
    return total / _assessments.length;
  }

  int _getHighestScore() {
    if (_assessments.isEmpty) return 0;
    return _assessments.map((e) => e.point).reduce((a, b) => a > b ? a : b);
  }

  int _getLowestScore() {
    if (_assessments.isEmpty) return 0;
    return _assessments.map((e) => e.point).reduce((a, b) => a < b ? a : b);
  }

  Widget _buildStatCard({
    required String title,
    required dynamic value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (color ?? AppTheme.tigerOrange).withOpacity(0.8),
            (color ?? AppTheme.tigerOrange).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value is double ? value.toStringAsFixed(1) : value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueYears() {
    return _assessments
        .map((e) => e.yearAssessment)
        .toSet()
        .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  List<String> _getUniqueAspects() {
    final aspects = _assessments
        .where((a) => a.aspectSub?.nameAspectSub != null)
        .map((a) => a.aspectSub!.nameAspectSub!)
        .toSet()
        .toList();
    print('Debug - Found aspects: $aspects');
    return aspects..sort();
  }

  void _applyFilters() {
    setState(() {
      _filteredAssessments = _assessments.where((assessment) {
        bool matchYear = _selectedYear == null || 
            assessment.yearAssessment == _selectedYear;
        
        bool matchAspect = _selectedAspect == null || 
            (assessment.aspectSub?.nameAspectSub == _selectedAspect);
        
        print('Debug - Checking assessment:');
        print('Year: ${assessment.yearAssessment} vs $_selectedYear');
        print('Aspect: ${assessment.aspectSub?.nameAspectSub} vs $_selectedAspect');
        
        return matchYear && matchAspect;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tigerBlack,
      body: Column(
        children: [
          // Statistik Cards (seperti sebelumnya)
          if (!_isLoading && _assessments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 48,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Rata-rata',
                      value: _calculateAverage(),
                      icon: Icons.analytics,
                      color: AppTheme.tigerOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Tertinggi',
                      value: _getHighestScore(),
                      icon: Icons.arrow_upward,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Terendah',
                      value: _getLowestScore(),
                      icon: Icons.arrow_downward,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          
          // Filter Section
          if (!_isLoading && _assessments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Tahun', style: TextStyle(color: Colors.white70)),
                          value: _selectedYear,
                          items: _getUniqueYears()
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year, style: TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedYear = value);
                            _applyFilters();
                          },
                          dropdownColor: AppTheme.tigerBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Aspek', style: TextStyle(color: Colors.white70)),
                          value: _selectedAspect,
                          items: _getUniqueAspects()
                              .map((aspect) => DropdownMenuItem(
                                    value: aspect,
                                    child: Text(aspect, style: TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAspect = value);
                            _applyFilters();
                          },
                          dropdownColor: AppTheme.tigerBlack,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedYear != null || _selectedAspect != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.tigerOrange),
                      onPressed: () {
                        setState(() {
                          _selectedYear = null;
                          _selectedAspect = null;
                          _filteredAssessments = _assessments;
                        });
                      },
                    ),
                ],
              ),
            ),

          // List Assessment
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.tigerOrange))
                : RefreshIndicator(
                    onRefresh: _loadAssessments,
                    color: AppTheme.tigerOrange,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredAssessments.length,
                      itemBuilder: (context, index) {
                        final assessment = _filteredAssessments[index];
                        return AssessmentCard(
                          assessment: assessment,
                          student: assessment.student,
                          aspectSub: assessment.aspectSub,
                          onEdit: () => _showAssessmentForm(assessment),
                          onDelete: () => _deleteAssessment(assessment.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssessmentForm(),
        backgroundColor: AppTheme.tigerOrange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Assessment assessment) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.tigerBlack,
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus penilaian ini?',
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
            onPressed: () {
              Navigator.pop(context);
              _deleteAssessment(assessment.id);
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddAssessmentDialog([Assessment? assessment]) async {
    final yearAcademicController = TextEditingController(text: assessment?.yearAcademic);
    final yearAssessmentController = TextEditingController(text: assessment?.yearAssessment);
    final pointController = TextEditingController(text: assessment?.point.toString());
    final ketController = TextEditingController(text: assessment?.ket);
    final studentIdController = TextEditingController(text: assessment?.regIdStudent.toString());
    final aspectSubIdController = TextEditingController(text: assessment?.idAspectSub.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tigerBlack,
        title: Text(
          assessment == null ? 'Tambah Penilaian' : 'Edit Penilaian',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearAcademicController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tahun Akademik',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                ),
              ),
              TextField(
                controller: yearAssessmentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tahun Assessment',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                ),
              ),
              TextField(
                controller: pointController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Point',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ketController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                ),
                maxLines: 3,
              ),
              TextField(
                controller: studentIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ID Siswa',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: aspectSubIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ID Aspek',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: tigerOrange),
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
              style: TextStyle(color: tigerOrange),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newAssessment = Assessment(
                  id: assessment?.id,
                  yearAcademic: yearAcademicController.text,
                  yearAssessment: yearAssessmentController.text,
                  regIdStudent: int.parse(studentIdController.text),
                  idAspectSub: int.parse(aspectSubIdController.text),
                  idCoach: 1, // Sesuaikan dengan ID coach yang sedang login
                  point: int.parse(pointController.text),
                  ket: ketController.text,
                  dateAssessment: DateTime.now(),
                );

                if (assessment == null) {
                  final createdAssessment = await _apiService.createAssessment(newAssessment);
                  setState(() {
                    _assessments.add(createdAssessment);
                  });
                } else {
                  final updatedAssessment = await _apiService.updateAssessment(newAssessment);
                  setState(() {
                    final index = _assessments.indexWhere((a) => a.id == assessment.id);
                    if (index != -1) {
                      _assessments[index] = updatedAssessment;
                    }
                  });
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil menyimpan penilaian')),
                  );
                }
              } catch (e) {
                print('Error in dialog: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(
              'Simpan',
              style: TextStyle(color: tigerOrange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssessment(int? id) async {
    if (id == null) return;
    try {
      await _apiService.deleteAssessment(id);
      setState(() {
        _assessments.removeWhere((a) => a.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menghapus penilaian')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAssessmentForm([Assessment? assessment]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentFormScreen(
          assessment: assessment,
          onSubmit: (assessment) async {
            try {
              if (assessment.id != null) {
                await _apiService.updateAssessment(assessment);
              } else {
                await _apiService.createAssessment(assessment);
              }
              if (mounted) {
                Navigator.pop(context);
                await _loadAssessments();
                _applyFilters();
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        ),
      ),
    );
  }
}
