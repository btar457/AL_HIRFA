import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/strings.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // يعتمد على google-services.json / GoogleService-Info.plist في مجلدات
    // المنصات (android/ios) بعد إنشائها وربطها بمشروع Firebase.
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('تعذّرت تهيئة Firebase (لم يتم ربط مشروع Firebase بعد): $e');
  }
  runApp(const AlHirfaApp());
}

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
