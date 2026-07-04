import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/artisan_product_listing.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});
  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  final List<ArtisanProductListing> _products = [
    const ArtisanProductListing(name: 'إناء نحاسي منقوش', category: 'نحاسيات', price: '125,000', status: ArtisanProductStatus.active),
    const ArtisanProductListing(name: 'طبق نحاسي مزخرف', category: 'نحاسيات', price: '90,000', status: ArtisanProductStatus.pending),
    const ArtisanProductListing(name: 'إبريق نحاسي بصري', category: 'نحاسيات', price: '210,000', status: ArtisanProductStatus.active),
    const ArtisanProductListing(name: 'شمعدان نحاسي قديم', category: 'نحاسيات', price: '65,000', status: ArtisanProductStatus.rejected),
    const ArtisanProductListing(name: 'مرآة نحاسية منقوشة', category: 'نحاسيات', price: '150,000', status: ArtisanProductStatus.pending),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ArtisanProductListing> _productsFor(ArtisanProductStatus? status) {
    if (status == null) return _products;
    return _products.where((p) => p.status == status).toList();
  }

  void _confirmDelete(ArtisanProductListing product) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('حذف المنتج؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('لا يمكن التراجع عن حذف "${product.name}".', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                setState(() => _products.remove(product));
                Navigator.pop(context);
              },
              child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: Text('منتجاتي (${_products.length})', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'الكل'), Tab(text: 'نشط'), Tab(text: 'معلق'), Tab(text: 'مرفوض')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsList(_productsFor(null)),
            _buildProductsList(_productsFor(ArtisanProductStatus.active)),
            _buildProductsList(_productsFor(ArtisanProductStatus.pending)),
            _buildProductsList(_productsFor(ArtisanProductStatus.rejected)),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.gold,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductsList(List<ArtisanProductListing> products) {
    if (products.isEmpty) {
      return Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, i) => _buildProductCard(products[i]),
    );
  }

  Widget _buildProductCard(ArtisanProductListing product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        _buildStatusChip(product.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(product.category, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('د.ع ${product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: product))),
                  child: const Text('تعديل', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _confirmDelete(product),
                  child: const Text('حذف', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ArtisanProductStatus status) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case ArtisanProductStatus.active:
        bg = Colors.green.withOpacity(0.2);
        fg = Colors.green;
        label = 'نشط';
        break;
      case ArtisanProductStatus.pending:
        bg = Colors.grey.withOpacity(0.2);
        fg = Colors.grey;
        label = 'معلق';
        break;
      case ArtisanProductStatus.rejected:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.red;
        label = 'مرفوض';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
