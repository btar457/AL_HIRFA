import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.8))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(AppStrings.appName, style: TextStyle(color: AppColors.gold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 6)),
                const SizedBox(height: 8),
                Text(AppStrings.heritageTagline, style: TextStyle(color: AppColors.subText, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                const SizedBox(height: 48),
                const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
