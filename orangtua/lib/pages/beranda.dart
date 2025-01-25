import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BerandaPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const BerandaPage({super.key, required this.userData});

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;
  String? nama;
  String? photo;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Data dummy untuk statistik anak
  final Map<String, dynamic> childStats = {
    'attendance': 85,
    'performance': 78,
    'nextMatch': 'Minggu, 20 Des 2023',
    'lastAssessment': 'A'
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      nama = prefs.getString('name') ?? widget.userData['name'] ?? 'Pengguna';
      photo = widget.userData['photo'] ?? prefs.getString('photo');

      if (widget.userData['reg_id_student'] != null) {
        await _fetchStudentData(widget.userData['reg_id_student']);
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchStudentData(String regIdStudent) async {
    try {
      final apiService = ApiService();
      final result = await apiService.getDataByRegIdStudent(regIdStudent);
      if (result['status'] == 'success' && result['data'] != null) {
        setState(() {
          nama = result['data']['name'];
          photo = result['data']['photo'];
          _updateSharedPreferences();
        });
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  Future<void> _updateSharedPreferences() async {
    await prefs.setString('name', nama ?? '');
    await prefs.setString('photo', photo ?? '');
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF212121),
              Color(0xFF212121).withOpacity(0.8),
            ],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TigerStripePainter(),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header Profile
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: photo != null ? NetworkImage(photo!) : null,
                                  child: photo == null ? Icon(Icons.person) : null,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat Datang,',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        nama ?? 'Pengguna',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.notifications_outlined, color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          
                          // Quick Actions
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menu Cepat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildQuickAction(Icons.calendar_today, 'Jadwal', () {}),
                                    _buildQuickAction(Icons.assessment, 'Penilaian', () {}),
                                    _buildQuickAction(Icons.payment, 'Pembayaran', () {}),
                                    _buildQuickAction(Icons.message, 'Pesan', () {}),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Statistik Anak
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statistik Anak',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  children: [
                                    _buildStatCard('Kehadiran', '${childStats['attendance']}%', 
                                      Icons.timer, Colors.green),
                                    _buildStatCard('Performa', '${childStats['performance']}%', 
                                      Icons.show_chart, Colors.blue),
                                    _buildStatCard('Pertandingan\nSelanjutnya', childStats['nextMatch'], 
                                      Icons.sports_soccer, Colors.orange),
                                    _buildStatCard('Penilaian\nTerakhir', childStats['lastAssessment'], 
                                      Icons.grade, Colors.purple),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TigerStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 30) {
      final path = Path();
      path.moveTo(0, i.toDouble());

      for (var x = 0; x < size.width; x += 10) {
        path.quadraticBezierTo(
          x + 5,
          i + 10 * math.sin(x * 0.1),
          x + 10,
          i.toDouble(),
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TigerStripePainter oldDelegate) => false;
}
