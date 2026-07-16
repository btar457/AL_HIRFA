import 'package:flutter/material.dart';
import '../core/constants/app_rules.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';

/// حالة سلة المشتري (AL-HIRFA-Firebase-Setup.md — PART 4.2). حالة محلية
/// بالكامل، لا تعتمد على Firebase.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  int _deliveryFeePerItem = AppRules.fixedDeliveryFee;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  /// كل عنصر في السلة يصبح طلباً مستقلاً (حرفي وشحنة مختلفَين محتملَين)،
  /// لذا رسم التوصيل الثابت يُحتسب لكل عنصر وليس مرة واحدة للسلة كاملة.
  int get deliveryFee => _items.length * _deliveryFeePerItem;
  int get total => subtotal + deliveryFee;

  /// يُحدَّث من الشاشات التي تجلب إعدادات AppSettingsService الفعلية، كي لا
  /// يبقى سعر التوصيل المعروض ثابتاً حتى لو غيّرته الإدارة.
  void setDeliveryFeePerItem(int fee) {
    if (fee == _deliveryFeePerItem) return;
    _deliveryFeePerItem = fee;
    notifyListeners();
  }

  void addItem(ProductModel product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
