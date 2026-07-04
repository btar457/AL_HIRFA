import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/artisan_product_listing.dart';

/// تعديل منتج — سيتم بناؤها بالكامل في خطوة لاحقة من نفس المواصفات.
class EditProductScreen extends StatelessWidget {
  final ArtisanProductListing product;
  const EditProductScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, iconTheme: const IconThemeData(color: AppColors.gold), title: const Text('تعديل المنتج', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))),
        body: Center(child: Text(product.name, style: const TextStyle(color: AppColors.text))),
      ),
    );
  }
}
