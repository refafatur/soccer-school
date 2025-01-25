import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _schedules = [];
  bool _isLoading = true;

  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color jungleGreen = const Color(0xFF2E7D32);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final response = await _apiService.getSchedule();
      setState(() {
        _schedules = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

String _formatDate(dynamic dateStr) {
  if (dateStr == null) return '';
  try {
    if (dateStr is int) {
      // Konversi timestamp ke string terlebih dahulu
      final date = DateTime.fromMillisecondsSinceEpoch(dateStr * 1000); // Tambahkan * 1000 untuk konversi detik ke milidetik
      return DateFormat('dd MMMM yyyy').format(date);
    } else if (dateStr is String) {
      // Pastikan string bisa di-parse sebagai tanggal
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy').format(date);
    }
    return '';
  } catch (e) {
    print('Error formatting date: $e'); // Tambahkan log untuk debugging
    return '';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tigerBlack,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: tigerBlack,
          ),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(tigerOrange),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  color: tigerOrange,
                  child: _schedules.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada jadwal tersedia',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _schedules.length,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 8,
                          ),
                          itemBuilder: (context, index) {
                            final schedule = _schedules[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: schedule.statusSchedule == 1 
                                      ? jungleGreen.withOpacity(0.3)  // Aktif - hijau
                                      : Colors.red.withOpacity(0.3),  // Tidak aktif - merah
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Status indicator
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: schedule.statusSchedule == 1 
                                            ? jungleGreen.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: schedule.statusSchedule == 1 
                                              ? jungleGreen
                                              : Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        schedule.statusSchedule == 1 ? 'Aktif' : 'Tidak Aktif',
                                        style: TextStyle(
                                          color: schedule.statusSchedule == 1 
                                              ? jungleGreen
                                              : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Existing content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          schedule.nameSchedule,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: goldAccent,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(schedule.dateSchedule),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (schedule.waktuBermain != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: goldAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${schedule.waktuBermain} Menit',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (schedule.namaLapangan != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.stadium,
                                                size: 16,
                                                color: goldAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                schedule.namaLapangan!,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (schedule.namaPertandingan != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.sports_soccer,
                                                size: 16,
                                                color: goldAccent,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                schedule.namaPertandingan!,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }
}