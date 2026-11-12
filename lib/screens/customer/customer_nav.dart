import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/app_settings_service.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'customer_home_screen.dart';
import 'customer_profile_screen.dart';
import 'marketplace_screen.dart';
import 'orders_history_screen.dart';
import '../../core/settings/app_prefs.dart';

/// الحاوية الرئيسية لتجربة المشتري عبر شريط تنقل سفلي بأربع تبويبات.
class CustomerNav extends StatefulWidget {
  final int initialIndex;
  const CustomerNav({super.key, this.initialIndex = 0});
  @override
  State<CustomerNav> createState() => _CustomerNavState();
}

class _CustomerNavState extends State<CustomerNav> {
  late int _index = widget.initialIndex;

  final _screens = [
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
    // سعر التوصيل الذي حدّدته الإدارة — كانت السلة تعرض القيمة الافتراضية
    // (5,000) حتى فتح شاشة إتمام الشراء، فيختلف المجموع بين الشاشتين.
    final cart = context.read<CartProvider>();
    AppSettingsService.instance.getSettings().then((s) => cart.setDeliveryFeePerItem(s.fixedDeliveryFee)).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        body: _screens[_index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: AppColors.navBackground),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.gold,
            unselectedItemColor: AppColors.subText,
            selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 11),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: tr('الرئيسية', 'Home')),
              BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: tr('المتجر', 'Shop')),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: tr('طلباتي', 'My orders')),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: tr('الحساب', 'Account')),
            ],
          ),
        ),
      ),
    );
  }
}
