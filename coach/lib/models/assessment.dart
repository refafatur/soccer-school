import 'student.dart';
import 'aspect_sub.dart';
import 'coach.dart';

class Assessment {
  final int? id;
  final String yearAcademic;
  final String yearAssessment;
  final int regIdStudent;
  final int idAspectSub;
  final int idCoach;
  final int point;
  final String ket;
  final DateTime dateAssessment;
  
  Student? student;
  AspectSub? aspectSub;
  Coach? coach;

  Assessment({
    this.id,
    required this.yearAcademic,
    required this.yearAssessment,
    required this.regIdStudent,
    required this.idAspectSub,
    required this.idCoach,
    required this.point,
    required this.ket,
    required this.dateAssessment,
    this.student,
    this.aspectSub,
    this.coach,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    try {
      print('Processing Assessment JSON: $json');
      
      // If the response contains a nested data object, use that instead
      final Map<String, dynamic> assessmentData = 
          json.containsKey('data') ? json['data'] : json;

      return Assessment(
        id: assessmentData['id_assessment'] is String 
            ? int.parse(assessmentData['id_assessment']) 
            : assessmentData['id_assessment'],
        yearAcademic: assessmentData['year_academic']?.toString() ?? '',
        yearAssessment: assessmentData['year_assessment']?.toString() ?? '',
        regIdStudent: assessmentData['reg_id_student'] is String 
            ? int.parse(assessmentData['reg_id_student']) 
            : assessmentData['reg_id_student'],
        idAspectSub: assessmentData['id_aspect_sub'] is String 
            ? int.parse(assessmentData['id_aspect_sub']) 
            : assessmentData['id_aspect_sub'],
        idCoach: assessmentData['id_coach'] is String 
            ? int.parse(assessmentData['id_coach']) 
            : assessmentData['id_coach'],
        point: assessmentData['point'] is String 
            ? int.parse(assessmentData['point']) 
            : assessmentData['point'],
        ket: assessmentData['ket']?.toString() ?? '',
        dateAssessment: assessmentData['date_assessment'] != null 
            ? DateTime.parse(assessmentData['date_assessment']) 
            : DateTime.now(),
        student: json['student'],
        aspectSub: json['aspect_sub'],
      );
    } catch (e) {
      print('Error parsing Assessment: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id_assessment': id,
    'year_academic': yearAcademic,
    'year_assessment': yearAssessment,
    'reg_id_student': regIdStudent,
    'id_aspect_sub': idAspectSub,
    'id_coach': idCoach,
    'point': point,
    'ket': ket,
    'date_assessment': dateAssessment.toIso8601String(),
  };
}