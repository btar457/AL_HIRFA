import 'package:cloud_firestore/cloud_firestore.dart';

/// إشعار مرسَل من الإدارة أو النظام (شاشة notifications_screen وadmin_notifications_screen).
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String targetAudience; // all, customer, artisan, shipping
  final int recipientCount;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetAudience,
    this.recipientCount = 0,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      targetAudience: map['targetAudience'] as String? ?? 'all',
      recipientCount: map['recipientCount'] as int? ?? 0,
      read: map['read'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'targetAudience': targetAudience,
      'recipientCount': recipientCount,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
