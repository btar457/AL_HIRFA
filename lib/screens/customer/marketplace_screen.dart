import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/categories.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';
import '../shared/notifications_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

MarketplaceProduct _toMarketplaceProduct(ProductModel product) {
  return MarketplaceProduct(
    name: product.name,
    price: _formatPrice(product.price),
    city: product.city,
    cityTag: product.city.toUpperCase(),
  );
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCity = 'الكل';
  String _selectedCategory = 'all';

  final _cities = const ['الكل', 'نجف', 'بصرة', 'بغداد', 'أربيل', 'موصل', 'كربلاء', 'الديوانية'];

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.uid;

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
                child: StreamBuilder<List<ProductModel>>(
                  stream: ProductService.instance.getActiveProducts(city: _selectedCity == 'الكل' ? null : _selectedCity, categoryId: _selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('تعذّر تحميل المنتجات', style: TextStyle(color: AppColors.subText)));
                    }
                    if (!snapshot.hasData) {
                      return const ProductGridShimmer();
                    }
                    final products = snapshot.data!;
                    if (products.isEmpty) {
                      return Center(child: Text('لا توجد منتجات حالياً', style: TextStyle(color: AppColors.subText)));
                    }
                    return StreamBuilder<Set<String>>(
                      stream: userId == null ? Stream.value(const <String>{}) : ProductService.instance.getFavoriteIds(userId),
                      builder: (context, favSnapshot) {
                        final favoriteIds = favSnapshot.data ?? const <String>{};
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
                          itemCount: products.length,
                          itemBuilder: (context, i) {
                            final product = products[i];
                            return MarketplaceProductCard(
                              product: _toMarketplaceProduct(product),
                              isFavorite: favoriteIds.contains(product.id),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                              onFavoriteToggle: userId == null ? null : () => ProductService.instance.toggleFavorite(product.id, userId),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
          Consumer<NotificationProvider>(
            builder: (context, notifications, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.gold),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
                if (notifications.unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
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
}
