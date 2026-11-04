import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';

/// سياسة الخصوصية الكاملة (راجع AL-HIRFA-Legal-Rules.md — PART 8).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static List<String> get _buyerData => [
    tr('الاسم، البريد، الهاتف، العنوان', 'Name, email, phone, address'),
    tr('سجل الطلبات والتقييمات', 'Order and review history'),
    tr('صورة الملف الشخصي (اختياري)', 'Profile photo (optional)'),
  ];

  static List<String> get _artisanData => [
    tr('الهوية المهنية، الموقع', 'Professional identity, location'),
    tr('سجل المنتجات والمبيعات', 'Product and sales history'),
  ];

  static List<String> get _shippingData => [
    tr('بيانات الشركة، IBAN، السجل التجاري', 'Company details, IBAN, commercial registration'),
    tr('سجل التوصيلات', 'Delivery history'),
  ];

  static List<String> get _technicalData => [
    tr('رمز إشعارات الدفع (FCM Token) — لإرسال إشعارات الطلبات والتحديثات لجهازك', 'Push notification token (FCM) — to send order notifications and updates to your device'),
    tr('بيانات أعطال وتشخيص تقني (Firebase Crashlytics) — لتحسين استقرار التطبيق فقط', 'Crash and diagnostic data (Firebase Crashlytics) — only to improve app stability'),
  ];

  static List<String> get _thirdParties => [
    tr('Firebase (Google) — تسجيل الدخول، قاعدة البيانات، الإشعارات، وتقارير الأعطال', 'Firebase (Google) — sign-in, database, notifications and crash reports'),
    tr('Cloudflare R2 — تخزين صور المنتجات المرفوعة', 'Cloudflare R2 — storage for uploaded product photos'),
  ];

  static List<String> get _securityMeasures => [
    tr('تشفير HTTPS لكل الاتصالات', 'HTTPS encryption for all connections'),
    tr('Firebase Security Rules لحماية Firestore', 'Firebase Security Rules protecting the database'),
    tr('IBAN مشفّر في قاعدة البيانات', 'IBAN stored privately'),
    tr('رمز QR للتحقق من هوية المنتج', 'QR code to verify product authenticity'),
    tr('لا يرى المشتري رقم IBAN الحرفي', 'Buyers never see bank details'),
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
          title: Text(tr('سياسة الخصوصية', 'Privacy policy'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              tr('نحرص في AL-HIRFA على حماية بياناتك الشخصية، ونجمع فقط ما يلزم لتشغيل المنصة وتقديم تجربة آمنة لجميع الأطراف.', 'At AL-HIRFA we protect your personal data and collect only what\'s needed to run the platform and keep it safe for everyone.'),
              style: TextStyle(color: AppColors.subText, fontSize: 13, height: 24 / 14),
            ),
            const SizedBox(height: 24),
            Text(tr('البيانات المجمّعة', 'Data we collect'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildSection(title: tr('من المشتري', 'From buyers'), points: _buyerData),
            const SizedBox(height: 16),
            _buildSection(title: tr('من الحرفي', 'From artisans'), points: _artisanData),
            const SizedBox(height: 16),
            _buildSection(title: tr('من شركة الشحن', 'From shipping companies'), points: _shippingData),
            const SizedBox(height: 16),
            _buildSection(title: tr('بيانات تقنية', 'Technical data'), points: _technicalData),
            const SizedBox(height: 24),
            Text(tr('مزوّدو الخدمة (الأطراف الثالثة)', 'Service providers (third parties)'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildSection(title: tr('نستعين بهم لتشغيل المنصة فقط', 'Used only to run the platform'), points: _thirdParties),
            const SizedBox(height: 16),
            _buildNotice(tr('لا نبيع بياناتك ولا نشاركها لأغراض تسويقية مع أي جهة. مزوّدو الخدمة أعلاه يعالجون بياناتك تقنياً بصفتهم البنية التحتية للتطبيق فقط، ولا نفصح عنها لأي طرف آخر إلا بأمر قانوني صادر من الجهات المختصة.', 'We don\'t sell your data or share it for marketing. The providers above process it only as the app\'s technical infrastructure, and we disclose it to no one else except under a lawful order from the competent authorities.')),
            const SizedBox(height: 24),
            Text(tr('أمان البيانات', 'Data security'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildSection(title: tr('الإجراءات المتّبعة', 'Measures we take'), points: _securityMeasures),
            const SizedBox(height: 24),
            Text(tr('الحد الأدنى للعمر', 'Minimum age'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(tr('يجب أن يكون عمرك 18 عاماً فأكثر لإنشاء حساب وإجراء معاملات مالية عبر AL-HIRFA.', 'You must be 18 or older to create an account and make transactions on AL-HIRFA.'), style: TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 13)),
            const SizedBox(height: 24),
            Text(tr('حذف الحساب وبياناتك', 'Deleting your account and data'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildNotice(tr('يمكنك طلب حذف حسابك وجميع بياناتك الشخصية في أي وقت من "الملف الشخصي ← حذف الحساب"، أو بمراسلتنا على support@alhirfa.iq. تُحذف بياناتك خلال 30 يوماً كحد أقصى، عدا سجلات المعاملات المالية التي نحتفظ بها للامتثال القانوني.', 'You can delete your account and all your personal data at any time from "Profile → Delete account", or by emailing support@alhirfa.iq. Your data is deleted within 30 days at most, except financial transaction records kept for legal compliance.')),
            const SizedBox(height: 24),
            Text(tr('الجهة المسؤولة عن معالجة بياناتك', 'Who is responsible for your data'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(tr('يُدار تطبيق AL-HIRFA من قِبل Mustafa Alshlany (بغداد، العراق). للتواصل بخصوص بياناتك الشخصية: mustafaalshlany@gmail.com', 'AL-HIRFA is operated by Mustafa Alshlany (Baghdad, Iraq). For questions about your personal data: mustafaalshlany@gmail.com'), style: TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 13)),
            const SizedBox(height: 24),
            Center(
              child: Text(tr('آخر تحديث: سبتمبر 2026 — للاستفسارات: support@alhirfa.iq', 'Last updated: September 2026 — questions: support@alhirfa.iq'), style: TextStyle(color: AppColors.subText, fontSize: 11)),
            ),
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
          Text(title, style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(child: Text(point, style: TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14))),
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
          Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 14))),
        ],
      ),
    );
  }
}
