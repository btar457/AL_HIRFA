import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'product_detail_screen.dart';

class _Review {
  final String reviewerName;
  final int rating;
  final String comment;
  final String date;
  const _Review({required this.reviewerName, required this.rating, required this.comment, required this.date});
}

class ArtisanPublicProfileScreen extends StatefulWidget {
  const ArtisanPublicProfileScreen({super.key});
  @override
  State<ArtisanPublicProfileScreen> createState() => _ArtisanPublicProfileScreenState();
}

class _ArtisanPublicProfileScreenState extends State<ArtisanPublicProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  final _products = const [
    MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'بصرة', cityTag: 'BASRA COPPER'),
    MarketplaceProduct(name: 'طقم نحاسيات بغدادية مذهبة', price: '380,000', city: 'بغداد', cityTag: 'BAGHDAD BRASS'),
    MarketplaceProduct(name: 'مزهرية طينية بابلية تراثية', price: '175,000', city: 'بغداد', cityTag: 'BABYLON CLAY'),
  ];

  final _reviews = const [
    _Review(reviewerName: 'سارة العبيدي', rating: 5, comment: 'قطعة رائعة ودقة صنع عالية، تسليم سريع.', date: '٢٨ يونيو ٢٠٢٦'),
    _Review(reviewerName: 'محمد الكناني', rating: 4, comment: 'جودة ممتازة، أنصح بالتعامل مع الحرفي.', date: '١٥ يونيو ٢٠٢٦'),
    _Review(reviewerName: 'نور الزهراوي', rating: 5, comment: 'تفاصيل النقش دقيقة جداً وتطابق الوصف تماماً.', date: '٢ يونيو ٢٠٢٦'),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildInfo(),
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
            children: [_buildProductsTab(), _buildReviewsTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                child: const Icon(Icons.person, color: AppColors.gold, size: 38),
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

  Widget _buildInfo() {
    return Column(
      children: [
        const Text('أبو مصطفى', textAlign: TextAlign.center, style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('بغداد — نحاسيات وأعمال معدنية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 13)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat(Icons.star, 'التقييم', '٤.٨'),
            _statDivider(),
            _buildStat(Icons.inventory_2_outlined, 'المبيعات', '٣٢٠'),
            _statDivider(),
            _buildStat(Icons.calendar_today_outlined, 'الخبرة', '١٢ سنة'),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'حرفي عراقي متخصص في صناعة النحاسيات منذ أكثر من عقد، يجمع بين الأصالة والدقة في كل قطعة يصنعها بيديه.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subText, fontSize: 13, height: 1.6),
          ),
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

  Widget _buildProductsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: _products.length,
      itemBuilder: (context, i) {
        final product = _products[i];
        return MarketplaceProductCard(
          product: product,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: ProductModel.fromMarketplaceProduct(product)))),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, i) {
        final review = _reviews[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background, border: Border.all(color: AppColors.gold.withOpacity(0.4))),
                    child: const Icon(Icons.person, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(review.reviewerName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: AppColors.gold, size: 16)),
              ),
              const SizedBox(height: 8),
              Text(review.comment, style: TextStyle(color: AppColors.subText, fontSize: 13, height: 1.5)),
              const SizedBox(height: 8),
              Text(review.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
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
