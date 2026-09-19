import 'package:cloud_firestore/cloud_firestore.dart';

/// تسوية أسبوعية بين شركة الشحن ومنصة AL-HIRFA (PART 2.1 — settlements).
class SettlementModel {
  final String id;
  final String shippingUid;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int deliveriesCount;
  final int totalEarnings; // أرباح الشركة تلك الأسبوع
  final int platformDue; // المستحق لـ AL-HIRFA
  final String status; // pending, paid, late, deducted
  final int penaltyAmount;
  final DateTime createdAt;

  const SettlementModel({
    required this.id,
    required this.shippingUid,
    required this.weekStart,
    required this.weekEnd,
    required this.deliveriesCount,
    required this.totalEarnings,
    required this.platformDue,
    required this.status,
    this.penaltyAmount = 0,
    required this.createdAt,
  });

  factory SettlementModel.fromMap(String id, Map<String, dynamic> map) {
    return SettlementModel(
      id: id,
      shippingUid: map['shippingUid'] as String? ?? '',
      weekStart: (map['weekStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekEnd: (map['weekEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveriesCount: map['deliveriesCount'] as int? ?? 0,
      totalEarnings: map['totalEarnings'] as int? ?? 0,
      platformDue: map['platformDue'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
      penaltyAmount: map['penaltyAmount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shippingUid': shippingUid,
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'deliveriesCount': deliveriesCount,
      'totalEarnings': totalEarnings,
      'platformDue': platformDue,
      'status': status,
      'penaltyAmount': penaltyAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
