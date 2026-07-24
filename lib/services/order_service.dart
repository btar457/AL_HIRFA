import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_rules.dart';
import '../models/order_model.dart';
import '../models/transaction_model.dart';
import 'admin_service.dart';
import 'notification_service.dart';

/// طبقة إدارة الطلبات ودورة حياتها الكاملة عبر Firestore.
class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _ordersCollection = 'orders';
  static const _transactionsCollection = 'transactions';
  static const _rateLimitsCollection = 'rate_limits';

  /// يُشتَق من معرّف الطلب الفريد في Firestore (بدل رقم عشوائي قابل للتكرار)
  /// لضمان عدم تصادم رقمين مختلفين إطلاقاً.
  String _generateOrderNumber(String orderId) => 'HRF-${orderId.substring(0, 8).toUpperCase()}';

  /// ينشئ عدّة طلبات دفعة واحدة (سلة بأكثر من منتج، منتج واحد لكل طلب) ضمن
  /// WriteBatch ذرّية واحدة — إما تُنشأ كل الطلبات معاً أو لا يُنشأ أي منها،
  /// فلا تبقى حالة جزئية (بعض الطلبات أُنشئت وبعضها لا) كما كان يحدث سابقاً
  /// مع حلقة تستدعي إنشاءً مستقلاً لكل طلب على حدة.
  ///
  /// عدّاد rate_limits/{buyerUid} مُستبعَد عمداً من هذه الدفعة: firestore.rules
  /// تسمح فقط بزيادة +1 واحدة لكل كتابة (rate_limits/update تشترط
  /// hourlyCount == القيمة السابقة + 1 بالضبط)، وأثبتت اختبارات
  /// firestore-tests/rules.test.mjs تجريبياً أن أي محاولتين لكتابة نفس
  /// المستند ضمن دفعة واحدة تُقيَّمان معاً مقابل حالته *قبل* الدفعة لا
  /// تصاعدياً، فتفشل كتابة ثانية +1 دائماً — لا يوجد شكل من WriteBatch يزيد
  /// العدّاد بمقدار N بلا تعديل القاعدة نفسها. الفحص أدناه (قبل بناء الدفعة)
  /// يمنع الدفعة كاملة إن كانت ستتجاوز الحد، ثم الزيادات الفعلية بعد نجاح
  /// الدفعة تبقى متسلسلة +1 كما كانت دائماً (AppRules.maxOrdersPerHour) —
  /// موثوقيتها كما كانت تماماً، لأن دمجها ذرّياً مع الدفعة غير ممكن هنا.
  Future<List<String>> createOrders(List<OrderModel> orders) async {
    if (orders.isEmpty) return [];
    final buyerUid = orders.first.buyerUid;

    final rateLimitRef = _firestore.collection(_rateLimitsCollection).doc(buyerUid);
    final rateLimitDoc = await rateLimitRef.get();
    var currentCount = 0;
    if (rateLimitDoc.exists) {
      final windowStart = (rateLimitDoc.data()!['windowStart'] as Timestamp).toDate();
      final windowExpired = DateTime.now().difference(windowStart) > const Duration(hours: 1);
      currentCount = windowExpired ? 0 : rateLimitDoc.data()!['hourlyCount'] as int;
    }
    if (currentCount + orders.length > AppRules.maxOrdersPerHour) {
      throw Exception('لقد تجاوزت الحد المسموح لعدد الطلبات خلال ساعة واحدة، يرجى المحاولة لاحقاً');
    }

    final batch = _firestore.batch();
    final newOrders = <OrderModel>[];
    for (final order in orders) {
      final docRef = _firestore.collection(_ordersCollection).doc();
      final newOrder = order.copyWith(
        id: docRef.id,
        orderNumber: _generateOrderNumber(docRef.id),
        status: 'pending',
        sellerApprovalDeadline: DateTime.now().add(Duration(hours: AppRules.sellerApprovalHours)),
      );
      batch.set(docRef, newOrder.toMap());
      newOrders.add(newOrder);
    }
    await batch.commit();

    for (var i = 0; i < newOrders.length; i++) {
      await _incrementRateLimit(buyerUid);
    }

    for (final newOrder in newOrders) {
      await NotificationService.instance.sendToUser(
        userUid: newOrder.artisanUid,
        title: 'طلب جديد ينتظر موافقتك',
        body: '${newOrder.productName} — ${newOrder.orderNumber}',
        type: 'new_order',
        data: {'orderId': newOrder.id},
      );
    }
    return newOrders.map((o) => o.id).toList();
  }

  Future<void> _incrementRateLimit(String buyerUid) async {
    final rateLimitRef = _firestore.collection(_rateLimitsCollection).doc(buyerUid);
    await _firestore.runTransaction((tx) async {
      final rateLimitDoc = await tx.get(rateLimitRef);
      final now = Timestamp.now();
      if (!rateLimitDoc.exists) {
        tx.set(rateLimitRef, {'hourlyCount': 1, 'windowStart': now});
      } else {
        final windowStart = rateLimitDoc.data()!['windowStart'] as Timestamp;
        final hourlyCount = rateLimitDoc.data()!['hourlyCount'] as int;
        final windowExpired = now.toDate().difference(windowStart.toDate()) > const Duration(hours: 1);
        if (windowExpired) {
          tx.set(rateLimitRef, {'hourlyCount': 1, 'windowStart': now});
        } else {
          tx.update(rateLimitRef, {'hourlyCount': hourlyCount + 1});
        }
      }
    });
  }

  /// الحرفي يوافق على الطلب — يفتح نافذة 5 دقائق لشركات الشحن للقبول.
  Future<void> sellerApproveOrder(String orderId) async {
    final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    final order = OrderModel.fromMap(orderId, orderDoc.data()!);

    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': 'seller_approved',
      'shippingAcceptDeadline': Timestamp.fromDate(DateTime.now().add(Duration(minutes: AppRules.shippingAcceptMinutes))),
    });

    await NotificationService.instance.sendToShippingCompanies(
      city: order.governorate,
      orderId: orderId,
      title: 'طلب توصيل جديد في ${order.governorate}',
      body: '${order.productName} — أجر التوصيل ${order.shippingEarnings} د.ع',
    );
    await NotificationService.instance.sendToUser(
      userUid: order.buyerUid,
      title: 'البائع وافق على طلبك',
      body: 'نبحث الآن عن شركة شحن لطلبك ${order.orderNumber}',
      type: 'shipping_assigned',
      data: {'orderId': orderId},
    );
  }

  /// الحرفي يرفض الطلب مع ذكر السبب.
  Future<void> sellerRejectOrder(String orderId, String reason) async {
    final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    final order = OrderModel.fromMap(orderId, orderDoc.data()!);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'cancelled', 'rejectionReason': reason, 'rejectedBy': 'seller'});

    await NotificationService.instance.sendToUser(
      userUid: order.buyerUid,
      title: 'تم إلغاء طلبك',
      body: reason,
      type: 'order_rejected',
      data: {'orderId': orderId},
    );

    await _enforceRejectionPenalties(order.artisanUid);
  }

  /// يطبّق تحذيراً/تعليقاً تراكمياً على الحرفي حسب حدود AppRules عند تكرار
  /// رفضه للطلبات (consecutiveRejectsWarning شهرياً/تراكمياً).
  Future<void> _enforceRejectionPenalties(String artisanUid) async {
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final monthlyRejects = await _firestore
        .collection(_ordersCollection)
        .where('artisanUid', isEqualTo: artisanUid)
        .where('rejectedBy', isEqualTo: 'seller')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .count()
        .get();
    final monthlyCount = monthlyRejects.count ?? 0;

    if (monthlyCount >= AppRules.monthlyRejectsSuspension) {
      await AdminService.instance.suspendUser(artisanUid, 'تجاوز الحد الأقصى لرفض الطلبات خلال الشهر ($monthlyCount مرات)');
      return;
    }

    final recentOrders = await _firestore
        .collection(_ordersCollection)
        .where('artisanUid', isEqualTo: artisanUid)
        .orderBy('createdAt', descending: true)
        .limit(AppRules.consecutiveRejectsWarning)
        .get();
    final allRecentRejected = recentOrders.docs.length == AppRules.consecutiveRejectsWarning &&
        recentOrders.docs.every((doc) => doc.data()['rejectedBy'] == 'seller');
    if (allRecentRejected) {
      await AdminService.instance.warnUser(artisanUid, 'رفض ${AppRules.consecutiveRejectsWarning} طلبات متتالية');
    }
  }

  /// شركة الشحن تقبل الطلب — Firestore Transaction تمنع قبول أكثر من شركة لنفس الطلب.
  Future<bool> shippingAcceptOrder(String orderId, String shippingUid, String shippingCompanyName) async {
    final companyDoc = await _firestore.collection('users').doc(shippingUid).get();
    final coverageProvinces = (companyDoc.data()?['provinces'] as List?)?.map((e) => e as String).toList() ?? const <String>[];

    final accepted = await _firestore.runTransaction<bool>((tx) async {
      final orderRef = _firestore.collection(_ordersCollection).doc(orderId);
      final orderSnap = await tx.get(orderRef);

      if (orderSnap.data()?['status'] != 'seller_approved') {
        return false; // سبقك شخص آخر أو الطلب لم يعد متاحاً
      }
      final orderGovernorate = (orderSnap.data()?['address'] as Map?)?['governorate'];
      if (!coverageProvinces.contains(orderGovernorate)) {
        throw Exception('هذا الطلب خارج نطاق تغطيتك المسجَّل');
      }

      tx.update(orderRef, {
        'status': 'shipping_assigned',
        'shippingUid': shippingUid,
        'shippingCompanyName': shippingCompanyName,
        'shippingAssignedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });

    if (accepted) {
      final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
      final order = OrderModel.fromMap(orderId, orderDoc.data()!);
      await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم تعيين شركة شحن لطلبك', body: shippingCompanyName, type: 'shipping_assigned', data: {'orderId': orderId});
      await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'بدأ الشحن', body: 'شركة $shippingCompanyName ستستلم طلبك قريباً', type: 'shipping_assigned', data: {'orderId': orderId});
    }
    return accepted;
  }

  /// شركة الشحن استلمت المنتج من الحرفي.
  Future<void> shippingPickedUp(String orderId) async {
    final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    final order = OrderModel.fromMap(orderId, orderDoc.data()!);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'picked_up'});

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'طلبك في الطريق إليك', body: order.productName, type: 'order_picked_up', data: {'orderId': orderId});
  }

  /// تأكيد التسليم — يبدأ عداد 72 ساعة لتحويل أرباح الحرفي.
  Future<void> confirmDelivery(String orderId) async {
    final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    final order = OrderModel.fromMap(orderId, orderDoc.data()!);

    await _confirmDeliveryAndCreateTransactions(orderId, order);
    await _firestore.collection('products').doc(order.productId).update({'salesCount': FieldValue.increment(1)});

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم التسليم', body: 'قيّم تجربتك مع ${order.productName}', type: 'order_delivered', data: {'orderId': orderId});
    await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'تم التسليم', body: 'أرباحك ستُحوَّل خلال ${AppRules.holdPeriodHours} ساعة', type: 'wallet_credited', data: {'orderId': orderId});
  }

  /// يحدّث حالة الطلب إلى delivered ويسجّل الحركات المالية الثلاث — حصة
  /// الحرفي (بحسبان فترة احتجاز 72 ساعة تُحتسب لاحقاً في wallet_service.dart
  /// من createdAt)، عمولة المنصة، وحصة شركة الشحن (تُدفع كاشاً فوراً بلا
  /// احتجاز) — ضمن WriteBatch واحدة ذرّية: إما تنجح الكتابات الأربع معاً أو
  /// تفشل كلها معاً، فلا يبقى طلب delivered بلا أثر مالي مقابل.
  Future<void> _confirmDeliveryAndCreateTransactions(String orderId, OrderModel order) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    batch.update(_firestore.collection(_ordersCollection).doc(orderId), {
      'status': 'delivered',
      'deliveredAt': Timestamp.now(),
    });

    // معرّف حتمي (orderId_type) بدل doc() العشوائي — يمنع تكرار نفس المعاملة
    // لنفس الطلب: أي محاولة ثانية تصطدم بوثيقة موجودة فتُعامَل كـupdate
    // وهي if false في firestore.rules (راجع transactions/{transactionId}).
    void addTransaction(String type, int amount, String fromUid, String toUid) {
      final ref = _firestore.collection(_transactionsCollection).doc('${orderId}_$type');
      batch.set(
        ref,
        TransactionModel(id: ref.id, orderId: orderId, type: type, amount: amount, fromUid: fromUid, toUid: toUid, status: 'completed', createdAt: now).toMap(),
      );
    }

    addTransaction('sale', order.artisanEarnings, order.buyerUid, order.artisanUid);
    addTransaction('commission', order.platformFee, order.buyerUid, 'platform');
    if (order.shippingUid != null) {
      addTransaction('delivery', order.shippingEarnings, order.buyerUid, order.shippingUid!);
    }

    await batch.commit();
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

  /// الطلبات المتاحة لشركات الشحن (بانتظار شركة تقبلها)، اختيارياً مصفّاة
  /// بمحافظة معيّنة — null يعرض كل المحافظات.
  /// [coverageProvinces] هو نطاق تغطية شركة الشحن المسجَّل فعلياً — الطلبات
  /// المعروضة تقتصر عليه دائماً، حتى لو لم يُحدَّد [governorateFilter].
  Stream<List<OrderModel>> getAvailableDeliveries(List<String> coverageProvinces, {String? governorateFilter}) {
    if (coverageProvinces.isEmpty) return Stream.value(const []);

    final allowed = governorateFilter != null && coverageProvinces.contains(governorateFilter)
        ? [governorateFilter]
        : coverageProvinces;

    Query<Map<String, dynamic>> query = _firestore.collection(_ordersCollection).where('status', isEqualTo: 'seller_approved');
    if (allowed.length <= 30) {
      query = query.where('address.governorate', whereIn: allowed);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<OrderModel>> getShippingOrders(String shippingUid) {
    return _firestore.collection(_ordersCollection).where('shippingUid', isEqualTo: shippingUid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Admin: كل طلبات المنصة عبر كل المستخدمين — لشاشة admin_orders.
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore.collection(_ordersCollection).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Admin: إلغاء قسري لطلب (عادة أثناء حل نزاع). إن كان الطلب مرتبطاً ببلاغ
  /// مفتوح، يُغلق البلاغ أيضاً بنفس السبب بدل تركه مفتوحاً للأبد.
  Future<void> adminCancelOrder(String orderId, String reason) async {
    final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    final order = OrderModel.fromMap(orderId, orderDoc.data()!);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'cancelled', 'rejectionReason': reason});

    if (order.disputeId != null) {
      await _firestore.collection('disputes').doc(order.disputeId).update({'status': 'resolved', 'resolution': reason, 'resolvedAt': Timestamp.now()});
    }

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم إلغاء طلبك', body: reason, type: 'order_cancelled', data: {'orderId': orderId});
    await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'تم إلغاء الطلب', body: reason, type: 'order_cancelled', data: {'orderId': orderId});
  }
}
