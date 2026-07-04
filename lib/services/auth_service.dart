import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// طبقة المصادقة وإدارة حسابات المستخدمين عبر Firebase Auth وFirestore.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _usersCollection = 'users';

  User? getCurrentUser() => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    final uid = credential.user!.uid;

    final user = UserModel(
      uid: uid,
      name: name,
      email: email.trim(),
      phone: phone,
      role: role,
      city: '',
      createdAt: DateTime.now(),
    );
    await _firestore.collection(_usersCollection).doc(uid).set(user.toMap());

    return credential;
  }

  Future<void> signOut() => _auth.signOut();

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
