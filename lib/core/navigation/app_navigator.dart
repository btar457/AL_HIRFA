import 'package:flutter/material.dart';

/// مفتاح تنقّل عام — يسمح لـ AuthProvider بإجبار العودة لشاشة الدخول فوراً
/// عند اكتشاف حظر/تعليق حساب مباشرةً من Firestore (بلا الحاجة لـ
/// BuildContext من داخل ChangeNotifier).
final navigatorKey = GlobalKey<NavigatorState>();
