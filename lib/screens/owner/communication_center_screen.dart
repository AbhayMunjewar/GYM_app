import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class CommunicationCenterScreen extends StatefulWidget {
  const CommunicationCenterScreen({Key? key}) : super(key: key);

  @override
  State<CommunicationCenterScreen> createState() => _CommunicationCenterScreenState();
}

class _CommunicationCenterScreenState extends State<CommunicationCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Holiday Hours Update',
      'body': 'The gym will close early at 6 PM on July 4th. Happy Independence Day!',
      'time': '2h ago',
      'audience': 'All Members',
      'icon': Icons.campaign,
    },
    {
      'title': 'New Spin Class Added',
      'body': 'We\'ve added a new 6:30 AM Spin Class on Tuesdays and Thursdays.',
      'time': '1d ago',
      'audience': 'All Members',
      'icon': Icons.pedal_bike,
    },
    {
      'title': 'Maintenance Notice',
      'body': 'The sauna will be under maintenance this Saturday from 8 AM – 12 PM.',
      'time': '3d ago',
      'audience': 'All Members',
      'icon': Icons.build_circle,
    },
  ];

  final List<Map<String, dynamic>> _conversations = [
    {'name': 'Alex Walker', 'lastMsg': 'Thanks for extending my trial!', 'time': '10m', 'unread': 2},
    {'name': 'Sarah Chen', 'lastMsg': 'Can I switch my plan to yearly?', 'time': '1h', 'unread': 1},
    {'name': 'Jordan Davis (Trainer)', 'lastMsg': 'Schedule updated for next week', 'time': '3h', 'unread': 0},
    {'name': 'Mike Johnson', 'lastMsg': 'Is the pool open on weekends?', 'time': '5h', 'unread': 0},
    {'name': 'Priya Sharma', 'lastMsg': 'Loved the new yoga class!', 'time': '1d', 'unread': 0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('COMMUNICATIONS', style: Theme.of(context).textTheme.labelLarge),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'ANNOUNCEMENTS'),
            Tab(text: 'MESSAGES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Announcements Tab
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Compose announcement card
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.campaign, color: AppColors.background, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Announcement', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Broadcast to all members or specific groups', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('RECENT', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 14),

              ...List.generate(_announcements.length, (index) {
                final a = _announcements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(a['icon'] as IconData, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(a['title'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            Text(a['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(a['body'] as String, style: TextStyle(color: AppColors.onSurface.withOpacity(0.8), fontSize: 14, height: 1.4)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(a['audience'] as String, style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          // Messages Tab
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ...List.generate(_conversations.length, (index) {
                final c = _conversations[index];
                final hasUnread = (c['unread'] as int) > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: hasUnread ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                          child: Text(
                            (c['name'] as String)[0],
                            style: TextStyle(
                              color: hasUnread ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                                fontSize: 15,
                              )),
                              const SizedBox(height: 2),
                              Text(
                                c['lastMsg'] as String,
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(c['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                            if (hasUnread) ...[
                              const SizedBox(height: 6),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${c['unread']}', style: const TextStyle(color: AppColors.background, fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
