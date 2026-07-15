import 'package:cloud_firestore/cloud_firestore.dart';

/// طلب سحب أرباح حرفي (مجموعة withdrawal_requests).
class WithdrawalRequestModel {
  final String id;
  final String artisanUid;
  final int amount;
  final String iban;
  final String status; // pending, paid, rejected
  final DateTime createdAt;

  const WithdrawalRequestModel({
    required this.id,
    required this.artisanUid,
    required this.amount,
    required this.iban,
    required this.status,
    required this.createdAt,
  });

  factory WithdrawalRequestModel.fromMap(String id, Map<String, dynamic> map) {
    return WithdrawalRequestModel(
      id: id,
      artisanUid: map['artisanUid'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      iban: map['iban'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
