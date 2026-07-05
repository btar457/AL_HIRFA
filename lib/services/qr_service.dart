import '../models/product_model.dart';

/// يبني نص شهادة الأصالة لمنتج ليُشفَّر داخل رمز QR (AL-HIRFA-Firebase-Setup.md
/// — PART 10، المرحلة 8: اللمسات النهائية).
///
/// ملاحظة معمارية: لا توجد صفحة تحقق حية على خادم خارجي يشير إليها الرمز
/// (يتطلب ذلك واجهة API عامة منفصلة عن هذا التطبيق) — الرمز يحمل بيانات
/// الشهادة نفسها كنص مقروء مباشرة عند المسح، وليس رابطاً لصفحة تحقق فعلية.
class QrService {
  QrService._();
  static final QrService instance = QrService._();

  String buildCertificatePayload(ProductModel product) {
    return 'شهادة موثوقية AL-HIRFA\n'
        'المنتج: ${product.name}\n'
        'الحرفي: ${product.artisanName}\n'
        'رقم المنتج: ${product.id}\n'
        'تاريخ الإصدار: ${_formatDate(product.createdAt)}';
  }

  String _formatDate(DateTime date) {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
