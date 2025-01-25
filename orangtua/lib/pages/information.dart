import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class TigerStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 35) {
      final path = Path();
      path.moveTo(0, i.toDouble());

      for (var x = 0; x < size.width; x += 15) {
        path.quadraticBezierTo(
          x + 8,
          i + 12 * math.sin(x * 0.12),
          x + 15,
          i.toDouble(),
        );
      }

      canvas.drawPath(path, paint..color = Colors.white.withOpacity(0.1));
    }
  }

  @override
  bool shouldRepaint(TigerStripePainter oldDelegate) => false;
}

class _InformationPageState extends State<InformationPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> infoList = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Tambahkan konstanta warna
  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color jungleGreen = const Color(0xFF2E7D32);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupPeriodicInformationCheck();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
    _loadInformation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInformation() async {
    try {
      final response = await _apiService.getInformation();
      final newInfoList = List<Map<String, dynamic>>.from(response);

      // Cek apakah ada informasi baru
      if (newInfoList.length > infoList.length) {
        // Ambil informasi terbaru
        final latestInfo = newInfoList.first;
        _showNewInformationNotification(latestInfo);
      }

      setState(() {
        infoList = newInfoList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error loading information: $e');
    }
  }

  void _setupPeriodicInformationCheck() {
    // Cek informasi baru setiap 5 menit
    Timer.periodic(Duration(minutes: 5), (timer) async {
      try {
        final response = await _apiService.getInformation();
        final newInfoList = List<Map<String, dynamic>>.from(response);

        // Bandingkan dengan data yang ada
        if (newInfoList.isNotEmpty && infoList.isNotEmpty) {
          final latestNewInfo = newInfoList.first;
          final latestCurrentInfo = infoList.first;

          // Cek apakah ada informasi baru berdasarkan ID
          if (latestNewInfo['id_information'] !=
              latestCurrentInfo['id_information']) {
            _showNewInformationNotification(latestNewInfo);
          }
        }

        // Update list informasi
        setState(() {
          infoList = newInfoList;
        });
      } catch (e) {
        print('Error checking for new information: $e');
      }
    });
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Biarkan kosong karena kita tidak perlu navigasi
      },
    );
  }

  Future<void> _showNewInformationNotification(
      Map<String, dynamic> info) async {
    const androidDetails = AndroidNotificationDetails(
      'informasi_sekolah_channel',
      'Informasi Sekolah',
      channelDescription: 'Notifikasi untuk informasi sekolah baru',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      color: Color(0xFF3949AB),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      info.hashCode, // ID unik untuk setiap notifikasi
      'Informasi Sekolah Baru',
      '${info['name_info']}\n\n${info['info']}',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: TigerStripePainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, -1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Informasi Sekolah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(2, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
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
              'Memuat informasi...',
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

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[300],
                size: 70,
              ),
            ),
            SizedBox(height: 20),
            Text(
              error!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _loadInformation,
              icon: Icon(Icons.refresh, size: 24),
              label: Text(
                'Coba Lagi',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInformation,
      color: Color(0xFF3949AB),
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: infoList.length,
        itemBuilder: (context, index) {
          final info = infoList[index];
          return _buildInfoCard(info, index);
        },
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> info, int index) {
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
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle tap
                },
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoHeader(info),
                      SizedBox(height: 15),
                      Text(
                        info['info'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildInfoFooter(info),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader(Map<String, dynamic> info) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            info['name_info'] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoFooter(Map<String, dynamic> info) {
    final bool isActive = info['status_info'] == 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive
                  ? Colors.green.withOpacity(0.4)
                  : Colors.red.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                color: isActive ? Colors.green[100] : Colors.red[100],
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                isActive ? 'Aktif' : 'Tidak Aktif',
                style: TextStyle(
                  color: isActive ? Colors.green[100] : Colors.red[100],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                _formatDate(info['date_info']),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
