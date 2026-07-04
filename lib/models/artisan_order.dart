enum ArtisanOrderStatus { newOrder, inProgress, completed, rejected }

/// طلب وارد على منتج الحرفي.
class ArtisanOrder {
  final String orderNumber;
  final String date;
  final String productName;
  final String price;
  final int quantity;
  final String buyerName;
  final String buyerPhone;
  final String province;
  final String neighborhood;
  final String notes;
  ArtisanOrderStatus status;
  String? shippingCompany;
  String? shippingRepPhone;

  ArtisanOrder({
    required this.orderNumber,
    required this.date,
    required this.productName,
    required this.price,
    this.quantity = 1,
    required this.buyerName,
    required this.buyerPhone,
    required this.province,
    required this.neighborhood,
    this.notes = '',
    required this.status,
    this.shippingCompany,
    this.shippingRepPhone,
  });
}
