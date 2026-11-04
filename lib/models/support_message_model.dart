import 'package:cloud_firestore/cloud_firestore.dart';

/// رسالة دعم يرسلها أي مستخدم من داخل التطبيق وتصل مباشرة للإدارة (مجموعة
/// support_messages)، بديل/مكمِّل لقنوات التواصل الخارجية (بريد/واتساب) في
/// about_screen.dart.
class SupportMessageModel {
  final String id;
  final String uid;
  final String name;
  final String role; // customer/artisan/shipping — دور المُرسِل وقت الإرسال
  final String message;
  final String status; // open/resolved
  final String? adminReply;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportMessageModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.role,
    required this.message,
    this.status = 'open',
    this.adminReply,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportMessageModel.fromMap(String id, Map<String, dynamic> map) {
    return SupportMessageModel(
      id: id,
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      adminReply: map['adminReply'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      'message': message,
      'status': status,
      'adminReply': adminReply,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }
}
