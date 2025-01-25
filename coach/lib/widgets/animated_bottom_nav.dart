import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AnimatedBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.tigerBlack.withOpacity(0.9),
            AppTheme.tigerBlack,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.tigerOrange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        backgroundColor: Colors.transparent,
        indicatorColor: AppTheme.tigerOrange.withOpacity(0.2),
        destinations: [
          _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.assessment_outlined, Icons.assessment, 'Penilaian'),
          _buildNavItem(Icons.category_outlined, Icons.category, 'Aspek'),
          _buildNavItem(Icons.schedule_outlined, Icons.schedule, 'Jadwal'),
          _buildNavItem(Icons.person_outline, Icons.person, 'Profil'),
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
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon, color: AppTheme.goldAccent),
      label: label,
    );
  }
} 