import 'package:flutter/material.dart';
import '../../screens/customer/marketplace_screen.dart';
import '../../screens/shared/main_nav.dart';

/// ينقل المستخدم إلى الشاشة الرئيسية المناسبة لدوره بعد تسجيل الدخول أو إنشاء الحساب.
///
/// القيم المتوقعة لـ [role]: customer / artisan / shipping / admin
/// (نفس قيم UserModel.role). لا توجد بعد شاشات "ArtisanDashboardScreen" أو
/// "ShippingDashboardScreen" مستقلة، فتُستخدم مؤقتاً تبويبات MainNav الحالية.
void navigateByRole(BuildContext context, String role) {
  late final Widget destination;
  switch (role) {
    case 'customer':
      destination = const MarketplaceScreen();
      break;
    case 'artisan':
      destination = const MainNav(initialIndex: 3); // TODO: استبدالها بـ ArtisanDashboardScreen عند بنائها
      break;
    case 'shipping':
      destination = const MainNav(); // TODO: استبدالها بـ ShippingDashboardScreen عند بنائها
      break;
    case 'admin':
      destination = const MainNav(initialIndex: 4);
      break;
    default:
      destination = const MarketplaceScreen();
  }
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
}
