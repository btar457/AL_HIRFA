import 'package:cloud_firestore/cloud_firestore.dart';

/// طلب موحّد للاستخدام عبر الأدوار (لوحات الإدارة)، إلى جانب ArtisanOrder
/// المستخدم في شاشات الحرفي.
class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int price;
  final int deliveryFee;
  final String buyerUid;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String artisanUid;
  final String artisanName;
  final String? shippingUid;
  final String? shippingCompanyName;
  final String status; // pending, accepted, rejected, shipping, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.deliveryFee,
    required this.buyerUid,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.artisanUid,
    required this.artisanName,
    this.shippingUid,
    this.shippingCompanyName,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImage: map['productImage'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      deliveryFee: map['deliveryFee'] as int? ?? 0,
      buyerUid: map['buyerUid'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerPhone: map['buyerPhone'] as String? ?? '',
      buyerAddress: map['buyerAddress'] as String? ?? '',
      artisanUid: map['artisanUid'] as String? ?? '',
      artisanName: map['artisanName'] as String? ?? '',
      shippingUid: map['shippingUid'] as String?,
      shippingCompanyName: map['shippingCompanyName'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'deliveryFee': deliveryFee,
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'artisanUid': artisanUid,
      'artisanName': artisanName,
      'shippingUid': shippingUid,
      'shippingCompanyName': shippingCompanyName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }
}
