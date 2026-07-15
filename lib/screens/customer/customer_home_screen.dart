import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/categories.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../widgets/common/marketplace_product_card.dart';
import '../shared/notifications_screen.dart';
import 'marketplace_screen.dart';
import 'orders_history_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

const _activeOrderStatuses = {'pending', 'seller_approved', 'shipping_assigned', 'picked_up'};

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
  return MarketplaceProduct(name: product.name, price: _formatPrice(product.price), city: product.city, cityTag: product.city.toUpperCase());
}

/// الشاشة الرئيسية للمشتري: ترحيب، وصول سريع للطلبات النشطة والفئات،
/// وأحدث المنتجات المضافة.
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context, user?.name ?? ''),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.5))),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('ابحث عن التحف والأعمال اليدوية...', style: TextStyle(color: AppColors.subText, fontSize: 13))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (user != null) _buildActiveOrdersCard(context, user.uid),
              const SizedBox(height: 20),
              const Text('تصفّح حسب الفئة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              _buildCategoriesGrid(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('أحدث المنتجات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
                    child: const Text('عرض الكل', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              _buildLatestProducts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
            if (name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('مرحباً، $name', style: TextStyle(color: AppColors.subText, fontSize: 13)),
            ],
          ],
        ),
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
    );
  }

  Widget _buildActiveOrdersCard(BuildContext context, String buyerUid) {
    return StreamBuilder(
      stream: OrderService.instance.getBuyerOrders(buyerUid),
      builder: (context, snapshot) {
        final activeCount = (snapshot.data ?? const []).where((o) => _activeOrderStatuses.contains(o.status)).length;
        if (activeCount == 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)])),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: Colors.black),
                const SizedBox(width: 10),
                Expanded(child: Text('لديك $activeCount طلب قيد التنفيذ — اضغط للمتابعة', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13))),
                const Icon(Icons.arrow_back_ios, color: Colors.black, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = kAppCategories.where((c) => c.id != 'all').toList();
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final category = categories[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarketplaceScreen(initialCategory: category.id))),
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(category.imagePath, width: 64, height: 64, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 6),
                  Text(category.nameAr, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestProducts(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.uid;
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService.instance.getActiveProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator(color: AppColors.gold)));
        }
        final products = snapshot.data!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latest = products.take(6).toList();
        if (latest.isEmpty) {
          return Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('لا توجد منتجات بعد', style: TextStyle(color: AppColors.subText))));
        }
        return GridView.builder(
          padding: const EdgeInsets.only(top: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
          itemCount: latest.length,
          itemBuilder: (context, i) {
            final product = latest[i];
            return MarketplaceProductCard(
              product: _toMarketplaceProduct(product),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
              onFavoriteToggle: userId == null ? null : () => ProductService.instance.toggleFavorite(product.id, userId),
            );
          },
        );
      },
    );
  }
}
