import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_rules.dart';
import '../models/order_model.dart';

/// طبقة إدارة الطلبات ودورة حياتها الكاملة عبر Firestore.
class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _ordersCollection = 'orders';

  String _generateOrderNumber() => 'HRF-${1000 + Random().nextInt(9000)}';

  /// ينشئ طلباً جديداً بحالة 'pending' ومهلة موافقة 48 ساعة للحرفي.
  Future<String> createOrder(OrderModel order) async {
    final docRef = _firestore.collection(_ordersCollection).doc();
    final newOrder = order.copyWith(
      id: docRef.id,
      orderNumber: _generateOrderNumber(),
      status: 'pending',
      sellerApprovalDeadline: DateTime.now().add(Duration(hours: AppRules.sellerApprovalHours)),
    );
    await docRef.set(newOrder.toMap());
    // TODO: إشعار الحرفي "طلب جديد ينتظر موافقتك" (بعد بناء notification_service.dart).
    return docRef.id;
  }

  /// الحرفي يوافق على الطلب — يفتح نافذة 5 دقائق لشركات الشحن للقبول.
  Future<void> sellerApproveOrder(String orderId) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': 'seller_approved',
      'shippingAcceptDeadline': Timestamp.fromDate(DateTime.now().add(Duration(minutes: AppRules.shippingAcceptMinutes))),
    });
    // TODO: إرسال FCM لشركات الشحن في نفس المحافظة + إشعار المشتري (notification_service.dart).
  }

  /// الحرفي يرفض الطلب مع ذكر السبب.
  Future<void> sellerRejectOrder(String orderId, String reason) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'cancelled', 'rejectionReason': reason});
    // TODO: إشعار المشتري بالسبب + تحديث warningCount للحرفي (admin_service.dart لاحقاً).
  }

  /// شركة الشحن تقبل الطلب — Firestore Transaction تمنع قبول أكثر من شركة لنفس الطلب.
  Future<bool> shippingAcceptOrder(String orderId, String shippingUid, String shippingCompanyName) async {
    return _firestore.runTransaction<bool>((tx) async {
      final orderRef = _firestore.collection(_ordersCollection).doc(orderId);
      final orderSnap = await tx.get(orderRef);

      if (orderSnap.data()?['status'] != 'seller_approved') {
        return false; // سبقك شخص آخر أو الطلب لم يعد متاحاً
      }

      tx.update(orderRef, {
        'status': 'shipping_assigned',
        'shippingUid': shippingUid,
        'shippingCompanyName': shippingCompanyName,
        'shippingAssignedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
    // TODO: إشعار المشتري والحرفي أن الشحن بدأ (notification_service.dart).
  }

  /// شركة الشحن استلمت المنتج من الحرفي.
  Future<void> shippingPickedUp(String orderId) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'picked_up'});
    // TODO: إشعار المشتري "المنتج في الطريق إليك" (notification_service.dart).
  }

  /// تأكيد التسليم — يبدأ عداد 72 ساعة لتحويل أرباح الحرفي.
  Future<void> confirmDelivery(String orderId) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': 'delivered',
      'deliveredAt': Timestamp.now(),
    });
    // TODO: إنشاء transaction records وبدء عداد 72 ساعة (wallet_service.dart لاحقاً).
  }

  /// بث حالة طلب واحد حياً — يُستخدم في order_tracking_screen.dart.
  Stream<OrderModel?> watchOrder(String orderId) {
    return _firestore.collection(_ordersCollection).doc(orderId).snapshots().map(
      (doc) => doc.exists ? OrderModel.fromMap(doc.id, doc.data()!) : null,
    );
  }

  Stream<List<OrderModel>> getBuyerOrders(String buyerUid) {
    return _firestore.collection(_ordersCollection).where('buyerUid', isEqualTo: buyerUid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<List<OrderModel>> getArtisanOrders(String artisanUid) {
    return _firestore.collection(_ordersCollection).where('artisanUid', isEqualTo: artisanUid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// الطلبات المتاحة لشركات الشحن في محافظة معيّنة (بانتظار شركة تقبلها).
  Stream<List<OrderModel>> getAvailableDeliveries(String governorate) {
    return _firestore
        .collection(_ordersCollection)
        .where('status', isEqualTo: 'seller_approved')
        .where('address.governorate', isEqualTo: governorate)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<OrderModel>> getShippingOrders(String shippingUid) {
    return _firestore.collection(_ordersCollection).where('shippingUid', isEqualTo: shippingUid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList(),
    );
  }
}
