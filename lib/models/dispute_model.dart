import 'package:cloud_firestore/cloud_firestore.dart';

/// نزاع مسجّل في مجموعة "disputes" (راجع AL-HIRFA-Legal-Rules.md — PART 9.2).
class DisputeModel {
  final String id;
  final String orderId;
  final String reporterUid;
  final String reportedUid;
  final String type; // fake_product, damage, fraud, harassment
  final String description;
  final List<String> evidenceUrls;
  final String status; // open, reviewing, resolved, appealed
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const DisputeModel({
    required this.id,
    required this.orderId,
    required this.reporterUid,
    required this.reportedUid,
    required this.type,
    required this.description,
    required this.evidenceUrls,
    required this.status,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory DisputeModel.fromMap(String id, Map<String, dynamic> map) {
    return DisputeModel(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      reporterUid: map['reporterUid'] as String? ?? '',
      reportedUid: map['reportedUid'] as String? ?? '',
      type: map['type'] as String? ?? '',
      description: map['description'] as String? ?? '',
      evidenceUrls: (map['evidenceUrls'] as List?)?.map((e) => e as String).toList() ?? const [],
      status: map['status'] as String? ?? 'open',
      resolution: map['resolution'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'type': type,
      'description': description,
      'evidenceUrls': evidenceUrls,
      'status': status,
      'resolution': resolution,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
