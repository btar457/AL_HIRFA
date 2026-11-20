import 'package:cloud_firestore/cloud_firestore.dart';

/// حركة مالية مسجّلة في مجموعة "transactions" (راجع AL-HIRFA-Legal-Rules.md — PART 9.2).
class TransactionModel {
  final String id;
  final String orderId;
  final String type; // sale, commission, delivery, refund, penalty
  final int amount;
  final String fromUid;
  final String toUid; // platform, artisan, shipping
  final String status; // pending, completed, failed
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.orderId,
    required this.type,
    required this.amount,
    required this.fromUid,
    required this.toUid,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      fromUid: map['fromUid'] as String? ?? '',
      toUid: map['toUid'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'type': type,
      'amount': amount,
      'fromUid': fromUid,
      'toUid': toUid,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
