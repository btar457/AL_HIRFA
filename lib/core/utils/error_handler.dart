import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../settings/app_prefs.dart';

/// ترجمة أخطاء Firebase إلى رسائل عربية، وعرض SnackBar موحّد لكل التطبيق
/// (AL-HIRFA-Firebase-Setup.md — PART 8).
class AppError {
  AppError._();

  /// يحوّل استثناء (FirebaseAuthException أو أي خطأ آخر) إلى رسالة عربية مفهومة.
  static String getFirebaseError(Object error) {
    if (error is! FirebaseAuthException) {
      // أخطاء Firestore وغيرها — رسالة تدلّ على السبب الفعلي بدل "حدث خطأ"
      // العامة التي لا تساعد المستخدم ولا تساعد في تشخيص البلاغات.
      if (error is FirebaseException) {
        switch (error.code) {
          case 'permission-denied':
            return tr('لا يمكن إتمام هذا الإجراء — قد تكون حالة الطلب أو المنتج تغيّرت. حدّث الصفحة وحاول مجدداً', 'This action can\'t be completed — the order or product may have changed. Refresh and try again');
          case 'unavailable':
          case 'deadline-exceeded':
            return tr('تحقق من اتصالك بالإنترنت ثم حاول مجدداً', 'Check your internet connection and try again');
          case 'not-found':
            return tr('العنصر المطلوب لم يعد موجوداً', 'This item no longer exists');
        }
        return tr('حدث خطأ (${error.code})، حاول مرة أخرى', 'Something went wrong (${error.code}), please try again');
      }
      if (error is SocketException || error is TimeoutException || error is HttpException) {
        return tr('تحقق من اتصالك بالإنترنت ثم حاول مجدداً', 'Check your internet connection and try again');
      }
      // استثناءات التطبيق نفسه تحمل رسالة عربية مقصودة (مثل "فشل رفع الملف
      // إلى التخزين (403)") — كانت تُستبدل بالرسالة العامة فيضيع السبب.
      if (error is Exception) {
        final message = error.toString().replaceFirst('Exception: ', '').trim();
        if (message.isNotEmpty && !message.startsWith('Instance of')) {
          return message.length > 160 ? '${message.substring(0, 160)}…' : message;
        }
      }
      return tr('حدث خطأ، حاول مرة أخرى', 'Something went wrong, please try again');
    }
    switch (error.code) {
      case 'user-not-found':
        return tr('البريد الإلكتروني غير مسجّل', 'This email is not registered');
      case 'wrong-password':
      case 'invalid-credential':
        return tr('كلمة المرور غير صحيحة', 'Incorrect password');
      case 'email-already-in-use':
        return tr('البريد الإلكتروني مستخدم مسبقاً', 'This email is already in use');
      case 'weak-password':
        return tr('كلمة المرور ضعيفة جداً', 'Password is too weak');
      case 'invalid-email':
        return tr('صيغة البريد الإلكتروني غير صحيحة', 'Invalid email format');
      case 'network-request-failed':
        return tr('تحقق من اتصالك بالإنترنت', 'Check your internet connection');
      case 'too-many-requests':
        return tr('محاولات كثيرة، حاول لاحقاً', 'Too many attempts, try again later');
      case 'user-disabled':
      case 'account-suspended':
        return tr('تم تعليق هذا الحساب مؤقتاً، تواصل مع الدعم', 'This account is temporarily suspended, contact support');
      case 'account-banned':
        return tr('تم حظر هذا الحساب نهائياً', 'This account has been permanently banned');
      case 'account-pending':
        return tr('حسابك قيد المراجعة من الإدارة، سيصلك إشعار عند الموافقة', 'Your account is under review; you\'ll be notified once approved');
      case 'account-rejected':
        return tr('تم رفض طلب انضمامك، تواصل مع الدعم لمزيد من التفاصيل', 'Your application was declined, contact support for details');
      case 'email-not-verified':
        return tr('أكّد بريدك الإلكتروني أولاً — أرسلنا لك رابط التأكيد (تفقّد أيضاً الرسائل غير المرغوب فيها)', 'Confirm your email first — we sent you a confirmation link (also check your spam folder)');
      default:
        return tr('حدث خطأ، حاول مرة أخرى', 'Something went wrong, please try again');
    }
  }

  /// عرض SnackBar موحّد الشكل لكل رسائل النجاح/الخطأ في التطبيق.
  static void showSnackbar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.start, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade800 : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
