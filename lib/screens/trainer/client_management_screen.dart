// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class ClientManagementScreen extends StatelessWidget {
//   const ClientManagementScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('CLIENT MANAGEMENT', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(24),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           final clients = [
//             {'name': 'Sarah Jenkins', 'goal': 'Hypertrophy', 'status': 'On Track'},
//             {'name': 'Marcus Cole', 'goal': 'Weight Loss', 'status': 'Needs Review'},
//             {'name': 'Elena Rostova', 'goal': 'Endurance', 'status': 'On Track'},
//           ];
//           final client = clients[index];
//           final isNeedsReview = client['status'] == 'Needs Review';

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: GlassCard(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     backgroundColor: AppColors.surface,
//                     child: Icon(Icons.person, color: Colors.white),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(client['name']!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//                         Text(client['goal']!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: isNeedsReview ? Colors.red.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       client['status']!,
//                       style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                             color: isNeedsReview ? Colors.red : AppColors.primary,
//                             fontSize: 10,
//                           ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAIClientManagementApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);
const Color kError = Color(0xFFFFB4AB);

class VelocityAIClientManagementApp extends StatelessWidget {
  const VelocityAIClientManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Client Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const ClientDashboardScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

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
                          const DashboardHeader(),
                          const SizedBox(height: 48),
                          const StatsGrid(),
                          const SizedBox(height: 48),
                          const ClientListSection(),
                          const SizedBox(height: 48),
                          _buildInsightsSection(isDesktop),
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

  Widget _buildInsightsSection(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(child: RecentAttendanceCard()),
          SizedBox(width: 24),
          Expanded(child: NetworkPerformanceCard()),
        ],
      );
    }
    return Column(
      children: const [
        RecentAttendanceCard(),
        SizedBox(height: 24),
        NetworkPerformanceCard(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

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
            Text('CLIENT ROSTER', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.1)),
            const SizedBox(height: 8),
            const Text('Monitor performance metrics and attendance for your elite athletes in real-time.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kSurfaceHigh.withOpacity(0.5),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.filter_list, color: kPrimary),
              label: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {},
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 12,
                shadowColor: kPrimary.withOpacity(0.4),
              ),
              icon: const Icon(Icons.add),
              label: const Text('ADD CLIENT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              onPressed: () {},
            )
          ],
        )
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        
        int crossAxisCount = 4;
        if (isMobile) crossAxisCount = 1;
        if (isTablet) crossAxisCount = 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 2.5 : 1.3,
          children: const [
            _StatCardTotalClients(),
            _StatCardActiveNow(),
            _StatCardAttendance(),
            _StatCardRetention(),
          ],
        );
      },
    );
  }
}

class _StatCardTotalClients extends StatelessWidget {
  const _StatCardTotalClients();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('TOTAL CLIENTS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('42', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation(kPrimary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          )
        ],
      ),
    );
  }
}

class _StatCardActiveNow extends StatefulWidget {
  const _StatCardActiveNow();

  @override
  State<_StatCardActiveNow> createState() => _StatCardActiveNowState();
}

