import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../../core/settings/app_prefs.dart';

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
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('حذف المنتج؟', 'Delete product?'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(tr('لا يمكن التراجع عن حذف "${product.name}".', 'Deleting "${product.name}" can\'t be undone.'), style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await ProductService.instance.deleteProduct(product.id);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: Text(tr('حذف', 'Delete'), style: TextStyle(fontWeight: FontWeight.bold)),
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
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: Text(tr('منتجاتي', 'My products'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: [Tab(text: tr('الكل', 'All')), Tab(text: tr('نشط', 'Active')), Tab(text: tr('معلق', 'Pending')), Tab(text: tr('مرفوض', 'Rejected'))],
          ),
        ),
        body: artisanUid == null
            ? Center(child: Text(tr('سجّل الدخول لعرض منتجاتك', 'Sign in to see your products'), style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<ProductModel>>(
                stream: ProductService.instance.getArtisanProducts(artisanUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(tr('تعذّر تحميل المنتجات', 'Couldn\'t load products'), style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color: AppColors.gold));
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
      return Center(child: Text(tr('لا توجد منتجات', 'No products'), style: TextStyle(color: AppColors.subText)));
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
                    : Icon(Icons.auto_awesome, color: AppColors.gold, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(product.name, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        _buildStatusChip(product.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(product.category, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(tr('د.ع ${_formatPrice(product.price)}', 'IQD ${_formatPrice(product.price)}'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (product.stock == null)
                      Text(tr('الكمية غير محددة — حدّثها من "تعديل"', 'Quantity not set — update it from "Edit"'), style: TextStyle(color: AppColors.subText, fontSize: 12))
                    else if (product.isOutOfStock)
                      Text(tr('نفدت الكمية — اضغط "تعديل" لإضافة كمية', 'Out of stock — tap "Edit" to add quantity'), style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))
                    else
                      Text(tr('الكمية المتوفرة: ${product.stock}', 'In stock: ${product.stock}'), style: TextStyle(color: product.stock! <= 2 ? Colors.orange : AppColors.subText, fontSize: 12)),
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
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: product))),
                  child: Text(tr('تعديل', 'Edit'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _confirmDelete(product),
                  child: Text(tr('حذف', 'Delete'), style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
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
        label = tr('نشط', 'Active');
        break;
      case 'pending':
        bg = Colors.grey.withOpacity(0.2);
        fg = Colors.grey;
        label = tr('معلق', 'Pending');
        break;
      case 'suspended':
        bg = Colors.orange.withOpacity(0.2);
        fg = Colors.orange;
        label = tr('موقوف', 'Suspended');
        break;
      default:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.red;
        label = tr('مرفوض', 'Rejected');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
