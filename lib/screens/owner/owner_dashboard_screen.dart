// import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIOwnerDashboardApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF131313);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIOwnerDashboardApp extends StatelessWidget {
  const VelocityAIOwnerDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Owner Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const OwnerDashboardScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

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
                          const PageHeader(),
                          const SizedBox(height: 32),
                          const KpiGrid(),
                          const SizedBox(height: 32),
                          _buildBentoGrid(isDesktop),
                          const SizedBox(height: 32),
                          const PriorityRenewalsSection(),
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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const MobileBottomNav() 
          : null,
    );
  }

  Widget _buildBentoGrid(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 8, child: RevenueTrendsCard()),
          SizedBox(width: 24),
          Expanded(flex: 4, child: TrainerRankingsCard()),
        ],
      );
    }
    return Column(
      children: const [
        RevenueTrendsCard(),
        SizedBox(height: 24),
        TrainerRankingsCard(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Executive Overview', 
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)
        ),
        SizedBox(height: 8),
        Text(
          'Good morning, Alex. Performance is up 12% across all metrics this week.', 
          style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)
        ),
      ],
    );
  }
}

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: isMobile ? 2.2 : 1.5,
          children: const [
            _KpiCard(
              title: 'TOTAL MEMBERS',
              value: '1,284',
              badgeText: '+2.4%',
              badgeColor: kPrimary,
              icon: Icons.group,
              progress: 0.85,
            ),
            _KpiCard(
              title: 'REVENUE',
              value: '\$42.8k',
              badgeText: '+14.2%',
              badgeColor: kPrimary,
              icon: Icons.payments,
              progress: 0.92,
            ),
            _KpiCard(
              title: 'ATTENDANCE',
              value: '84%',
              badgeText: '-1.8%',
              badgeColor: kError,
              icon: Icons.event_available,
              progress: 0.84,
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final double progress;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  color: badgeColor == kError ? Colors.white : kPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  shadows: badgeColor == kPrimary 
                      ? [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 15)] 
                      : null,
                )
              ),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kSecondaryContainer, kPrimary]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class RevenueTrendsCard extends StatelessWidget {
  const RevenueTrendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Revenue Trends', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Year-to-date fiscal performance', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                    child: const Text('MONTHLY', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(8)),
                    child: const Text('WEEKLY', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          const SizedBox(
            height: 250,
            child: _BarChartMockup(),
          )
        ],
      ),
    );
  }
}

class _BarChartMockup extends StatelessWidget {
  const _BarChartMockup();

  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.65, 0.55, 0.9, 0.75, 0.6, 0.85];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) {
        final isPrimary = h == 0.9; // Highlight highest bar
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FractionallySizedBox(
              heightFactor: h,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  border: isPrimary ? const Border(top: BorderSide(color: kPrimary, width: 2)) : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TrainerRankingsCard extends StatelessWidget {
  const TrainerRankingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trainer Rankings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _TrainerRow(rank: '1', name: 'Marcus Thorne', spec: 'High Intensity Training', score: '98%', isFirst: true),
          const SizedBox(height: 16),
          _TrainerRow(rank: '2', name: 'Sarah Jenkins', spec: 'Yoga & Mobility', score: '92%'),
          const SizedBox(height: 16),
          _TrainerRow(rank: '3', name: 'Elena Rodriguez', spec: 'Strength & Conditioning', score: '89%'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('VIEW FULL ROSTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class _TrainerRow extends StatelessWidget {
  final String rank;
  final String name;
  final String spec;
  final String score;
  final bool isFirst;

  const _TrainerRow({
    required this.rank, required this.name, required this.spec, required this.score, this.isFirst = false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: isFirst ? kPrimary : Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(rank, style: TextStyle(color: isFirst ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(spec, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
        Text(score, style: TextStyle(color: isFirst ? kPrimary : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class PriorityRenewalsSection extends StatelessWidget {
  const PriorityRenewalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.alarm, color: kPrimary),
                  SizedBox(width: 12),
                  Text('Priority Renewals', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                child: const Text('12 PENDING', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth > 600) crossAxisCount = 2;
              if (constraints.maxWidth > 900) crossAxisCount = 4;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: const [
                  _RenewalCard(name: 'Jameson Carter', plan: 'Elite Annual Plan', expires: 'Expires in 2 days', isUrgent: true),
                  _RenewalCard(name: 'Sophia Chen', plan: 'Pro Monthly Plan', expires: 'Expires in 4 days', isUrgent: true),
                  _RenewalCard(name: 'David Miller', plan: 'Student Power Plan', expires: 'Expires in 12 days', isUrgent: false),
                  _RenewalCard(name: 'Leila Vance', plan: 'Corporate Silver', expires: 'Expires in 15 days', isUrgent: false),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

class _RenewalCard extends StatelessWidget {
  final String name;
  final String plan;
  final String expires;
  final bool isUrgent;

  const _RenewalCard({required this.name, required this.plan, required this.expires, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isUrgent ? kPrimary : Colors.white.withOpacity(0.2), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(plan, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(expires, style: TextStyle(color: isUrgent ? kError : kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
              const Text('Contact', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('DASHBOARD', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('TRAINING', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('COMMUNITY', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                      const Text('MEMBERS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 24),
                    ],
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const SizedBox(width: 16),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary.withOpacity(0.5)),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAuh2OfSh4mndcvJHcvZWPQLD1bzGYRM5Inb-v4X_EQiN9zw8WOQYDFlbXMzPMFjIOTxhR7ebfhIgsM4nw3RzjPmc1zkWlY8YFUoO71esoymnXNY_hF29iZL3tstVWNUvsxSUVEaGYrZCiSQlHS8uorNSovs6ShN1J-NOcbg_diTBbpC13B9hoChCsTjQ0YqTrU4mpYMQueVoWdndim5hQ-i8ntHQdRJ0EOdsiu0cOnkgbxs27j3aqVauS7bNaXlUsnwKBd9mNp7Qk'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ]
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
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCJtlbmgEczVUxx9bsWhmU_sktCllZ9ErPvJKZo6wI6CYXNeSjCKvBoyCwQvHmpY44NpDNwx9nlak31chQPJFGhKJp9fIJ_Guhea1wGwBj-xzFcD-fkHLBNB3PmKnZYWAXvhS0cXOEzju8Koi287XJ0rBBVkfDhWa1VIjwQgLv8SFbbCCeWGqUiIM2Rkd_tO_pZbTUbvYtQOtV5x3eAUasV9SfxFb_kBl2xNrOtrYU57sSAvy8_pEH0lzoy3I_oJiX2Fo8SVc2Lj8s'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('LEVEL 42', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard', isActive: true),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.military_tech, title: 'Challenges'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
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
        borderRadius: BorderRadius.circular(12),
        border: isActive ? const Border(left: BorderSide(color: kPrimary, width: 4)) : null,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home', isActive: true),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
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

// --- UTILITY ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

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
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}