import 'package:flutter_test/flutter_test.dart';
import 'package:al_hirfa/models/order_model.dart';
import 'package:al_hirfa/models/product_model.dart';
import 'package:al_hirfa/models/user_model.dart';
import 'package:al_hirfa/screens/admin/admin_artisans_ledger_screen.dart';

OrderModel _order(String id, String status, {int price = 10000, int fee = 500, bool paid = false}) => OrderModel(
      id: id, orderNumber: id, productId: 'p', productName: 'n', productImage: '', price: price, deliveryFee: 5000,
      totalAmount: price + 5000, platformFee: fee, artisanEarnings: price - fee + 5000, shippingEarnings: 0,
      buyerUid: 'b', buyerName: 'b', buyerPhone: '', governorate: 'بغداد', district: '', addressNotes: '',
      artisanUid: 'a', artisanName: 'a', status: status, createdAt: DateTime(2026), commissionPaid: paid,
    );

ProductModel _product(String status) => ProductModel(
      id: status, name: 'n', description: 'd', price: 1, category: 'c', city: 'x', images: const [],
      artisanUid: 'a', artisanName: 'a', status: status, createdAt: DateTime(2026),
    );

void main() {
  test('ledger splits owed, paid and pending commission correctly', () {
    final l = ArtisanLedger(
      UserModel(uid: 'a', name: 'A', email: '', phone: '', role: 'artisan', city: '', createdAt: DateTime(2026)),
      [_product('active'), _product('pending'), _product('deleted')],
      [
        _order('1', 'delivered', fee: 500),
        _order('2', 'delivered', fee: 700, paid: true),
        _order('3', 'pending', fee: 300),
        _order('4', 'cancelled', fee: 900),
      ],
    );
    expect(l.owed, 500);
    expect(l.paid, 700);
    expect(l.pending, 300);
    expect(l.salesTotal, 20000);
    expect(l.owedOrderIds, ['1']);
    expect(l.activeProducts, 1);
    expect(l.visibleProducts, 2);
  });
}
