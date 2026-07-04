import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// حالة إشعارات المستخدم الحالي (AL-HIRFA-Firebase-Setup.md — PART 4.4).
/// TODO: يُربط بـ notification_service.dart الحقيقي (FCM) في مرحلة الشحن القادمة.
class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications(String userId) async {
    // TODO: NotificationService.getUserNotifications(userId)
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: تحديث isRead لهذا الإشعار في Firestore.
  }

  Future<void> markAllAsRead(String userId) async {
    // TODO: NotificationService.markAllAsRead(userId)
    _unreadCount = 0;
    notifyListeners();
  }
}
