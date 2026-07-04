import 'package:flutter/material.dart';
import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

void main() => runApp(const AlHirfaApp());

class AlHirfaApp extends StatelessWidget {
  const AlHirfaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
