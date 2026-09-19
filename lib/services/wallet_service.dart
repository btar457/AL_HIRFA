import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_rules.dart';
import '../models/order_model.dart';
import '../models/settlement_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/withdrawal_request_model.dart';
import 'notification_service.dart';

/// طبقة المحافظ والتسويات الأسبوعية، مبنية بالكامل فوق سجل transactions
/// (لا يوجد مستند "محفظة" مستقل — الرصيد محسوب حياً من الحركات).
class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _transactionsCollection = 'transactions';
  static const _settlementsCollection = 'settlements';
  static const _withdrawalsCollection = 'withdrawal_requests';
  static const _ordersCollection = 'orders';

  /// محفظة الحرفي: يُقسَّم مجموع حركات 'sale' المكتملة إلى متاح (تجاوز
  /// فترة الاحتجاز 72 ساعة) ومحتجز (لا يزال ضمنها)، مطروحاً منه أي مبالغ
  /// طلب سحبها بالفعل (قيد المعالجة أو مدفوعة) — لمنع سحب نفس الرصيد مرتين.
  Stream<WalletModel> getArtisanWallet(String artisanUid) {
    return _firestore
        .collection(_transactionsCollection)
        .where('toUid', isEqualTo: artisanUid)
        .where('type', isEqualTo: 'sale')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .asyncMap((snapshot) async {
      final now = DateTime.now();
      var available = 0;
      var pending = 0;
      var total = 0;
      for (final doc in snapshot.docs) {
        final tx = TransactionModel.fromMap(doc.id, doc.data());
        total += tx.amount;
        final releasedAt = tx.createdAt.add(Duration(hours: AppRules.holdPeriodHours));
        if (now.isAfter(releasedAt)) {
          available += tx.amount;
        } else {
          pending += tx.amount;
        }
      }

      final withdrawals = await _firestore.collection(_withdrawalsCollection).where('artisanUid', isEqualTo: artisanUid).where('status', whereIn: ['pending', 'paid']).get();
      final withdrawn = withdrawals.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as int? ?? 0));
      available = (available - withdrawn).clamp(0, available);

      return WalletModel(availableBalance: available, pendingBalance: pending, totalEarnings: total);
    });
  }

  /// طلب سحب أرباح الحرفي — يتحقق من الحد الأدنى والرصيد المتاح فعلياً قبل التسجيل.
  Future<void> requestWithdrawal({
    required String artisanUid,
    required int amount,
    required String iban,
  }) async {
    if (amount < AppRules.minWithdrawal) {
      throw Exception('الحد الأدنى للسحب ${AppRules.minWithdrawal} د.ع');
    }
    final wallet = await getArtisanWallet(artisanUid).first;
    if (amount > wallet.availableBalance) {
      throw Exception('الرصيد المتاح غير كافٍ لهذا السحب');
    }

    await _firestore.collection(_withdrawalsCollection).add({
      'artisanUid': artisanUid,
      'amount': amount,
      'iban': iban,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    await NotificationService.instance.sendBulkNotification(targetRole: 'admin', title: 'طلب سحب جديد', body: 'حرفي طلب سحب $amount د.ع');
  }

  /// Admin: طلبات سحب الحرفيين بحسب الحالة — لشاشة admin_financials.
  Stream<List<WithdrawalRequestModel>> getWithdrawalRequests({String status = 'pending'}) {
    return _firestore.collection(_withdrawalsCollection).where('status', isEqualTo: status).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => WithdrawalRequestModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Admin: تأكيد صرف طلب سحب فعلياً (تحويل بنكي يدوي خارج التطبيق) وتسجيله كمدفوع.
  Future<void> confirmWithdrawal(String withdrawalId) async {
    final doc = await _firestore.collection(_withdrawalsCollection).doc(withdrawalId).get();
    final artisanUid = doc.data()?['artisanUid'] as String? ?? '';
    final amount = doc.data()?['amount'] as int? ?? 0;

    await _firestore.collection(_withdrawalsCollection).doc(withdrawalId).update({'status': 'paid'});

    await NotificationService.instance.sendToUser(userUid: artisanUid, title: 'تم صرف طلب السحب', body: 'تم تحويل $amount د.ع إلى حسابك البنكي', type: 'withdrawal_paid');
  }

  /// Admin: رفض طلب سحب (مثلاً بيانات IBAN غير صحيحة) — يعيد المبلغ إلى الرصيد المتاح.
  Future<void> rejectWithdrawal(String withdrawalId, String reason) async {
    final doc = await _firestore.collection(_withdrawalsCollection).doc(withdrawalId).get();
    final artisanUid = doc.data()?['artisanUid'] as String? ?? '';

    await _firestore.collection(_withdrawalsCollection).doc(withdrawalId).update({'status': 'rejected', 'rejectionReason': reason});

    await NotificationService.instance.sendToUser(userUid: artisanUid, title: 'تم رفض طلب السحب', body: reason, type: 'withdrawal_rejected');
  }

  /// محفظة شركة الشحن: مجموع حركات 'delivery' المكتملة (تُدفع كاشاً فوراً، لا احتجاز).
  Stream<WalletModel> getShippingWallet(String shippingUid) {
    return _firestore
        .collection(_transactionsCollection)
        .where('toUid', isEqualTo: shippingUid)
        .where('type', isEqualTo: 'delivery')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      final total = snapshot.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as int? ?? 0));
      return WalletModel(availableBalance: total, totalEarnings: total);
    });
  }

  (DateTime, DateTime) _currentWeekRange() {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));
    return (weekStart, weekStart.add(const Duration(days: 7)));
  }

  Future<List<OrderModel>> _deliveredOrdersInWeek(String shippingUid, DateTime weekStart, DateTime weekEnd) async {
    final snapshot = await _firestore.collection(_ordersCollection).where('shippingUid', isEqualTo: shippingUid).where('status', isEqualTo: 'delivered').get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).where((order) {
      final completedAt = order.deliveredAt ?? order.createdAt;
      return !completedAt.isBefore(weekStart) && completedAt.isBefore(weekEnd);
    }).toList();
  }

  /// يحسب المستحق لهذا الأسبوع للعرض فقط دون حفظه — يُستخدم في شاشة
  /// المحفظة كي لا يُنشئ كل فتح للشاشة مستند تسوية جديداً.
  Future<SettlementModel> previewCurrentWeekSettlement(String shippingUid) async {
    final (weekStart, weekEnd) = _currentWeekRange();
    final weekOrders = await _deliveredOrdersInWeek(shippingUid, weekStart, weekEnd);
    return SettlementModel(
      id: '',
      shippingUid: shippingUid,
      weekStart: weekStart,
      weekEnd: weekEnd,
      deliveriesCount: weekOrders.length,
      totalEarnings: weekOrders.fold<int>(0, (acc, o) => acc + o.shippingEarnings),
      platformDue: weekOrders.fold<int>(0, (acc, o) => acc + (o.deliveryFee - o.shippingEarnings)),
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  /// مجموع الغرامات المخصومة من تأمين الشركة حتى الآن (من تسويات متأخرة فعلياً).
  Future<int> getUsedDeposit(String shippingUid) async {
    final snapshot = await _firestore.collection(_settlementsCollection).where('shippingUid', isEqualTo: shippingUid).where('status', isEqualTo: 'late').get();
    return snapshot.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['penaltyAmount'] as int? ?? 0));
  }

  /// يحسب تسوية الأسبوع الحالي لشركة شحن من طلباتها المُسلَّمة فعلياً، ويحفظها.
  Future<SettlementModel> calculateSettlement(String shippingUid) async {
    final (weekStart, weekEnd) = _currentWeekRange();
    final weekOrders = await _deliveredOrdersInWeek(shippingUid, weekStart, weekEnd);

    final totalEarnings = weekOrders.fold<int>(0, (acc, o) => acc + o.shippingEarnings);
    final platformDue = weekOrders.fold<int>(0, (acc, o) => acc + (o.deliveryFee - o.shippingEarnings));

    final docRef = _firestore.collection(_settlementsCollection).doc();
    final settlement = SettlementModel(
      id: docRef.id,
      shippingUid: shippingUid,
      weekStart: weekStart,
      weekEnd: weekEnd,
      deliveriesCount: weekOrders.length,
      totalEarnings: totalEarnings,
      platformDue: platformDue,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await docRef.set(settlement.toMap());
    return settlement;
  }

  /// Admin: تأكيد أن شركة الشحن سدّدت المستحق.
  Future<void> confirmSettlement(String settlementId) {
    return _firestore.collection(_settlementsCollection).doc(settlementId).update({'status': 'paid'});
  }

  /// يطبّق غرامة تأخر 2% على مبلغ التأمين ويُخطر الشركة.
  Future<void> applyLatePenalty(String settlementId) async {
    final doc = await _firestore.collection(_settlementsCollection).doc(settlementId).get();
    final settlement = SettlementModel.fromMap(settlementId, doc.data()!);
    final penalty = (settlement.platformDue * AppRules.latePenaltyRate).round();

    await _firestore.collection(_settlementsCollection).doc(settlementId).update({'status': 'late', 'penaltyAmount': penalty});

    await NotificationService.instance.sendToUser(
      userUid: settlement.shippingUid,
      title: 'غرامة تأخر في السداد',
      body: 'تم خصم $penalty د.ع من مبلغ التأمين بسبب التأخر في السداد',
      type: 'settlement_late',
    );
  }
}
