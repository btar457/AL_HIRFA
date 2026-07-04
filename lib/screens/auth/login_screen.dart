import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// شاشة تسجيل الدخول (تصميم على شكل بطاقة فوق خلفية ضبابية داكنة).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Widget _buildField({required IconData icon, required String hint, TextEditingController? controller, bool obscure = false, Widget? suffix, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.horizontal(right: Radius.circular(9))),
            child: Icon(icon, color: Colors.black),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.subText.withOpacity(0.7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                suffixIcon: suffix,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(text, style: TextStyle(color: AppColors.subText, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // خلفية الحرفي العراقي الضبابية الداكنة
            Positioned.fill(
              child: Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    const SizedBox(height: 8),
                    Text('HERITAGE IRAQI CRAFTSMANSHIP', style: TextStyle(color: AppColors.subText, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Container(width: 60, height: 2, color: AppColors.gold),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('تسجيل الدخول', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          _buildLabel('البريد الإلكتروني'),
                          _buildField(icon: Icons.mail_outline, hint: 'name@example.com', controller: _emailController, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 18),
                          _buildLabel('كلمة المرور'),
                          _buildField(
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () {},
                            child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(height: 20),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('صنع بكل فخر في العراق', style: TextStyle(color: AppColors.subText, fontSize: 11)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
