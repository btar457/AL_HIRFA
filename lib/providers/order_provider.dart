import 'package:flutter/material.dart';
import '../models/order_model.dart';

/// حالة الطلبات عبر أدوار المشتري/الحرفي/الشحن (AL-HIRFA-Firebase-Setup.md
/// — PART 4.3). TODO: يُربط بـ order_service.dart الحقيقي في مرحلة
/// "الطلبات" القادمة (بما فيها Firestore Transaction لقبول التوصيل).
class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> loadBuyerOrders(String buyerUid) async {
    _isLoading = true;
    notifyListeners();
    // TODO: OrderService.getBuyerOrders(buyerUid)
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadArtisanOrders(String artisanUid) async {
    _isLoading = true;
    notifyListeners();
    // TODO: OrderService.getArtisanOrders(artisanUid)
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAvailableDeliveries(String city) async {
    _isLoading = true;
    notifyListeners();
    // TODO: OrderService.getAvailableDeliveries(city)
    _isLoading = false;
    notifyListeners();
  }

  Future<String> createOrder(OrderModel order) async {
    // TODO: OrderService.createOrder(order) — يُنشئ orderNumber ويحفظ في Firestore.
    return '';
  }

  Future<void> approveOrder(String orderId) async {
    // TODO: OrderService.sellerApproveOrder(orderId)
  }

  Future<bool> acceptDelivery(String orderId, String shippingUid) async {
    // TODO: OrderService.shippingAcceptOrder(orderId, shippingUid) عبر Firestore Transaction.
    return false;
  }
}
