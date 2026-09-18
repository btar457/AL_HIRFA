import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// ترجمة أخطاء Firebase إلى رسائل عربية، وعرض SnackBar موحّد لكل التطبيق
/// (AL-HIRFA-Firebase-Setup.md — PART 8).
class AppError {
  AppError._();

  /// يحوّل استثناء (FirebaseAuthException أو أي خطأ آخر) إلى رسالة عربية مفهومة.
  ///
  /// تشخيص مؤقّت (إصدار الاختبار الداخلي الأول على Play): الفرعان أدناه
  /// يُلحقان تفاصيل الخطأ الفعلي بالرسالة بدل إخفائه خلف نص عام، لمعرفة
  /// السبب الحقيقي وراء فشل تسجيل الدخول على كل الحسابات في أول بناء موزَّع
  /// عبر Play (مرشّح رئيسي: App Check/Play Integrity). يُزال هذا التفصيل
  /// الإضافي بعد تحديد السبب وإصلاحه.
  static String getFirebaseError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'حدث خطأ، حاول مرة أخرى (${error.runtimeType}: $error)';
    }
    switch (error.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجّل';
      case 'wrong-password':
      case 'invalid-credential':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'user-disabled':
      case 'account-suspended':
        return 'تم تعليق هذا الحساب مؤقتاً، تواصل مع الدعم';
      case 'account-banned':
        return 'تم حظر هذا الحساب نهائياً';
      case 'account-pending':
        return 'حسابك قيد المراجعة من الإدارة، سيصلك إشعار عند الموافقة';
      case 'account-rejected':
        return 'تم رفض طلب انضمامك، تواصل مع الدعم لمزيد من التفاصيل';
      default:
        return 'حدث خطأ، حاول مرة أخرى (${error.code})';
    }
  }

  /// عرض SnackBar موحّد الشكل لكل رسائل النجاح/الخطأ في التطبيق.
  static void showSnackbar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade800 : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
