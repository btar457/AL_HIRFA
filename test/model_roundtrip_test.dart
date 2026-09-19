import 'package:flutter_test/flutter_test.dart';
import 'package:al_hirfa/models/order_model.dart';
import 'package:al_hirfa/models/product_model.dart';
import 'package:al_hirfa/models/review_model.dart';

// اختبارات ذهاب-وإياب (toMap -> fromMap) للنماذج الأساسية. هذا يحمي تحديداً
// من فئة الأخطاء التي وقعت فعلياً في هذا المشروع أكثر من مرة: إضافة حقل
// جديد للنموذج وتحديث fromMap/toMap بشكل صحيح لكن نسيان حقل آخر عند إعادة
// بناء النموذج في مكان ثانٍ (كما حدث مع artisanPhotoUrl في
// ProductService.addProduct).

void main() {
  group('ProductModel round-trip', () {
    test('every field survives toMap -> fromMap', () {
      final original = ProductModel(
        id: 'p1',
        name: 'سجادة يدوية',
        description: 'وصف المنتج',
        price: 25000,
        category: 'carpets',
        city: 'بغداد',
        images: const ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
        artisanUid: 'artisan-1',
        artisanName: 'أبو مصطفى',
        artisanPhotoUrl: 'https://example.com/avatar.jpg',
        narrative: 'قصة المنتج',
        material: 'صوف',
        originPlace: 'الموصل',
        technique: 'نسيج يدوي',
        status: 'active',
        rating: 4.5,
        reviewCount: 12,
        salesCount: 3,
        createdAt: DateTime(2026, 1, 1, 10, 30),
      );

      final restored = ProductModel.fromMap(original.id, original.toMap());

      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.price, original.price);
      expect(restored.category, original.category);
      expect(restored.city, original.city);
      expect(restored.images, original.images);
      expect(restored.artisanUid, original.artisanUid);
      expect(restored.artisanName, original.artisanName);
      expect(restored.artisanPhotoUrl, original.artisanPhotoUrl);
      expect(restored.narrative, original.narrative);
      expect(restored.material, original.material);
      expect(restored.originPlace, original.originPlace);
      expect(restored.technique, original.technique);
      expect(restored.status, original.status);
      expect(restored.rating, original.rating);
      expect(restored.reviewCount, original.reviewCount);
      expect(restored.salesCount, original.salesCount);
      expect(restored.createdAt, original.createdAt);
    });

    test('missing fields fall back to safe defaults instead of throwing', () {
      final restored = ProductModel.fromMap('p1', const {});
      expect(restored.artisanPhotoUrl, '');
      expect(restored.status, 'pending');
      expect(restored.images, isEmpty);
    });
  });

  group('ReviewModel round-trip', () {
    test('every field survives toMap -> fromMap', () {
      final original = ReviewModel(
        id: 'r1',
        orderId: 'o1',
        productId: 'p1',
        buyerUid: 'buyer-1',
        buyerName: 'أحمد',
        buyerPhotoUrl: 'https://example.com/buyer.jpg',
        rating: 5,
        comment: 'ممتاز',
        createdAt: DateTime(2026, 2, 2, 9),
      );

      final restored = ReviewModel.fromMap(original.id, original.toMap());

      expect(restored.orderId, original.orderId);
      expect(restored.productId, original.productId);
      expect(restored.buyerUid, original.buyerUid);
      expect(restored.buyerName, original.buyerName);
      expect(restored.buyerPhotoUrl, original.buyerPhotoUrl);
      expect(restored.rating, original.rating);
      expect(restored.comment, original.comment);
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('OrderModel round-trip', () {
    test('every field including nested address survives toMap -> fromMap', () {
      final original = OrderModel(
        id: 'o1',
        orderNumber: 'HRF-ABCD1234',
        productId: 'p1',
        productName: 'سجادة يدوية',
        productImage: 'https://example.com/1.jpg',
        price: 25000,
        deliveryFee: 5000,
        totalAmount: 30000,
        platformFee: 3000,
        artisanEarnings: 22500,
        shippingEarnings: 4500,
        buyerUid: 'buyer-1',
        buyerName: 'أحمد',
        buyerPhone: '07701234567',
        governorate: 'بغداد',
        district: 'الكرادة',
        addressNotes: 'قرب الجسر',
        artisanUid: 'artisan-1',
        artisanName: 'أبو مصطفى',
        shippingUid: 'shipping-1',
        shippingCompanyName: 'شركة النور',
        status: 'delivered',
        sellerApprovalDeadline: DateTime(2026, 1, 3),
        shippingAcceptDeadline: DateTime(2026, 1, 2),
        isReviewed: true,
        disputeId: 'd1',
        createdAt: DateTime(2026, 1, 1),
        deliveredAt: DateTime(2026, 1, 5),
      );

      final restored = OrderModel.fromMap(original.id, original.toMap());

      expect(restored.orderNumber, original.orderNumber);
      expect(restored.price, original.price);
      expect(restored.deliveryFee, original.deliveryFee);
      expect(restored.totalAmount, original.totalAmount);
      expect(restored.platformFee, original.platformFee);
      expect(restored.artisanEarnings, original.artisanEarnings);
      expect(restored.shippingEarnings, original.shippingEarnings);
      expect(restored.buyerUid, original.buyerUid);
      expect(restored.governorate, original.governorate);
      expect(restored.district, original.district);
      expect(restored.addressNotes, original.addressNotes);
      expect(restored.artisanUid, original.artisanUid);
      expect(restored.shippingUid, original.shippingUid);
      expect(restored.shippingCompanyName, original.shippingCompanyName);
      expect(restored.status, original.status);
      expect(restored.sellerApprovalDeadline, original.sellerApprovalDeadline);
      expect(restored.shippingAcceptDeadline, original.shippingAcceptDeadline);
      expect(restored.isReviewed, original.isReviewed);
      expect(restored.disputeId, original.disputeId);
      expect(restored.createdAt, original.createdAt);
      expect(restored.deliveredAt, original.deliveredAt);
    });

    test('optional shipping/dispute fields stay null when never set', () {
      final original = OrderModel(
        id: 'o1',
        orderNumber: 'HRF-ABCD1234',
        productId: 'p1',
        productName: 'سجادة يدوية',
        productImage: '',
        price: 25000,
        deliveryFee: 5000,
        totalAmount: 30000,
        platformFee: 3000,
        artisanEarnings: 22500,
        shippingEarnings: 4500,
        buyerUid: 'buyer-1',
        buyerName: 'أحمد',
        buyerPhone: '07701234567',
        governorate: 'بغداد',
        district: 'الكرادة',
        artisanUid: 'artisan-1',
        artisanName: 'أبو مصطفى',
        status: 'pending',
        createdAt: DateTime(2026, 1, 1),
      );

      final restored = OrderModel.fromMap(original.id, original.toMap());

      expect(restored.shippingUid, isNull);
      expect(restored.shippingCompanyName, isNull);
      expect(restored.disputeId, isNull);
      expect(restored.deliveredAt, isNull);
      expect(restored.sellerApprovalDeadline, isNull);
    });
  });
}
