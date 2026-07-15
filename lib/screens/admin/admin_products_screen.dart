import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../customer/product_detail_screen.dart';

/// إدارة المنتجات على مستوى المنصة (ADMIN-10).
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reject(ProductModel product) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('رفض المنتج', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'سبب الرفض', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                await ProductService.instance.rejectProduct(product.id, reason);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.bold)),
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
          title: const Text('إدارة المنتجات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'قيد المراجعة'), Tab(text: 'منشورة'), Tab(text: 'موقوفة'), Tab(text: 'مرفوضة')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList('pending'),
            _buildList('active'),
            _buildList('suspended'),
            _buildList('rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String status) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService.instance.getProductsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('تعذّر تحميل المنتجات', style: TextStyle(color: AppColors.subText)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final products = snapshot.data!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (products.isEmpty) return Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, i) => _buildCard(products[i]),
        );
      },
    );
  }

  Widget _buildCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)])),
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(imageUrl: product.images.first, fit: BoxFit.cover)
                    : const Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('د.ع ${product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(product.artisanName, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (product.status == 'pending')
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))), child: const Text('معاينة', style: TextStyle(color: AppColors.gold, fontSize: 12)))),
                const SizedBox(width: 6),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => ProductService.instance.approveProduct(product.id), child: const Text('موافقة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 6),
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _reject(product), child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontSize: 12)))),
              ],
            )
          else if (product.status == 'active')
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => ProductService.instance.suspendProduct(product.id), child: const Text('إيقاف', style: TextStyle(color: Colors.orange, fontSize: 12)))),
              ],
            )
          else if (product.status == 'suspended')
            Row(
              children: [
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => ProductService.instance.reactivateProduct(product.id), child: const Text('إعادة تفعيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
              ],
            ),
        ],
      ),
    );
  }
}
