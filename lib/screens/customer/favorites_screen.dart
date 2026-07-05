import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'customer_nav.dart';
import 'product_detail_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: const Text('المفضلة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: userId == null
            ? _buildEmptyState(context, 'سجّل الدخول لعرض المفضلة')
            : StreamBuilder<List<ProductModel>>(
                stream: ProductService.instance.getFavorites(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل المفضلة', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final favorites = snapshot.data!;
                  if (favorites.isEmpty) {
                    return _buildEmptyState(context, 'لا توجد منتجات في المفضلة');
                  }
                  return _buildFavoritesGrid(context, favorites, userId);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, color: Color(0xFF555555), size: 80),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('أضف منتجات تعجبك لمتابعتها لاحقاً', style: TextStyle(color: AppColors.subText, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerNav())),
              child: const Text('تصفح المتجر', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(BuildContext context, List<ProductModel> favorites, String userId) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: favorites.length,
      itemBuilder: (context, i) {
        final product = favorites[i];
        return Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => ProductService.instance.toggleFavorite(product.id, userId),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: MarketplaceProductCard(
            product: MarketplaceProduct(name: product.name, price: _formatPrice(product.price), city: product.city, cityTag: product.city.toUpperCase()),
            isFavorite: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
            onFavoriteToggle: () => ProductService.instance.toggleFavorite(product.id, userId),
          ),
        );
      },
    );
  }
}
