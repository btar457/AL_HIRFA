import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import 'checkout_screen.dart';
import 'marketplace_screen.dart';

const int _kDeliveryFee = 5000;

int _parsePrice(String price) => int.parse(price.replaceAll(',', ''));

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class _CartItem {
  final MarketplaceProduct product;
  int quantity;
  _CartItem({required this.product, this.quantity = 1});
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<_CartItem> _items = [
    _CartItem(product: const MarketplaceProduct(name: 'سجادة حرير نجفية مطرزة يدوياً', price: '450,000', city: 'نجف', cityTag: 'NAJAF SILK')),
    _CartItem(product: const MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'بصرة', cityTag: 'BASRA COPPER'), quantity: 2),
  ];

  int get _subtotal => _items.fold(0, (sum, item) => sum + _parsePrice(item.product.price) * item.quantity);

  void _removeItem(_CartItem item) => setState(() => _items.remove(item));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text('سلتي (${_items.length})', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: _items.isEmpty ? _buildEmptyState() : _buildCartBody(),
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
            const Icon(Icons.shopping_cart_outlined, color: Color(0xFF555555), size: 80),
            const SizedBox(height: 20),
            const Text('سلتك فارغة', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
              child: const Text('تصفح المتجر', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBody() {
    final total = _subtotal + _kDeliveryFee;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (context, i) => _buildCartItemCard(_items[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              _buildSummaryCard(total),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(product: _items.first.product))),
                  child: const Text('إتمام الشراء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(_CartItem item) {
    return Dismissible(
      key: ValueKey(item.product.name),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('أبو مصطفى', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('د.ع ${item.product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _quantityButton(icon: Icons.remove, onTap: () => setState(() => item.quantity = item.quantity > 1 ? item.quantity - 1 : 1)),
                      SizedBox(width: 36, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))),
                      _quantityButton(icon: Icons.add, onTap: () => setState(() => item.quantity++)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold)),
        child: Icon(icon, color: AppColors.gold, size: 14),
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _summaryRow('المجموع الفرعي', _formatPrice(_subtotal)),
          const SizedBox(height: 8),
          _summaryRow('سعر التوصيل', _formatPrice(_kDeliveryFee)),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع الكلي', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${_formatPrice(total)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 14)),
        Text('$value د.ع', style: const TextStyle(color: AppColors.text, fontSize: 14)),
      ],
    );
  }
}
