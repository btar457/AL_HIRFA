import 'product_model.dart';

/// عنصر ضمن سلة المشتري (يُستخدم من CartProvider).
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get totalPrice => product.price * quantity;
}
