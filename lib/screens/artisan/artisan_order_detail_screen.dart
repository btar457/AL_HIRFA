import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../models/artisan_order.dart';

const int _kDeliveryFee = 5000;
const double _kCommissionRate = 0.10;

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

class ArtisanOrderDetailScreen extends StatelessWidget {
  final ArtisanOrder order;
  const ArtisanOrderDetailScreen({super.key, required this.order});

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final productTotal = _parsePrice(order.price) * order.quantity;
    final total = productTotal + _kDeliveryFee;
    final commission = (productTotal * _kCommissionRate).round();
    final net = total - commission;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text('تفاصيل الطلب ${order.orderNumber}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductCard(),
            const SizedBox(height: 16),
            _buildBuyerCard(),
            const SizedBox(height: 16),
            _buildShippingCard(),
            const SizedBox(height: 16),
            _buildInvoiceCard(productTotal, commission, net),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text('د.ع ${order.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('الكمية: ${order.quantity}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.buyerName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(order.buyerPhone, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: const StadiumBorder()),
                onPressed: () => _call(order.buyerPhone),
                icon: const Icon(Icons.call, color: AppColors.gold, size: 16),
                label: const Text('اتصال', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 8),
          Text('${order.province}، ${order.neighborhood}', style: const TextStyle(color: AppColors.text, fontSize: 13)),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(order.notes, style: TextStyle(color: AppColors.subText, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.gold, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.shippingCompany != null ? 'جاري الشحن' : 'بانتظار الشحن', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                if (order.shippingCompany != null) ...[
                  const SizedBox(height: 4),
                  Text(order.shippingCompany!, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
                if (order.shippingRepPhone != null) ...[
                  const SizedBox(height: 2),
                  Text('المندوب: ${order.shippingRepPhone}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(int productTotal, int commission, int net) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _invoiceRow('سعر المنتج', _formatPrice(productTotal)),
          const SizedBox(height: 8),
          _invoiceRow('سعر التوصيل', _formatPrice(_kDeliveryFee)),
          const SizedBox(height: 8),
          _invoiceRow('المجموع', _formatPrice(productTotal + _kDeliveryFee)),
          const SizedBox(height: 8),
          _invoiceRow('عمولة AL-HIRFA (10%)', '- ${_formatPrice(commission)}', valueColor: Colors.redAccent),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('صافي ربحك', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${_formatPrice(net)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 14)),
        Text('$value د.ع', style: TextStyle(color: valueColor ?? AppColors.text, fontSize: 14)),
      ],
    );
  }
}
