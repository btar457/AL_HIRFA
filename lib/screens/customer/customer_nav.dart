import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'customer_home_screen.dart';
import 'customer_profile_screen.dart';
import 'marketplace_screen.dart';
import 'orders_history_screen.dart';

/// الحاوية الرئيسية لتجربة المشتري عبر شريط تنقل سفلي بأربع تبويبات.
class CustomerNav extends StatefulWidget {
  final int initialIndex;
  const CustomerNav({super.key, this.initialIndex = 0});
  @override
  State<CustomerNav> createState() => _CustomerNavState();
}

class _CustomerNavState extends State<CustomerNav> {
  late int _index = widget.initialIndex;

  final _screens = const [
    CustomerHomeScreen(),
    MarketplaceScreen(),
    OrdersHistoryScreen(),
    CustomerProfileScreen(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'المتجر'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'الحساب'),
          ],
        ),
      ),
    );
  }
}
