import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/common/product_form.dart';
import '../../core/settings/app_prefs.dart';

class EditProductScreen extends StatelessWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    return ProductForm(
      initialProduct: product,
      title: tr('تعديل المنتج', 'Edit product'),
      submitLabel: tr('حفظ التعديلات', 'Save changes'),
      successTitle: tr('تم حفظ التعديلات', 'Changes saved'),
      successMessage: tr('تم تحديث بيانات "${product.name}" بنجاح.', '"${product.name}" was updated.'),
    );
  }
}
