import 'package:flutter/material.dart';
import 'package:youth_tiger_soccer_school/screens/home_screen.dart';
import '../services/api_service.dart';
import 'dart:math';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:youth_tiger_soccer_school/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _nohpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Update color scheme dengan warna-warna yang mencerminkan harimau
  final Color tigerOrange = const Color(0xFFFF5722);  // Warna harimau
  final Color tigerBlack = const Color(0xFF212121);   // Warna strip harimau
  final Color jungleGreen = const Color(0xFF2E7D32);  // Warna lapangan
  final Color goldAccent = const Color(0xFFFFD700);   // Warna aksen prestasi

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _nohpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tigerBlack,
      body: Stack(
        children: [
          // Tiger stripe pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: TigerStripePainter(),
            ),
          ),
          // Animated soccer field lines
          Positioned.fill(
            child: CustomPaint(
              painter: SoccerFieldPainter(
                progress: _animationController.value,
                color: jungleGreen.withOpacity(0.1),
              ),
            ),
          ),
          // Dynamic floating elements
          ...List.generate(
            15,
            (index) => TweenAnimationBuilder<double>(
              duration: Duration(seconds: 3 + index),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Positioned(
                  left: cos(value * 2 * pi + index) * 40 + MediaQuery.of(context).size.width * (index / 15),
                  top: sin(value * 2 * pi + index) * 40 + MediaQuery.of(context).size.height * 0.3,
                  child: index % 2 == 0
                    ? Icon(
                        Icons.sports_soccer,
                        size: 15 + index * 1.5,
                        color: Colors.white.withOpacity(0.1),
                      )
                    : Text(
                        '⚡',
                        style: TextStyle(
                          fontSize: 20 + index * 1.5,
                          color: goldAccent.withOpacity(0.1),
                        ),
                      ),
                );
              },
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Animated tiger logo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            TweenAnimationBuilder<double>(
                              duration: const Duration(seconds: 2),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        tigerOrange.withOpacity(0.5 * value),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Tiger icon with soccer ball
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    tigerOrange,
                                    tigerOrange.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: tigerOrange.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Icon(
                                    Icons.pets, // Tiger icon
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  Positioned(
                                    right: -5,
                                    bottom: -5,
                                    child: Icon(
                                      Icons.sports_soccer,
                                      size: 30,
                                      color: goldAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Animated title with tiger theme
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              goldAccent,
                              tigerOrange,
                              goldAccent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: tigerBlack.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: tigerOrange.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tigerOrange.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'YOUTH TIGER',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: tigerBlack,
                                        offset: const Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                      Shadow(
                                        color: goldAccent.withOpacity(0.5),
                                        offset: const Offset(-1, -1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  height: 2,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        goldAccent,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  'SOCCER SCHOOL',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 5,
                                    shadows: [
                                      Shadow(
                                        color: tigerBlack,
                                        offset: const Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                      Shadow(
                                        color: goldAccent.withOpacity(0.5),
                                        offset: const Offset(-1, -1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Login form dengan desain yang lebih menyatu
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                tigerBlack.withOpacity(0.8),  // Ubah ke warna gelap
                                tigerBlack.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: tigerOrange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Silakan masuk untuk melanjutkan',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    // Input fields dengan style yang lebih menyatu
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(color: Colors.white70),
                                          prefixIcon: Icon(Icons.email_outlined, color: tigerOrange),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: TextFormField(
                                        controller: _nohpController,
                                        style: const TextStyle(color: Colors.white),
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          labelText: 'No HP',
                                          labelStyle: TextStyle(color: Colors.white70),
                                          prefixIcon: Icon(Icons.phone_outlined, color: tigerOrange),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(20),
                                          hintText: '08xxxxxxxxxx',
                                          hintStyle: TextStyle(color: Colors.white30),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'No HP tidak boleh kosong';
                                          }
                                          if (!value.startsWith('0')) {
                                            return 'No HP harus dimulai dengan 0';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    // Button dengan style yang lebih menarik
                                    Container(
                                      width: double.infinity,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            tigerOrange,
                                            goldAccent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: tigerOrange.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(tigerBlack),
                                                ),
                                              )
                                            : const Text(
                                                'MASUK',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_emailController.text.isEmpty || _nohpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan No HP harus diisi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _nohpController.text,
      );
      
      // Debug print
      Provider.of<AuthProvider>(context, listen: false).printCoachData();
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Custom painter untuk pattern strip harimau
class TigerStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 40) {
      final path = Path();
      path.moveTo(0, i.toDouble());
      
      for (var x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          i + 10 * sin(x * 0.1),
          x + 20,
          i.toDouble(),
        );
      }
      
      canvas.drawPath(path, paint..color = Colors.black.withOpacity(0.05));
    }
  }

  @override
  bool shouldRepaint(TigerStripePainter oldDelegate) => false;
}

// Custom painter untuk garis lapangan
class SoccerFieldPainter extends CustomPainter {
  final double progress;
  final Color color;

  SoccerFieldPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw field lines with animation
    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width * progress, centerY),
      paint,
    );

    // Draw circle in center
    canvas.drawCircle(
      Offset(size.width / 2, centerY),
      30 * progress,
      paint,
    );
  }

  @override
  bool shouldRepaint(SoccerFieldPainter oldDelegate) => 
    oldDelegate.progress != progress;
} 