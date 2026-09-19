import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// حالة إشعارات المستخدم الحالي (AL-HIRFA-Firebase-Setup.md — PART 4.4).
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  StreamSubscription<List<NotificationModel>>? _subscription;
  String? _userId;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// يبدأ الاستماع الحي لإشعارات المستخدم؛ يتجاهل الاستدعاء إن كان
  /// المستخدم نفسه مشتركاً بالفعل (يُستدعى عادة عند كل بناء للشاشة).
  void loadNotifications(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    _subscription = NotificationService.instance.getUserNotifications(userId).listen((items) {
      _notifications = items;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await NotificationService.instance.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await NotificationService.instance.markAllAsRead(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
