// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';
// import 'package:google_fonts/google_fonts.dart';

// class MemberDashboard extends StatelessWidget {
//   const MemberDashboard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Good Morning,',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       Text(
//                         'Alex',
//                         style: Theme.of(context).textTheme.headlineLarge,
//                       ),
//                     ],
//                   ),
//                   const CircleAvatar(
//                     radius: 24,
//                     backgroundColor: AppColors.primary,
//                     child: Icon(Icons.person, color: Colors.black),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 32),
//               // KPI Row
//               Row(
//                 children: [
//                   Expanded(
//                     child: GlassCard(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('WORKOUTS',
//                               style: Theme.of(context).textTheme.labelLarge),
//                           const SizedBox(height: 8),
//                           Text('12',
//                               style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                                     fontSize: 40,
//                                     color: AppColors.primary,
//                                   )),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: GlassCard(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('CALORIES',
//                               style: Theme.of(context).textTheme.labelLarge),
//                           const SizedBox(height: 8),
//                           Text('4.2k',
//                               style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                                     fontSize: 40,
//                                   )),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // Upcoming Session
//               GlassCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('NEXT SESSION',
//                         style: Theme.of(context).textTheme.labelLarge),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: AppColors.secondary.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(Icons.fitness_center,
//                               color: AppColors.secondary),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Hypertrophy Back',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodyLarge
//                                       ?.copyWith(fontWeight: FontWeight.bold)),
//                               Text('Today, 5:30 PM',
//                                   style: TextStyle(
//                                       color: AppColors.onSurfaceVariant)),
//                             ],
//                           ),
//                         ),
//                         const Icon(Icons.chevron_right, color: Colors.white),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: Colors.white54,
//         type: BottomNavigationBarType.fixed,
//         currentIndex: 0, // Hardcoded for dashboard view
//         onTap: (index) {
//           if (index == 0) {
//             context.go('/dashboard');
//           } else if (index == 1) {
//             context.push('/workout-center');
//           } else if (index == 2) {
//             context.push('/diet-center');
//           } else if (index == 3) {
//             context.push('/profile');
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
//           BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFFADC6FF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIApp extends StatelessWidget {
  const VelocityAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Member Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          
          return Row(
            children: [
              if (isDesktop) const DesktopSideNav(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (!isDesktop) const MobileTopAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const HeroSection(),
                          const SizedBox(height: 48),
                          const BentoDashboardGrid(),
                          const SizedBox(height: 48),
                          const AiAndActionsSection(),
                          const SizedBox(height: 48),
                          const UpcomingChallenges(),
                          const SizedBox(height: 80), // Bottom padding
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
}

// --- WIDGETS: LAYOUT COMPONENTS ---

class MobileTopAppBar extends StatelessWidget {
  const MobileTopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kBackground.withOpacity(0.8),
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.bolt, color: kPrimary),
          const SizedBox(width: 8),
          Text(
            'VELOCITY',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 24.0, left: 8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDusNxgVkgcyeUqDWRLPj2hdfDD902Keon7_B3zk5eNGqE-pNBTVSP8JRKfWkBBic7UYTJnRhKQQa0_mGlcpu0VrYuY9fRcmbqK_ejQQctYGo9MH6ndr81n8cd2EwbVSqj1pKPLIla-ebVjz5OrmQ2Uafwc2go1NEURYgZfXE7e-BAUMx4zuqkfykpxbC4vmW5g921wjKGQdgahwX9e9PNURLKB4Ico9Y04SYNV6vLRKN5v4KNphTKZJmoPrRYcINVRv0yWABGzDeA'),
          ),
        )
      ],
    );
  }
}

class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
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
                const SizedBox(height: 16),
                Text(
                  'VELOCITY AI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: kPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary.withOpacity(0.3)),
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBu6H65sJKld-CLeybZd7EmkaFkr0oP0kj5gwpz7CjaB20Fjd1yIQbvWFQJXiEgabQlbRL9hm2wkIMswRIpm5kzofFFwSKPISm6sEbaqY4CIOULLhcxPy0T3yKkWcmqEUsBVF8o7r6gu6q9FOPVxOYb7lhDml7ZOONNYbaaOwKB-LAAq-RAdDc5Z2aHkoWl1QiU5gQlpQqeaJ6OWBVwdex3ZGImJ_aVWZ_fVhGcpiz7ohDt2Ek-eyVqAFImmWmxLRcBzg3ZOq4c0os'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alex Rivers', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text('PRO ATHLETE • LEVEL 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, letterSpacing: 1)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard', isActive: true),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.analytics, title: 'Analytics'),
                _NavTile(icon: Icons.group, title: 'Members'),
                _NavTile(icon: Icons.military_tech, title: 'Rewards'),
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
        color: kSurface.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavIcon(icon: Icons.home, title: 'Home', isActive: true),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.bar_chart, title: 'Stats'),
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

