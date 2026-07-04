import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// سياسة الخصوصية الكاملة (راجع AL-HIRFA-Legal-Rules.md — PART 8).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _buyerData = [
    'الاسم، البريد، الهاتف، العنوان',
    'سجل الطلبات والتقييمات',
    'سلوك التصفح (للتوصيات)',
  ];

  static const _artisanData = [
    'الهوية المهنية، IBAN، الموقع',
    'سجل المنتجات والمبيعات',
  ];

  static const _shippingData = [
    'بيانات الشركة، IBAN، السجل التجاري',
    'سجل التوصيلات',
  ];

  static const _securityMeasures = [
    'تشفير HTTPS لكل الاتصالات',
    'Firebase Security Rules لحماية Firestore',
    'IBAN مشفّر في قاعدة البيانات',
    'رمز QR للتحقق من هوية المنتج',
    'لا يرى المشتري رقم IBAN الحرفي',
    'لا يرى الحرفي بيانات بطاقة المشتري',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('سياسة الخصوصية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'نحرص في AL-HIRFA على حماية بياناتك الشخصية، ونجمع فقط ما يلزم لتشغيل المنصة وتقديم تجربة آمنة لجميع الأطراف.',
              style: TextStyle(color: AppColors.subText, fontSize: 13, height: 24 / 14),
            ),
            const SizedBox(height: 24),
            const Text('البيانات المجمّعة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildSection(title: 'من المشتري', points: _buyerData),
            const SizedBox(height: 16),
            _buildSection(title: 'من الحرفي', points: _artisanData),
            const SizedBox(height: 16),
            _buildSection(title: 'من شركة الشحن', points: _shippingData),
            const SizedBox(height: 16),
            _buildNotice('لا تُشارك بياناتك مع أي طرف ثالث، إلا بأمر قانوني صادر من الجهات المختصة.'),
            const SizedBox(height: 24),
            const Text('أمان البيانات', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildSection(title: 'الإجراءات المتّبعة', points: _securityMeasures),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> points}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(child: Text(point, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNotice(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.4))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 14))),
        ],
      ),
    );
  }
}
