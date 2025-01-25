import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/information_page.dart';
import 'screens/student_page.dart';
import 'screens/management_page.dart';
import 'screens/schedule_page.dart';
import 'screens/point_rate_page.dart';
import 'screens/coach_page.dart';
import 'screens/aspect_page.dart';
import 'screens/aspect_sub_page.dart';
import 'screens/assessment_page.dart';
import 'screens/assessment_setting_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSB Tiger Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFFFFD700),
          background: const Color(0xFF212121),
        ),
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.token, required this.userData});

  final String title;
  final String token;
  final Map<String, dynamic> userData;
  @override
  State<MyHomePage> createState() => _MyHomePageState(token: token, userData: userData);
}

class _MyHomePageState extends State<MyHomePage> {
  final String token;
  final Map<String, dynamic> userData;
  _MyHomePageState({required this.token, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.purple],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'SSB Tiger Manager',
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.home,
                title: 'Home',
                page: HomePage(token: token, userData: userData),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.info,
                title: 'Information Page',
                page: const InformationPage(),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.person,
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
                icon: Icons.co_present,
                title: 'Coach Page',
                page: CoachPage(),
              ),
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
              const Divider(color: Color.fromARGB(137, 221, 23, 23)),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_hwcplx4x.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Selamat Datang di SSB Tiger Manager',
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
