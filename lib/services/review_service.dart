import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

/// طبقة تقييمات المشتري لطلب مكتمل (PART 3.1 — بلا تعديل أو حذف لاحقاً).
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _reviewsCollection = 'reviews';
  static const _ordersCollection = 'orders';
  static const _productsCollection = 'products';

  /// يسجّل تقييماً جديداً، يعلّم الطلب isReviewed، ويعيد حساب متوسط تقييم
  /// المنتج (rating/reviewCount) بشكل ذرّي عبر transaction.
  Future<void> submitReview({
    required String orderId,
    required String productId,
    required String buyerUid,
    required String buyerName,
    String buyerPhotoUrl = '',
    required int rating,
    String comment = '',
  }) async {
    final reviewRef = _firestore.collection(_reviewsCollection).doc();
    final productRef = _firestore.collection(_productsCollection).doc(productId);
    final orderRef = _firestore.collection(_ordersCollection).doc(orderId);

    await _firestore.runTransaction((tx) async {
      final productSnap = await tx.get(productRef);
      final currentRating = (productSnap.data()?['rating'] as num?)?.toDouble() ?? 0;
      final currentCount = productSnap.data()?['reviewCount'] as int? ?? 0;
      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + rating) / newCount;

      tx.set(
        reviewRef,
        ReviewModel(
          id: reviewRef.id,
          orderId: orderId,
          productId: productId,
          buyerUid: buyerUid,
          buyerName: buyerName,
          buyerPhotoUrl: buyerPhotoUrl,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        ).toMap(),
      );
      tx.update(orderRef, {'isReviewed': true});
      tx.update(productRef, {'rating': newRating, 'reviewCount': newCount});
    });
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore.collection(_reviewsCollection).where('productId', isEqualTo: productId).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ReviewModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// كل تقييمات منتجات حرفي معيّن (للملف العام) — يُفرَز محلياً بدل orderBy
  /// كي لا يحتاج فهرساً مركّباً إضافياً فوق whereIn.
  Future<List<ReviewModel>> getArtisanReviews(List<String> productIds) async {
    if (productIds.isEmpty) return const [];
    final reviews = <ReviewModel>[];
    for (var i = 0; i < productIds.length; i += 30) {
      final batch = productIds.sublist(i, i + 30 > productIds.length ? productIds.length : i + 30);
      final snapshot = await _firestore.collection(_reviewsCollection).where('productId', whereIn: batch).get();
      reviews.addAll(snapshot.docs.map((doc) => ReviewModel.fromMap(doc.id, doc.data())));
    }
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}
