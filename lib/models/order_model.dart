import 'package:cloud_firestore/cloud_firestore.dart';

/// طلب شراء موحّد عبر أدوار المشتري/الحرفي/الشحن/الإدارة
/// (AL-HIRFA-Firebase-Setup.md — PART 2.1، مجموعة orders).
class OrderModel {
  final String id;
  final String orderNumber; // HRF-XXXX
  final String productId;
  final String productName;
  final String productImage;
  final int price;
  final int deliveryFee;
  final int totalAmount;
  final int platformFee; // عمولة AL-HIRFA (منتج + شحن)
  final int artisanEarnings; // 90% من سعر المنتج
  final int shippingEarnings; // 4,500 د.ع
  final String buyerUid;
  final String buyerName;
  final String buyerPhone;
  final String governorate;
  final String district;
  final String addressNotes;
  final String artisanUid;
  final String artisanName;
  final String? shippingUid;
  final String? shippingCompanyName;
  final String status; // pending, seller_approved, shipping_assigned, picked_up, delivered, cancelled, disputed
  final DateTime? sellerApprovalDeadline;
  final DateTime? shippingAcceptDeadline;
  final bool isReviewed;
  final String? disputeId;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.deliveryFee,
    required this.totalAmount,
    required this.platformFee,
    required this.artisanEarnings,
    required this.shippingEarnings,
    required this.buyerUid,
    required this.buyerName,
    required this.buyerPhone,
    required this.governorate,
    required this.district,
    this.addressNotes = '',
    required this.artisanUid,
    required this.artisanName,
    this.shippingUid,
    this.shippingCompanyName,
    required this.status,
    this.sellerApprovalDeadline,
    this.shippingAcceptDeadline,
    this.isReviewed = false,
    this.disputeId,
    required this.createdAt,
    this.deliveredAt,
  });

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? status,
    String? shippingUid,
    String? shippingCompanyName,
    DateTime? sellerApprovalDeadline,
    DateTime? shippingAcceptDeadline,
    bool? isReviewed,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      platformFee: platformFee,
      artisanEarnings: artisanEarnings,
      shippingEarnings: shippingEarnings,
      buyerUid: buyerUid,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      governorate: governorate,
      district: district,
      addressNotes: addressNotes,
      artisanUid: artisanUid,
      artisanName: artisanName,
      shippingUid: shippingUid ?? this.shippingUid,
      shippingCompanyName: shippingCompanyName ?? this.shippingCompanyName,
      status: status ?? this.status,
      sellerApprovalDeadline: sellerApprovalDeadline ?? this.sellerApprovalDeadline,
      shippingAcceptDeadline: shippingAcceptDeadline ?? this.shippingAcceptDeadline,
      isReviewed: isReviewed ?? this.isReviewed,
      disputeId: disputeId,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final address = map['address'] as Map<String, dynamic>? ?? const {};
    return OrderModel(
      id: id,
      orderNumber: map['orderNumber'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImage: map['productImage'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      deliveryFee: map['deliveryFee'] as int? ?? 0,
      totalAmount: map['totalAmount'] as int? ?? 0,
      platformFee: map['platformFee'] as int? ?? 0,
      artisanEarnings: map['artisanEarnings'] as int? ?? 0,
      shippingEarnings: map['shippingEarnings'] as int? ?? 0,
      buyerUid: map['buyerUid'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerPhone: map['buyerPhone'] as String? ?? '',
      governorate: address['governorate'] as String? ?? '',
      district: address['district'] as String? ?? '',
      addressNotes: address['notes'] as String? ?? '',
      artisanUid: map['artisanUid'] as String? ?? '',
      artisanName: map['artisanName'] as String? ?? '',
      shippingUid: map['shippingUid'] as String?,
      shippingCompanyName: map['shippingCompanyName'] as String?,
      status: map['status'] as String? ?? 'pending',
      sellerApprovalDeadline: (map['sellerApprovalDeadline'] as Timestamp?)?.toDate(),
      shippingAcceptDeadline: (map['shippingAcceptDeadline'] as Timestamp?)?.toDate(),
      isReviewed: map['isReviewed'] as bool? ?? false,
      disputeId: map['disputeId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'artisanEarnings': artisanEarnings,
      'shippingEarnings': shippingEarnings,
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'address': {'governorate': governorate, 'district': district, 'notes': addressNotes},
      'artisanUid': artisanUid,
      'artisanName': artisanName,
      'shippingUid': shippingUid,
      'shippingCompanyName': shippingCompanyName,
      'status': status,
      'sellerApprovalDeadline': sellerApprovalDeadline != null ? Timestamp.fromDate(sellerApprovalDeadline!) : null,
      'shippingAcceptDeadline': shippingAcceptDeadline != null ? Timestamp.fromDate(shippingAcceptDeadline!) : null,
      'isReviewed': isReviewed,
      'disputeId': disputeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }
}
