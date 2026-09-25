import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_rules.dart';
import '../models/order_model.dart';
import '../models/transaction_model.dart';
import 'admin_service.dart';
import 'notification_service.dart';

/// الكمية المطلوبة أكبر من المتوفر. [productName]/[available] null إن
/// اكتُشف النفاد لحظة الحفظ فقط (مشترٍ آخر سبق لآخر قطعة).
class OutOfStockException implements Exception {
  final String? productName;
  final int? available;
  const OutOfStockException(this.productName, this.available);

  String get message {
    if (productName == null) return 'نفدت كمية أحد المنتجات قبل إتمام طلبك — راجع سلتك وحاول مجدداً';
    if (available == 0) return 'نفدت كمية "$productName" — احذفه من السلة لإتمام الطلب';
    return 'المتوفر من "$productName" $available فقط — عدّل الكمية في السلة';
  }
}

/// طبقة إدارة الطلبات ودورة حياتها الكاملة عبر Firestore.
class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _ordersCollection = 'orders';
  static const _transactionsCollection = 'transactions';
  static const _rateLimitsCollection = 'rate_limits';

  /// حد منتجات مختلفة في طلب واحد: كل منتج بمخزون متتبَّع يكلّف قواعد
  /// Firestore عدة قراءات get()/getAfter() ضمن الدفعة، وحدّها للدفعة الواحدة
  /// ثابت — مُختبَر في firestore-tests (8 تنجح، 10 تفشل).
  static const maxItemsPerCheckout = 8;

  /// يُشتَق من معرّف الطلب الفريد في Firestore (بدل رقم عشوائي قابل للتكرار)
  /// لضمان عدم تصادم رقمين مختلفين إطلاقاً.
  String _generateOrderNumber(String orderId) => 'HRF-${orderId.substring(0, 8).toUpperCase()}';

  /// يجلب طلباً ويتحقق من وجوده فعلياً قبل قراءة حقوله — بدل orderDoc.data()!
  /// المباشر الذي كان يرمي null-check exception غامضاً لو حُذف/فُقد المستند.
  /// نظري بحت حالياً (allow delete: if false على orders في كل الحالات)، لكن
  /// رسالة خطأ واضحة أفضل من انهيار null-check صامت لو تغيّر ذلك مستقبلاً.
  Future<OrderModel> _requireOrder(String orderId) async {
    final doc = await _firestore.collection(_ordersCollection).doc(orderId).get();
    if (!doc.exists) {
      throw Exception('تعذّر العثور على الطلب');
    }
    return OrderModel.fromMap(orderId, doc.data()!);
  }

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

    // قراءة خارج أي transaction/دفعة — نافذة سباق نظرية بين جلستين متزامنتين
    // لنفس المشتري. مقبول عند الحجم الحالي، مؤجَّل لا محسوم — راجع
    // POST_LAUNCH_DECISIONS.md البند 2.
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

    // [order.reservedQuantity] القادم من السلة = الكمية المطلوبة. المخزون
    // يُقرأ هنا طازجاً (قد تكون السلة قديمة)؛ الخصم الفعلي داخل الدفعة أدناه
    // تحرسه firestore.rules (stock >= 0 بعد الخصم) فلا يُباع أكثر من المتوفر
    // حتى لو تزامن مشتريان — تفشل الدفعة كاملة بدل البيع الزائد.
    final productDocs = await Future.wait(orders.map((o) => _firestore.collection('products').doc(o.productId).get()));
    final stocks = <int?>[];
    for (var i = 0; i < orders.length; i++) {
      final stock = productDocs[i].data()?['stock'] as int?;
      if (stock != null && stock < orders[i].reservedQuantity) {
        throw OutOfStockException(orders[i].productName, stock);
      }
      stocks.add(stock);
    }

    final batch = _firestore.batch();
    final newOrders = <OrderModel>[];
    for (var i = 0; i < orders.length; i++) {
      final order = orders[i];
      final docRef = _firestore.collection(_ordersCollection).doc();
      final tracked = stocks[i] != null;
      final newOrder = order.copyWith(
        id: docRef.id,
        orderNumber: _generateOrderNumber(docRef.id),
        status: 'pending',
        sellerApprovalDeadline: DateTime.now().add(Duration(hours: AppRules.sellerApprovalHours)),
        reservedQuantity: tracked ? order.reservedQuantity : 0,
      );
      batch.set(docRef, newOrder.toMap());
      if (tracked) {
        batch.update(_firestore.collection('products').doc(order.productId), {
          'stock': FieldValue.increment(-order.reservedQuantity),
          'lastReservationOrderId': docRef.id,
        });
      }
      newOrders.add(newOrder);
    }
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // رفض القواعد هنا يعني غالباً أن مشترياً آخر سبقه لآخر قطعة.
      if (e.code == 'permission-denied' && stocks.any((s) => s != null)) {
        throw OutOfStockException(null, null);
      }
      rethrow;
    }

    // ما دون هذا السطر غير ذرّي مع الدفعة أعلاه (rate_limits + الإشعارات) —
    // انقطاع هنا يترك عدّاداً ناقصاً أو إشعاراً ضائعاً. مقبول عند الحجم
    // الحالي، مؤجَّل لا محسوم — راجع POST_LAUNCH_DECISIONS.md البند 1.
    // فشله لا يجب أن يُظهر خطأً للمشتري: طلباته أُنشئت فعلاً، ورسالة خطأ
    // هنا تُبقي السلة ممتلئة فيعيد الطلب ويُنشئ طلبات مكرَّرة.
    try {
      for (var i = 0; i < newOrders.length; i++) {
        await _incrementRateLimit(buyerUid);
      }

      for (var i = 0; i < newOrders.length; i++) {
        final newOrder = newOrders[i];
        await NotificationService.instance.sendToUser(
          userUid: newOrder.artisanUid,
          title: 'طلب جديد ينتظر موافقتك',
          body: '${newOrder.productName} — ${newOrder.orderNumber}',
          type: 'new_order',
          data: {'orderId': newOrder.id},
        );
        if (stocks[i] != null && stocks[i]! - newOrder.reservedQuantity <= 0) {
          await NotificationService.instance.sendToUser(
            userUid: newOrder.artisanUid,
            title: 'نفدت كمية منتجك',
            body: '${newOrder.productName} — حدّث الكمية من "تعديل المنتج" ليعود متاحاً للشراء',
            type: 'out_of_stock',
            data: {'productId': newOrder.productId},
          );
        }
      }
    } catch (_) {}
    return newOrders.map((o) => o.id).toList();
  }

  /// يعيد الكمية المحجوزة لطلب أُلغي إلى مخزون منتجه.
  /// فشله لا يُفشل الإلغاء نفسه (تم فعلاً) — الحرفي يستطيع تصحيح الكمية
  /// يدوياً من "تعديل المنتج".
  Future<void> _restoreStock(OrderModel order) async {
    if (order.reservedQuantity <= 0) return;
    try {
      await _firestore.collection('products').doc(order.productId).update({'stock': FieldValue.increment(order.reservedQuantity)});
    } catch (_) {}
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

  /// الحرفي يوافق على الطلب. قسم شركات الشحن مغلق مؤقتاً — الحرفي نفسه
  /// يتكفّل بالتوصيل ويؤكّده لاحقاً عبر confirmDelivery مباشرة من هذه الحالة
  /// (راجع firestore.rules: فرع "الحرفي يؤكّد التسليم بنفسه").
  Future<void> sellerApproveOrder(String orderId) async {
    final order = await _requireOrder(orderId);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'seller_approved'});

    await NotificationService.instance.sendToUser(
      userUid: order.buyerUid,
      title: 'البائع وافق على طلبك',
      body: 'سيتواصل معك الحرفي لتوصيل طلبك ${order.orderNumber}',
      type: 'shipping_assigned',
      data: {'orderId': orderId},
    );
  }

  /// الحرفي يرفض الطلب مع ذكر السبب.
  Future<void> sellerRejectOrder(String orderId, String reason) async {
    final order = await _requireOrder(orderId);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'cancelled', 'rejectionReason': reason, 'rejectedBy': 'seller'});
    await _restoreStock(order);

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
      final order = await _requireOrder(orderId);
      await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم تعيين شركة شحن لطلبك', body: shippingCompanyName, type: 'shipping_assigned', data: {'orderId': orderId});
      await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'بدأ الشحن', body: 'شركة $shippingCompanyName ستستلم طلبك قريباً', type: 'shipping_assigned', data: {'orderId': orderId});
    }
    return accepted;
  }

  /// شركة الشحن استلمت المنتج من الحرفي.
  Future<void> shippingPickedUp(String orderId) async {
    final order = await _requireOrder(orderId);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'picked_up'});

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'طلبك في الطريق إليك', body: order.productName, type: 'order_picked_up', data: {'orderId': orderId});
  }

  /// تأكيد التسليم — الحرفي يستلم كامل المبلغ كاشاً من الزبون مباشرة عند
  /// التسليم، وعمولة المنصة (platformFee) تُسجَّل كدَين يسدّده لاحقاً (راجع
  /// admin_commissions_owed_screen.dart) بدل تحويل مؤجَّل من المنصة إليه
  /// كما كان في نموذج الدفع الإلكتروني القديم — لا علاقة لـ holdPeriodHours
  /// بهذا المسار إطلاقاً.
  Future<void> confirmDelivery(String orderId) async {
    final order = await _requireOrder(orderId);

    await _confirmDeliveryAndCreateTransactions(orderId, order);
    await _firestore.collection('products').doc(order.productId).update({'salesCount': FieldValue.increment(1)});

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم التسليم', body: 'قيّم تجربتك مع ${order.productName}', type: 'order_delivered', data: {'orderId': orderId});
    await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'تم التسليم', body: 'لا تنسَ تسديد عمولة المنصة (${order.platformFee} د.ع) عن هذا الطلب', type: 'wallet_credited', data: {'orderId': orderId});
  }

  /// يحدّث حالة الطلب إلى delivered ثم يسجّل الحركات المالية — حصة الحرفي،
  /// عمولة المنصة، وحصة شركة الشحن إن وُجدت (تُدفع كاشاً فوراً بلا احتجاز).
  ///
  /// عمداً نداءان متتاليان لا WriteBatch واحدة: قاعدة transactions/create في
  /// firestore.rules تشترط orderData(orderId).status == 'delivered'، وهذا
  /// الـ get() يُقيَّم مقابل حالة قاعدة البيانات *قبل* تنفيذ أي WriteBatch لا
  /// تسلسلياً معه (نفس قيد Firestore الموثّق أعلاه في createOrders بخصوص
  /// rate_limits، لكنه هنا يمس مستنداً مختلفاً ضمن نفس الدفعة) — فدمج تحديث
  /// حالة الطلب مع إنشاء المعاملات في batch واحدة يجعل الفحص يفشل دائماً
  /// ويُرفَض التسليم كلياً. الفجوة الناتجة عن الفصل (تحديث الطلب قد ينجح ثم
  /// تفشل المعاملات لاحقاً) مقبولة بنفس منطق الفجوات الموثّقة في
  /// POST_LAUNCH_DECISIONS.md، وتُعالَج تلقائياً: طلب delivered بلا معاملات
  /// قابل لإعادة المحاولة لاحقاً بنفس المعرّفات الحتمية (orderId_type) بلا
  /// ازدواج.
  Future<void> _confirmDeliveryAndCreateTransactions(String orderId, OrderModel order) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': 'delivered',
      'deliveredAt': Timestamp.now(),
    });

    final batch = _firestore.batch();
    final now = DateTime.now();

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
    final order = await _requireOrder(orderId);

    await _firestore.collection(_ordersCollection).doc(orderId).update({'status': 'cancelled', 'rejectionReason': reason});
    await _restoreStock(order);

    if (order.disputeId != null) {
      await _firestore.collection('disputes').doc(order.disputeId).update({'status': 'resolved', 'resolution': reason, 'resolvedAt': Timestamp.now()});
    }

    await NotificationService.instance.sendToUser(userUid: order.buyerUid, title: 'تم إلغاء طلبك', body: reason, type: 'order_cancelled', data: {'orderId': orderId});
    await NotificationService.instance.sendToUser(userUid: order.artisanUid, title: 'تم إلغاء الطلب', body: reason, type: 'order_cancelled', data: {'orderId': orderId});
  }

  /// Admin: يعلّم كل عمولات حرفي معيّن المستحقة والمؤكَّدة (طلبات delivered
  /// لم تُعلَّم بعد) بأنها دُفعت — بعد أن يحوّل الحرفي المبلغ للمنصة يدوياً
  /// خارج التطبيق (تحويل بنكي). راجع admin_commissions_owed_screen.dart.
  ///
  /// [artisanUid] دفاع إضافي بلا فائدة أمنية فعلية (Firestore rules تعيد
  /// فحص isAdmin() بشكل مستقل بغضّ النظر) — يمنع فقط خطأ برمجي مستقبلي في
  /// تجميع _groupByArtisan من تعليم عمولات حرفي آخر مدفوعة بالخطأ بصمت؛ لو
  /// حدث تطابق خاطئ يفشل الاستدعاء بالكامل بدل تنفيذ جزء منه فقط.
  Future<void> markArtisanCommissionPaid(String artisanUid, List<String> orderIds) async {
    if (orderIds.isEmpty) return;
    final orders = await Future.wait(orderIds.map(_requireOrder));
    final mismatched = orders.where((o) => o.artisanUid != artisanUid);
    if (mismatched.isNotEmpty) {
      throw Exception('طلب لا يخص هذا الحرفي — تم إلغاء العملية بالكامل');
    }

    final batch = _firestore.batch();
    for (final orderId in orderIds) {
      batch.update(_firestore.collection(_ordersCollection).doc(orderId), {'commissionPaid': true});
    }
    await batch.commit();
  }
}
