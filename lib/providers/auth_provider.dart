import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// حالة المصادقة العامة للتطبيق (AL-HIRFA-Firebase-Setup.md — PART 4.1).
///
/// signIn/signUp/signOut تستدعي AuthService الحالي فعلياً. تحميل بيانات
/// المستخدم الكاملة (UserModel) وتحديث الملف الشخصي مؤجّلان لمرحلة "Auth"
/// القادمة عند توسيع auth_service.dart بـ getCurrentUser()/updateProfile()
/// الحقيقيين (حالياً AuthService لا يعيد سوى UserCredential/الدور فقط).
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String get role => _currentUser?.role ?? '';
  String? get errorMessage => _errorMessage;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AuthService.instance.signIn(email: email, password: password);
      // TODO: تحميل UserModel الكامل من Firestore عبر AuthService.getCurrentUser() (مرحلة Auth).
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await AuthService.instance.signUp(email: email, password: password, role: role, name: name, phone: phone);
      // TODO: تحميل UserModel الكامل بعد إنشاء الحساب (مرحلة Auth).
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    // TODO: يُنفَّذ في مرحلة Auth القادمة (auth_service.getCurrentUser يُعيد UserModel كامل من Firestore).
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    // TODO: يُنفَّذ في مرحلة Auth القادمة (auth_service.updateProfile).
  }
}
