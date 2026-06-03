import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAINotificationsApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF131313);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAINotificationsApp extends StatelessWidget {
  const VelocityAINotificationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Notifications Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const NotificationsScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -50,
            right: -20,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kPrimary.withOpacity(0.05), blurRadius: 120, spreadRadius: 50)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: kSecondaryContainer.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kSecondaryContainer.withOpacity(0.05), blurRadius: 150, spreadRadius: 50)
                ],
              ),
            ),
          ),

          // Main Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 768;
              return Row(
                children: [
                  if (isDesktop) const DesktopSideNav(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            24.0, 
                            100.0, 
                            24.0, 
                            isDesktop ? 48.0 : 120.0
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const PageHeader(),
                              const SizedBox(height: 32),
                              const FilterChips(),
                              const SizedBox(height: 24),
                              const NotificationFeed(),
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
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 768 
          ? const MobileBottomNav() 
          : null,
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTIFICATIONS', 
          style: TextStyle(
            color: Colors.white, 
            fontSize: isMobile ? 40 : 64, 
            fontWeight: FontWeight.w800, 
            letterSpacing: -1, 
            height: 1.1
          )
        ),
        const SizedBox(height: 8),
        const Text(
          'Stay updated on your progress, squads, and system status.', 
          style: TextStyle(color: kOnSurfaceVariant, fontSize: 18)
        ),
      ],
    );
  }
}