// --- WIDGETS: CONTENT SECTIONS ---

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 15, spreadRadius: 2),
                ],
              ),
              child: const Text(
                'PRO ELITE MEMBER',
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'READY TO CRUSH IT,\nALEX?',
              style: TextStyle(
                fontSize: isMobile ? 40 : 56,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('CURRENT STREAK', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('12 DAYS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.local_fire_department, color: kPrimary, size: 28),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class BentoDashboardGrid extends StatelessWidget {
  const BentoDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 8, child: TodayWorkoutCard()),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Column(
                  children: const [
                    MetricCard(title: 'Calories', icon: Icons.local_dining, value: '1,240', total: '/ 2,500 kcal', progress: 0.49, color: kPrimary),
                    SizedBox(height: 24),
                    MetricCard(title: 'Hydration', icon: Icons.water_drop, value: '2.1', total: '/ 3.0 L', progress: 0.70, color: kSecondary),
                  ],
                ),
              )
            ],
          )
        : Column(
            children: const [
              TodayWorkoutCard(),
              SizedBox(height: 24),
              MetricCard(title: 'Calories', icon: Icons.local_dining, value: '1,240', total: '/ 2,500 kcal', progress: 0.49, color: kPrimary),
              SizedBox(height: 24),
              MetricCard(title: 'Hydration', icon: Icons.water_drop, value: '2.1', total: '/ 3.0 L', progress: 0.70, color: kSecondary),
            ],
          );
  }
}

