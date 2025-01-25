import 'package:flutter/material.dart';
import 'assessment_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'aspect_screen.dart';
import 'information_screen.dart';
import 'assessment_setting_screen.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'point_rate_screen.dart';
import '../widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import '../screens/login_screen.dart';

// Tambahkan class AppTheme untuk mengatasi error undefined name
class AppTheme {
  static const Color tigerBlack = Color(0xFF212121);
  static const Color tigerOrange = Color(0xFFFF5722);
  static const Color goldAccent = Color(0xFFFFD700);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    AssessmentScreen(),
    const ScheduleScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Youth Tiger',
    'Schedule',
    'Profile',
  ];

  TextStyle _getTitleStyle(int index) {
    if (index == 0) { // Untuk halaman Youth Tiger
      return const TextStyle(
        fontSize: 24, // Ukuran lebih besar
        color: Colors.white,
        fontWeight: FontWeight.w800, // Bold lebih tebal
        letterSpacing: 0.5, // Tambahan letter spacing untuk keterbacaan
      );
    }
    return const TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Tampilkan dialog konfirmasi
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: AppTheme.tigerBlack,
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(color: AppTheme.tigerOrange),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tigerOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Hapus token dan data login lainnya
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Hapus semua data tersimpan

        if (!mounted) return;
        
        // Kembali ke halaman login dan hapus semua route sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            _titles[_selectedIndex],
            style: _getTitleStyle(_selectedIndex),
          ),
        ),
        actions: [
          // Icon search untuk semua halaman
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search action
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.tigerBlack,
            onSelected: (value) {
              switch (value) {
                case 'aspects':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AspectScreen()),
                  );
                  break;
                case 'information':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InformationScreen()),
                  );
                  break;
                case 'point_rate':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PointRateScreen()),
                  );
                  break;
                case 'assessment_setting':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AssessmentSettingScreen()),
                  );
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'aspects',
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: AppTheme.tigerOrange),
                    const SizedBox(width: 12),
                    const Text('Aspects', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'information',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.tigerOrange),
                    const SizedBox(width: 12),
                    const Text('Information', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'point_rate',
                child: Row(
                  children: [
                    Icon(Icons.star_outline, color: AppTheme.tigerOrange),
                    const SizedBox(width: 12),
                    const Text('Point Rate', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'assessment_setting',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: AppTheme.tigerOrange),
                    const SizedBox(width: 12),
                    const Text('Assessment Setting', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.tigerOrange),
                    const SizedBox(width: 12),
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.tigerBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTheme.tigerOrange.withOpacity(0.2),
        destinations: [
          _buildNavItem(Icons.assessment_outlined, Icons.assessment, 'Assessment'),
          _buildNavItem(Icons.schedule_outlined, Icons.schedule, 'Schedule'),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  NavigationDestination _buildNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.white70),
      selectedIcon: Icon(selectedIcon, color: AppTheme.tigerOrange),
      label: label,
    );
  }
}