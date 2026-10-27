import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

IconData _iconFor(NotificationModel n) {
  if (n.title.contains('قبول') || n.title.contains('الطريق') || n.title.contains('تسليم') || n.title.contains('شحن')) return Icons.local_shipping_outlined;
  if (n.title.contains('عرض')) return Icons.local_offer_outlined;
  if (n.title.contains('مؤسس') || n.title.contains('حساب')) return Icons.admin_panel_settings_outlined;
  return Icons.notifications_outlined;
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'قبل قليل';
  if (diff.inHours < 1) return 'قبل ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
  return 'قبل ${diff.inDays} يوم';
}

/// شاشة الإشعارات الشخصية للمستخدم — مربوطة بـ NotificationProvider الحقيقي (SHARED-1).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('الإشعارات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
          actions: [
            if (userId != null)
              TextButton(
                onPressed: () => context.read<NotificationProvider>().markAllAsRead(userId),
                child: const Text('تعليم الكل كمقروء', style: TextStyle(color: AppColors.gold, fontSize: 12)),
              ),
          ],
        ),
        body: userId == null
            ? Center(child: Text('سجّل الدخول لعرض إشعاراتك', style: TextStyle(color: AppColors.subText)))
            : Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final notifications = provider.notifications;
                  if (notifications.isEmpty) {
                    return Center(child: Text('لا توجد إشعارات', style: TextStyle(color: AppColors.subText)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = notifications[i];
                      return GestureDetector(
                        onTap: () => provider.markAsRead(n.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: n.read ? Colors.transparent : AppColors.gold.withOpacity(0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
                                child: Icon(_iconFor(n), color: AppColors.gold, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(n.body, style: TextStyle(color: AppColors.subText, fontSize: 12, height: 24 / 12)),
                                    const SizedBox(height: 6),
                                    Text(_timeAgo(n.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 10)),
                                  ],
                                ),
                              ),
                              if (!n.read) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
