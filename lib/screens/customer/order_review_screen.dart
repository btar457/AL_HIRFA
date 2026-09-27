import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../services/review_service.dart';
import 'orders_history_screen.dart';

/// شاشة تقييم المشتري لطلب مكتمل (CUSTOMER-11).
class OrderReviewScreen extends StatefulWidget {
  final OrderModel order;
  const OrderReviewScreen({super.key, required this.order});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  static const _ratingLabels = {
    1: 'سيء جداً',
    2: 'سيء',
    3: 'مقبول',
    4: 'جيد',
    5: 'ممتاز!',
  };

  Future<void> _submit() async {
    final buyer = context.read<AuthProvider>().currentUser;
    if (buyer == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ReviewService.instance.submitReview(
        orderId: widget.order.id,
        productId: widget.order.productId,
        buyerUid: buyer.uid,
        buyerName: buyer.name,
        buyerPhotoUrl: buyer.photoUrl,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (!mounted) return;
      _showThankYouDialog();
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('شكراً لتقييمك!', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: Text('تم إرسال تقييمك بنجاح.', style: TextStyle(color: AppColors.subText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()), (route) => route.isFirst),
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
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
          title: const Text('تقييم طلبك', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProductCard(),
              const SizedBox(height: 28),
              _buildStars(),
              const SizedBox(height: 10),
              Text(
                _rating == 0 ? 'اختر تقييمك' : _ratingLabels[_rating]!,
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: Text('ملاحظاتك حول المنتج', style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'اكتب تقييمك هنا...',
                  hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.card,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: (_rating > 0 && !_isSubmitting) ? _submit : null,
                  icon: _isSubmitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.send_outlined),
                  label: const Text('إرسال التقييم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ProductThumbnail(imageUrl: widget.order.productImage, size: 100, borderRadius: 12, iconSize: 32),
          const SizedBox(height: 12),
          Text(widget.order.productName, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(widget.order.artisanName, style: TextStyle(color: AppColors.subText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final selected = i < _rating;
        return GestureDetector(
          onTap: () => setState(() => _rating = i + 1),
          child: AnimatedScale(
            scale: selected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.star, size: 40, color: selected ? AppColors.gold : AppColors.subText.withOpacity(0.4)),
            ),
          ),
        );
      }),
    );
  }
}
