import 'package:flutter_test/flutter_test.dart';
import 'package:al_hirfa/core/constants/app_rules.dart';
import 'package:al_hirfa/models/app_settings_model.dart';

void main() {
  group('AppSettingsModel.fromMap', () {
    test('falls back to AppRules defaults when no settings doc exists', () {
      final settings = AppSettingsModel.fromMap(null);

      expect(settings.productCommission, AppRules.productCommission);
      expect(settings.shippingCommission, AppRules.shippingCommission);
      expect(settings.fixedDeliveryFee, AppRules.fixedDeliveryFee);
      expect(settings.platformDeliveryFee, AppRules.platformDeliveryFee);
      expect(settings.companyNetDelivery, AppRules.companyNetDelivery);
    });

    test('splits the delivery fee using the saved shippingCommission, not a hardcoded 10%', () {
      // انحدار عن الثغرة التي أُصلحت: كانت fromMap تتجاهل shippingCommission
      // المحفوظة وتفرض 10% ثابتة دوماً بغض النظر عمّا يضبطه المدير.
      final settings = AppSettingsModel.fromMap({
        'fixedDeliveryFee': 5000,
        'shippingCommission': 0.20,
      });

      expect(settings.shippingCommission, 0.20);
      expect(settings.platformDeliveryFee, 1000);
      expect(settings.companyNetDelivery, 4000);
    });

    test('recomputes the split when fixedDeliveryFee itself changes', () {
      final settings = AppSettingsModel.fromMap({
        'fixedDeliveryFee': 6000,
        'shippingCommission': 0.10,
      });

      expect(settings.fixedDeliveryFee, 6000);
      expect(settings.platformDeliveryFee, 600);
      expect(settings.companyNetDelivery, 5400);
    });

    test('reads productCommission independently from shippingCommission', () {
      final settings = AppSettingsModel.fromMap({'productCommission': 0.15});

      expect(settings.productCommission, 0.15);
      expect(settings.shippingCommission, AppRules.shippingCommission);
    });
  });
}
