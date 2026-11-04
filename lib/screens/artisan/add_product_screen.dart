import 'package:flutter/material.dart';
import '../../widgets/common/product_form.dart';
import '../../core/settings/app_prefs.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ProductForm(
      title: tr('إضافة منتج جديد', 'Add new product'),
      submitLabel: tr('نشر المنتج', 'Publish product'),
      successTitle: tr('تم إرسال المنتج للمراجعة', 'Product sent for review'),
      successMessage: tr('سيظهر المنتج في قائمتك بحالة "معلق" حتى تتم مراجعته.', 'The product will appear in your list as "Pending" until it\'s reviewed.'),
    );
  }
}
