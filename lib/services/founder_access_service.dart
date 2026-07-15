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

  static const _usersCollection = 'users';
  static const _logCollection = 'founder_access_log';

  /// هل يوجد حساب أدمن واحد على الأقل بالفعل؟ يحدّد ما إذا كانت المحاولة
  /// الحالية "تأسيس أول حساب" أم "دخول عادي" لحساب موجود.
  Future<bool> founderExists() async {
    final snapshot = await _firestore.collection(_usersCollection).where('role', isEqualTo: 'admin').count().get();
    return (snapshot.count ?? 0) > 0;
  }

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
