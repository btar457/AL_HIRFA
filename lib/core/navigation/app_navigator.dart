import 'package:flutter/material.dart';

/// مفتاح تنقّل عام — يسمح لـ AuthProvider بإجبار العودة لشاشة الدخول فوراً
/// عند اكتشاف حظر/تعليق حساب مباشرةً من Firestore (بلا الحاجة لـ
/// BuildContext من داخل ChangeNotifier).
final navigatorKey = GlobalKey<NavigatorState>();

/// شاشة البداية (AuthGate في main.dart) — تُسجَّل من main كي تستطيع شاشات
/// أخرى إعادة التطبيق إليها دون استيراد main.dart.
WidgetBuilder? appStartBuilder;

/// يعيد التنقّل كاملاً إلى شاشة البداية، فتُبنى كل الشاشات من جديد (بعد
/// تغيير اللغة/المظهر مثلاً). إعادة بناء MaterialApp وحدها لا تكفي:
/// navigatorKey عام فيُنقل Navigator القديم بمساراته كما هي.
void restartToStart() {
  final builder = appStartBuilder;
  if (builder == null) return;
  navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: builder), (route) => false);
}
