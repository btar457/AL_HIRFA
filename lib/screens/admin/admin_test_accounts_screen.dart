import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';
import '../../core/utils/error_handler.dart';
import '../../services/test_account_service.dart';

/// حسابات دخول جاهزة لمختبري Google Play: زرّ واحد يُنشئ حساب مشترٍ أو حرفي
/// معتمَداً ومعفى من تأكيد البريد، ثم نسخ/مشاركة بياناته مع المختبر.
class AdminTestAccountsScreen extends StatefulWidget {
  const AdminTestAccountsScreen({super.key});

  @override
  State<AdminTestAccountsScreen> createState() => _AdminTestAccountsScreenState();
}

class _AdminTestAccountsScreenState extends State<AdminTestAccountsScreen> {
  static const _testingLink = 'https://play.google.com/apps/testing/com.alhirfa.app';
  static const _groupLink = 'https://groups.google.com/g/algarfa_tester';

  String? _creatingRole;

  String _roleLabel(String role) => role == 'artisan' ? tr('حرفي (بائع)', 'Artisan (seller)') : tr('مشترٍ', 'Buyer');

  String _shareText(TestAccount a) {
    final role = a.role == 'artisan' ? 'حرفي (بائع) / Artisan' : 'مشترٍ / Buyer';
    return 'AL-HIRFA — حساب تجريبي / Test account\n'
        'النوع / Type: $role\n'
        'البريد / Email: ${a.email}\n'
        'كلمة المرور / Password: ${a.password}\n\n'
        '1) انضم للمجموعة / Join the group: $_groupLink\n'
        '2) فعّل الاختبار / Opt in: $_testingLink\n'
        '3) ثبّت التطبيق وسجّل الدخول بالبيانات أعلاه / Install the app and sign in with the details above.\n'
        'تجربة فقط — لا بيع ولا توصيل حقيقي / Testing only — no real sales or delivery.';
  }

  Future<void> _create(String role) async {
    setState(() => _creatingRole = role);
    try {
      final account = await TestAccountService.instance.create(role);
      if (!mounted) return;
      _showCreated(account);
    } catch (e) {
      if (mounted) AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _creatingRole = null);
    }
  }

  void _copy(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    AppError.showSnackbar(context, message, isError: false);
  }

  void _showCreated(TestAccount a) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(tr('تم إنشاء الحساب', 'Account created'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: SelectableText('${a.email}\n${a.password}', style: TextStyle(color: AppColors.text, height: 1.7)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('إغلاق', 'Close'), style: TextStyle(color: AppColors.subText))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(ctx);
                Share.share(_shareText(a));
              },
              icon: const Icon(Icons.share, size: 18),
              label: Text(tr('مشاركة', 'Share')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDisable(TestAccount a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(tr('إيقاف الحساب؟', 'Disable account?'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(tr('لن يتمكن المختبر من الدخول به بعد الآن.', 'The tester will no longer be able to sign in with it.'), style: TextStyle(color: AppColors.subText)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.subText))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('إيقاف', 'Disable'), style: const TextStyle(color: Colors.redAccent))),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await TestAccountService.instance.disable(a.uid);
    } catch (e) {
      if (mounted) AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  Widget _createButton(String role, IconData icon) {
    final busy = _creatingRole == role;
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _creatingRole != null ? null : () => _create(role),
        icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Icon(icon, size: 20),
        label: Text(tr('+ ', '+ ') + _roleLabel(role), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _accountCard(TestAccount a) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.gold.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(a.role == 'artisan' ? Icons.storefront_outlined : Icons.shopping_bag_outlined, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(_roleLabel(a.role), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: SelectableText('${a.email}\n${a.password}', style: TextStyle(color: AppColors.text, fontSize: 14, height: 1.6)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: tr('نسخ', 'Copy'),
                  icon: Icon(Icons.copy, color: AppColors.subText, size: 20),
                  onPressed: () => _copy('${a.email}\n${a.password}', tr('تم النسخ', 'Copied')),
                ),
                IconButton(
                  tooltip: tr('مشاركة', 'Share'),
                  icon: Icon(Icons.share, color: AppColors.gold, size: 20),
                  onPressed: () => Share.share(_shareText(a)),
                ),
                IconButton(
                  tooltip: tr('إيقاف', 'Disable'),
                  icon: const Icon(Icons.block, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDisable(a),
                ),
              ],
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
          iconTheme: IconThemeData(color: AppColors.gold),
          title: Text(tr('حسابات المختبرين', 'Tester accounts'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                tr('حساب جاهز ومعتمد بلا تأكيد بريد — أرسله للمختبر ليدخل فوراً.', 'A ready, approved account with no email confirmation — send it to a tester to sign in right away.'),
                style: TextStyle(color: AppColors.subText, fontSize: 13, height: 1.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _createButton('customer', Icons.shopping_bag_outlined),
                  const SizedBox(width: 12),
                  _createButton('artisan', Icons.storefront_outlined),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TestAccount>>(
                stream: TestAccountService.instance.watchAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(AppError.getFirebaseError(snapshot.error!), style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: AppColors.gold));
                  final accounts = snapshot.data!;
                  if (accounts.isEmpty) {
                    return Center(child: Text(tr('لا توجد حسابات بعد', 'No accounts yet'), style: TextStyle(color: AppColors.subText)));
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: accounts.map(_accountCard).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
