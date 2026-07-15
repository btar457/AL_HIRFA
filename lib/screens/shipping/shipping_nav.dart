import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import 'active_deliveries_screen.dart';
import 'available_deliveries_screen.dart';
import 'delivery_history_screen.dart';
import 'shipping_profile_screen.dart';

/// الحاوية الرئيسية لتجربة شركة الشحن عبر شريط تنقل سفلي بأربع تبويبات (SHIPPING-1).
class ShippingNav extends StatefulWidget {
  final int initialIndex;
  const ShippingNav({super.key, this.initialIndex = 0});
  @override
  State<ShippingNav> createState() => _ShippingNavState();
}

class _ShippingNavState extends State<ShippingNav> {
  late int _index = widget.initialIndex;

  final _screens = const [
    AvailableDeliveriesScreen(),
    ActiveDeliveriesScreen(),
    DeliveryHistoryScreen(),
    ShippingProfileScreen(),
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
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'المتاحة'),
            BottomNavigationBarItem(icon: Icon(Icons.pin_drop_outlined), activeIcon: Icon(Icons.pin_drop), label: 'النشطة'),
            BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'السجل'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
