import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// شاشة تسجيل الدخول.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية ضبابية داكنة ترمز لأجواء الحرفي العراقي (لا يوجد أصل صورة بعد، تمثيل زخرفي مؤقت)
            Positioned.fill(
              child: Opacity(
                opacity: 0.14,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(center: Alignment.topCenter, radius: 1.3, colors: [AppColors.goldLight, AppColors.background]),
                    ),
                    child: const Center(child: Icon(Icons.mosque, size: 280, color: AppColors.gold)),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 6)),
                      const SizedBox(height: 8),
                      Text('HERITAGE IRAQI CRAFTSMANSHIP', style: TextStyle(color: AppColors.subText, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      Container(width: 60, height: 2, color: AppColors.gold),
                      const SizedBox(height: 36),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline, color: AppColors.gold),
                          hintText: 'البريد الإلكتروني',
                          hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gold),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'كلمة المرور',
                          hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () {},
                          child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ليس لديك حساب؟', style: TextStyle(color: AppColors.subText, fontSize: 13)),
                          TextButton(
                            onPressed: () {},
                            child: const Text('انضم إلينا', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('صنع بكل فخر في العراق', style: TextStyle(color: AppColors.subText, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
