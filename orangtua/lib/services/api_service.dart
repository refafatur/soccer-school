import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Menggunakan io
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as kIsWeb;

class ApiService {
  final String baseUrl = 'https://hayy.my.id/api';
  final String baseImageUrl = 'https://hayy.my.id';

  Future<Map<String, dynamic>> login(String email, String birthDate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orangtua/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'date_birth': birthDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = data['user'] as Map<String, dynamic>;

        String photoUrl = '';
        if (user['photo'] != null && user['photo'].toString().isNotEmpty) {
          photoUrl = '$baseImageUrl/${user['photo']}';
        }

        return {
          'user': {
            'reg_id_student': user['reg_id_student']?.toString() ?? '',
            'email': user['email']?.toString() ?? '',
            'date_birth': user['date_birth']?.toString() ?? '',
            'name': user['name']?.toString() ?? '',
            'nohp': user['nohp']?.toString() ?? '',
            'photo': photoUrl,
            'registration_date': user['registration_date']?.toString() ?? '',
            'status': user['status']?.toString() ?? '',
          },
          'token': data['token']?.toString() ?? '',
        };
      }
      throw Exception('Login gagal: ${response.body}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getDataByRegIdStudent(
      String regIdStudent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('$baseUrl/orangtua/get_data_orangtua'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'reg_id_student': regIdStudent,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          String photoUrl = '';
          if (data['user']['photo'] != null &&
              data['user']['photo'].toString().isNotEmpty) {
            photoUrl = '$baseImageUrl/${data['user']['photo']}';
          }

          return {
            'status': 'success',
            'data': {
              ...data['user'],
              'photo': photoUrl,
            },
          };
        }
        throw Exception('Data tidak valid');
      }
      throw Exception('Gagal mendapatkan data: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Gagal mendapatkan data pengguna');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInformation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/information'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      throw Exception('Gagal mengambil data informasi: ${response.statusCode}');
    } catch (e) {
      print('Error dalam getInformation: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/schedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'status': 'success',
          'data': data,
        };
      }
      throw Exception('Gagal mengambil data jadwal: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getAssessment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final regIdStudent = prefs.getString('reg_id_student');

      if (token == null) throw Exception('Token tidak ditemukan');
      if (regIdStudent == null)
        throw Exception('reg_id_student tidak ditemukan');

      final response = await http.post(
        Uri.parse('$baseUrl/orangtua/assessment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'reg_id_student': regIdStudent,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'status': 'success',
          'data': data
              .map((item) => {
                    'id_assessment': item['id_assessment'],
                    'year_academic': item['year_academic'],
                    'year_assessment': item['year_assessment'],
                    'reg_id_student': item['reg_id_student'],
                    'id_aspect_sub': item['id_aspect_sub'],
                    'id_coach': item['id_coach'],
                    'point': item['point'],
                    'ket': item['ket'],
                    'date_assessment': item['date_assessment'],
                  })
              .toList(),
        };
      }
      throw Exception(
          'Gagal mengambil data assessment: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getAssessmentSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/assessment_setting'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'data': jsonDecode(response.body),
        };
      }
      throw Exception(
          'Gagal mengambil data assessment settings: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Gagal mengambil data profil: ${response.statusCode}');
    } catch (e) {
      print('Error dalam getProfile: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String regIdStudent, Map<String, dynamic> formData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      // Buat multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/orangtua/profile/$regIdStudent'),
      );

      // Tambahkan headers
      request.headers.addAll({
        'Authorization': token,
        'Accept': 'application/json',
      });

      // Tambahkan fields
      formData.forEach((key, value) {
        if (key != 'photo') {
          request.fields[key] = value.toString();
        }
      });

      // Jika ada foto baru
      if (formData.containsKey('photo') && formData['photo'] != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', formData['photo']),
        );
      }

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Ambil data profil terbaru
          final updatedProfile = await getProfile();
          return updatedProfile;
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memperbarui profil');
        }
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal memperbarui profil: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam updateProfile: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
