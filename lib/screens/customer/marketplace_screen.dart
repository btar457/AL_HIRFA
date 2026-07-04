import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/categories.dart';
import '../../models/marketplace_product.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'customer_profile_screen.dart';
import 'orders_history_screen.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCity = 'الكل';
  String _selectedCategory = 'all';
  final Set<String> _favoriteNames = {};
  int _navIndex = 1;
  final bool _hasNotifications = true;

  final _cities = const ['الكل', 'نجف', 'بصرة', 'بغداد', 'أربيل', 'موصل', 'كربلاء', 'الديوانية'];

  final _products = const [
    MarketplaceProduct(name: 'سجادة حرير نجفية مطرزة يدوياً', price: '450,000', city: 'نجف', cityTag: 'NAJAF SILK'),
    MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'بصرة', cityTag: 'BASRA COPPER'),
    MarketplaceProduct(name: 'طقم نحاسيات بغدادية مذهبة', price: '380,000', city: 'بغداد', cityTag: 'BAGHDAD BRASS'),
    MarketplaceProduct(name: 'نسيج صوفي أربيلي تقليدي', price: '165,000', city: 'أربيل', cityTag: 'ERBIL WEAVE'),
    MarketplaceProduct(name: 'منحوتة حجرية موصلية', price: '295,000', city: 'موصل', cityTag: 'MOSUL STONE'),
    MarketplaceProduct(name: 'إكسسوار ذهبي كربلائي', price: '520,000', city: 'كربلاء', cityTag: 'KARBALA GOLD'),
    MarketplaceProduct(name: 'عباءة صوف ديوانية أصيلة', price: '140,000', city: 'الديوانية', cityTag: 'DIWANIYAH WOOL'),
    MarketplaceProduct(name: 'مزهرية طينية بابلية تراثية', price: '175,000', city: 'بغداد', cityTag: 'BABYLON CLAY'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCity == 'الكل' ? _products : _products.where((p) => p.city == _selectedCity).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryCards(),
              _buildCityFilters(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final product = filtered[i];
                    return MarketplaceProductCard(
                      product: product,
                      isFavorite: _favoriteNames.contains(product.name),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                      onFavoriteToggle: () => setState(() {
                        if (_favoriteNames.contains(product.name)) {
                          _favoriteNames.remove(product.name);
                        } else {
                          _favoriteNames.add(product.name);
                        }
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.menu, color: AppColors.gold), onPressed: () {}),
          const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.gold), onPressed: () {}),
              if (_hasNotifications)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {}, // TODO: فتح search_screen عند بنائها
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.5))),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('ابحث عن التحف والأعمال اليدوية...', style: TextStyle(color: AppColors.subText, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    return SizedBox(
      height: 130,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: kAppCategories.map((category) {
            final selected = _selectedCategory == category.id;
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category.id),
                child: Container(
                  width: 100,
                  height: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.gold : Colors.transparent, width: 2),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(category.imagePath, fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.4)),
                      Positioned(
                        bottom: 8,
                        left: 4,
                        right: 4,
                        child: Text(
                          category.nameAr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCityFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _cities.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final city = _cities[i];
          final selected = _selectedCity == city;
          return GestureDetector(
            onTap: () => setState(() => _selectedCity = city),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(selected ? 1 : 0.4)),
              ),
              child: Center(
                child: Text(city, style: TextStyle(color: selected ? Colors.black : AppColors.text, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onNavTap(int index) async {
    switch (index) {
      case 2:
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()));
        setState(() => _navIndex = 1);
        break;
      case 3:
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfileScreen()));
        setState(() => _navIndex = 1);
        break;
      default:
        setState(() => _navIndex = index); // "الرئيسية" لا شاشة مخصصة لها بعد
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF111111)),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: const Color(0xFF888888),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'المتجر'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'الحساب'),
        ],
      ),
    );
  }
}
