import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../screens/admin/admin_nav.dart';
import '../../screens/artisan/artisan_nav.dart';
import '../../screens/customer/customer_nav.dart';
import '../../screens/shared/terms_screen.dart';
import '../../screens/shipping/shipping_nav.dart';
import '../../services/auth_service.dart';
import '../constants/app_rules.dart';
import '../constants/colors.dart';

/// ينقل المستخدم إلى الشاشة الرئيسية المناسبة لدوره بعد تسجيل الدخول أو إنشاء الحساب.
///
/// القيم المتوقعة لـ [role]: customer / artisan / shipping / admin
/// (نفس قيم UserModel.role).
///
/// إن مُرِّر [user] وكان إصدار الشروط المخزّن لديه مختلفاً عن
/// [AppRules.currentTermsVersion] (PART 11.5)، يُعرض BottomSheet إلزامي
/// غير قابل للإغلاق يجبره على الموافقة على الشروط المحدّثة قبل الدخول.
/// عندما لا يُمرَّر [user] (الحالة الحالية لكل نقاط الدخول، لأن Firebase
/// لم يُربط بعد بواجهة المستخدم)، يُتخطى الفحص مباشرة.
void navigateByRole(BuildContext context, String role, {UserModel? user}) {
  void push() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destinationForRole(role)));

  if (user != null && user.termsVersion != AppRules.currentTermsVersion) {
    _showTermsUpdateSheet(context, user, push);
    return;
  }
  push();
}

/// الشاشة الرئيسية المطابقة للدور (بدون أي تنقّل) — يُستخدم من [navigateByRole]
/// ومن AuthGate في main.dart عند تحديد الوجهة الأولية حسب حالة تسجيل الدخول.
Widget destinationForRole(String role) {
  switch (role) {
    case 'customer':
      return const CustomerNav();
    case 'artisan':
      return const ArtisanNav();
    case 'shipping':
      return const ShippingNav();
    case 'admin':
      return const AdminNav();
    default:
      return const CustomerNav();
  }
}

void _showTermsUpdateSheet(BuildContext context, UserModel user, VoidCallback onAccepted) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تم تحديث الشروط والأحكام', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                'يجب قراءة الشروط الجديدة والموافقة عليها للمتابعة في استخدام AL-HIRFA.',
                style: TextStyle(color: AppColors.subText, fontSize: 13, height: 24 / 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(sheetContext, MaterialPageRoute(builder: (_) => const TermsScreen())),
                child: const Text('عرض الشروط الكاملة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    await AuthService.instance.updateTermsVersion(user.uid, AppRules.currentTermsVersion);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                    onAccepted();
                  },
                  child: const Text('أوافق على الشروط المحدّثة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
