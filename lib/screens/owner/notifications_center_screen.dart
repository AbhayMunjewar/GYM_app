import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New Member Signup',
        'body': 'Emma Wilson just registered for a Premium plan.',
        'time': '2 min ago',
        'icon': Icons.person_add,
        'color': const Color(0xFF4CAF50),
        'isRead': false,
      },
      {
        'title': 'Payment Received',
        'body': '\$149.00 from Alex Walker — Annual Renewal',
        'time': '15 min ago',
        'icon': Icons.payment,
        'color': AppColors.primary,
        'isRead': false,
      },
      {
        'title': 'Equipment Alert',
        'body': 'Treadmill #4 flagged for maintenance by Trainer Jordan.',
        'time': '1h ago',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'isRead': false,
      },
      {
        'title': 'Class Full',
        'body': 'HIIT Blast (6:30 AM Tuesday) has reached capacity — 25/25.',
        'time': '3h ago',
        'icon': Icons.group,
        'color': AppColors.secondary,
        'isRead': true,
      },
      {
        'title': 'Subscription Expiring',
        'body': '3 members have subscriptions expiring this week.',
        'time': '5h ago',
        'icon': Icons.timer_outlined,
        'color': Colors.redAccent,
        'isRead': true,
      },
      {
        'title': 'Monthly Report Ready',
        'body': 'Your June analytics report is ready for download.',
        'time': '1d ago',
        'icon': Icons.assessment,
        'color': AppColors.primary,
        'isRead': true,
      },
      {
        'title': 'Trainer Schedule Updated',
        'body': 'Jordan Davis updated availability for next week.',
        'time': '1d ago',
        'icon': Icons.calendar_month,
        'color': AppColors.secondary,
        'isRead': true,
      },
      {
        'title': 'Feedback Received',
        'body': 'Sarah Chen left a 5-star review: "Best gym experience!"',
        'time': '2d ago',
        'icon': Icons.star,
        'color': const Color(0xFFFFD700),
        'isRead': true,
      },
    ];

    final unreadCount = notifications.where((n) => !(n['isRead'] as bool)).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('NOTIFICATIONS', style: Theme.of(context).textTheme.labelLarge),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {},
              child: Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Unread count badge
          if (unreadCount > 0) ...[
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('$unreadCount', style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Unread Notifications', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Notification list
          ...List.generate(notifications.length, (index) {
            final n = notifications[index];
            final isRead = n['isRead'] as bool;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (n['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                              Expanded(
                                child: Text(
                                  n['title'] as String,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(n['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n['body'] as String,
                            style: TextStyle(color: AppColors.onSurface.withOpacity(isRead ? 0.6 : 0.85), fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
