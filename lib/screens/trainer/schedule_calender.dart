import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAITrainerScheduleApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFFADC6FF);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAITrainerScheduleApp extends StatelessWidget {
  const VelocityAITrainerScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Trainer Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const TrainerScheduleScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class TrainerScheduleScreen extends StatelessWidget {
  const TrainerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
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
                      padding: EdgeInsets.fromLTRB(
                        24.0, 
                        100.0, 
                        24.0, 
                        isDesktop ? 48.0 : 120.0
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const ScheduleHeader(),
                          const SizedBox(height: 32),
                          _buildGrid(isDesktop),
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
      floatingActionButton: const CustomFAB(),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const MobileBottomNav() 
          : null,
    );
  }

  Widget _buildGrid(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 8, child: CalendarCard()),
          SizedBox(width: 24),
          Expanded(
            flex: 4, 
            child: Column(
              children: [
                AvailabilityCard(),
                SizedBox(height: 24),
                MonthlyLoadCard(),
              ],
            )
          ),
        ],
      );
    }
    return Column(
      children: const [
        CalendarCard(),
        SizedBox(height: 24),
        AvailabilityCard(),
        SizedBox(height: 24),
        MonthlyLoadCard(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Flex(
      direction: isMobile ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TRAINER CONTROL', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Session Schedule', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shadowColor: kPrimary.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('Monthly', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('Weekly'),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Calendar Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    const Text('September 2024', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                  ],
                ),
                if (MediaQuery.of(context).size.width > 600)
                  Row(
                    children: [
                      _LegendItem(color: kPrimary, label: 'PT'),
                      const SizedBox(width: 16),
                      _LegendItem(color: kSecondaryContainer, label: 'Group'),
                      const SizedBox(width: 16),
                      _LegendItem(color: kError, label: 'Consultation'),
                    ],
                  )
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          
          // Calendar Grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                      .map((day) => Expanded(child: Center(child: Text(day, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)))))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Calendar Cells
                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: MediaQuery.of(context).size.width > 900 ? 0.8 : 0.6,
                  children: [
                    // Empty days
                    for (int i = 26; i <= 31; i++) _CalendarCell(day: i.toString(), isEmpty: true),
                    // Active days
                    const _CalendarCell(day: '01', events: [kSecondaryContainer, kPrimary], isPartial: true),
                    const _CalendarCell(day: '02'),
                    const _CalendarCell(day: '03', labelEvent: 'PT: J. DOE', eventColor: kPrimary),
                    const _CalendarCell(day: '04', labelEvent: 'HIIT SQUAD', eventColor: kSecondaryContainer, isHighlighted: true),
                    for (int i = 5; i <= 14; i++) _CalendarCell(day: i.toString().padLeft(2, '0')),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final String day;
  final bool isEmpty;
  final bool isHighlighted;
  final List<Color>? events; // Small dot/line indicators
  final bool isPartial;
  final String? labelEvent;
  final Color? eventColor;

  const _CalendarCell({
    required this.day,
    this.isEmpty = false,
    this.isHighlighted = false,
    this.events,
    this.isPartial = false,
    this.labelEvent,
    this.eventColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlighted ? kPrimary.withOpacity(0.1) : (isEmpty ? Colors.transparent : Colors.white.withOpacity(0.05)),
        border: Border.all(color: isHighlighted ? kPrimary : (isEmpty ? Colors.transparent : Colors.white.withOpacity(0.1))),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighlighted ? [BoxShadow(color: kPrimary.withOpacity(0.1), blurRadius: 20)] : null,
      ),
      child: Stack(
        children: [
          Text(
            day, 
            style: TextStyle(
              color: isEmpty ? Colors.white.withOpacity(0.2) : (isHighlighted ? kPrimary : kOnSurfaceVariant), 
              fontSize: 14, 
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal
            )
          ),
          
          if (events != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events!.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  height: 4,
                  width: isPartial && c == kPrimary ? 24 : double.infinity,
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
                )).toList(),
              ),
            ),
            
          if (labelEvent != null && eventColor != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: eventColor!.withOpacity(0.2),
                  border: Border(left: BorderSide(color: eventColor!, width: 2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(labelEvent!, style: TextStyle(color: eventColor, fontSize: 8, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            )
        ],
      ),
    );
  }
}

class AvailabilityCard extends StatefulWidget {
  const AvailabilityCard({super.key});

  @override
  State<AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  bool _workingHours = true;
  bool _groupBookings = true;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Availability', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Icon(Icons.more_horiz, color: kOnSurfaceVariant),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsToggle(
            icon: Icons.schedule, 
            iconColor: kPrimary, 
            title: 'Working Hours', 
            desc: '08:00 AM - 06:00 PM', 
            value: _workingHours, 
            onChanged: (v) => setState(() => _workingHours = v)
          ),
          const SizedBox(height: 16),
          _SettingsToggle(
            icon: Icons.weekend, 
            iconColor: kSecondaryContainer, 
            title: 'Accept Group Bookings', 
            desc: 'Max 12 members/session', 
            value: _groupBookings, 
            onChanged: (v) => setState(() => _groupBookings = v)
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('UPCOMING NEXT', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('SEP', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, height: 1)),
                          Text('04', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, height: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('HIIT Warriors Session', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('04:30 PM • Gym Floor A', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: kOnSurfaceVariant),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon, required this.iconColor, required this.title, required this.desc, required this.value, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                ],
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            activeTrackColor: kPrimary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          )
        ],
      ),
    );
  }
}

class MonthlyLoadCard extends StatelessWidget {
  const MonthlyLoadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        children: [
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: Container(color: Colors.transparent)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MONTHLY LOAD', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('84%', style: TextStyle(color: kPrimary, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
                  SizedBox(width: 8),
                  Padding(padding: EdgeInsets.only(bottom: 4.0), child: Text('Capacity', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  widthFactor: 0.84,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kSecondaryContainer, kPrimary]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('12 more slots available this week.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- APP BAR & NAV ---

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
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
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
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCszJSk7JxURNHbCjbrabRilOmMdQxJL6eByLOxNJxZepde8cI9rQFXpIsX0ScbKcsxvrZpQvs3JU1mVBMv_FZlvYQyO49-r1vxqL9sClgIwe4H9b_YcwEdcJ8bdc0uu7EZc-sskuSAaCZvyZZk8a3rK_7SAj4yfRFiMU1eq9EUodabQlowWZyuVjiAYXNCgHjLpnvW0HkIo9JCSLWLQ2vvEVruY7l9TRYhgY9J7a17hbCNgCcaA9EZVbf22YhqG8M5MuCcErKY480'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training', isActive: true),
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
  final bool isActive;

  const _NavTile({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? kPrimary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? const Border(right: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? kPrimary : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
              _BottomNavIcon(icon: Icons.exercise, title: 'Workouts', isActive: true),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.equalizer, title: 'Stats'),
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
        Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontSize: 12)),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
        ]
      ],
    );
  }
}

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: kPrimary,
      foregroundColor: Colors.black,
      elevation: 12,
      child: const Icon(Icons.add, size: 32),
    );
  }
}

// --- UTILITY WIDGET ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}