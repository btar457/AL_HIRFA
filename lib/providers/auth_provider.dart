import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_rules.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// حالة المصادقة العامة للتطبيق (AL-HIRFA-Firebase-Setup.md — PART 4.1).
///
/// يستمع إلى AuthService.authStateChanges باستمرار: عند تسجيل الدخول (من
/// أي مصدر) يحمّل UserModel الكامل تلقائياً، وعند الخروج يمسح الحالة محلياً.
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  /// true إلى حين وصول أول حدث من authStateChanges عند بدء التطبيق — يميّز
  /// "لا يزال يتحقق" عن "تأكّد أنه غير مسجّل دخوله" لصالح AuthGate في main.dart.
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _currentUser != null;
  String get role => _currentUser?.role ?? '';
  String? get errorMessage => _errorMessage;

  /// true إن كان إصدار الشروط الذي وافق عليه المستخدم مختلفاً عن الإصدار
  /// الحالي (PART 11.5) — يُتحقّق منه عند كل دخول.
  bool get needsTermsUpdate => _currentUser != null && _currentUser!.termsVersion != AppRules.currentTermsVersion;

  AuthProvider() {
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      _isInitializing = false;
      if (user == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        loadCurrentUser();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await AuthService.instance.signIn(email: email, password: password);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
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
      _currentUser = await AuthService.instance.signUp(email: email, password: password, role: role, name: name, phone: phone);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// يحمّل UserModel الكامل للمستخدم الحالي من Firestore.
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await AuthService.instance.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await AuthService.instance.updateProfile(data);
    await loadCurrentUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
