import 'package:flutter/material.dart';
import 'package:test_app_new/core/theme/app_theme.dart';
import 'package:test_app_new/views/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _displayDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    Future.delayed(_displayDuration, _goToHome);
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SizedBox.expand(
        child: Image.asset('lib/assets/images/splash.png', fit: BoxFit.contain),
      ),
    );
  }
}
