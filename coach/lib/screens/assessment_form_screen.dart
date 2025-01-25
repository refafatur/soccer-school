import 'package:flutter/material.dart';
import '../models/assessment.dart';
import '../models/student.dart';
import '../models/aspect_sub.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';

class AssessmentFormScreen extends StatefulWidget {
  final Assessment? assessment; // Null untuk add, berisi data untuk edit
  final Function(Assessment) onSubmit;

  const AssessmentFormScreen({
    Key? key, 
    this.assessment,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Student> _students = [];
  List<AspectSub> _aspectSubs = [];
  
  // Form controllers
  late TextEditingController _yearAcademicController;
  late TextEditingController _yearAssessmentController;
  late TextEditingController _pointController;
  late TextEditingController _ketController;
  
  Student? _selectedStudent;
  AspectSub? _selectedAspectSub;
  DateTime _selectedDate = DateTime.now();

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
    setState(() => _isLoading = true);
    try {
      final students = await ApiService().getStudents();
      final aspectSubs = await ApiService().getAspectSubs();
      
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
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _submitForm() {
    final coach = Provider.of<AuthProvider>(context, listen: false).coach;
    if (coach == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data coach tidak ditemukan')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedStudent == null || _selectedAspectSub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih siswa dan aspek penilaian')),
      );
      return;
    }

    try {
      print('Debug values before creating assessment:');
      print('Student ID: ${_selectedStudent?.regIdStudent}');
      print('Aspect Sub ID: ${_selectedAspectSub?.idAspectSub}');
      print('Point: ${_pointController.text}');
      
      final assessment = Assessment(
        id: widget.assessment?.id,
        yearAcademic: _yearAcademicController.text,
        yearAssessment: _yearAssessmentController.text,
        regIdStudent: _selectedStudent!.regIdStudent!,
        idAspectSub: _selectedAspectSub!.idAspectSub!,
        idCoach: coach.idCoach!,
        point: int.parse(_pointController.text),
        ket: _ketController.text,
        dateAssessment: _selectedDate,
      );

      widget.onSubmit(assessment);
    } catch (e) {
      print('Error creating assessment object: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.tigerBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.assessment == null ? 'Add Assessment' : 'Edit Assessment',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.tigerOrange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.tigerOrange),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown Student
                    DropdownButtonFormField<Student>(
                      value: _selectedStudent,
                      decoration: InputDecoration(
                        labelText: 'Select Student',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _students.map((student) {
                        return DropdownMenuItem(
                          value: student,
                          child: Text(student.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStudent = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a student';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Aspect Sub
                    DropdownButtonFormField<AspectSub>(
                      value: _selectedAspectSub,
                      decoration: InputDecoration(
                        labelText: 'Select Aspect',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _aspectSubs.map((aspect) {
                        return DropdownMenuItem(
                          value: aspect,
                          child: Text(aspect.nameAspectSub ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAspectSub = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select an aspect';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Year Academic
                    TextFormField(
                      controller: _yearAcademicController,
                      decoration: InputDecoration(
                        labelText: 'Academic Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter academic year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Year Assessment
                    TextFormField(
                      controller: _yearAssessmentController,
                      decoration: InputDecoration(
                        labelText: 'Assessment Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter assessment year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Keterangan
                    TextFormField(
                      controller: _ketController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Point
                    TextFormField(
                      controller: _pointController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Point',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter point';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    ListTile(
                      title: const Text('Assessment Date'),
                      subtitle: Text(
                        _selectedDate.toString().split(' ')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Icon(
                        Icons.calendar_today,
                        color: AppTheme.tigerOrange,
                      ),
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
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tigerOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          widget.assessment == null ? 'Add Assessment' : 'Update Assessment',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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