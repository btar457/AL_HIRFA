import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/violation_model.dart';
import 'notification_service.dart';

/// طبقة إحصائيات لوحة تحكم المؤسس، ومراجعة الحرفيين، وإدارة حسابات
/// المستخدمين (AL-HIRFA-Firebase-Setup.md — PART 10، المرحلة 7: Admin).
class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _usersCollection = 'users';
  static const _productsCollection = 'products';
  static const _ordersCollection = 'orders';
  static const _transactionsCollection = 'transactions';
  static const _violationsCollection = 'violations';

  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ---------------------------------------------------------------------
  // إحصائيات لوحة التحكم (ADMIN-2)
  // ---------------------------------------------------------------------

  Future<int> _countUsers({required String role, bool? isActive, String? approvalStatus}) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_usersCollection).where('role', isEqualTo: role);
    if (isActive != null) query = query.where('isActive', isEqualTo: isActive);
    if (approvalStatus != null) query = query.where('approvalStatus', isEqualTo: approvalStatus);
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getActiveArtisansCount() => _countUsers(role: 'artisan', isActive: true, approvalStatus: 'approved');
  Future<int> getBuyersCount() => _countUsers(role: 'customer');
  Future<int> getShippingCompaniesCount() => _countUsers(role: 'shipping', isActive: true);
  Future<int> getPendingArtisansCount() => _countUsers(role: 'artisan', approvalStatus: 'pending');
  Future<int> getPendingShippingCompaniesCount() => _countUsers(role: 'shipping', approvalStatus: 'pending');

  Future<int> getTotalProductsCount() async {
    final snapshot = await _firestore.collection(_productsCollection).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getNewUsersTodayCount() async {
    final snapshot = await _firestore.collection(_usersCollection).where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart)).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getOrdersTodayCount() async {
    final snapshot = await _firestore.collection(_ordersCollection).where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart)).count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getActiveDeliveriesCount() async {
    final snapshot = await _firestore.collection(_ordersCollection).where('status', whereIn: ['shipping_assigned', 'picked_up']).count().get();
    return snapshot.count ?? 0;
  }

  /// إيرادات المنصة اليوم = مجموع حركات العمولة (commission) المكتملة اليوم.
  Future<int> getRevenueToday() async {
    final snapshot = await _firestore
        .collection(_transactionsCollection)
        .where('type', isEqualTo: 'commission')
        .where('status', isEqualTo: 'completed')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart))
        .get();
    return snapshot.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as int? ?? 0));
  }

  /// إيرادات الشهر الحالي مُفصَّلة (عمولة المنتجات مقابل عمولة الشحن) من
  /// الطلبات المُسلَّمة فعلياً — لشاشة admin_financials.
  Future<({int total, int productCommission, int shippingCommission})> getMonthlyRevenueBreakdown() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .get();
    final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList();

    var productCommission = 0;
    var shippingCommission = 0;
    for (final order in orders) {
      final shippingCut = order.deliveryFee - order.shippingEarnings;
      shippingCommission += shippingCut;
      productCommission += order.platformFee - shippingCut;
    }
    return (total: productCommission + shippingCommission, productCommission: productCommission, shippingCommission: shippingCommission);
  }

  Future<int> getOpenDisputesCount() async {
    final snapshot = await _firestore.collection('disputes').where('status', isEqualTo: 'open').count().get();
    return snapshot.count ?? 0;
  }

  /// إجمالي مبيعات آخر 7 أيام (قيمة الطلبات المُنشأة كل يوم)، من الأقدم
  /// إلى الأحدث — لعرضها في الرسم البياني الأسبوعي بلوحة التحكم.
  Future<List<double>> getWeeklySales() async {
    final start = _todayStart.subtract(const Duration(days: 6));
    final snapshot = await _firestore.collection(_ordersCollection).where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).get();
    final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList();

    return List<double>.generate(7, (i) {
      final day = start.add(Duration(days: i));
      return orders.where((o) => o.createdAt.year == day.year && o.createdAt.month == day.month && o.createdAt.day == day.day).fold<double>(0, (acc, o) => acc + o.totalAmount);
    });
  }

  // ---------------------------------------------------------------------
  // مراجعة طلبات الحرفيين الجدد (ADMIN-4)
  // ---------------------------------------------------------------------

  Stream<List<UserModel>> getArtisansByApprovalStatus(String approvalStatus) => getUsersByRoleAndApprovalStatus('artisan', approvalStatus);

  Future<void> approveArtisan(String uid) => approveAccount(uid, roleLabel: 'حرفي', message: 'تهانينا! تمت الموافقة على حسابك كحرفي، يمكنك الآن تسجيل الدخول وإضافة منتجاتك');

  Future<void> rejectArtisan(String uid, String reason) => rejectAccount(uid, reason);

  /// حسابات دور معيّن (حرفي/شركة شحن) بحالة مراجعة معيّنة — لشاشتي
  /// review_artisans وadmin_shipping.
  Stream<List<UserModel>> getUsersByRoleAndApprovalStatus(String role, String approvalStatus) {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: role)
        .where('approvalStatus', isEqualTo: approvalStatus)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList());
  }

  /// موافقة عامة على أي حساب بانتظار المراجعة (حرفي أو شركة شحن).
  Future<void> approveAccount(String uid, {String roleLabel = 'الحساب', String? message}) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'approvalStatus': 'approved'});
    await NotificationService.instance.sendToUser(
      userUid: uid,
      title: 'تم قبول طلبك',
      body: message ?? 'تهانينا! تمت الموافقة على $roleLabel، يمكنك الآن تسجيل الدخول',
      type: 'account_approved',
    );
  }

  /// رفض عام لأي حساب بانتظار المراجعة (حرفي أو شركة شحن).
  Future<void> rejectAccount(String uid, String reason) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'approvalStatus': 'rejected'});
    await NotificationService.instance.sendToUser(
      userUid: uid,
      title: 'تم رفض طلبك',
      body: reason,
      type: 'account_rejected',
    );
  }

  // ---------------------------------------------------------------------
  // إدارة حسابات المستخدمين (ADMIN-3)
  // ---------------------------------------------------------------------

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    return doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null;
  }

  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore.collection(_usersCollection).where('role', isEqualTo: role).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<List<ViolationModel>> getUserViolations(String uid) {
    return _firestore.collection(_violationsCollection).where('userUid', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ViolationModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> _recordViolation(String uid, {required String type, required String description, required String severity, int penaltyDays = 0}) async {
    final ref = _firestore.collection(_violationsCollection).doc();
    await ref.set(ViolationModel(id: ref.id, userUid: uid, type: type, description: description, severity: severity, penaltyDays: penaltyDays, createdAt: DateTime.now()).toMap());
  }

  /// تحذير: يزيد عدّاد الإنذارات ويسجّل مخالفة دون تعليق الحساب.
  Future<void> warnUser(String uid, String reason) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'warningCount': FieldValue.increment(1)});
    await _recordViolation(uid, type: 'warning', description: reason, severity: 'warning');
    await NotificationService.instance.sendToUser(userUid: uid, title: 'تحذير من الإدارة', body: reason, type: 'account_warning');
  }

  /// تعليق مؤقت: يمنع الدخول فوراً (accessBlockCode في AuthService) دون حظر نهائي.
  Future<void> suspendUser(String uid, String reason) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'isActive': false, 'banned': false});
    await _recordViolation(uid, type: 'suspension', description: reason, severity: 'suspension');
    await NotificationService.instance.sendToUser(userUid: uid, title: 'تم تعليق حسابك', body: reason, type: 'account_suspended');
  }

  /// حظر نهائي.
  Future<void> banUser(String uid, String reason) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'isActive': false, 'banned': true});
    await _recordViolation(uid, type: 'ban', description: reason, severity: 'ban');
    await NotificationService.instance.sendToUser(userUid: uid, title: 'تم حظر حسابك نهائياً', body: reason, type: 'account_banned');
  }

  /// رفع التعليق عن حساب معلَّق (لا يعمل على حساب محظور نهائياً).
  Future<void> liftSuspension(String uid) async {
    await _firestore.collection(_usersCollection).doc(uid).update({'isActive': true});
    await NotificationService.instance.sendToUser(userUid: uid, title: 'تم رفع التعليق عن حسابك', body: 'يمكنك الآن استخدام حسابك بشكل طبيعي', type: 'account_reactivated');
  }
}
