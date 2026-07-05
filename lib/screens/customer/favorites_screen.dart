import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'customer_nav.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<MarketplaceProduct> _favorites = [
    const MarketplaceProduct(name: 'سجادة حرير نجفية مطرزة يدوياً', price: '450,000', city: 'نجف', cityTag: 'NAJAF SILK'),
    const MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'بصرة', cityTag: 'BASRA COPPER'),
    const MarketplaceProduct(name: 'منحوتة حجرية موصلية', price: '295,000', city: 'موصل', cityTag: 'MOSUL STONE'),
  ];

  void _removeFavorite(MarketplaceProduct product) {
    setState(() => _favorites.removeWhere((p) => p.name == product.name));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text('المفضلة (${_favorites.length})', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: _favorites.isEmpty ? _buildEmptyState() : _buildFavoritesGrid(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, color: Color(0xFF555555), size: 80),
            const SizedBox(height: 20),
            const Text('لا توجد منتجات في المفضلة', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildFavoritesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: _favorites.length,
      itemBuilder: (context, i) {
        final product = _favorites[i];
        return Dismissible(
          key: ValueKey(product.name),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeFavorite(product),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: MarketplaceProductCard(
            product: product,
            isFavorite: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: ProductModel.fromMarketplaceProduct(product)))),
            onFavoriteToggle: () => _removeFavorite(product),
          ),
        );
      },
    );
  }
}
