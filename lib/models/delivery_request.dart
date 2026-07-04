enum DeliveryStatus { waitingPickup, inTransit, delivered }

/// طلب توصيل ضمن شاشات شركة الشحن (متاح → نشط → مكتمل).
class DeliveryRequest {
  final String orderNumber;
  final String productName;
  final String category;
  final String fromProvince;
  final String toProvince;
  final String buyerAddress;
  final String sellerPhone;
  final String buyerPhone;
  final String distance;
  final int fee;
  DeliveryStatus status;

  DeliveryRequest({
    required this.orderNumber,
    required this.productName,
    required this.category,
    required this.fromProvince,
    required this.toProvince,
    required this.buyerAddress,
    required this.sellerPhone,
    required this.buyerPhone,
    required this.distance,
    required this.fee,
    this.status = DeliveryStatus.waitingPickup,
  });
}
