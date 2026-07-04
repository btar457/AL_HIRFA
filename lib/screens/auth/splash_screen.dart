import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(AppStrings.appName, style: TextStyle(color: AppColors.gold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 6)),
            const SizedBox(height: 8),
            const Text(AppStrings.appNameArabic, style: TextStyle(color: AppColors.gold, fontSize: 22, letterSpacing: 4)),
            const SizedBox(height: 6),
            Text(AppStrings.appTagline, style: TextStyle(color: AppColors.subText, fontSize: 13)),
            const SizedBox(height: 48),
            const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5)),
          ],
        ),
      ),
    );
  }
}
