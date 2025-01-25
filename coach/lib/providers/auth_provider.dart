import 'package:flutter/material.dart';
import '../models/coach.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _coachData;
  String? _token;

  Future<void> login(String email, String nohp) async {
    try {
      print('Attempting login...');
      final response = await _apiService.login(email, nohp);
      
      // Debug print
      print('Login response received:');
      print(response);
      
      if (response['status'] == 'success') {
        _token = response['token'];
        _coachData = response['data'];
        _apiService.setToken(_token!);
        
        // Debug print
        print('Login successful:');
        print('Token: $_token');
        print('Coach data: $_coachData');
        
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Login gagal');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Getter untuk mengakses data coach
  Map<String, dynamic>? get coachData => _coachData;
  String? get token => _token;

  // Method untuk debugging
  void printCoachData() {
    print('Current coach data: $_coachData');
    print('Current token: $_token');
  }

  Coach? get coach {
    if (_coachData == null) return null;
    return Coach.fromJson(_coachData!);
  }
} 