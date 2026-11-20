import 'package:cloud_firestore/cloud_firestore.dart';

/// مخالفة مسجّلة في مجموعة "violations" (راجع AL-HIRFA-Legal-Rules.md — PART 9.2).
class ViolationModel {
  final String id;
  final String userUid;
  final String type; // late_delivery, fake_product, etc.
  final String description;
  final String severity; // warning, suspension, ban
  final int penaltyDays;
  final DateTime createdAt;

  const ViolationModel({
    required this.id,
    required this.userUid,
    required this.type,
    required this.description,
    required this.severity,
    required this.penaltyDays,
    required this.createdAt,
  });

  factory ViolationModel.fromMap(String id, Map<String, dynamic> map) {
    return ViolationModel(
      id: id,
      userUid: map['userUid'] as String? ?? '',
      type: map['type'] as String? ?? '',
      description: map['description'] as String? ?? '',
      severity: map['severity'] as String? ?? 'warning',
      penaltyDays: map['penaltyDays'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'type': type,
      'description': description,
      'severity': severity,
      'penaltyDays': penaltyDays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
