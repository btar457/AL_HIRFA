import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/notification_model.dart';

/// شاشة الإشعارات الشخصية للمستخدم (SHARED-1).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(id: '1', title: 'تم قبول طلبك', body: 'وافق الحرفي على طلب "إناء نحاسي منقوش" وسيُرسل قريباً.', targetAudience: 'customer', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    NotificationModel(id: '2', title: 'طلبك في الطريق', body: 'استلم مندوب التوصيل طلبك وهو في طريقه إليك الآن.', targetAudience: 'customer', read: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    NotificationModel(id: '3', title: 'عرض خاص', body: 'خصومات على منتجات نحاسية مختارة هذا الأسبوع.', targetAudience: 'customer', read: true, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  IconData _iconFor(NotificationModel n) {
    if (n.title.contains('قبول') || n.title.contains('الطريق')) return Icons.local_shipping_outlined;
    if (n.title.contains('عرض')) return Icons.local_offer_outlined;
    return Icons.notifications_outlined;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'قبل قليل';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('الإشعارات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: _notifications.isEmpty
            ? Center(child: Text('لا توجد إشعارات', style: TextStyle(color: AppColors.subText)))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = _notifications[i];
                  return Container(
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
                  );
                },
              ),
      ),
    );
  }
}
