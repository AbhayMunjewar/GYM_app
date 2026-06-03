// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../components/kinetic_button.dart';
// import '../../theme/app_theme.dart';

// class SubscriptionPlanManagementScreen extends StatelessWidget {
//   const SubscriptionPlanManagementScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('SUBSCRIPTIONS & PLANS', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Active Tiers', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
//             const SizedBox(height: 16),
//             _buildPlanCard(context, 'Basic Kinetic', '\$49/mo', '120 Active Members', false),
//             const SizedBox(height: 16),
//             _buildPlanCard(context, 'Pro Velocity', '\$99/mo', '150 Active Members', true),
//             const SizedBox(height: 16),
//             _buildPlanCard(context, 'Elite Ecosystem', '\$199/mo', '72 Active Members', false),
//             const SizedBox(height: 32),
//             KineticButton(
//               text: 'Create New Plan',
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlanCard(BuildContext context, String name, String price, String members, bool isPopular) {
//     return GlassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(name, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
//               if (isPopular)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: AppColors.primary),
//                   ),
//                   child: Text('MOST POPULAR', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary, fontSize: 10)),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(price, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: isPopular ? AppColors.primary : Colors.white)),
//           const SizedBox(height: 16),
//           const Divider(color: Colors.white24),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               const Icon(Icons.people, color: Colors.white54, size: 16),
//               const SizedBox(width: 8),
//               Text(members, style: TextStyle(color: AppColors.onSurfaceVariant)),
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
  runApp(const VelocityAIMembershipApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF131313);
const Color kSurfaceLow = Color(0xFF1C1B1B);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIMembershipApp extends StatelessWidget {
  const VelocityAIMembershipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Membership Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MembershipHubScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class MembershipHubScreen extends StatefulWidget {
  const MembershipHubScreen({super.key});

  @override
  State<MembershipHubScreen> createState() => _MembershipHubScreenState();
}

class _MembershipHubScreenState extends State<MembershipHubScreen> {
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
                          const KpiGrid(),
                          const SizedBox(height: 48),
                          const TierSection(),
                          const SizedBox(height: 48),
                          const PerformanceSection(),
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
}

// --- WIDGETS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('MEMBERSHIP HUB', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
      const SizedBox(height: 8),
      const Text('Manage elite performance athletes and membership cycles.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
    ],
  );
}

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 900 ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: count,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
        children: const [
          _KpiCard(title: 'TOTAL REVENUE', val: '\$142.8k', delta: '+12.4%', color: kPrimary),
          _KpiCard(title: 'ACTIVE USERS', val: '4,822', delta: '3 Tiers', color: Colors.white),
          _KpiCard(title: 'CHURN RATE', val: '1.8%', delta: '-0.4%', color: Color(0xFFFFB4AB)),
          _KpiCard(title: 'RENEWAL RATE', val: '94.2%', delta: 'Elite Tier', color: kSecondaryContainer),
        ],
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final String title, val, delta;
  final Color color;
  const _KpiCard({required this.title, required this.val, required this.delta, required this.color});

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(val, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(delta, style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
      ],
    ),
  );
}

class TierSection extends StatelessWidget {
  const TierSection({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Membership Tiers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: const [
            Expanded(child: _TierCard(title: 'BASIC', price: '\$29', features: ['Logs', 'Sync', 'Reports'], color: Colors.white)),
            SizedBox(width: 16, height: 16),
            Expanded(child: _TierCard(title: 'PRO', price: '\$79', features: ['Everything in Basic', 'Pulse', 'Recovery'], isFeatured: true, color: kPrimary)),
            SizedBox(width: 16, height: 16),
            Expanded(child: _TierCard(title: 'ELITE', price: '\$199', features: ['Everything in Pro', 'Neural-Link', '1-on-1 AI'], color: Colors.white)),
          ],
        );
      }),
    ],
  );
}

class _TierCard extends StatelessWidget {
  final String title, price;
  final List<String> features;
  final bool isFeatured;
  final Color color;
  const _TierCard({required this.title, required this.price, required this.features, this.isFeatured = false, required this.color});

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('$price/mo', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...features.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: kPrimary), const SizedBox(width: 8), Text(f)]))),
        const Spacer(),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: isFeatured ? kPrimary : Colors.white10), onPressed: () {}, child: const Text('EDIT PLAN')),
      ],
    ),
  );
}

class PerformanceSection extends StatelessWidget {
  const PerformanceSection({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Performance Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('View Details', style: TextStyle(color: kPrimary))]),
        const SizedBox(height: 32),
        SizedBox(height: 200, child: CustomPaint(painter: ChartPainter())),
      ],
    ),
  );
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = kPrimary.withOpacity(0.4)..style = PaintingStyle.fill;
    final heights = [0.4, 0.6, 0.3, 0.8, 1.0, 0.7, 0.5];
    final w = size.width / (heights.length * 1.5);
    for (int i = 0; i < heights.length; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(i * (w * 1.5), size.height * (1 - heights[i]), w, size.height * heights[i]), const Radius.circular(4)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- UTILITY ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const GlassCard({super.key, required this.child, this.padding, this.border});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(color: kSurface.withOpacity(0.7), border: border ?? Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
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
    child: Column(children: [
      const SizedBox(height: 100),
      const ListTile(leading: CircleAvatar(backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBUeEFR4BMOQYFZAD28SMdiIyBIXz2uE4B363pTLFCAbz-gbXzLEZVltuflEx_G2oXpF23GSUPZehmWm9lAszECA1vknufweUu3tvFCtcVJ_h0Uoo53WOGiJmNlXI23qEeGINf2JWW0V74z70BQHx8XS3Fw4N6fLPTsUe5qcQkQw7gZZOxQQxYobcs4v_wGaQOZWt8rieLw9_N754GYnc8wL5-PrqnIGeR1EKETXa6PcYLAuONe400lEC1sFJksUuanfpelodFRgIA')), title: Text('Alex Rivers'), subtitle: Text('Pro Athlete • Lvl 42')),
      ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard')),
      ListTile(leading: const Icon(Icons.fitness_center), title: const Text('Training')),
      ListTile(leading: const Icon(Icons.settings, color: kPrimary), title: const Text('Settings')),
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
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ],
  );
}