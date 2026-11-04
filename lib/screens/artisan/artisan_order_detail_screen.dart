import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/report_problem_dialog.dart';
import '../../core/settings/app_prefs.dart';

// نفس تعريف الحالات القديمة (شركة شحن) في artisan_orders_screen.dart — طلبات
// عالقة من قبل إغلاق القسم مؤقتاً، لا مسار جديد يصل إليها الآن.
const _legacyShippingStatuses = {'shipping_assigned', 'picked_up'};

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class ArtisanOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const ArtisanOrderDetailScreen({super.key, required this.order});
  @override
  State<ArtisanOrderDetailScreen> createState() => _ArtisanOrderDetailScreenState();
}

class _ArtisanOrderDetailScreenState extends State<ArtisanOrderDetailScreen> {
  OrderModel get order => widget.order;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _acceptOrder() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('قبول الطلب؟', 'Accept the order?'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(tr('بعد قبولك، أنت المسؤول عن توصيل الطلب للزبون وتحصيل المبلغ كاشاً.', 'Once you accept, you\'re responsible for delivering the order and collecting the payment in cash.'), style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await OrderService.instance.sellerApproveOrder(order.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
              },
              child: Text(tr('تأكيد', 'Confirm'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectOrder() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('رفض الطلب', 'Reject order'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: tr('سبب الرفض', 'Reason for rejection'),
              hintStyle: TextStyle(color: AppColors.subText),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('تراجع', 'Back'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await OrderService.instance.sellerRejectOrder(order.id, reasonController.text.trim());
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
              },
              child: Text(tr('تأكيد الرفض', 'Confirm rejection'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelivery() {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('تأكيد التسليم؟', 'Confirm delivery?'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(tr('أكِّد فقط بعد تسليم المنتج فعلياً واستلام كامل المبلغ من الزبون.', 'Only confirm after you\'ve handed over the product and received the full payment.'), style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await OrderService.instance.confirmDelivery(order.id);
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
              },
              child: Text(tr('تم التسليم', 'Delivered'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: IconThemeData(color: AppColors.gold),
          title: Text(tr('تفاصيل الطلب ${order.orderNumber}', 'Order ${order.orderNumber}'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductCard(),
            const SizedBox(height: 16),
            _buildBuyerCard(),
            const SizedBox(height: 16),
            _buildDeliveryStatusCard(),
            const SizedBox(height: 16),
            _buildInvoiceCard(),
            if (order.status == 'pending' || order.status == 'seller_approved') ...[
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
            if (!['cancelled', 'disputed'].contains(order.status)) ...[
              const SizedBox(height: 16),
              _buildReportProblemButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (order.status == 'pending') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _acceptOrder,
              child: Text(tr('قبول الطلب', 'Accept order'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _rejectOrder,
              child: Text(tr('رفض الطلب', 'Reject order'), style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }
    // seller_approved
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: _confirmDelivery,
        child: Text(tr('تم التسليم', 'Delivered'), style: TextStyle(fontWeight: FontWeight.bold)),
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
                Text(order.productName, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(tr('د.ع ${_formatPrice(order.price)}', 'IQD ${_formatPrice(order.price)}'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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
                  Text(order.buyerName, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(order.buyerPhone, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: const StadiumBorder()),
                onPressed: () => _call(order.buyerPhone),
                icon: Icon(Icons.call, color: AppColors.gold, size: 16),
                label: Text(tr('اتصال', 'Call'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Text('${order.governorate}، ${order.district}', style: TextStyle(color: AppColors.text, fontSize: 13)),
          if (order.addressNotes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(order.addressNotes, style: TextStyle(color: AppColors.subText, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  /// بطاقة حالة التوصيل — تعكس فعلياً من المسؤول عن التوصيل حسب حالة الطلب،
  /// بدل بطاقة "جاري الشحن" الثابتة القديمة التي كانت تظهر دائماً حتى بعد
  /// إغلاق قسم شركات الشحن (الحرفي أصبح هو من يوصّل الطلب بنفسه الآن).
  Widget _buildDeliveryStatusCard() {
    if (_legacyShippingStatuses.contains(order.status)) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.local_shipping_outlined, color: AppColors.gold, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.shippingCompanyName != null ? tr('جاري الشحن', 'Shipping') : tr('بانتظار الشحن', 'Awaiting shipping'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
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
    if (order.status == 'seller_approved') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.4))),
        child: Row(
          children: [
            Icon(Icons.delivery_dining_outlined, color: AppColors.gold, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(tr('أنت مسؤول عن توصيل هذا الطلب وتحصيل المبلغ كاشاً من الزبون', 'You\'re responsible for delivering this order and collecting the cash payment'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      );
    }
    if (order.status == 'delivered') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
            SizedBox(width: 12),
            Text(tr('تم التسليم', 'Delivered'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _invoiceRow(tr('سعر المنتج', 'Product price'), _formatPrice(order.price)),
          const SizedBox(height: 8),
          _invoiceRow(tr('سعر التوصيل', 'Delivery fee'), _formatPrice(order.deliveryFee)),
          const SizedBox(height: 8),
          _invoiceRow(tr('المجموع', 'Total'), _formatPrice(order.totalAmount)),
          const SizedBox(height: 8),
          _invoiceRow(tr('عمولة AL-HIRFA', 'AL-HIRFA commission'), '- ${_formatPrice(order.platformFee)}', valueColor: Colors.redAccent),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('صافي ربحك', 'Your net earnings'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(tr('${_formatPrice(order.artisanEarnings)} د.ع', '${_formatPrice(order.artisanEarnings)} IQD'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
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
        icon: Icon(Icons.report_problem_outlined, color: AppColors.subText, size: 18),
        label: Text(tr('الإبلاغ عن مشكلة', 'Report a problem'), style: TextStyle(color: AppColors.subText, fontSize: 13)),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 14)),
        Text(tr('$value د.ع', '$value IQD'), style: TextStyle(color: valueColor ?? AppColors.text, fontSize: 14)),
      ],
    );
  }
}
