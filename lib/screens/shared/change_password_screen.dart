import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../../core/settings/app_prefs.dart';

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
  bool _isSaving = false;
  String _newPassword = '';

  bool get _hasMinLength => _newPassword.length >= 8;
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _isValid =>
      _currentController.text.isNotEmpty && _hasMinLength && _hasUppercase && _hasDigit && _newPassword == _confirmController.text && _confirmController.text.isNotEmpty;

  InputDecoration _fieldDecoration({Widget? suffix}) {
    return InputDecoration(
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
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

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<AuthProvider>().changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('تم تغيير كلمة المرور', 'Password changed'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(tr('حسناً', 'OK'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(tr('تغيير كلمة المرور', 'Change password'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: AppColors.text),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ).copyWith(hintText: tr('كلمة المرور الحالية', 'Current password')),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                style: TextStyle(color: AppColors.text),
                onChanged: (value) => setState(() => _newPassword = value),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ).copyWith(hintText: tr('كلمة المرور الجديدة', 'New password')),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: TextStyle(color: AppColors.text),
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration(
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ).copyWith(hintText: tr('تأكيد كلمة المرور الجديدة', 'Confirm new password')),
              ),
              const SizedBox(height: 16),
              _buildRequirement(tr('٨ أحرف على الأقل', 'At least 8 characters'), _hasMinLength),
              _buildRequirement(tr('حرف كبير واحد على الأقل', 'At least one uppercase letter'), _hasUppercase),
              _buildRequirement(tr('رقم واحد على الأقل', 'At least one number'), _hasDigit),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: (_isValid && !_isSaving) ? _save : null,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(tr('حفظ', 'Save'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
