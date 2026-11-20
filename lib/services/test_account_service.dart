import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_model.dart';

/// بيانات دخول حساب مختبر جاهز (تُعرض للإدارة لنسخها/مشاركتها).
class TestAccount {
  final String uid;
  final String email;
  final String password;
  final String role; // customer/artisan
  final DateTime createdAt;

  const TestAccount({required this.uid, required this.email, required this.password, required this.role, required this.createdAt});

  factory TestAccount.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return TestAccount(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      password: d['password'] as String? ?? '',
      role: d['role'] as String? ?? 'customer',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// يُنشئ حسابات دخول جاهزة لمختبري Google Play (مشترٍ أو حرفي) من شاشة
/// الإدارة، كي يدخل المختبر فوراً دون تسجيل أو تأكيد بريد.
///
/// الإنشاء يتم عبر نسخة Firebase ثانوية مستقلة: createUserWithEmailAndPassword
/// على النسخة الافتراضية كانت ستسجّل دخول الحساب الجديد وتُخرج المدير. الحساب
/// الجديد يكتب مستنده بنفسه بنفس قيود التسجيل العادي (حرفي = pending)، ثم
/// يعتمده المدير من جلسته ويضع علامة isTestAccount (الإعفاء من تأكيد البريد) —
/// قواعد Firestore تمنع أي مستخدم من وضع هذه العلامة لنفسه.
class TestAccountService {
  TestAccountService._();
  static final TestAccountService instance = TestAccountService._();

  static const _appName = 'testAccounts';
  static const _collection = 'test_accounts';
  static const emailDomain = 'tester.alhirfa.app';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TestAccount>> watchAccounts() => _firestore
      .collection(_collection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(TestAccount.fromDoc).toList());

  Future<FirebaseApp> _secondaryApp() async {
    for (final app in Firebase.apps) {
      if (app.name == _appName) return app;
    }
    final app = await Firebase.initializeApp(name: _appName, options: Firebase.app().options);
    try {
      await FirebaseAppCheck.instanceFor(app: app).activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
      );
    } catch (_) {}
    return app;
  }

  static String _digits(Random r, int n) => List.generate(n, (_) => r.nextInt(10)).join();

  Future<TestAccount> create(String role) async {
    assert(role == 'customer' || role == 'artisan');
    final random = Random.secure();
    final tag = role == 'artisan' ? 'artisan' : 'buyer';
    final number = _digits(random, 4);
    final email = 'test.$tag.$number@$emailDomain';
    final password = 'Hirfa${_digits(random, 6)}';
    final name = role == 'artisan' ? 'حرفي تجريبي $number' : 'مشترٍ تجريبي $number';

    final app = await _secondaryApp();
    final auth = FirebaseAuth.instanceFor(app: app);
    final db = FirebaseFirestore.instanceFor(app: app);

    final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    final now = DateTime.now();
    try {
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: '',
        role: role,
        city: 'بغداد',
        createdAt: now,
        // termsVersion فارغ عمداً: المختبر يوافق على الشروط بنفسه عند أول دخول.
        approvalStatus: role == 'artisan' ? 'pending' : 'approved',
      );
      await db.collection('users').doc(uid).set(user.toMap());
      await db.collection('users').doc(uid).collection('private').doc('contact').set({'phone': ''});
    } catch (e) {
      await credential.user!.delete();
      await auth.signOut();
      rethrow;
    }
    await auth.signOut();

    await _firestore.collection('users').doc(uid).update({'approvalStatus': 'approved', 'isTestAccount': true});
    await _firestore.collection(_collection).doc(uid).set({
      'email': email,
      'password': password,
      'role': role,
      'createdAt': Timestamp.fromDate(now),
    });
    return TestAccount(uid: uid, email: email, password: password, role: role, createdAt: now);
  }

  /// يحذف بيانات الدخول من القائمة ويوقف الحساب (لا يحذف حساب Auth نفسه —
  /// ذلك يتطلب Admin SDK؛ الإيقاف يمنع الدخول فعلياً عبر accessBlockCode).
  Future<void> disable(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isActive': false});
    await _firestore.collection(_collection).doc(uid).delete();
  }
}
