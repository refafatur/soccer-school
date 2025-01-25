import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama aplikasi
  static const Color tigerOrange = Color(0xFFFF5722);
  static const Color tigerBlack = Color(0xFF212121);
  static const Color jungleGreen = Color(0xFF2E7D32);
  static const Color goldAccent = Color(0xFFFFD700);
  
  // Gradient umum
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tigerOrange, goldAccent],
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: tigerBlack.withOpacity(0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: tigerOrange.withOpacity(0.3)),
    boxShadow: [
      BoxShadow(
        color: tigerOrange.withOpacity(0.2),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  // Text styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2,
  );

  static const TextStyle subheaderStyle = TextStyle(
    fontSize: 18,
    color: Colors.white70,
    letterSpacing: 1,
  );

  // ThemeData untuk aplikasi
  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: tigerBlack,
    colorScheme: ColorScheme.dark(
      primary: tigerOrange,
      secondary: goldAccent,
      background: tigerBlack,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: tigerBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headerStyle,
      iconTheme: const IconThemeData(color: tigerOrange),
    ),
    // ... tambahkan tema lainnya
  );
} 