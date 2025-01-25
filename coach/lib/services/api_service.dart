import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/assessment.dart';
import '../models/assessment_setting.dart';
import '../models/coach.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import '../models/student.dart';
import '../models/aspect_sub.dart';
import 'package:dio/dio.dart';
import '../models/schedule.dart';
import '../models/aspect.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL untuk Express.js yang berjalan di port 3000
  final String baseUrl = 'http://localhost:3000/api';

  String? token;
  static Map<String, dynamic>? _coachData;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // Login
  Future<Map<String, dynamic>> login(String email, String nohp) async {
    try {
      print('=== LOGIN ATTEMPT ===');
      print('Email: $email');
      print('NoHP: $nohp');
      
      final response = await http.post(
        Uri.parse('$baseUrl/coach/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'nohp': nohp,
        }),
      );

      print('=== SERVER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Response body kosong');
        }

        final Map<String, dynamic> data;
        try {
          data = json.decode(response.body) as Map<String, dynamic>;
          print('Parsed Data: $data');
        } catch (e) {
          print('JSON Parse Error: $e');
          throw Exception('Format response tidak valid: ${response.body}');
        }
        
        if (data['status'] == 'success' && data['token'] != null) {
          token = data['token'];
          _dio.options.headers['Authorization'] = 'Bearer $token';
          return data;
        } else {
          print('Invalid Response Format: $data');
          throw Exception(data['message'] ?? 'Format response tidak valid');
        }
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = {'message': 'Terjadi kesalahan pada server'};
        }
        throw Exception(errorData['message'] ?? 'Login gagal');
      }
    } catch (e) {
      print('=== LOGIN ERROR ===');
      print(e.toString());
      throw Exception('Gagal melakukan login: ${e.toString()}');
    }
  }

  // Aspect
  Future<List<Aspect>> getAspects() async {
    try {
      print('=== FETCHING ASPECTS ===');
      final response = await _dio.get('/aspect');
      print('Aspect Response: ${response.data}');
      
      if (response.statusCode == 200) {
        // Handle nested data structure
        final List<dynamic> data = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
            
        print('Processing aspect data: $data');
        
        return data.map((json) {
          try {
            return Aspect.fromJson(json);
          } catch (e) {
            print('Error parsing individual aspect: $e');
            print('Problematic aspect JSON: $json');
            return null;
          }
        }).where((aspect) => aspect != null).cast<Aspect>().toList();
      } else {
        throw Exception('Failed to load aspects');
      }
    } catch (e) {
      print('Error getting aspects: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : ''}');
      throw Exception('Failed to load aspects: $e');
    }
  }

  Future<List<AspectSub>> getAspectSubs() async {
    try {
      print('=== FETCHING ASPECT SUBS ===');
      final response = await _dio.get('/aspect_sub');
      print('AspectSub Response: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => AspectSub.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load aspect subs');
      }
    } catch (e) {
      print('Error in getAspectSubs: $e');
      throw Exception('Failed to load aspect subs: $e');
    }
  }

  // Assessment
Future<List<Assessment>> getAssessments() async {
  try {
    print('=== FETCHING ASSESSMENTS ===');
    final response = await _dio.get('/coach/assessment');
    print('Raw Assessment Response: ${response.data}');

    if (response.statusCode == 200) {
      // Ambil data dari respons JSON
      final List<dynamic> assessmentData = response.data;
      print('Processing ${assessmentData.length} assessments');

      return assessmentData.map((json) {
        try {
          return Assessment(
            id: json['id_assessment'] as int,
            yearAcademic: json['year_academic'] as String,
            yearAssessment: json['year_assessment'] as String,
            regIdStudent: json['reg_id_student'] as int,
            idAspectSub: json['id_aspect_sub'] as int,
            idCoach: json['id_coach'] as int,
            point: json['point'] as int,
            ket: json['ket'] as String,
            dateAssessment: DateTime.parse(json['date_assessment'] as String),
            student: Student(
              regIdStudent: json['reg_id_student'] as int,
              name: json['student_name'] as String,
              idStudent: '', // Kosong karena tidak disediakan
              dateBirth: DateTime.now(), // Kosong karena tidak disediakan
              gender: '', // Kosong karena tidak disediakan
              email: '', // Kosong karena tidak disediakan
              nohp: '', // Kosong karena tidak disediakan
              registrationDate: DateTime.now(), // Kosong karena tidak disediakan
              status: null, // Kosong karena tidak disediakan
            ),
            aspectSub: AspectSub(
              idAspectSub: json['id_aspect_sub'] as int,
              idAspect: json['id_aspect'] as int,
              nameAspectSub: json['name_aspect_sub'] as String,
              ketAspectSub: json['ket_aspect_sub'] as String,
            ),
          );
        } catch (e) {
          print('Error processing assessment: $e');
          print('Problematic JSON: $json');
          throw Exception('Failed to parse assessment: $e');
        }
      }).toList();
    } else {
      throw Exception('Failed to load assessments');
    }
  } catch (e) {
    print('Error in getAssessments: $e');
    throw Exception('Error: $e');
  }
}

  Future<Assessment> createAssessment(Assessment assessment) async {
    try {
      final response = await _dio.post(
        '/coach/assessment',
        data: assessment.toJson(),
      );
      return Assessment.fromJson(response.data);
    } catch (e) {
      throw 'Gagal membuat assessment: $e';
    }
  }

  // Update Assessment
