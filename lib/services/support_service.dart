import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_message_model.dart';
import 'notification_service.dart';

/// رسائل الدعم المرسَلة من داخل التطبيق مباشرة للإدارة (مجموعة
/// support_messages) — بديل/مكمِّل لقنوات التواصل الخارجية (بريد/واتساب).
class SupportService {
  SupportService._();
  static final SupportService instance = SupportService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _collection = 'support_messages';

  /// يُنشئ رسالة دعم جديدة ويُشعر كل حسابات الإدارة فوراً (نفس نمط طلب
  /// السحب في wallet_service.dart: sendBulkNotification(targetRole: 'admin')).
  Future<void> sendMessage({
    required String uid,
    required String name,
    required String role,
    required String message,
  }) async {
    await _firestore.collection(_collection).add(
      SupportMessageModel(id: '', uid: uid, name: name, role: role, message: message, createdAt: DateTime.now()).toMap(),
    );
    await NotificationService.instance.sendBulkNotification(
      targetRole: 'admin',
      title: 'رسالة دعم جديدة',
      body: '$name: $message',
    );
  }

  /// رسائل مستخدم معيّن (لعرض سجل رسائله وردود الإدارة عليها).
  Stream<List<SupportMessageModel>> getMyMessages(String uid) {
    return _firestore.collection(_collection).where('uid', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => SupportMessageModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// Admin: كل رسائل الدعم عبر كل المستخدمين.
  Stream<List<SupportMessageModel>> getAllMessages() {
    return _firestore.collection(_collection).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => SupportMessageModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<int> getOpenMessagesCount() {
    return _firestore.collection(_collection).where('status', isEqualTo: 'open').snapshots().map((s) => s.docs.length);
  }

  /// Admin: يردّ على رسالة ويعلّمها كمُعالَجة.
  Future<void> resolveMessage(String id, {String? adminReply}) {
    return _firestore.collection(_collection).doc(id).update({
      'status': 'resolved',
      'adminReply': adminReply,
      'resolvedAt': Timestamp.now(),
    });
  }
}
