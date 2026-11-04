import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';

/// الشروط والأحكام الكاملة (راجع AL-HIRFA-Legal-Rules.md — "ملخص القوانين للمستخدمين").
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static List<String> get _buyerRules => [
    tr('ادفع كاشاً عند الاستلام فقط', 'Pay cash on delivery only'),
    tr('افحص المنتج قبل الدفع للمندوب', 'Inspect the product before paying'),
    tr('يحق لك رفض المنتج التالف أو المختلف عمّا طلبته دون أي التزام بالدفع', 'You may refuse a damaged product, or one different from what you ordered, without paying'),
    tr('قيّم تجربتك خلال 7 أيام', 'Rate your experience within 7 days'),
    tr('عند وجود خلاف حول طلب، افتح بلاغاً من داخل التطبيق — تراجعه الإدارة وتفصل فيه خلال 48 ساعة', 'If there\'s a dispute about an order, open a report in the app — the admin reviews and decides within 48 hours'),
    tr('للشكاوى: تواصل معنا خلال 24 ساعة', 'For complaints: contact us within 24 hours'),
  ];

  static List<String> get _artisanRules => [
    tr('انشر منتجات حقيقية بصور حقيقية', 'Publish real products with real photos'),
    tr('رد على الطلبات خلال 48 ساعة', 'Respond to orders within 48 hours'),
    tr('قسم شركات الشحن مغلق مؤقتاً — أنت المسؤول عن توصيل طلباتك وتحصيل المبلغ كاشاً من الزبون مباشرة', 'Shipping companies are paused for now — you deliver your own orders and collect cash directly from the buyer'),
    tr('عمولة المنصة 5% من سعر المنتج فقط (لا تُحتسب على رسم التوصيل)، وتُسجَّل كمبلغ مستحق عليك تسدّده للمنصة لاحقاً نقداً باليد — راجع "عمولة مستحقة عليك" في لوحتك', 'The platform commission is 5% of the product price only (not the delivery fee). It\'s recorded as an amount you owe and pay to the platform later in cash — see "Commission you owe" on your dashboard'),
    tr('التأخر في سداد العمولة المستحقة شهراً كاملاً = تنبيه أول، ثم تنبيه ثانٍ وأخير بعد شهر آخر بلا سداد، ثم حظر تلقائي للحساب إن لم تستجب لأي من التنبيهين', 'Commission unpaid for a full month = first notice, then a second and final notice after another month, then automatic account suspension if neither is answered'),
    tr('3 رفضات متتالية = تحذير رسمي', '3 rejections in a row = official warning'),
  ];

  static List<String> get _shippingRules => [
    tr('⏸ قسم شركات الشحن مغلق مؤقتاً — البنود التالية غير مُفعَّلة حالياً وتخص الحسابات القديمة فقط', '⏸ Shipping companies are paused — the following terms are not active and apply to older accounts only'),
    tr('أجر ثابت 4,500 د.ع لكل توصيل', 'Fixed fee of 4,500 IQD per delivery'),
    tr('أول من يقبل يأخذ الطلب', 'First to accept gets the order'),
    tr('سدّد مستحقات المنصة كل جمعة', 'Pay platform dues every Friday'),
    tr('التأخر في السداد = غرامة 2% أسبوعياً', 'Late payment = 2% weekly penalty'),
    tr('التأمين المودع يحمي الطرفين', 'The deposit protects both parties'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(tr('الشروط والأحكام', 'Terms & conditions'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              tr('توضّح هذه الشروط حقوق والتزامات كل طرف على منصة AL-HIRFA. باستخدامك للمنصة فإنك توافق على الالتزام بها.', 'These terms set out the rights and obligations of each party on AL-HIRFA. By using the platform you agree to them.'),
              style: TextStyle(color: AppColors.subText, fontSize: 13, height: 24 / 14),
            ),
            const SizedBox(height: 24),
            _buildSection(title: tr('للمشتري', 'For buyers'), rules: _buyerRules),
            const SizedBox(height: 24),
            _buildSection(title: tr('للحرفي', 'For artisans'), rules: _artisanRules),
            const SizedBox(height: 24),
            _buildSection(title: tr('لشركة الشحن', 'For shipping companies'), rules: _shippingRules),
            const SizedBox(height: 24),
            Text(
              tr('يُدار تطبيق AL-HIRFA من قِبل Mustafa Alshlany (بغداد، العراق) — للتواصل الرسمي: mustafaalshlany@gmail.com', 'AL-HIRFA is operated by Mustafa Alshlany (Baghdad, Iraq) — official contact: mustafaalshlany@gmail.com'),
              style: TextStyle(color: AppColors.subText, fontSize: 12, height: 22 / 12),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> rules}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...rules.map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(child: Text(rule, style: TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
