import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dispute_model.dart';
import 'notification_service.dart';

/// طبقة البلاغات/النزاعات بين أطراف الطلب (AL-HIRFA-Legal-Rules.md — PART 9.2).
class DisputeService {
  DisputeService._();
  static final DisputeService instance = DisputeService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _disputesCollection = 'disputes';

  /// يسجّل بلاغاً جديداً بحالة 'open' ويُخطر الإدارة.
  Future<String> createDispute({
    required String orderId,
    required String reporterUid,
    required String reportedUid,
    required String type,
    required String description,
    List<String> evidenceUrls = const [],
  }) async {
    final docRef = _firestore.collection(_disputesCollection).doc();
    final dispute = DisputeModel(
      id: docRef.id,
      orderId: orderId,
      reporterUid: reporterUid,
      reportedUid: reportedUid,
      type: type,
      description: description,
      evidenceUrls: evidenceUrls,
      status: 'open',
      createdAt: DateTime.now(),
    );
    await docRef.set(dispute.toMap());
    await NotificationService.instance.sendBulkNotification(targetRole: 'admin', title: 'بلاغ جديد', body: description);
    return docRef.id;
  }

  Stream<List<DisputeModel>> getDisputesByStatus(String status) {
    return _firestore.collection(_disputesCollection).where('status', isEqualTo: status).orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => DisputeModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Stream<DisputeModel?> watchDispute(String disputeId) {
    return _firestore.collection(_disputesCollection).doc(disputeId).snapshots().map(
      (doc) => doc.exists ? DisputeModel.fromMap(doc.id, doc.data()!) : null,
    );
  }

  /// Admin: يضع النزاع قيد المراجعة (يبدأ سباق مهلة 48 ساعة — AppRules.disputeResolutionHours).
  Future<void> markReviewing(String disputeId) {
    return _firestore.collection(_disputesCollection).doc(disputeId).update({'status': 'reviewing'});
  }

  /// Admin: يغلق النزاع بقرار نهائي ويُخطر الطرفين.
  Future<void> resolveDispute(String disputeId, String resolution) async {
    final doc = await _firestore.collection(_disputesCollection).doc(disputeId).get();
    final dispute = DisputeModel.fromMap(disputeId, doc.data()!);

    await _firestore.collection(_disputesCollection).doc(disputeId).update({
      'status': 'resolved',
      'resolution': resolution,
      'resolvedAt': Timestamp.now(),
    });

    await NotificationService.instance.sendToUser(userUid: dispute.reporterUid, title: 'تم حل البلاغ', body: resolution, type: 'dispute_resolved', data: {'disputeId': disputeId});
    await NotificationService.instance.sendToUser(userUid: dispute.reportedUid, title: 'تم حل البلاغ المقدَّم ضدك', body: resolution, type: 'dispute_resolved', data: {'disputeId': disputeId});
  }
}
