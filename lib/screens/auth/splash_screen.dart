import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/settings/app_prefs.dart';

/// شاشة البداية البصرية فقط — قرار التوجيه (تسجيل دخول/شاشة الدور) يتّخذه
/// AuthGate في main.dart بحسب حالة AuthProvider.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/images/splash_bg.jpg', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: AppColors.imageOverlay)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.appName, style: TextStyle(color: AppColors.gold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  Text(AppStrings.heritageTagline, style: TextStyle(color: AppColors.subText, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 48),
                  SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
