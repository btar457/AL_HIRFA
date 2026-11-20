import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings_model.dart';

/// طبقة إعدادات العمولات وسعر التوصيل — مستند واحد يقرأه/يعدّله الجميع بدل
/// ثوابت AppRules الثابتة (ADMIN-8).
class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _docPath = 'app_config/rules';

  Future<AppSettingsModel> getSettings() async {
    final doc = await _firestore.doc(_docPath).get();
    return AppSettingsModel.fromMap(doc.data());
  }

  Stream<AppSettingsModel> watchSettings() {
    return _firestore.doc(_docPath).snapshots().map((doc) => AppSettingsModel.fromMap(doc.data()));
  }

  Future<void> updateSettings({
    required double productCommission,
    required double shippingCommission,
    required int fixedDeliveryFee,
  }) {
    return _firestore.doc(_docPath).set({
      'productCommission': productCommission,
      'shippingCommission': shippingCommission,
      'fixedDeliveryFee': fixedDeliveryFee,
    });
  }
}
