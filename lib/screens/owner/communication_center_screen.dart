// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class CommunicationCenterScreen extends StatefulWidget {
//   const CommunicationCenterScreen({Key? key}) : super(key: key);

//   @override
//   State<CommunicationCenterScreen> createState() => _CommunicationCenterScreenState();
// }

// class _CommunicationCenterScreenState extends State<CommunicationCenterScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   final List<Map<String, dynamic>> _announcements = [
//     {
//       'title': 'Holiday Hours Update',
//       'body': 'The gym will close early at 6 PM on July 4th. Happy Independence Day!',
//       'time': '2h ago',
//       'audience': 'All Members',
//       'icon': Icons.campaign,
//     },
//     {
//       'title': 'New Spin Class Added',
//       'body': 'We\'ve added a new 6:30 AM Spin Class on Tuesdays and Thursdays.',
//       'time': '1d ago',
//       'audience': 'All Members',
//       'icon': Icons.pedal_bike,
//     },
//     {
//       'title': 'Maintenance Notice',
//       'body': 'The sauna will be under maintenance this Saturday from 8 AM – 12 PM.',
//       'time': '3d ago',
//       'audience': 'All Members',
//       'icon': Icons.build_circle,
//     },
//   ];

//   final List<Map<String, dynamic>> _conversations = [
//     {'name': 'Alex Walker', 'lastMsg': 'Thanks for extending my trial!', 'time': '10m', 'unread': 2},
//     {'name': 'Sarah Chen', 'lastMsg': 'Can I switch my plan to yearly?', 'time': '1h', 'unread': 1},
//     {'name': 'Jordan Davis (Trainer)', 'lastMsg': 'Schedule updated for next week', 'time': '3h', 'unread': 0},
//     {'name': 'Mike Johnson', 'lastMsg': 'Is the pool open on weekends?', 'time': '5h', 'unread': 0},
//     {'name': 'Priya Sharma', 'lastMsg': 'Loved the new yoga class!', 'time': '1d', 'unread': 0},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('COMMUNICATIONS', style: Theme.of(context).textTheme.labelLarge),
//         actions: [
//           IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: () {}),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: AppColors.primary,
//           labelColor: AppColors.primary,
//           unselectedLabelColor: AppColors.onSurfaceVariant,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//           tabs: const [
//             Tab(text: 'ANNOUNCEMENTS'),
//             Tab(text: 'MESSAGES'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Announcements Tab
//           ListView(
//             padding: const EdgeInsets.all(24),
//             children: [
//               // Compose announcement card
//               GlassCard(
//                 padding: const EdgeInsets.all(18),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: const Icon(Icons.campaign, color: AppColors.background, size: 24),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('New Announcement', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 2),
//                           Text('Broadcast to all members or specific groups', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               Text('RECENT', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
//               const SizedBox(height: 14),

//               ...List.generate(_announcements.length, (index) {
//                 final a = _announcements[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: GlassCard(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(a['icon'] as IconData, color: AppColors.primary, size: 20),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(a['title'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
//                             ),
//                             Text(a['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Text(a['body'] as String, style: TextStyle(color: AppColors.onSurface.withOpacity(0.8), fontSize: 14, height: 1.4)),
//                         const SizedBox(height: 10),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: AppColors.secondary.withOpacity(0.12),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(a['audience'] as String, style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),

//           // Messages Tab
//           ListView(
//             padding: const EdgeInsets.all(24),
//             children: [
//               ...List.generate(_conversations.length, (index) {
//                 final c = _conversations[index];
//                 final hasUnread = (c['unread'] as int) > 0;
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: GlassCard(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 22,
//                           backgroundColor: hasUnread ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
//                           child: Text(
//                             (c['name'] as String)[0],
//                             style: TextStyle(
//                               color: hasUnread ? AppColors.primary : AppColors.onSurfaceVariant,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 14),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(c['name'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                 fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
//                                 fontSize: 15,
//                               )),
//                               const SizedBox(height: 2),
//                               Text(
//                                 c['lastMsg'] as String,
//                                 style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(c['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
//                             if (hasUnread) ...[
//                               const SizedBox(height: 6),
//                               Container(
//                                 width: 22,
//                                 height: 22,
//                                 decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
//                                 child: Center(
//                                   child: Text('${c['unread']}', style: const TextStyle(color: AppColors.background, fontSize: 11, fontWeight: FontWeight.w800)),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAICommunicationApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAICommunicationApp extends StatelessWidget {
  const VelocityAICommunicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Communication Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const CommunicationScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(preferredSize: Size.fromHeight(64), child: TopAppBar()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          return Row(
            children: [
              if (isDesktop) const DesktopSideNav(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(24, 100, 24, isDesktop ? 48 : 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const PageHeader(),
                          const SizedBox(height: 32),
                          _buildBentoGrid(isDesktop),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 ? const MobileBottomNav() : null,
    );
  }

  Widget _buildBentoGrid(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 7, child: Column(children: [AnnouncementCard(), SizedBox(height: 24), SmartAutomationsCard()])),
          SizedBox(width: 24),
          Expanded(flex: 5, child: LiveChatSideCard()),
        ],
      );
    }
    return Column(
      children: const [AnnouncementCard(), SizedBox(height: 24), SmartAutomationsCard(), SizedBox(height: 24), LiveChatSideCard()],
    );
  }
}

