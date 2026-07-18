import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_rules.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _logCollection = 'founder_access_log';
  static const _usersCollection = 'users';
  static const _founderLockPath = 'system_config/founder_lock';

  /// هل سبق أن أُسِّس حساب مؤسس؟ قراءة عامة مسموحة (لا بيانات حسّاسة في
  /// المستند) تُستخدم لتحديد ما إذا كانت المحاولة الحالية "تأسيس" أم "دخول".
  Future<bool> founderLockExists() async {
    final doc = await _firestore.doc(_founderLockPath).get();
    return doc.exists;
  }

  /// يُنشئ حساب المؤسس الأول بأمان حقيقي على مستوى Security Rules، لا مجرّد
  /// اتفاق ضمني في التطبيق: يُنشئ حساب Firebase Auth أولاً (uid يصبح
  /// معروفاً)، ثم يحجز مستند system_config/founder_lock مربوطاً بهذا الـ uid
  /// تحديداً — تضمن Firestore نجاح إنشاء مستند واحد فقط لنفس المسار مهما
  /// تزامنت المحاولات (بلا حاجة لـ transaction يدوي)، فتُقبل قاعدة الأمان
  /// لإنشاء مستند مستخدم بدور admin فقط لهذا الـ uid تحديداً وللأبد. عند
  /// خسارة السباق أو أي فشل لاحق، يُنظّف كل ما أُنشئ (حذف حساب Auth + تحرير
  /// القفل إن كان هو من حجزه).
  Future<UserModel> bootstrapFounder({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final uid = credential.user!.uid;

    try {
      await _firestore.doc(_founderLockPath).set({'claimedBy': uid, 'claimedAt': Timestamp.now()});
    } catch (_) {
      await credential.user!.delete();
      throw Exception('تم تأسيس حساب المؤسس بالفعل من جهاز آخر، الرجاء تسجيل الدخول بدلاً من ذلك');
    }

    try {
      final user = UserModel(
        uid: uid,
        name: name,
        email: email.trim(),
        phone: phone,
        role: 'admin',
        city: '',
        createdAt: DateTime.now(),
        termsAccepted: true,
        termsAcceptedAt: DateTime.now(),
        termsVersion: AppRules.currentTermsVersion,
        approvalStatus: 'approved',
      );
      await _firestore.collection(_usersCollection).doc(uid).set(user.toMap());
      await AuthService.instance.saveFCMToken(uid);
      return user;
    } catch (e) {
      await _firestore.doc(_founderLockPath).delete();
      await credential.user!.delete();
      rethrow;
    }
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
