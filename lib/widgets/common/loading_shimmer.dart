import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';

/// مستطيل وامض (Shimmer) بلون التطبيق — لبناء هياكل تحميل (Skeletons) بدل
/// مؤشرات الدوران أثناء أول تحميل لأي StreamBuilder/FutureBuilder.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({super.key, this.width, required this.height, this.borderRadius = const BorderRadius.all(Radius.circular(8))});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.gold.withOpacity(0.15),
      child: Container(width: width, height: height, decoration: BoxDecoration(color: AppColors.card, borderRadius: borderRadius)),
    );
  }
}

/// هيكل تحميل لشبكة بطاقات منتجات (مثل marketplace_screen)، بنفس أبعاد
/// MarketplaceProductCard تقريباً حتى لا تقفز الواجهة عند وصول البيانات.
class ProductGridShimmer extends StatelessWidget {
  final int itemCount;
  const ProductGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: itemCount,
      itemBuilder: (context, i) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 12),
          const SizedBox(height: 6),
          ShimmerBox(width: 80, height: 12),
        ],
      ),
    );
  }
}

/// هيكل تحميل لقائمة صفوف أفقية (سجل معاملات/طلبات) — صف واحد يتكرر.
class ListRowShimmer extends StatelessWidget {
  final int itemCount;
  const ListRowShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ShimmerBox(width: double.infinity, height: 64, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
