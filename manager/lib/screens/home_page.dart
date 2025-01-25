import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'information_page.dart';
import 'student_page.dart';
import 'management_page.dart';
import 'schedule_page.dart';
import 'point_rate_page.dart';
import 'coach_page.dart';
import 'aspect_page.dart';
import 'aspect_sub_page.dart';
import 'assessment_page.dart';
import 'assessment_setting_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const HomePage({
    super.key,
    required this.token,
    required this.userData,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentTime;
  late String currentDate;

  final List<Map<String, String>> schedules = [
    {'date': '2025-01-10', 'event': 'Team Meeting'},
    {'date': '2025-01-02', 'event': 'Strategy Session'},
    {'date': '2025-01-03', 'event': 'Fitness Training'},
    {'date': '2025-01-04', 'event': 'Match Practice'},
  ];

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm').format(DateTime.now());
      currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    });
  }

  Map<String, String>? getUpcomingSchedule() {
    for (var schedule in schedules) {
      if (schedule['date']!.compareTo(currentDate) >= 0) {
        return schedule;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final upcomingSchedule = getUpcomingSchedule();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_soccer, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sport Academy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C2C),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      (widget.userData['name'] ?? 'N')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userData['name'] ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.userData['department'] ??
                        'Departemen tidak tersedia',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.aspect_ratio,
                    title: 'Aspect Page',
                    page: AspectPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.subdirectory_arrow_right,
                    title: 'Aspect Sub Page',
                    page: AspectSubPage(aspect: 'Dribbling', idAspect: 1),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.assessment,
                    title: 'Assessment Page',
                    page: AssessmentPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_suggest,
                    title: 'Assessment Setting Page',
                    page: const AssessmentSettingPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info,
                    title: 'Information Page',
                    page: const InformationPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    title: 'Student Page',
                    page: StudentPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Management Page',
                    page: const ManagementPage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Schedule Page',
                    page: const SchedulePage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.stacked_line_chart,
                    title: 'Point Rate Page',
                    page: PointRatePage(),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.sports,
                    title: 'Coach Page',
                    page: CoachPage(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(upcomingSchedule),
              const SizedBox(height: 25),
              _buildHariPentingCard(),
              const SizedBox(height: 25),
              const Text(
                'Quick Access',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildEnhancedGridItem(
                    context,
                    'Aspect Page',
                    Icons.aspect_ratio,
                    AspectPage(),
                  ),
                  _buildEnhancedGridItem(
                    context,
                    'Information Page',
                    Icons.info,
                    const InformationPage(),
                  ),
                  _buildEnhancedGridItem(
                    context,
                    'Student Page',
                    Icons.people,
                    StudentPage(),
                  ),
                  _buildEnhancedGridItem(
                    context,
                    'Point Rate Page',
                    Icons.stacked_line_chart,
                    PointRatePage(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, String>? upcomingSchedule) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[900]!.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[100],
                ),
              ),
            ],
          ),
          if (upcomingSchedule != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.event, color: Colors.white, size: 20),
                      SizedBox(width: 5),
                      Text(
                        'Next Event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    upcomingSchedule['event']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.yellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    upcomingSchedule['date']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[100],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHariPentingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.deepOrange[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange[900]!.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Upcoming Matches',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Season 2025',
                    style: TextStyle(
                      color: Colors.orange[100],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'January',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Text(
                      '3 Matches',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Match',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Saturday, Jan 10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '9 Days',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Remaining',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGridItem(
      BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3A3A3A),
              const Color(0xFF2C2C2C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[400]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
