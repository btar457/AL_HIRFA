import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_rules.dart';
import '../core/navigation/app_navigator.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
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
  StreamSubscription<UserModel?>? _userDocSubscription;

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
    String city = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await AuthService.instance.signUp(email: email, password: password, role: role, name: name, phone: phone, city: city);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;
    await AuthService.instance.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// يحمّل UserModel الكامل للمستخدم الحالي من Firestore. يُخرج تلقائياً أي
  /// حساب أصبح معلّقاً/محظوراً/مرفوضاً بعد أن سُجّل دخوله فعلياً (جلسة
  /// Firebase Auth قد تبقى سارية رغم تغيّر حالة الحساب لاحقاً من الإدارة)،
  /// ثم يبدأ مراقبة حيّة لنفس المستند (راجع _watchForLiveBlock) كي لا يبقى
  /// الحساب مسجَّلاً دخوله فعلياً بعد حظره لاحقاً دون إعادة تشغيل التطبيق.
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await AuthService.instance.getCurrentUser();
      if (user != null && AuthService.accessBlockCode(user) != null) {
        await AuthService.instance.signOut();
        _currentUser = null;
      } else {
        _currentUser = user;
        if (user != null) _watchForLiveBlock(user.uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// يراقب مستند المستخدم الحالي حيّاً؛ إن أصبح محظوراً/معلّقاً/مرفوضاً
  /// بينما هو ما يزال مسجَّلاً دخوله على هذا الجهاز، يُسجَّل خروجه فوراً
  /// ويُعاد توجيهه لشاشة الدخول مباشرةً بدل انتظار إعادة تشغيل التطبيق.
  void _watchForLiveBlock(String uid) {
    _userDocSubscription?.cancel();
    _userDocSubscription = AuthService.instance.watchUser(uid).listen((updatedUser) async {
      if (updatedUser == null) return;
      final blockCode = AuthService.accessBlockCode(updatedUser);
      if (blockCode == null) return;

      await _userDocSubscription?.cancel();
      _userDocSubscription = null;
      await AuthService.instance.signOut();
      _currentUser = null;
      notifyListeners();

      final navState = navigatorKey.currentState;
      if (navState == null) return;
      navState.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      final messengerContext = navState.overlay?.context;
      if (messengerContext != null) {
        ScaffoldMessenger.of(messengerContext).showSnackBar(
          SnackBar(content: Text(blockCode == 'account-banned' ? 'تم حظر حسابك من قبل الإدارة' : 'تم تعليق حسابك من قبل الإدارة')),
        );
      }
    });
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await AuthService.instance.updateProfile(data);
    await loadCurrentUser();
  }

  Future<void> uploadProfilePhoto(File imageFile) async {
    final uid = _currentUser?.uid;
    if (uid == null) return;
    await AuthService.instance.uploadProfilePhoto(uid, imageFile);
    await loadCurrentUser();
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return AuthService.instance.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
