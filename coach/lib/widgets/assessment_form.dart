import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/assessment.dart';
import '../models/student.dart';
import '../models/aspect_sub.dart';

class AssessmentForm extends StatefulWidget {
  final Assessment? assessment;
  final Function(Assessment) onSubmit;

  const AssessmentForm({
    Key? key,
    this.assessment,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AssessmentForm> createState() => _AssessmentFormState();
}

class _AssessmentFormState extends State<AssessmentForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  List<Student> _students = [];
  List<AspectSub> _aspectSubs = [];
  DateTime _selectedDate = DateTime.now();
  
  Student? _selectedStudent;
  AspectSub? _selectedAspectSub;
  
  late TextEditingController _yearAcademicController;
  late TextEditingController _yearAssessmentController;
  late TextEditingController _pointController;
  late TextEditingController _ketController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadFormData();
  }

  void _initializeControllers() {
    _yearAcademicController = TextEditingController(text: widget.assessment?.yearAcademic);
    _yearAssessmentController = TextEditingController(text: widget.assessment?.yearAssessment);
    _pointController = TextEditingController(text: widget.assessment?.point.toString());
    _ketController = TextEditingController(text: widget.assessment?.ket);
    
    if (widget.assessment != null) {
      _selectedDate = widget.assessment!.dateAssessment;
    }
  }

  Future<void> _loadFormData() async {
    try {
      final students = await _apiService.getStudents();
      final aspectSubs = await _apiService.getAspectSubs();
      
      setState(() {
        _students = students;
        _aspectSubs = aspectSubs;
        
        if (widget.assessment != null) {
          _selectedStudent = _students.firstWhere(
            (s) => s.regIdStudent == widget.assessment!.regIdStudent
          );
          _selectedAspectSub = _aspectSubs.firstWhere(
            (a) => a.idAspectSub == widget.assessment!.idAspectSub
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Student>(
            value: _selectedStudent,
            decoration: const InputDecoration(labelText: 'Siswa'),
            items: _students.map((student) {
              return DropdownMenuItem<Student>(
                value: student,
                child: Text(student.name ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedStudent = value);
            },
            validator: (value) {
              if (value == null) return 'Pilih siswa';
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<AspectSub>(
            value: _selectedAspectSub,
            decoration: const InputDecoration(labelText: 'Aspek Penilaian'),
            items: _aspectSubs.map((aspect) {
              return DropdownMenuItem<AspectSub>(
                value: aspect,
                child: Text(aspect.nameAspectSub),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedAspectSub = value);
            },
            validator: (value) {
              if (value == null) return 'Pilih aspek penilaian';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _yearAcademicController,
            decoration: const InputDecoration(
              labelText: 'Tahun Akademik',
              hintText: 'Contoh: 2023/2024',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan tahun akademik';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _yearAssessmentController,
            decoration: const InputDecoration(
              labelText: 'Tahun Penilaian',
              hintText: 'Contoh: 2023',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan tahun penilaian';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _pointController,
            decoration: const InputDecoration(labelText: 'Nilai'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan nilai';
              }
              if (int.tryParse(value) == null) {
                return 'Nilai harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _ketController,
            decoration: const InputDecoration(labelText: 'Keterangan'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          ListTile(
            title: const Text('Tanggal Penilaian'),
            subtitle: Text(_formatDate(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.assessment == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudent == null || _selectedAspectSub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siswa dan aspek penilaian')),
      );
      return;
    }

    final assessment = Assessment(
      id: widget.assessment?.id,
      yearAcademic: _yearAcademicController.text,
      yearAssessment: _yearAssessmentController.text,
      regIdStudent: _selectedStudent!.regIdStudent!,
      idAspectSub: _selectedAspectSub!.idAspectSub!,
      idCoach: widget.assessment?.idCoach ?? 1,
      point: int.parse(_pointController.text),
      ket: _ketController.text,
      dateAssessment: _selectedDate,
      student: _selectedStudent,
      aspectSub: _selectedAspectSub,
    );

    widget.onSubmit(assessment);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _yearAcademicController.dispose();
    _yearAssessmentController.dispose();
    _pointController.dispose();
    _ketController.dispose();
    super.dispose();
  }
} 