Future<Assessment> updateAssessment(Assessment assessment) async {
  try {
    final response = await _dio.put(
      '/coach/assessment/${assessment.id}',
      data: assessment.toJson(),
    );

    if (response.statusCode == 200) {
      final json = response.data;
      return Assessment.fromJson(json);
    } else {
      throw Exception('Failed to update assessment');
    }
  } catch (e) {
    throw Exception('Error updating assessment: $e');
  }
}

  Future<void> deleteAssessment(int id) async {
    try {
      print('Deleting assessment with ID: $id');
      await _dio.delete('/coach/assessment/$id');  // Sesuaikan dengan route di server.js
    } catch (e) {
      print('Error deleting assessment: $e');
      throw 'Gagal menghapus assessment: $e';
    }
  }

  // Assessment Setting
  Future<List<AssessmentSetting>> getAssessmentSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assessment_setting'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => AssessmentSetting.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data assessment setting');
    }
  }

  Future<AssessmentSetting> createAssessmentSetting(AssessmentSetting setting) async {
    try {
      print('Creating assessment setting: ${setting.toJson()}');
      final response = await _dio.post(
        '/coach/assessment_setting',
        data: setting.toJson(),
      );
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return AssessmentSetting.fromJson(response.data);
      } else {
        throw 'Gagal membuat pengaturan: ${response.statusCode}';
      }
    } catch (e) {
      print('Error creating assessment setting: $e');
      if (e.toString().contains('DioException')) {
        return setting;
      }
      throw 'Gagal membuat pengaturan: $e';
    }
  }

  Future<AssessmentSetting> updateAssessmentSetting(int id, AssessmentSetting setting) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assessment_setting/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(setting.toJson()),
    );

    if (response.statusCode == 200) {
      return AssessmentSetting.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengupdate assessment setting');
    }
  }

  Future<void> deleteAssessmentSetting(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assessment_setting/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus assessment setting');
    }
  }

  // Information, Schedule, Point Rate
  Future<List<dynamic>> getInformation() async {
    final response = await http.get(
      Uri.parse('$baseUrl/information'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil informasi');
    }
  }

  Future<List<Schedule>> getSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/schedule'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Schedule.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil jadwal');
    }
  }

  Future<List<dynamic>> getPointRate() async {
    final response = await http.get(
      Uri.parse('$baseUrl/point_rate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil point rate');
    }
  }

  // Coach Update
  Future<Coach> updateCoach(int id, Coach coach, {dynamic photoFile}) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/coach/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      
      // Log untuk debugging
      print('Mengirim update coach dengan photo: $photoFile');

      // Update fields sesuai model baru
      if (coach.nameCoach != null) request.fields['name_coach'] = coach.nameCoach!;
      if (coach.coachDepartment != null) request.fields['coach_department'] = coach.coachDepartment!;
      if (coach.yearsCoach != null) request.fields['years_coach'] = coach.yearsCoach!;
      if (coach.email != null) request.fields['email'] = coach.email!;
      if (coach.nohp != null) request.fields['nohp'] = coach.nohp!;
      if (coach.statusCoach != null) request.fields['status_coach'] = coach.statusCoach.toString();
      if (coach.license != null) request.fields['license'] = coach.license!;
      if (coach.experience != null) request.fields['experience'] = coach.experience!;
      if (coach.achievements != null) request.fields['achievements'] = coach.achievements!;

      if (photoFile != null && photoFile is Uint8List) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            photoFile,
            filename: 'photo.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        _coachData = data['data'];
        return Coach.fromJson(data['data']);
      } else {
        throw Exception('Gagal mengupdate profil: ${responseData}');
      }
    } catch (e) {
      throw Exception('Gagal mengupdate profil: $e');
    }
  }

  // Coach APIs
  Future<Coach> getCoachProfile() async {
    try {
      if (token == null) {
        throw Exception('Token tidak ditemukan, silahkan login ulang');
      }

      print('Accessing URL: $baseUrl/coach/profile'); // Debug URL
      print('Using token: $token'); // Debug token

      final response = await http.get(
        Uri.parse('$baseUrl/coach/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _coachData = data['data'];
        return Coach.fromJson(_coachData!);
      } else {
        throw Exception('Gagal mengambil data profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting coach profile: $e');
      throw Exception('Gagal mengambil data coach: $e');
    }
  }

  // Tambahkan fungsi baru untuk mengambil semua data coach
  Future<List<Coach>> getAllCoaches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coach/coaches'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Coach.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data coach');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Student>> getStudents() async {
    try {
      print('=== FETCHING STUDENTS ===');
      final response = await _dio.get('/register_student');
      print('Student Response Raw: ${response.data}');
      
      if (response.statusCode == 200) {
        // Handle both direct array or nested data structure
        final List<dynamic> data = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
            
        print('Processing student data: $data');
        
        return data.map((json) {
          try {
            return Student.fromJson(json);
          } catch (e) {
            print('Error parsing individual student: $e');
            print('Problematic student JSON: $json');
            return null;
          }
        }).where((student) => student != null).cast<Student>().toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error in getStudents: $e');
      print('Stack trace: ${e is Error ? e.stackTrace : ''}');
      throw Exception('Failed to load students: $e');
    }
  }

  void setToken(String newToken) {
    token = newToken;
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
    print('Token set: $newToken'); // Debug token setting
  }
}