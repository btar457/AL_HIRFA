import '../core/constants/app_rules.dart';

/// إعدادات العمولات وسعر التوصيل القابلة للتعديل من لوحة الإدارة
/// (admin_commissions_screen) — تُقرأ من Firestore بدل ثوابت AppRules
/// الثابتة، مع الرجوع لقيم AppRules كافتراضي إن لم يُعدِّلها أحد بعد.
class AppSettingsModel {
  final double productCommission;
  final double shippingCommission;
  final int fixedDeliveryFee;
  final int platformDeliveryFee;
  final int companyNetDelivery;

  const AppSettingsModel({
    required this.productCommission,
    required this.shippingCommission,
    required this.fixedDeliveryFee,
    required this.platformDeliveryFee,
    required this.companyNetDelivery,
  });

  /// حصة AL-HIRFA من سعر التوصيل تبقى 10% منه (نفس نسبة الافتراضي
  /// 500/5000)، والباقي يذهب لشركة الشحن — كي يبقى السعران متّسقين مهما
  /// عدّلت الإدارة سعر التوصيل الكلي.
  factory AppSettingsModel.fromMap(Map<String, dynamic>? map) {
    final fixedDeliveryFee = (map?['fixedDeliveryFee'] as num?)?.toInt() ?? AppRules.fixedDeliveryFee;
    final platformDeliveryFee = (fixedDeliveryFee * 0.1).round();
    return AppSettingsModel(
      productCommission: (map?['productCommission'] as num?)?.toDouble() ?? AppRules.productCommission,
      shippingCommission: (map?['shippingCommission'] as num?)?.toDouble() ?? AppRules.shippingCommission,
      fixedDeliveryFee: fixedDeliveryFee,
      platformDeliveryFee: platformDeliveryFee,
      companyNetDelivery: fixedDeliveryFee - platformDeliveryFee,
    );
  }

  Map<String, dynamic> toMap() => {
    'productCommission': productCommission,
    'shippingCommission': shippingCommission,
    'fixedDeliveryFee': fixedDeliveryFee,
  };
}
