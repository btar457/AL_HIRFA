import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

/// طبقة تأسيس ودخول حساب المؤسس (Admin) — بديل آمن عن التعديل اليدوي في
/// Firebase Console لإنشاء أول حساب أدمن، مع تسجيل كل محاولة وصول.
///
/// ملاحظة: "تنبيه الدخول" هنا هو مستند حقيقي في Firestore (سجل + إشعار
/// داخل التطبيق لحساب المؤسس نفسه) وليس بريداً/رسالة SMS فعلية — لا يوجد
/// Backend منفصل قادر على إرسال ذلك من تطبيق Flutter وحده (نفس القيد
/// المذكور في notification_service.dart).
class FounderAccessService {
  FounderAccessService._();
  static final FounderAccessService instance = FounderAccessService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _logCollection = 'founder_access_log';
  static const _founderLockPath = 'system_config/founder_lock';

  /// يحجز "مقعد التأسيس" بشكل ذرّي عبر Firestore transaction بدل فحص العدد
  /// ثم الإنشاء بخطوتين منفصلتين (ما كان يسمح لمحاولتين متزامنتين بإنشاء
  /// أكثر من حساب مؤسس واحد). يُعيد true لمحاولة التأسيس الفائزة فقط.
  Future<bool> claimFounderSlot() async {
    final lockRef = _firestore.doc(_founderLockPath);
    return _firestore.runTransaction<bool>((tx) async {
      final snap = await tx.get(lockRef);
      if (snap.exists) return false;
      tx.set(lockRef, {'claimedAt': Timestamp.now()});
      return true;
    });
  }

  /// يُفرِج عن مقعد التأسيس إن فشل إنشاء الحساب فعلياً بعد حجزه، حتى لا
  /// يُقفَل التأسيس للأبد بسبب محاولة فاشلة (كلمة مرور ضعيفة، انقطاع شبكة...).
  Future<void> releaseFounderSlot() => _firestore.doc(_founderLockPath).delete();

  /// يسجّل كل محاولة وصول ناجحة لحساب المؤسس (تأسيس أو دخول)، ويُرسل
  /// إشعاراً داخلياً حقيقياً لنفس الحساب كتنبيه أمني.
  Future<void> logAccess({
    required String uid,
    required String action, // created / login
    required String name,
    required String email,
    required String phone,
  }) async {
    await _firestore.collection(_logCollection).add({
      'uid': uid,
      'action': action,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.now(),
    });

    await NotificationService.instance.sendToUser(
      userUid: uid,
      title: action == 'created' ? 'تم إنشاء حساب المؤسس' : 'تنبيه: تسجيل دخول كمؤسس',
      body: action == 'created' ? 'تم تأسيس حساب المؤسس بنجاح من هذا الجهاز' : 'تم تسجيل الدخول إلى حساب المؤسس الآن',
      type: 'founder_access',
    );
  }
}
