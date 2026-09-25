import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

/// شاشة إعادة تعيين كلمة المرور — تُفتح مباشرة داخل التطبيق عبر App Link
/// (راجع main.dart: مستمع app_links) بدل صفحة Firebase الافتراضية.
class ResetPasswordScreen extends StatefulWidget {
  final String oobCode;
  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _done = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.confirmPasswordReset(
        oobCode: widget.oobCode,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _done = true);
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: _done ? _buildSuccess() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_reset, color: AppColors.gold, size: 72),
          const SizedBox(height: 24),
          const Text('كلمة مرور جديدة', style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('اختر كلمة مرور جديدة لحسابك', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 14, height: 1.6)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'كلمة المرور الجديدة',
              hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmController,
            obscureText: true,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'تأكيد كلمة المرور',
              hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
            ),
            validator: (v) => (v != _passwordController.text) ? 'كلمتا المرور غير متطابقتين' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('تأكيد كلمة المرور الجديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.gold, size: 72),
        const SizedBox(height: 24),
        const Text('تم تغيير كلمة المرور بنجاح', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 14, height: 1.6)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
