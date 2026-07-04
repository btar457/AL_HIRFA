import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// شاشة تغيير كلمة المرور (SHARED-7).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _newPassword = '';

  bool get _hasMinLength => _newPassword.length >= 8;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _isValid => _hasMinLength && _hasUppercase && _hasDigit && _newPassword == _confirmController.text && _confirmController.text.isNotEmpty;

  InputDecoration _fieldDecoration({Widget? suffix}) {
    return InputDecoration(
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildRequirement(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.cancel_outlined, color: met ? Colors.green : AppColors.subText, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: met ? Colors.green : AppColors.subText, fontSize: 12)),
        ],
      ),
    );
  }

  void _save() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تم تغيير كلمة المرور', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('تغيير كلمة المرور', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                style: const TextStyle(color: AppColors.text),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ).copyWith(hintText: 'كلمة المرور الحالية'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                style: const TextStyle(color: AppColors.text),
                onChanged: (value) => setState(() => _newPassword = value),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ).copyWith(hintText: 'كلمة المرور الجديدة'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: AppColors.text),
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ).copyWith(hintText: 'تأكيد كلمة المرور الجديدة'),
              ),
              const SizedBox(height: 16),
              _buildRequirement('٨ أحرف على الأقل', _hasMinLength),
              _buildRequirement('حرف كبير واحد على الأقل', _hasUppercase),
              _buildRequirement('رقم واحد على الأقل', _hasDigit),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _isValid ? _save : null,
                  child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
