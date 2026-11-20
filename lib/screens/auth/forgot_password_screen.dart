import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../services/auth_service.dart';
import '../../core/settings/app_prefs.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _contactController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    final email = _contactController.text.trim();
    if (email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.resetPassword(email);
      if (!mounted) return;
      AppError.showSnackbar(context, tr('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني', 'A reset link was sent to your email'), isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset, color: AppColors.gold, size: 72),
                  const SizedBox(height: 24),
                  Text(tr('نسيت كلمة المرور؟', 'Forgot password?'), style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    tr('أدخل بريدك الإلكتروني المسجَّل وسنرسل لك رابط إعادة التعيين', 'Enter your registered email and we\'ll send you a reset link'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subText, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: tr('البريد الإلكتروني', 'Email'),
                      hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _isLoading ? null : _sendResetEmail,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text(tr('إرسال رابط إعادة التعيين', 'Send reset link'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(tr('العودة لتسجيل الدخول', 'Back to sign in'), style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
