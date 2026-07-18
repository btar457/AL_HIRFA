import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/report_problem_dialog.dart';

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
  final OrderModel order;
  const ArtisanOrderDetailScreen({super.key, required this.order});

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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
            _buildInvoiceCard(),
            if (!['cancelled', 'disputed'].contains(order.status)) ...[
              const SizedBox(height: 16),
              _buildReportProblemButton(context),
            ],
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
          ProductThumbnail(imageUrl: order.productImage, size: 120, borderRadius: 10, iconSize: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text('د.ع ${_formatPrice(order.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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
          Text('${order.governorate}، ${order.district}', style: const TextStyle(color: AppColors.text, fontSize: 13)),
          if (order.addressNotes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(order.addressNotes, style: TextStyle(color: AppColors.subText, fontSize: 12)),
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
                Text(order.shippingCompanyName != null ? 'جاري الشحن' : 'بانتظار الشحن', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                if (order.shippingCompanyName != null) ...[
                  const SizedBox(height: 4),
                  Text(order.shippingCompanyName!, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _invoiceRow('سعر المنتج', _formatPrice(order.price)),
          const SizedBox(height: 8),
          _invoiceRow('سعر التوصيل', _formatPrice(order.deliveryFee)),
          const SizedBox(height: 8),
          _invoiceRow('المجموع', _formatPrice(order.totalAmount)),
          const SizedBox(height: 8),
          _invoiceRow('عمولة AL-HIRFA', '- ${_formatPrice(order.platformFee)}', valueColor: Colors.redAccent),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('صافي ربحك', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${_formatPrice(order.artisanEarnings)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportProblemButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.subText.withOpacity(0.4)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () {
          final artisanUid = context.read<AuthProvider>().currentUser?.uid;
          if (artisanUid == null) return;
          showReportProblemDialog(context, orderId: order.id, reporterUid: artisanUid, reportedUid: order.buyerUid, disputeType: 'artisan_report');
        },
        icon: const Icon(Icons.report_problem_outlined, color: AppColors.subText, size: 18),
        label: Text('الإبلاغ عن مشكلة', style: TextStyle(color: AppColors.subText, fontSize: 13)),
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
