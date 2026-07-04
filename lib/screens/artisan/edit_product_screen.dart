import 'package:flutter/material.dart';
import '../../models/artisan_product_listing.dart';
import '../../widgets/common/product_form.dart';

class EditProductScreen extends StatelessWidget {
  final ArtisanProductListing product;
  const EditProductScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    return ProductForm(
      initialProduct: product,
      title: 'تعديل المنتج',
      submitLabel: 'حفظ التعديلات',
      successTitle: 'تم حفظ التعديلات',
      successMessage: 'تم تحديث بيانات "${product.name}" بنجاح.',
    );
  }
}
