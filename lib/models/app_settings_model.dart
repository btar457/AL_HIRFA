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

  /// حصة AL-HIRFA من سعر التوصيل = نسبة shippingCommission (القابلة للتعديل
  /// من لوحة الإدارة) مضروبة في سعر التوصيل الكلي، والباقي يذهب لشركة الشحن.
  factory AppSettingsModel.fromMap(Map<String, dynamic>? map) {
    final fixedDeliveryFee = (map?['fixedDeliveryFee'] as num?)?.toInt() ?? AppRules.fixedDeliveryFee;
    final shippingCommission = (map?['shippingCommission'] as num?)?.toDouble() ?? AppRules.shippingCommission;
    final platformDeliveryFee = (fixedDeliveryFee * shippingCommission).round();
    return AppSettingsModel(
      productCommission: (map?['productCommission'] as num?)?.toDouble() ?? AppRules.productCommission,
      shippingCommission: shippingCommission,
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
