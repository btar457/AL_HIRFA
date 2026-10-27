import 'package:cloud_firestore/cloud_firestore.dart';

/// تقييم المشتري لطلب مكتمل (PART 3.1 — نافذة 7 أيام، بلا تعديل أو حذف).
class ReviewModel {
  final String id;
  final String orderId;
  final String productId;
  final String buyerUid;
  final String buyerName;
  final String buyerPhotoUrl;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.buyerUid,
    required this.buyerName,
    this.buyerPhotoUrl = '',
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      buyerUid: map['buyerUid'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerPhotoUrl: map['buyerPhotoUrl'] as String? ?? '',
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'buyerPhotoUrl': buyerPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
