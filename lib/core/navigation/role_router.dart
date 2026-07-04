import 'package:flutter/material.dart';
import '../../screens/artisan/artisan_nav.dart';
import '../../screens/customer/customer_nav.dart';
import '../../screens/shared/main_nav.dart';

/// ينقل المستخدم إلى الشاشة الرئيسية المناسبة لدوره بعد تسجيل الدخول أو إنشاء الحساب.
///
/// القيم المتوقعة لـ [role]: customer / artisan / shipping / admin
/// (نفس قيم UserModel.role). لا توجد بعد شاشة "ShippingDashboardScreen"
/// مستقلة، فتُستخدم مؤقتاً تبويبات MainNav الحالية.
void navigateByRole(BuildContext context, String role) {
  late final Widget destination;
  switch (role) {
    case 'customer':
      destination = const CustomerNav();
      break;
    case 'artisan':
      destination = const ArtisanNav();
      break;
    case 'shipping':
      destination = const MainNav(); // TODO: استبدالها بـ ShippingDashboardScreen عند بنائها
      break;
    case 'admin':
      destination = const MainNav(initialIndex: 4);
      break;
    default:
      destination = const CustomerNav();
  }
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
}
