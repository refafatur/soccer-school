import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assessment.dart';
import '../models/student.dart';
import '../models/aspect_sub.dart';
import '../styles/app_theme.dart';

class AssessmentCard extends StatelessWidget {
  final Assessment assessment;
  final Student? student;
  final AspectSub? aspectSub;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AssessmentCard({
    required this.assessment,
    this.student,
    this.aspectSub,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  Color _getPointColor(int point) {
    if (point >= 90) return Colors.green.withOpacity(0.8);
    if (point >= 75) return AppTheme.tigerOrange.withOpacity(0.8);
    return Colors.red.withOpacity(0.8);
  }

  String _getPointLabel(int point) {
    if (point >= 90) return 'Sangat Baik';
    if (point >= 75) return 'Baik';
    return 'Perlu Perbaikan';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.tigerOrange.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.student?.name ?? 'Nama tidak tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aspek: ${assessment.aspectSub?.nameAspectSub ?? 'Tidak tersedia'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: AppTheme.tigerOrange),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahun Akademik: ${assessment.yearAcademic}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Tahun Penilaian: ${assessment.yearAssessment}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (assessment.ket.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Keterangan: ${assessment.ket}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPointColor(assessment.point),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${assessment.point}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getPointLabel(assessment.point),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
}