// --- WIDGETS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('COMMUNICATION CENTER', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
      SizedBox(height: 8),
      Text('Architect elite performance routines and distribute them across your roster.', style: TextStyle(color: kOnSurfaceVariant)),
    ],
  );
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: const [Icon(Icons.campaign, color: kPrimary), SizedBox(width: 8), Text('Mass Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: kPrimary.withOpacity(0.3))), child: const Text('NEW CAMPAIGN', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 24),
        const _InputField(label: 'CAMPAIGN SUBJECT', hint: 'e.g. Early Bird Access'),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(child: _DropdownField(label: 'TARGET AUDIENCE', items: ['All Members', 'Premium Tier'])),
          SizedBox(width: 16),
          Expanded(child: _DropdownField(label: 'DELIVERY CHANNEL', items: ['Email', 'App Push'])),
        ]),
        const SizedBox(height: 16),
        const _InputField(label: 'MESSAGE CONTENT', hint: 'Type your announcement here...', maxLines: 4),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: () {}, child: const Text('SCHEDULE')),
          const SizedBox(width: 16),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.black), onPressed: () {}, child: const Text('SEND NOW')),
        ])
      ],
    ),
  );
}

class SmartAutomationsCard extends StatelessWidget {
  const SmartAutomationsCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [Icon(Icons.auto_mode, color: kSecondaryContainer), SizedBox(width: 8), Text('Smart Automations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 24),
        _ToggleRow(title: 'Daily Streak Reminder', desc: 'Triggered after 18h inactivity', isActive: true),
        _ToggleRow(title: 'New Milestone Reached', desc: 'Triggered on Level Up', isActive: true),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('CREATE CUSTOM AUTOMATION'))
      ],
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final String title, desc;
  final bool isActive;
  const _ToggleRow({required this.title, required this.desc, required this.isActive});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12))]),
      Switch(value: isActive, onChanged: (v) {}, activeColor: kPrimary)
    ]),
  );
}

class LiveChatSideCard extends StatelessWidget {
  const LiveChatSideCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Live Chat', style: TextStyle(fontWeight: FontWeight.bold)), Icon(Icons.circle, color: kPrimary, size: 12)]),
        const SizedBox(height: 24),
        _ChatTile(name: 'Marcus Chen', msg: 'How do I adjust macros...'),
        _ChatTile(name: 'Sarah Vane', msg: 'The workout app crashed...'),
        const Spacer(),
        ElevatedButton(onPressed: () {}, child: const Text('VIEW ALL CONVERSATIONS')),
      ],
    ),
  );
}

class _ChatTile extends StatelessWidget {
  final String name, msg;
  const _ChatTile({required this.name, required this.msg});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      const CircleAvatar(backgroundColor: kSurfaceHigh, child: Icon(Icons.person, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(msg, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis)]))
    ]),
  );
}

// --- UTILITY WIDGETS ---

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const GlassCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(color: kSurface.withOpacity(0.7), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    ),
  );
}

class _InputField extends StatelessWidget {
  final String label, hint;
  final int maxLines;
  const _InputField({required this.label, required this.hint, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    TextField(maxLines: maxLines, decoration: InputDecoration(filled: true, fillColor: kSurfaceLow, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), hintText: hint)),
  ]);
}

class _DropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  const _DropdownField({required this.label, required this.items});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: kSurfaceLow, borderRadius: BorderRadius.circular(8)), child: DropdownButtonHideUnderline(child: DropdownButton(value: items.first, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) {}))),
  ]);
}

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: kBackground.withOpacity(0.8),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: const [Icon(Icons.bolt, color: kPrimary), SizedBox(width: 8), Text('VELOCITY AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimary, fontStyle: FontStyle.italic))]),
      const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
    ])),
  );
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 288,
    color: kSurface,
    child: Column(children: [
      const SizedBox(height: 100),
      const ListTile(leading: CircleAvatar(backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBgsXylZCc3n2-lwWIjJ7ixHyb2oRM7spKJa5fZc6MJkyhtdBXILdMfJMVlhluzH273pKykCV-2eXI1NAsRXOO7-QXcnfoEPomnfhv_4tjrJzwwNG2YumV8YZjvKb-ksZDy9wviHp5faNwrORqLTAsDt7lWBR_SxtqhCFGX3wV3_psresJs5N_U8l1csqTNf-zTTAnoOKs7NxIA-WlKH77lPjzgjudT449M1uhxpOcsHfyEPdSSCIioOmY8oYP1-AFs7sI6b_Q4gkE')), title: Text('Alex Rivers'), subtitle: Text('Pro Athlete • Lvl 42')),
      ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard')),
      ListTile(leading: const Icon(Icons.fitness_center), title: const Text('Training')),
      ListTile(leading: const Icon(Icons.monitoring), title: const Text('Analytics')),
      ListTile(leading: const Icon(Icons.group), title: const Text('Members')),
      ListTile(leading: const Icon(Icons.military_tech), title: const Text('Rewards')),
      const Spacer(),
      ListTile(leading: const Icon(Icons.settings), title: const Text('Settings')),
    ]),
  );
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    backgroundColor: kBackground,
    selectedItemColor: kPrimary,
    unselectedItemColor: kOnSurfaceVariant,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
      BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI Buddy'),
      BottomNavigationBarItem(icon: Icon(Icons.equalizer), label: 'Stats'),
    ],
  );
}