class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        image: const DecorationImage(
          image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuD5tJg_RPTRJYrSOyD_MCH5G-Hj___8_mCKMgSu3RYXBabKb585IxHF8N_ZYMp2KxJENxHzutKHeJlz3dpYKATeB9htvytzpE5VXdI40B1SzwRz_fRqtRsCNxI6hcpZ-TQDtsQzOI7287m_qbfmcynS8QSQHpcUspFRCOZeoIVvodcTgqacinhOfgWEptquBJZtCxnR-BFkIOqGAhsrX6ClYt3A2lDg-xuFoTWh4ShBc7ooVOHLgZF8TOqUTsHX4Oot3nN0bganO78'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBackground, kBackground.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.schedule, color: kPrimary, size: 16),
                    SizedBox(width: 8),
                    Text('TODAY\'S FOCUS • 45 MIN', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('POWER CHEST & TRICEPS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START WORKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      onPressed: () {},
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('VIEW ROUTINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      onPressed: () {},
                    )
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

class MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String total;
  final double progress;
  final Color color;

  const MetricCard({super.key, required this.title, required this.icon, required this.value, required this.total, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(title.toUpperCase(), style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text(total, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ),
    );
  }
}

class AiAndActionsSection extends StatelessWidget {
  const AiAndActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(flex: 7, child: AiCoachCard()),
              const SizedBox(width: 24),
              Expanded(
                flex: 5,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    QuickAction(icon: Icons.restaurant_menu, title: 'Generate Diet'),
                    QuickAction(icon: Icons.monitor_weight, title: 'Log Weight'),
                    QuickAction(icon: Icons.psychology, title: 'Mental Prep'),
                    QuickAction(icon: Icons.history, title: 'Past PRs'),
                  ],
                ),
              ),
            ],
          )
        : Column(
            children: [
              const AiCoachCard(),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  QuickAction(icon: Icons.restaurant_menu, title: 'Generate Diet'),
                  QuickAction(icon: Icons.monitor_weight, title: 'Log Weight'),
                  QuickAction(icon: Icons.psychology, title: 'Mental Prep'),
                  QuickAction(icon: Icons.history, title: 'Past PRs'),
                ],
              ),
            ],
          );
  }
}

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(Icons.smart_toy, size: 160, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.auto_awesome, color: kPrimary),
                  ),
                  const SizedBox(width: 16),
                  const Text('AI Coach Recommendations', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NUTRITION OPTIMIZATION', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14, height: 1.5, fontFamily: 'Inter'),
                        children: [
                          const TextSpan(text: '"Alex, your recovery metrics suggest a slight deficit. '),
                          TextSpan(
                            text: 'Increase protein intake by 15g',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: kPrimary),
                          ),
                          const TextSpan(text: ' for today\'s post-workout meal to optimize muscle synthesis."'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SLEEP INSIGHT', style: TextStyle(color: kSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(height: 8),
                    Text(
                      '"Restorative sleep was 12% higher last night. You\'re primed for peak performance today. Push for a PR on bench press!"',
                      style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('ASK AI COACH', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: kPrimary, size: 16),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;

  const QuickAction({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kPrimary, size: 40),
            const SizedBox(height: 16),
            Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class UpcomingChallenges extends StatelessWidget {
  const UpcomingChallenges({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('UPCOMING CHALLENGES', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: kOnSurfaceVariant)),
            )
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return Row(
                children: const [
                  Expanded(child: ChallengeCard(title: 'Summer Shred \'24', desc: 'Burn 15k calories in 30 days.', badge: 'LIVE', isLive: true, progress: 0.62)),
                  SizedBox(width: 24),
                  Expanded(child: ChallengeCard(title: 'Iron Brotherhood', desc: 'Community lifting challenge.', badge: '2 DAYS LEFT', icon: Icons.groups)),
                  SizedBox(width: 24),
                  Expanded(child: ProProgramCard()),
                ],
              );
            }
            return Column(
              children: const [
                ChallengeCard(title: 'Summer Shred \'24', desc: 'Burn 15k calories in 30 days. Unlock exclusive gear.', badge: 'LIVE', isLive: true, progress: 0.62),
                SizedBox(height: 16),
                ChallengeCard(title: 'Iron Brotherhood', desc: 'Community lifting challenge. Average 4 workouts/week.', badge: '2 DAYS LEFT', icon: Icons.groups),
                SizedBox(height: 16),
                ProProgramCard(),
              ],
            );
          }
        )
      ],
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String desc;
  final String badge;
  final bool isLive;
  final double? progress;
  final IconData icon;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.desc,
    required this.badge,
    this.isLive = false,
    this.progress,
    this.icon = Icons.military_tech,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: isLive ? kPrimary.withOpacity(0.5) : Colors.white.withOpacity(0.1), width: 2)),
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? kPrimary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge, style: TextStyle(color: isLive ? kPrimary : kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Icon(icon, color: kOnSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 24),
            if (progress != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  Text('${(progress! * 100).toInt()}%', style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: kPrimary,
                borderRadius: BorderRadius.circular(4),
              )
            ] else ...[
              // Mock avatars for community
              Row(
                children: [
                  _Avatar(img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCDia2pNjtYY9khciSbDG7qFc0l12F8qM-SM8CIXBVYOP9D3iTPWjjGvAX9s5PQpa7Dje8GFVKY1-QTB7svr_2BT2vX095RQyKGVqe34SnpRaUOXqjc0cNoOgL4_VK9OehABNJB1x8vYI7xLrTO1Nu00LNW_YUASgYlnPhXFKqa5knYwyfOt0tml3Tonw6xMSNnswZUQjoQfAXT5YG_yFuxjLUYbXRhb5JRRR_fe7NdOtZsF_AxWcA95A9T32ux_Wwi5n1eG__g7VA'),
                  Transform.translate(offset: const Offset(-10, 0), child: _Avatar(img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA24OTD3k8uVFwSmaszMiCPEtfxYCusJkimsgjdNiwpV-mNPFX0Ee2l2HdE4H00SN7aJtUx3COpgx_KKnsKh0tQVDMwCkxyhnY_LJTu5cRFu1Kq9k8L2iPI0wRAYf4RmkXKjW9Jb7AK4avMFHnP2gSj9iN5YkVz-xW6JfmQc5zdCxYtB7thRHXrfnchSd-Dg8igeTuAUVWZ44Jj6BKUamUnewcyEFr1XYEib5wKWRK1QNvXWSPVGs89QJQNlVlThZtdBmfX8abq76k')),
                  Transform.translate(
                    offset: const Offset(-20, 0),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: const Color(0xFF353534), shape: BoxShape.circle, border: Border.all(color: kBackground, width: 2)),
                      alignment: Alignment.center,
                      child: const Text('+241', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String img;
  const _Avatar({required this.img});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kBackground, width: 2),
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
      ),
    );
  }
}

class ProProgramCard extends StatelessWidget {
  const ProProgramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 2)),
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PRO ELITE ONLY', style: TextStyle(color: kSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.lock_open, color: kOnSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Olympic Prep', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            const Text('Direct coaching from Elite Tier Velocity mentors.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(color: kPrimary.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('JOIN PROGRAM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
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