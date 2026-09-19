import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/navigation/role_router.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../../services/founder_access_service.dart';

/// نص اعتماد صغير في واجهة تسجيل الدخول — الضغط المطوَّل عليه (وليس ضغطاً
/// عادياً) يفتح نموذج "دخول المؤسس" المخفي، وهو المسار الوحيد داخل
/// التطبيق للوصول لحساب الأدمن دون التعديل اليدوي في Firebase Console.
/// يعمل النموذج نفسه لتأسيس أول حساب مؤسس إن لم يوجد أي حساب أدمن بعد،
/// ولتسجيل الدخول لاحقاً لنفس الحساب.
class FounderAccessCredit extends StatefulWidget {
  const FounderAccessCredit({super.key});
  @override
  State<FounderAccessCredit> createState() => _FounderAccessCreditState();
}

class _FounderAccessCreditState extends State<FounderAccessCredit> {
  static const _holdDuration = Duration(seconds: 5);
  Timer? _holdTimer;
  Timer? _tickTimer;
  double _progress = 0;

  void _startHold() {
    _holdTimer = Timer(_holdDuration, () {
      if (mounted) _showFounderDialog();
    });
    // يحدّث مؤشراً بصرياً كل 50ms كي يشعر المستخدم أن الضغط مسجَّل فعلياً
    // بدل الانتظار بلا أي استجابة (كان السبب الرئيسي لظهور الميزة كأنها معطوبة).
    final start = DateTime.now();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      setState(() => _progress = (elapsed / _holdDuration.inMilliseconds).clamp(0, 1));
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _tickTimer?.cancel();
    _tickTimer = null;
    if (mounted) setState(() => _progress = 0);
  }

  void _showFounderDialog() {
    _cancelHold();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const _FounderAccessDialog());
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('المؤسس Mustafa Alshlany', style: TextStyle(color: AppColors.subText, fontSize: 11)),
          if (_progress > 0) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: _progress, backgroundColor: AppColors.subText.withOpacity(0.2), color: AppColors.gold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FounderAccessDialog extends StatefulWidget {
  const _FounderAccessDialog();
  @override
  State<_FounderAccessDialog> createState() => _FounderAccessDialogState();
}

class _FounderAccessDialogState extends State<_FounderAccessDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() => _error = 'أكمل كل الحقول');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      final founderExists = await FounderAccessService.instance.founderLockExists();
      if (!founderExists) {
        await FounderAccessService.instance.bootstrapFounder(email: email, password: password, name: name, phone: phone);
        await auth.loadCurrentUser();
      } else {
        await auth.signIn(email, password);
        if (auth.currentUser?.role != 'admin') {
          await auth.signOut();
          throw Exception('بيانات الدخول غير صحيحة');
        }
      }

      final user = auth.currentUser!;
      await FounderAccessService.instance.logAccess(
        uid: user.uid,
        action: founderExists ? 'login' : 'created',
        name: name,
        email: email,
        phone: phone,
      );

      if (!mounted) return;
      Navigator.pop(context);
      navigateByRole(context, 'admin', user: user);
    } catch (e) {
      setState(() {
        _error = e is Exception && e.toString().startsWith('Exception: ') ? e.toString().replaceFirst('Exception: ', '') : AppError.getFirebaseError(e);
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
      filled: true,
      fillColor: AppColors.background,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('دخول المؤسس', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, style: const TextStyle(color: AppColors.text), decoration: _decoration('الاسم')),
              const SizedBox(height: 10),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.text), decoration: _decoration('البريد الإلكتروني')),
              const SizedBox(height: 10),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, style: const TextStyle(color: AppColors.text), decoration: _decoration('رقم الهاتف')),
              const SizedBox(height: 10),
              TextField(controller: _passwordController, obscureText: true, style: const TextStyle(color: AppColors.text), decoration: _decoration('كلمة المرور')),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.subText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('دخول', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
