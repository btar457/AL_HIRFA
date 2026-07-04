import 'package:flutter/material.dart';
import '../../widgets/common/product_form.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProductForm(
      title: 'إضافة منتج جديد',
      submitLabel: 'نشر المنتج',
      successTitle: 'تم إرسال المنتج للمراجعة',
      successMessage: 'سيظهر المنتج في قائمتك بحالة "معلق" حتى تتم مراجعته.',
    );
  }
}
