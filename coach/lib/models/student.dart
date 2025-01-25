class Student {
  final int? regIdStudent;
  final String? idStudent;
  final String? name;
  final DateTime? dateBirth;
  final String? gender;
  final String? photo;
  final String? email;
  final String? nohp;
  final DateTime? registrationDate;
  final int? status;

  Student({
    this.regIdStudent,
    this.idStudent,
    this.name,
    this.dateBirth,
    this.gender,
    this.photo,
    this.email,
    this.nohp,
    this.registrationDate,
    this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    try {
      print('Processing student JSON: $json');
      
      // Helper function for safe integer parsing
      int? parseIntSafely(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) {
          // Remove any non-numeric characters and parse
          final cleanString = value.replaceAll(RegExp(r'[^0-9-]'), '');
          return cleanString.isEmpty ? null : int.tryParse(cleanString);
        }
        return null;
      }

      // Helper function for safe DateTime parsing
      DateTime? parseDateSafely(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) {
          try {
            // Handle different date formats
            if (value.contains('T')) {
              return DateTime.parse(value);
            } else {
              // Add time component if missing
              return DateTime.parse('${value}T00:00:00.000Z');
            }
          } catch (e) {
            print('Date parse error: $e for value: $value');
            return null;
          }
        }
        return null;
      }

      final student = Student(
        regIdStudent: parseIntSafely(json['reg_id_student']),
        idStudent: json['id_student']?.toString(),
        name: json['name']?.toString(),
        dateBirth: parseDateSafely(json['date_birth']),
        gender: json['gender']?.toString(),
        photo: json['photo']?.toString(),
        email: json['email']?.toString(),
        nohp: json['nohp']?.toString(),
        registrationDate: parseDateSafely(json['registration_date']),
        status: parseIntSafely(json['status']),
      );

      print('Successfully parsed student: ${student.name}');
      return student;
      
    } catch (e) {
      print('Error parsing Student: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'reg_id_student': regIdStudent,
    'id_student': idStudent,
    'name': name,
    'date_birth': dateBirth?.toIso8601String(),
    'gender': gender,
    'photo': photo,
    'email': email,
    'nohp': nohp,
    'registration_date': registrationDate?.toIso8601String(),
    'status': status,
  };
}