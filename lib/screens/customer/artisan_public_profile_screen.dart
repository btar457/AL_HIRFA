import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';
import '../../services/review_service.dart';
import '../../widgets/common/marketplace_product_card.dart';
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

MarketplaceProduct _toMarketplaceProduct(ProductModel product) {
  return MarketplaceProduct(name: product.name, price: _formatPrice(product.price), city: product.city, cityTag: product.city.toUpperCase(), imageUrl: product.images.isNotEmpty ? product.images.first : '');
}

class _ArtisanProfileData {
  final UserModel artisan;
  final List<ProductModel> products;
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalSales;
  const _ArtisanProfileData({required this.artisan, required this.products, required this.reviews, required this.averageRating, required this.totalSales});
}

/// الملف العام لحرفي (يُفتح من زر "زيارة الملف" في صفحة المنتج).
class ArtisanPublicProfileScreen extends StatefulWidget {
  final String artisanUid;
  const ArtisanPublicProfileScreen({super.key, required this.artisanUid});
  @override
  State<ArtisanPublicProfileScreen> createState() => _ArtisanPublicProfileScreenState();
}

class _ArtisanPublicProfileScreenState extends State<ArtisanPublicProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final Future<_ArtisanProfileData?> _dataFuture = _loadData();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<_ArtisanProfileData?> _loadData() async {
    final artisan = await AdminService.instance.getUserById(widget.artisanUid);
    if (artisan == null) return null;

    final allProducts = await ProductService.instance.getArtisanProducts(widget.artisanUid).first;
    final activeProducts = allProducts.where((p) => p.status == 'active').toList();

    final totalReviewCount = activeProducts.fold<int>(0, (sum, p) => sum + p.reviewCount);
    final weightedRatingSum = activeProducts.fold<double>(0, (sum, p) => sum + (p.rating * p.reviewCount));
    final averageRating = totalReviewCount > 0 ? weightedRatingSum / totalReviewCount : 0.0;
    final totalSales = activeProducts.fold<int>(0, (sum, p) => sum + p.salesCount);

    final reviews = await ReviewService.instance.getArtisanReviews(activeProducts.map((p) => p.id).toList());

    return _ArtisanProfileData(artisan: artisan, products: activeProducts, reviews: reviews, averageRating: averageRating, totalSales: totalSales);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FutureBuilder<_ArtisanProfileData?>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final data = snapshot.data;
            if (snapshot.hasError || data == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBackButton(),
                  const Spacer(),
                  Text('تعذّر تحميل ملف الحرفي', style: TextStyle(color: AppColors.subText)),
                  const Spacer(),
                ],
              );
            }
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildHeader(data.artisan),
                      const SizedBox(height: 16),
                      _buildInfo(data),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.gold,
                      labelColor: AppColors.gold,
                      unselectedLabelColor: AppColors.subText,
                      tabs: const [Tab(text: 'منتجاته'), Tab(text: 'تقييماته')],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [_buildProductsTab(data.products), _buildReviewsTab(data.reviews)],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.gold, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel artisan) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF1A1208)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.85)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                child: artisan.photoUrl.isEmpty
                    ? const Icon(Icons.person, color: AppColors.gold, size: 38)
                    : CachedNetworkImage(imageUrl: artisan.photoUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.gold, size: 38)),
              ),
            ),
          ),
          Positioned(
            top: 248,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.black, size: 12),
                    SizedBox(width: 4),
                    Text('حرفي موثّق', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(_ArtisanProfileData data) {
    return Column(
      children: [
        Text(data.artisan.name, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(data.artisan.city, textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 13)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat(Icons.star, 'التقييم', data.averageRating > 0 ? data.averageRating.toStringAsFixed(1) : '—'),
            _statDivider(),
            _buildStat(Icons.inventory_2_outlined, 'المبيعات', '${data.totalSales}'),
            _statDivider(),
            _buildStat(Icons.storefront_outlined, 'المنتجات', '${data.products.length}'),
          ],
        ),
      ],
    );
  }

  Widget _statDivider() => Container(width: 1, height: 30, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.gold.withOpacity(0.3));

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 11)),
      ],
    );
  }

  Widget _buildProductsTab(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(child: Text('لا توجد منتجات منشورة بعد', style: TextStyle(color: AppColors.subText)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return MarketplaceProductCard(
          product: _toMarketplaceProduct(product),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        );
      },
    );
  }

  Widget _buildReviewsTab(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return Center(child: Text('لا توجد تقييمات بعد', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, i) {
        final review = reviews[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.background,
                    backgroundImage: review.buyerPhotoUrl.isEmpty ? null : CachedNetworkImageProvider(review.buyerPhotoUrl),
                    child: review.buyerPhotoUrl.isEmpty ? const Icon(Icons.person, color: AppColors.gold, size: 20) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(review.buyerName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: AppColors.gold, size: 16)),
              ),
              if (review.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(review.comment, style: TextStyle(color: AppColors.subText, fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