class _StatCardActiveNowState extends State<_StatCardActiveNow> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ACTIVE NOW', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('12', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            children: [
              FadeTransition(
                opacity: _pulseController,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
              ),
              const SizedBox(width: 8),
              const Text('LIVE TRAINING SESSIONS', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatCardAttendance extends StatelessWidget {
  const _StatCardAttendance();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('AVG. ATTENDANCE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '94', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                TextSpan(text: '%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ]
            )
          ),
          const Spacer(),
          const Text('+2% FROM LAST WEEK', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _StatCardRetention extends StatelessWidget {
  const _StatCardRetention();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('RETENTION RATE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '88', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                TextSpan(text: '%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ]
            )
          ),
          const Spacer(),
          const Text('TOP 5% IN REGION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class ClientListSection extends StatelessWidget {
  const ClientListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Flex(
              direction: MediaQuery.of(context).size.width < 768 ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width < 768 ? double.infinity : 384,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search athletes by name or goal...',
                      hintStyle: TextStyle(color: kOnSurfaceVariant.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: kOnSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width < 768) const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), border: Border.all(color: kPrimary.withOpacity(0.2)), borderRadius: BorderRadius.circular(20)),
                      child: const Text('All', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Active', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                      child: const Text('On Break', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          
          // Header Row (Desktop Only)
          if (MediaQuery.of(context).size.width > 900)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              color: Colors.white.withOpacity(0.02),
              child: Row(
                children: const [
                  Expanded(flex: 4, child: Text('ATHLETE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  Expanded(flex: 3, child: Text('PERFORMANCE PROGRESS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
                  Expanded(flex: 2, child: Align(alignment: Alignment.center, child: Text('ATTENDANCE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)))),
                  Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('ACTION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)))),
                ],
              ),
            ),
          
          // Client Rows
          _ClientRow(
            name: 'Jordan Hayes',
            desc: 'Marathon Training • 6mo',
            imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA8tPj4U3JHzowNNYfPJQgROs5Ojmvlstersd0LAI353cLY5GcGCaxSiM1ij_8YlRVo6MEDjc3E3GduUeTG7qGcezocJseDkk_rWmril3lTTteW0BWm7n1O9gnLwKljibplhx8F5o1n6QNAATstwn9zg9HG_9TCLqaXiZqJf17f5z7w1NnIZseLF2uoGAnbbJgzHmm0jQDBVwjyZcDpT2Xa9I2pHvM4ZfSS41m1lZztghCYIbtsDBIBqNUIAFg6jZ-VhZyRVStTsPM',
            status: 'ACTIVE',
            statusColor: kPrimary,
            perfHeights: const [0.4, 0.55, 0.45, 0.7, 0.85, 0.95, 0.90],
            perfColors: const [kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kPrimary, kPrimary, kPrimary],
            attendance: 0.92,
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          _ClientRow(
            name: 'Marcus Thorne',
            desc: 'Hypertrophy • 1.2yr',
            imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC8aitgIpUTfdeXqMSf52t_LTc09GsuK9iY92E54ET5BC5th8Qh78Lyg64xrcNvEiQQgkGbPnT2BQMvFQH9dfy6VE37DmsS8Tidmhy43dGzdD_BufujlcG4Ou8p_qKAP81U1_wnWtZ-SCLqu-YAcsJpwHvEnKA50lagOOC4-LcvKN6rB-P3SbVFu5vuY8azk1DA8SLjAv5iCD-qH2FcEDYJRQSYOWGZ9BVtNue_9YNWlE5pfjO_jsAm9NtixYk7Zyd8rsCE_tSEay0',
            status: 'ON BREAK',
            statusColor: kOnSurfaceVariant,
            perfHeights: const [0.8, 0.75, 0.85, 0.6, 0.3, 0.1, 0.05],
            perfColors: const [kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer],
            perfOpacity: 0.4,
            attendance: 0.48,
            attendanceColor: kError,
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          _ClientRow(
            name: 'Elena Costa',
            desc: 'Fat Loss • 3mo',
            imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC5P9Z5ebU3FLs0Se0PmyQXg1l2_aiKhN87gydues23FLDyw2LH1isufUxgLfCON_zx-HFGp_DqsJxLKGQNGKlFfWIrabEdcakP2B4UtSW4cZQrfJy5AB3AUKS5-3yarv8T31HxojIhSXAXIYldagpzKD1NM4L-OpQUy36QK0hX3hely8H2ldZa_FYFErDfDtNKyg6iqqzP44cuL3cZ7_gBh7WWf_bN0fmb5mGLRvKCrGQU5O6lM-MDqdk_cGk3jZ10Jwsx6Q3e8xM',
            status: 'ACTIVE',
            statusColor: kPrimary,
            perfHeights: const [0.2, 0.35, 0.5, 0.65, 0.8, 0.95, 1.0],
            perfColors: const [kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kSecondaryContainer, kPrimary, kPrimary, kPrimary],
            attendance: 1.0,
          ),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final String name;
  final String desc;
  final String imgUrl;
  final String status;
  final Color statusColor;
  final List<double> perfHeights;
  final List<Color> perfColors;
  final double perfOpacity;
  final double attendance;
  final Color? attendanceColor;

  const _ClientRow({
    required this.name,
    required this.desc,
    required this.imgUrl,
    required this.status,
    required this.statusColor,
    required this.perfHeights,
    required this.perfColors,
    this.perfOpacity = 1.0,
    required this.attendance,
    this.attendanceColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    Widget athleteCell = Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
          ],
        )
      ],
    );

    Widget statusCell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );

    Widget perfCell = Opacity(
      opacity: perfOpacity,
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(perfHeights.length, (index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: FractionallySizedBox(
                  heightFactor: perfHeights[index],
                  child: Container(
                    decoration: BoxDecoration(
                      color: perfColors[index],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    Widget attendanceCell = SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 4,
            color: Colors.white.withOpacity(0.05),
          ),
          CircularProgressIndicator(
            value: attendance,
            strokeWidth: 4,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(attendanceColor ?? kPrimary),
          ),
          Center(
            child: Text('${(attendance * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );

    Widget actionCell = IconButton(
      icon: const Icon(Icons.more_vert, color: kOnSurfaceVariant),
      onPressed: () {},
    );

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Row(
          children: [
            Expanded(flex: 4, child: athleteCell),
            Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: statusCell)),
            Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: perfCell)),
            Expanded(flex: 2, child: Align(alignment: Alignment.center, child: attendanceCell)),
            Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: actionCell)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          athleteCell,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statusCell,
              attendanceCell,
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: perfCell),
              const SizedBox(width: 16),
              actionCell,
            ],
          )
        ],
      ),
    );
  }
}

class RecentAttendanceCard extends StatelessWidget {
  const RecentAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RECENT ATTENDANCE', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('FULL HISTORY', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              )
            ],
          ),
          const SizedBox(height: 24),
          _AttendanceRow(name: 'Jordan Hayes', desc: 'Strength & Conditioning • Today, 08:30 AM', xp: '+450 XP', iconColor: kPrimary),
          const SizedBox(height: 16),
          _AttendanceRow(name: 'Elena Costa', desc: 'HIIT Circuit • Yesterday, 05:15 PM', xp: '+320 XP', iconColor: Colors.white),
          const SizedBox(height: 16),
          _AttendanceRow(name: 'David Miller', desc: 'Recovery Session • Yesterday, 02:00 PM', xp: '+150 XP', iconColor: Colors.white),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final String name;
  final String desc;
  final String xp;
  final Color iconColor;

  const _AttendanceRow({required this.name, required this.desc, required this.xp, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.history, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
              ],
            )
          ],
        ),
        Text(xp, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class NetworkPerformanceCard extends StatelessWidget {
  const NetworkPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NETWORK PERFORMANCE', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('System-wide performance benchmarks across all active programs.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(painter: LineChartPainter()),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('ELITE GROWTH', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('14.2%', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('AVG VO2 MAX', style: TextStyle(color: kSecondaryContainer, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text('54.2', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.125, size.height * 0.7, size.width * 0.25, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width * 0.75, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.3, size.width, size.height * 0.1);

    final Paint linePaint = Paint()
      ..shader = LinearGradient(colors: [kSecondaryContainer, kPrimary]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [kSecondaryContainer.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;
    
    for (int i = 1; i < 5; i++) {
      double x = size.width * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('Clients', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 32),
                      const Text('Schedule', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                      const Text('Programs', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      const SizedBox(width: 32),
                    ],
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
                        border: Border.all(color: kPrimary.withOpacity(0.3)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC1tW1WdTr2biHnjiiByJ3Yfcp0VdvyALrvkJ_MyjBdhzQ2BUBLVxX9l4ppocu1OLXTNooGpN5bWRT2Axc9ypcKYfK-CPlEYJeyH7Vc_6ntV24iDe7nBRGBNNShUSMJprMGL3mZZsdrmJTc-dLrwaaEAhuL8qJ34Ukj_jPK2K61BT5JnLeUC_xRzT938gx4YhMOqL6cLa_2OPpQrpXaG0hMEZ_eU_NvaSg_-TnPZySJjRRBv_JLZKRpV_NHRCzNAke4ykciwjZ-wEE'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Lvl 42', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.group, title: 'Members', isActive: true),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.monitoring, title: 'Analytics'),
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
              _BottomNavIcon(icon: Icons.exercise, title: 'Workouts'),
              _BottomNavIcon(icon: Icons.smart_toy, title: 'AI Buddy'),
              _BottomNavIcon(icon: Icons.group, title: 'Clients', isActive: true),
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