class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  int _selectedIndex = 0;
  final List<String> _filters = ['All', 'Workouts', 'Squads', 'System'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : Colors.transparent,
                  border: Border.all(color: isSelected ? kPrimary : Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : kOnSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NotificationFeed extends StatelessWidget {
  const NotificationFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader('TODAY'),
        const SizedBox(height: 16),
        const NotificationCard(
          title: 'HIIT Mastery Scheduled',
          time: '2m ago',
          body: 'Your personalized HIIT session with Coach Marcus starts in 30 minutes. Get hydrated!',
          icon: Icons.fitness_center,
          iconColor: kSecondaryContainer,
          isUnread: true,
          hasButtons: true,
        ),
        const SizedBox(height: 12),
        const NotificationCard(
          title: 'Squad Challenge: "Vanguard Alpha"',
          time: '1h ago',
          body: 'Alex, your squad just jumped to #3 on the Global Leaderboard. 500 points more to hit #1!',
          icon: Icons.group,
          iconColor: kPrimary,
          isUnread: true,
          hasBorder: true,
        ),
        
        const SizedBox(height: 32),
        _buildDateHeader('YESTERDAY'),
        const SizedBox(height: 16),
        const NotificationCard(
          title: 'Membership Renewed',
          time: 'Yesterday',
          body: 'Your Velocity Pro membership has been successfully renewed. Thank you for staying elite.',
          icon: Icons.credit_card,
          iconColor: kOnSurfaceVariant,
          isUnread: false,
          isMuted: true,
        ),
        const SizedBox(height: 12),
        const NotificationCard(
          title: 'AI Buddy Analysis Ready',
          time: 'Yesterday',
          body: 'Velocity AI has finished processing your weekly biometrics. Your recovery score is up by 12%!',
          icon: Icons.smart_toy,
          iconColor: kSecondaryContainer,
          isUnread: false,
          isMuted: true,
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBKPuKjs9rrdLN2MQhVbK9VHUUGEz0SEmH8ohe6dNa0m6xAfd_l2yxoV15ruFb-TT8xsJhmtEeqBx2UkahN1gH5PY6eNohMH68sKLgnbKLSjehdJrp8KMTEGjyMBRdrBQMvBEQWgzTejF3J_llXAc7c4zkkgaIHoLXaa6voVtogJ3vlTcTjtT_RLIyqY5CG9pJOFmbXQH-4GdmFtNAN9LRe-dH7H2ogkX-NZCL3xB46GqtspE4ncyE4FLkTefu35UnM6MQmigw6WIw',
        ),

        const SizedBox(height: 32),
        _buildDateHeader('EARLIER'),
        const SizedBox(height: 16),
        const NotificationCard(
          title: 'Badge Earned: "Century Sprinter"',
          time: '3 days ago',
          body: "You've completed 100 sprint intervals this month. A new achievement has been added to your trophy room.",
          icon: Icons.military_tech,
          iconColor: kPrimary,
          isUnread: false,
          isMuted: true,
        ),
      ],
    );
  }

  Widget _buildDateHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        color: kOnSurfaceVariant.withOpacity(0.5),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String title;
  final String time;
  final String body;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;
  final bool hasBorder;
  final bool isMuted;
  final bool hasButtons;
  final String? imageUrl;

  const NotificationCard({
    super.key,
    required this.title,
    required this.time,
    required this.body,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
    this.hasBorder = false,
    this.isMuted = false,
    this.hasButtons = false,
    this.imageUrl,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  late bool _isUnread;
  late bool _hasBorder;

  @override
  void initState() {
    super.initState();
    _isUnread = widget.isUnread;
    _hasBorder = widget.hasBorder;
  }

  void _markAsRead() {
    if (_isUnread || _hasBorder) {
      setState(() {
        _isUnread = false;
        _hasBorder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _markAsRead,
      child: Opacity(
        opacity: widget.isMuted ? 0.8 : 1.0,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          border: _hasBorder 
            ? const Border(left: BorderSide(color: kPrimary, width: 4))
            : Border.all(color: Colors.white.withOpacity(0.1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title, 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                        ),
                        Text(widget.time, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.body, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
                    
                    // Optional Buttons
                    if (widget.hasButtons) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {},
                            child: const Text('JOIN NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              backgroundColor: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {},
                            child: const Text('SNOOZE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      )
                    ],

                    // Optional Image
                    if (widget.imageUrl != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.3),
                                colorBlendMode: BlendMode.darken,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                )
                              ),
                            ),
                            const Positioned(
                              bottom: 12,
                              left: 12,
                              child: Text(
                                'VIEW DETAILED REPORT', 
                                style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)
                              ),
                            )
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
              
              // Unread Dot
              if (_isUnread) ...[
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.8), blurRadius: 8)],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// --- APP BAR & NAV COMPONENTS ---

class TopAppBar extends StatelessWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: kBackground.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt, color: kPrimary),
                    SizedBox(width: 8),
                    Text(
                      'VELOCITY AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: kPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('Dashboard', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Training', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Members', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Settings', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                    ],
                    IconButton(
                      icon: const Icon(Icons.notifications_active, color: kPrimary),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      margin: const EdgeInsets.only(top: 64),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.7),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAEq0BrnA2BXu-UZRenm7H2STzNj2sb9QlsesjhRt-0oBtUjULHCPFtqqPiplxEvW0inHV1oSCHKPaSXnqB6bDAlPHtvLbgSSpVgVmrKMCXfAa0npo1hEO744uEf8A03DQw0LgystfnQIikPiHW4Izpe_DBib1BjdI0zmuUzrlWfPU9t_VP5RbIQ-ouQMLHhBwZgP8mhlT2i1zY8HTk8k30ax8DjloRWHX1r9Hc_Bkv03gyC090aPmSWJQAT8s9eA7cmT7YzplJo_k'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards'),
                const Spacer(),
                _NavTile(icon: Icons.settings, title: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _NavTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: kOnSurfaceVariant),
        title: Text(
          title,
          style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14),
        ),
        hoverColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {},
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E).withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home'),
              _BottomNavIcon(icon: Icons.exercise, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.notifications, title: 'Stats', isActive: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _BottomNavIcon({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant, size: 24),
        const SizedBox(height: 4),
        Text(
          title, 
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant, 
            fontSize: 12, 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}

// --- UTILITY WIDGET ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const GlassCard({super.key, required this.child, this.padding, this.border});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: border ?? Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}