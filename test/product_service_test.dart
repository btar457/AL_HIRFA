import 'package:flutter_test/flutter_test.dart';
import 'package:al_hirfa/services/product_service.dart';

void main() {
  group('isFavoriteProductVisible', () {
    test('منتج نشط يظهر في المفضلة', () {
      expect(isFavoriteProductVisible(exists: true, data: {'status': 'active'}), isTrue);
    });

    test('منتج محذوف حذفاً ناعماً لا يظهر في المفضلة', () {
      expect(isFavoriteProductVisible(exists: true, data: {'status': 'deleted'}), isFalse);
    });

    test('وثيقة منتج غير موجودة أصلاً لا تظهر', () {
      expect(isFavoriteProductVisible(exists: false, data: null), isFalse);
    });
  });
}
