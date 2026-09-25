import 'package:cloud_firestore/cloud_firestore.dart';

/// إشعار فردي أو سجل إرسال جماعي (شاشتا notifications_screen وadmin_notifications_screen).
class NotificationModel {
  final String id;
  final String userId; // فارغ لسجلات البث الجماعي المحلية في admin_notifications_screen
  final String title;
  final String body;
  final String type; // order/shipping/review/system...
  final String targetAudience; // all, customer, artisan, shipping (لسجل الإرسال الجماعي)
  final int recipientCount;
  final bool read;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    this.userId = '',
    required this.title,
    required this.body,
    this.type = '',
    this.targetAudience = 'all',
    this.recipientCount = 0,
    this.read = false,
    this.data = const {},
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? '',
      targetAudience: map['targetAudience'] as String? ?? 'all',
      recipientCount: map['recipientCount'] as int? ?? 0,
      read: map['isRead'] as bool? ?? false,
      data: (map['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'targetAudience': targetAudience,
      'recipientCount': recipientCount,
      'isRead': read,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
