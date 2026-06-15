import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => userId != null ? const MainNavigation() : const LoginScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Logo
                Image.asset('assets/logo.png', height: 150, width: 150, fit: BoxFit.contain),
                const SizedBox(height: 30),
                const Text(
                  'ABSENSI',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF003366), letterSpacing: 4),
                ),
                const Text(
                  'UNIVERSITAS LAMPUNG',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366), letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Berbasis Lokasi dan Foto',
                  style: TextStyle(fontSize: 14, color: Color(0xFF003366).withOpacity(0.7), letterSpacing: 1),
                ),
                const Spacer(flex: 4),
                // Bottom icon
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
