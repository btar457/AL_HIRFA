import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_rules.dart';
import '../models/user_model.dart';

/// طبقة المصادقة وإدارة حسابات المستخدمين عبر Firebase Auth وFirestore.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _usersCollection = 'users';

  /// مستخدم Firebase Auth الحالي (null إن لم يسجّل الدخول).
  User? get firebaseUser => _auth.currentUser;

  /// تيار حالة تسجيل الدخول — يُستخدم لإعادة التوجيه التلقائي عند بدء التطبيق.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تسجيل مستخدم جديد: إنشاء الحساب في Firebase Auth، حفظ بياناته الكاملة
  /// في Firestore، وحفظ FCM token الخاص بالجهاز.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String city = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      name: name,
      email: email.trim(),
      phone: phone,
      role: role,
      city: city,
      createdAt: DateTime.now(),
      // register_screen لا يسمح بإنشاء الحساب أصلاً قبل تفعيل Checkbox
      // الموافقة على الشروط، لذا نُثبّت القبول بالإصدار الحالي هنا مباشرة.
      termsAccepted: true,
      termsAcceptedAt: DateTime.now(),
      termsVersion: AppRules.currentTermsVersion,
    );
    await _firestore.collection(_usersCollection).doc(uid).set(user.toMap());
    await saveFCMToken(uid);

    return user;
  }

  /// تسجيل الدخول، جلب بيانات المستخدم من Firestore، والتحقق من أن الحساب
  /// غير معلَّق (isActive) قبل السماح بالدخول.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    final uid = credential.user!.uid;

    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw FirebaseAuthException(code: 'user-not-found', message: 'تعذّر العثور على بيانات الحساب');
    }

    final user = UserModel.fromMap(uid, doc.data()!);
    if (!user.isActive) {
      await _auth.signOut();
      throw FirebaseAuthException(code: 'user-disabled', message: 'تم تعليق هذا الحساب');
    }

    await saveFCMToken(uid);
    return user;
  }

  /// تسجيل الخروج من Firebase Auth.
  Future<void> signOut() => _auth.signOut();

  /// إرسال بريد إعادة تعيين كلمة المرور.
  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// جلب بيانات المستخدم الحالي الكاملة (UserModel) من Firestore.
  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// تحديث بيانات المستخدم الحالي في Firestore.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection(_usersCollection).doc(uid).update(data);
  }

  /// جلب FCM token الخاص بالجهاز الحالي وحفظه في مستند المستخدم.
  Future<void> saveFCMToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await _firestore.collection(_usersCollection).doc(uid).update({'fcmToken': token});
  }

  /// يقرأ دور المستخدم الحالي من Firestore (customer/artisan/shipping/admin).
  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  /// يحدّث إصدار الشروط المقبول من المستخدم بعد موافقته على الشروط الجديدة (PART 11.5).
  Future<void> updateTermsVersion(String uid, String version) {
    return _firestore.collection(_usersCollection).doc(uid).update({
      'termsAccepted': true,
      'termsAcceptedAt': Timestamp.now(),
      'termsVersion': version,
    });
  }
}
