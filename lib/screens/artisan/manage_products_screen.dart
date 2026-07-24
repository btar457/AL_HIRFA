import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});
  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> _productsFor(List<ProductModel> all, String? status) {
    // 'deleted' حذف ناعم (product_service.dart: deleteProduct) — لا يظهر
    // للحرفي في أي تبويب هنا، بما فيها "الكل"، رغم بقائه في القاعدة لأجل
    // متوسط التقييم العام (artisan_public_profile_screen.dart).
    if (status == null) return all.where((p) => p.status != 'deleted').toList();
    return all.where((p) => p.status == status).toList();
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('حذف المنتج؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('لا يمكن التراجع عن حذف "${product.name}".', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await ProductService.instance.deleteProduct(product.id);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
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
    final artisanUid = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('منتجاتي', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'الكل'), Tab(text: 'نشط'), Tab(text: 'معلق'), Tab(text: 'مرفوض')],
          ),
        ),
        body: artisanUid == null
            ? Center(child: Text('سجّل الدخول لعرض منتجاتك', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<ProductModel>>(
                stream: ProductService.instance.getArtisanProducts(artisanUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل المنتجات', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final products = snapshot.data!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductsList(_productsFor(products, null)),
                      _buildProductsList(_productsFor(products, 'active')),
                      _buildProductsList(_productsFor(products, 'pending')),
                      _buildProductsList(_productsFor(products, 'rejected')),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.gold,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductsList(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, i) => _buildProductCard(products[i]),
    );
  }

  Widget _buildProductCard(ProductModel product) {
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
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                ),
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(imageUrl: product.images.first, fit: BoxFit.cover)
                    : const Icon(Icons.auto_awesome, color: AppColors.gold, size: 30),
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
                    Text('د.ع ${_formatPrice(product.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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

  Widget _buildStatusChip(String status) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case 'active':
        bg = Colors.green.withOpacity(0.2);
        fg = Colors.green;
        label = 'نشط';
        break;
      case 'pending':
        bg = Colors.grey.withOpacity(0.2);
        fg = Colors.grey;
        label = 'معلق';
        break;
      case 'suspended':
        bg = Colors.orange.withOpacity(0.2);
        fg = Colors.orange;
        label = 'موقوف';
        break;
      default:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.red;
        label = 'مرفوض';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
