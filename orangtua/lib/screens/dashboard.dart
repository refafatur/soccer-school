import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../pages/beranda.dart';
import '../pages/information.dart';
import '../screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/schedule.dart';
import '../pages/assessment.dart';
import '../pages/profile.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardPage({super.key, required this.userData});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingNavBar = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BerandaPage(userData: widget.userData),
      InformationPage(),
      SchedulePage(),
      AssessmentPage(),
      ProfilePage(userData: widget.userData),
    ];

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFloatingNavBar) {
          setState(() {
            _showFloatingNavBar = false;
          });
        }
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFloatingNavBar) {
          setState(() {
            _showFloatingNavBar = true;
          });
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF212121).withOpacity(0.9),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF212121), // tigerBlack
                const Color(0xFF212121).withOpacity(0.9),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF5722), // tigerOrange
                      const Color(0xFFFFD700), // goldAccent
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 40, color: const Color(0xFFFF5722)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userData['email'] ?? 'User Email',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.home, 'Beranda', 0),
              _buildDrawerItem(Icons.info, 'Informasi', 1),
              _buildDrawerItem(Icons.assessment, 'Assessment', 3),
              _buildDrawerItem(Icons.calendar_today, 'Jadwal', 2),
              _buildDrawerItem(Icons.person, 'Profile', 4),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFF5722)),
                title: const Text(
                  'Keluar',
                  style: TextStyle(
                      color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 65,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: _buildCenterNavItem(
                        0, Icons.home_rounded, 'Beranda', Colors.grey)),
                Expanded(
                    child: _buildCenterNavItem(
                        1, Icons.info_rounded, 'Information', Colors.grey)),
                Expanded(
                    child: _buildCenterNavItem(2, Icons.calendar_today_rounded,
                        'Jadwal', Colors.grey)),
                Expanded(
                    child: _buildCenterNavItem(3, Icons.assessment_rounded,
                        'Assessment', Colors.grey)),
                Expanded(
                    child: _buildCenterNavItem(
                        4, Icons.person_rounded, 'Profile', Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFFFF5722) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFF5722) : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFFF5722).withOpacity(0.1),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCenterNavItem(
      int index, IconData icon, String label, MaterialColor color) {
    bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFFFF5722) : Colors.grey,
              ),
              if (isSelected) ...[
                SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFFFF5722),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
