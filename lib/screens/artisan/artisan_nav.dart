import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'artisan_dashboard_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_profile_screen.dart';
import 'manage_products_screen.dart';

/// الحاوية الرئيسية لتجربة الحرفي عبر شريط تنقل سفلي بأربع تبويبات.
class ArtisanNav extends StatefulWidget {
  final int initialIndex;
  const ArtisanNav({super.key, this.initialIndex = 0});
  @override
  State<ArtisanNav> createState() => _ArtisanNavState();
}

class _ArtisanNavState extends State<ArtisanNav> {
  late int _index = widget.initialIndex;

  final _screens = const [
    ArtisanDashboardScreen(),
    ManageProductsScreen(),
    ArtisanOrdersScreen(),
    ArtisanProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      NotificationService.instance.initialize(uid);
      context.read<NotificationProvider>().loadNotifications(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFF111111)),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.subText,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'منتجاتي'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'الطلبات'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
