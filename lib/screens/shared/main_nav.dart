import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../customer/market_screen.dart';
import '../customer/orders_screen.dart';
import '../artisan/studio_screen.dart';
import '../artisan/artisan_screen.dart';
import '../admin/founder_screen.dart';

/// الحاوية الرئيسية التي تجمع الشاشات الخمس عبر شريط تنقل سفلي.
class MainNav extends StatefulWidget {
  final int initialIndex;
  const MainNav({super.key, this.initialIndex = 0});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _index;
  @override
  void initState() { super.initState(); _index = widget.initialIndex; }

  final _screens = const [
    MarketScreen(),
    OrdersScreen(),
    StudioScreen(),
    ArtisanScreen(),
    FounderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.gold.withOpacity(0.25), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: Colors.white30,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: AppStrings.navMarket),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: AppStrings.navOrders),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: AppStrings.navStudio),
            BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: AppStrings.navArtisan),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: AppStrings.navAdmin),
          ],
        ),
      ),
    );
  }
}
