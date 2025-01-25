import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Map<String, dynamic>> scheduleList = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;

  // Tambahkan konstanta warna
  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color jungleGreen = const Color(0xFF2E7D32);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _initializeNotifications();
    _loadSchedule();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
      },
    );
  }

  Future<void> _showScheduleNotification(Map<String, dynamic> schedule) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'jadwal_latihan_channel',
      'Jadwal Latihan',
      channelDescription: 'Notifikasi untuk jadwal latihan baru',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    String title = 'Jadwal Latihan Baru';
    String body =
        '${schedule['name_schedule']} - ${_formatDate(schedule['date_schedule'])}\n'
        'Waktu: ${schedule['waktu_bermain']} Menit\n'
        'Lokasi: ${schedule['nama_lapangan']}';

    await flutterLocalNotificationsPlugin.show(
      schedule['id_schedule'].hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _loadSchedule() async {
    try {
      final response = await _apiService.getSchedule();
      if (response['status'] == 'success' && response['data'] != null) {
        List<Map<String, dynamic>> newScheduleList =
            List<Map<String, dynamic>>.from(response['data']);

        // Cek jadwal baru
        for (var newSchedule in newScheduleList) {
          bool isNewSchedule = !scheduleList.any((oldSchedule) =>
              oldSchedule['id_schedule'] == newSchedule['id_schedule']);

          if (isNewSchedule) {
            String title = 'Jadwal Latihan Baru';
            String body =
                '${newSchedule['name_schedule']} - ${_formatDate(newSchedule['date_schedule'])}\n'
                'Waktu: ${newSchedule['waktu_bermain']} Menit\n'
                'Lokasi: ${newSchedule['nama_lapangan']}';

            await _showScheduleNotification(newSchedule);
          }
        }

        setState(() {
          scheduleList = newScheduleList;
          isLoading = false;
        });
      } else {
        throw Exception('Data jadwal tidak valid');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Tanggal tidak tersedia';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}-${date.month}-${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusText(dynamic status) {
    if (status == null) return 'Status tidak tersedia';
    if (status == 1) return 'Aktif';
    if (status == 0) return 'Tidak Aktif';
    return status.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tigerBlack,
              tigerBlack.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background patterns
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ModernPatternPainter(
                      animation: _animationController.value,
                    ),
                  );
                },
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Modern header with glassmorphism
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tigerOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Jadwal Latihan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Schedule list with modern cards
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: isLoading
                          ? _buildLoadingState()
                          : error != null
                              ? _buildErrorState()
                              : RefreshIndicator(
                                  onRefresh: _loadSchedule,
                                  color: Colors.white,
                                  backgroundColor: Color(0xFF3949AB),
                                  child: ListView.builder(
                                    padding:
                                        EdgeInsets.only(top: 8, bottom: 20),
                                    itemCount: scheduleList.length,
                                    itemBuilder: (context, index) {
                                      final schedule = scheduleList[index];
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Interval(
                                              0.4 + (index * 0.1),
                                              1.0,
                                              curve: Curves.easeOutQuart,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 8,
                                                sigmaY: 8,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.25),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          child: Icon(
                                                            Icons.sports_soccer,
                                                            color: Colors.white,
                                                            size: 28,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Expanded(
                                                          child: Text(
                                                            schedule['name_schedule']
                                                                    ?.toString() ??
                                                                'Jadwal Latihan',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20),
                                                    _buildScheduleInfo(
                                                      Icons.calendar_today,
                                                      _formatDate(schedule[
                                                              'date_schedule']
                                                          ?.toString()),
                                                      Colors.amber,
                                                    ),
                                                    SizedBox(height: 12),
                                                    _buildScheduleInfo(
                                                      Icons.access_time,
                                                      '${schedule['waktu_bermain']?.toString() ?? 'Waktu tidak tersedia'} Menit',
                                                      Colors.greenAccent,
                                                    ),
                                                    SizedBox(height: 12),
                                                    _buildScheduleInfo(
                                                      Icons.stadium,
                                                      schedule['nama_lapangan']
                                                              ?.toString() ??
                                                          'Lapangan tidak tersedia',
                                                      Colors.pinkAccent,
                                                    ),
                                                    SizedBox(height: 12),
                                                    _buildScheduleInfo(
                                                      Icons.sports,
                                                      schedule['nama_pertandingan']
                                                              ?.toString() ??
                                                          'Pertandingan tidak tersedia',
                                                      Colors.lightBlueAccent,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Memuat jadwal...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 70,
            ),
            SizedBox(height: 20),
            Text(
              error!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSchedule,
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(IconData icon, String text, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernPatternPainter extends CustomPainter {
  final double animation;

  ModernPatternPainter({this.animation = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 40) {
      final path = Path();
      path.moveTo(0, i.toDouble());

      for (var x = 0; x < size.width; x += 30) {
        path.quadraticBezierTo(
          x + 15,
          i + 20 * math.sin((x + animation * 100) * 0.05),
          x + 30,
          i.toDouble(),
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ModernPatternPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
