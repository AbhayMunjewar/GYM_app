import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIPerformanceApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF131313);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIPerformanceApp extends StatelessWidget {
  const VelocityAIPerformanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Performance Analytics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AnalyticsDashboardScreen(),
    );
  }
}

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

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
                          const HeaderSection(),
                          const SizedBox(height: 32),
                          const StatsGrid(),
                          const SizedBox(height: 32),
                          _buildChartSection(isDesktop),
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

  Widget _buildChartSection(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 8, child: RevenueTrendCard()),
          SizedBox(width: 24),
          Expanded(flex: 4, child: MemberTierCard()),
        ],
      );
    }
    return Column(
      children: const [RevenueTrendCard(), SizedBox(height: 24), MemberTierCard()],
    );
  }
}

// --- WIDGETS ---

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance Analytics', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Analyzing traffic density and average session duration.', style: TextStyle(color: kOnSurfaceVariant)),
      ],
    ),
  );
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: const [
          KpiCard(title: 'TOTAL MEMBERS', val: '1,284', delta: '+12%', color: kPrimary),
          KpiCard(title: 'ACTIVE NOW', val: '86', delta: '6.7%', color: kSecondaryContainer),
          KpiCard(title: 'NEW SIGNUPS', val: '42', delta: 'Last 7d', color: Colors.white),
          KpiCard(title: 'CHURN RISK', val: '18', delta: 'Expiring 48h', color: kError),
        ],
      );
    });
  }
}

class KpiCard extends StatelessWidget {
  final String title, val, delta;
  final Color color;
  const KpiCard({super.key, required this.title, required this.val, required this.delta, required this.color});

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(val, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(delta, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
      ],
    ),
  );
}

class RevenueTrendCard extends StatelessWidget {
  const RevenueTrendCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Revenue Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(children: [Text('WEEKLY', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)), const SizedBox(width: 16), const Text('MONTHLY')])
        ]),
        const SizedBox(height: 32),
        SizedBox(height: 200, child: CustomPaint(painter: BarChartPainter())),
      ],
    ),
  );
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kPrimary.withOpacity(0.4)..style = PaintingStyle.fill;
    final bars = [0.3, 0.5, 0.4, 0.8, 0.6, 0.9, 0.7];
    final w = size.width / (bars.length * 1.5);
    for (int i = 0; i < bars.length; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (w * 1.5), size.height * (1 - bars[i]), w, size.height * bars[i]),
        const Radius.circular(4),
      ), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class MemberTierCard extends StatelessWidget {
  const MemberTierCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        const Text('Member Tiering', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        SizedBox(height: 150, width: 150, child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: 0.72, strokeWidth: 10, color: kPrimary),
          const Text('72%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
        ])),
      ],
    ),
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
    child: Column(
      children: [
        const SizedBox(height: 64),
        const ListTile(leading: Icon(Icons.person, color: kPrimary), title: Text('Alex Rivers'), subtitle: Text('Pro Athlete')),
        _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
        _NavTile(icon: Icons.fitness_center, title: 'Training'),
        _NavTile(icon: Icons.monitoring, title: 'Analytics', isActive: true),
        _NavTile(icon: Icons.group, title: 'Members'),
      ],
    ),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  const _NavTile({required this.icon, required this.title, this.isActive = false});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
    title: Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant)),
    onTap: () {},
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