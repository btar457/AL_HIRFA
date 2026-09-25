import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

/// طبقة الإشعارات: تهيئة FCM على جهاز المستخدم، وتسجيل الإشعارات في
/// Firestore ليقرأها المستخدم داخل التطبيق.
///
/// ملاحظة معمارية مهمة: حزمة firebase_messaging على العميل تستطيع فقط
/// استقبال الإشعارات وجلب/تحديث fcmToken الخاص بجهازها — لا تستطيع إرسال
/// Push فعلي لجهاز مستخدم آخر (يتطلب ذلك بيانات اعتماد خادم عبر Firebase
/// Admin SDK، عادة داخل Cloud Function تُفعَّل تلقائياً عند إنشاء مستند في
/// notifications/). لذا sendToUser/sendToShippingCompanies/sendBulkNotification
/// هنا تُسجّل الإشعار في Firestore فعلياً (يظهر فوراً داخل notifications_screen)
/// لكنها لا تُطلق تنبيه push حقيقياً على الجهاز حتى تُضاف Cloud Function مقابلة.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _usersCollection = 'users';
  static const _notificationsCollection = 'notifications';

  /// يطلب إذن الإشعارات، يجلب FCM token الخاص بالجهاز الحالي ويحفظه في
  /// مستند المستخدم، ويحدّثه تلقائياً كلما تغيّر.
  Future<void> initialize(String userId) async {
    await _fcm.requestPermission();
    final token = await _fcm.getToken();
    if (token != null) {
      await _firestore.collection(_usersCollection).doc(userId).update({'fcmToken': token});
    }
    _fcm.onTokenRefresh.listen((newToken) {
      _firestore.collection(_usersCollection).doc(userId).update({'fcmToken': newToken});
    });
  }

  /// يسجّل إشعاراً لمستخدم واحد في Firestore.
  Future<void> sendToUser({
    required String userUid,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection(_notificationsCollection).add(
      NotificationModel(id: '', userId: userUid, title: title, body: body, type: type, data: data ?? const {}, createdAt: DateTime.now()).toMap(),
    );
  }

  /// يسجّل إشعار طلب توصيل جديد لكل شركات الشحن النشطة في محافظة معيّنة.
  Future<void> sendToShippingCompanies({
    required String city,
    required String orderId,
    required String title,
    required String body,
  }) async {
    final companies = await _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'shipping')
        .where('city', isEqualTo: city)
        .where('isActive', isEqualTo: true)
        .where('approvalStatus', isEqualTo: 'approved')
        .get();

    for (final doc in companies.docs) {
      await sendToUser(userUid: doc.id, title: title, body: body, type: 'new_delivery', data: {'orderId': orderId});
    }
  }

  /// إرسال جماعي (Admin) لكل مستخدمي دور معيّن، أو للجميع. يُعيد عدد المستلمين
  /// الفعلي، ويسجّل مستند ملخّص واحد (userId فارغ، لا يظهر في صندوق أي
  /// مستخدم) لعرضه في سجل admin_notifications_screen.
  Future<int> sendBulkNotification({
    required String targetRole, // all/customer/artisan/shipping
    required String title,
    required String body,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(_usersCollection);
    if (targetRole != 'all') {
      query = query.where('role', isEqualTo: targetRole);
    }
    final users = await query.get();
    for (final doc in users.docs) {
      await sendToUser(userUid: doc.id, title: title, body: body, type: 'system');
    }

    await _firestore.collection(_notificationsCollection).add(
      NotificationModel(id: '', title: title, body: body, type: 'system', targetAudience: targetRole, recipientCount: users.docs.length, createdAt: DateTime.now()).toMap(),
    );

    return users.docs.length;
  }

  /// سجل الإرسال الجماعي (مستندات userId فارغ) — لشاشة admin_notifications.
  Stream<List<NotificationModel>> getBroadcastLog() {
    return _firestore.collection(_notificationsCollection).where('userId', isEqualTo: '').orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> markAsRead(String notificationId) {
    return _firestore.collection(_notificationsCollection).doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestore.collection(_notificationsCollection).where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
