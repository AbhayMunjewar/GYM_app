// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';
// import 'package:go_router/go_router.dart';

// class TrainerDashboardScreen extends StatelessWidget {
//   const TrainerDashboardScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('TRAINER DASHBOARD', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: GlassCard(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Text('ACTIVE CLIENTS', style: Theme.of(context).textTheme.labelLarge),
//                         const SizedBox(height: 8),
//                         Text('14', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: AppColors.primary)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: GlassCard(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         Text('PENDING REVIEWS', style: Theme.of(context).textTheme.labelLarge),
//                         const SizedBox(height: 8),
//                         Text('3', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: AppColors.secondary)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             Text('Quick Actions', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
//             const SizedBox(height: 16),
//             GlassCard(
//               padding: EdgeInsets.zero,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.people, color: AppColors.primary),
//                     title: const Text('Client Management'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () => context.push('/trainer/clients'),
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.assignment, color: AppColors.primary),
//                     title: const Text('Assign Workouts & Diets'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () => context.push('/trainer/assign'),
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.library_books, color: AppColors.primary),
//                     title: const Text('Exercise Library'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () => context.push('/trainer/library'),
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
//                     title: const Text('Diet Assignment'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () => context.push('/trainer/diet-assign'),
//                   ),
//                   const Divider(color: Colors.white10, height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.person, color: AppColors.primary),
//                     title: const Text('My Profile'),
//                     trailing: const Icon(Icons.chevron_right, color: Colors.white54),
//                     onTap: () => context.push('/trainer/profile'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const VelocityAITrainerApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kSurface = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondary = Color(0xFFADC6FF);
const Color kError = Color(0xFFFFB4AB);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAITrainerApp extends StatelessWidget {
  const VelocityAITrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VELOCITY AI | Trainer Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const TrainerDashboardScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const MobileBottomNav() 
          : null,
    );
  }

  Widget _buildBentoGrid(bool isDesktop) {
    return Column(
      children: [
        // Top KPI Row
        if (isDesktop)
          Row(
            children: const [
              Expanded(child: KpiCardActiveClients()),
              SizedBox(width: 16),
              Expanded(child: KpiCardDailySessions()),
              SizedBox(width: 16),
              Expanded(child: KpiCardAvgPerformance()),
            ],
          )
        else
          Column(
            children: const [
              KpiCardActiveClients(),
              SizedBox(height: 16),
              KpiCardDailySessions(),
              SizedBox(height: 16),
              KpiCardAvgPerformance(),
            ],
          ),
        
        const SizedBox(height: 16),

        // Middle Row: Chart + Alerts
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 8, child: PerformanceAnalyticsCard()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: ProgressAlertsCard()),
            ],
          )
        else
          Column(
            children: const [
              PerformanceAnalyticsCard(),
              SizedBox(height: 16),
              ProgressAlertsCard(),
            ],
          ),

        const SizedBox(height: 16),

        // Bottom Row: Schedule
        const TodaysScheduleCard(),
      ],
    );
  }
}

// --- WIDGETS: HEADER ---

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
            Text('Performance Command', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
            const SizedBox(height: 8),
            const Text('Wednesday, October 24 | Elite Training Cycle', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            shadowColor: kPrimary.withOpacity(0.3),
          ),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('NEW TRAINING BLOCK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          onPressed: () {},
        )
      ],
    );
  }
}

// --- WIDGETS: KPIS ---

class KpiCardActiveClients extends StatelessWidget {
  const KpiCardActiveClients({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.group, color: kPrimary),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('+12%', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('ACTIVE CLIENTS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('42', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(painter: SparklinePainter(color: kPrimary, isCurve: true)),
          )
        ],
      ),
    );
  }
}

class KpiCardDailySessions extends StatelessWidget {
  const KpiCardDailySessions({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.calendar_today, color: kSecondary),
              const Text('TODAY', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('DAILY SESSIONS', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('08', style: TextStyle(color: kPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CustomPaint(painter: SparklinePainter(color: kSecondary, isCurve: false)),
          )
        ],
      ),
    );
  }
}

class KpiCardAvgPerformance extends StatelessWidget {
  const KpiCardAvgPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.bolt, color: kError),
                  Text('PEAK', style: TextStyle(color: kError, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('AVG PERFORMANCE', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              const Text('94%', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const SizedBox(height: 30), // Spacing equivalent
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 4,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const CircularProgressIndicator(
                    value: 0.94,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(kPrimary),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;
  final bool isCurve;

  SparklinePainter({required this.color, required this.isCurve});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    if (isCurve) {
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.6);
      path.quadraticBezierTo(size.width * 0.75, size.height * 1.0, size.width, size.height * 0.1);
    } else {
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.5);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.7);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- WIDGETS: CHART & ALERTS ---

class PerformanceAnalyticsCard extends StatelessWidget {
  const PerformanceAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Performance Analytics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(4)),
                      child: const Text('WEEK', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: kPrimary.withOpacity(0.2), border: Border.all(color: kPrimary.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                      child: const Text('MONTH', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: _BarChartMockup(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BarChartMockup extends StatelessWidget {
  const _BarChartMockup();

  @override
  Widget build(BuildContext context) {
    final heights = [0.5, 0.66, 0.75, 0.8, 1.0, 0.75, 0.66];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: h,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ProgressAlertsCard extends StatelessWidget {
  const ProgressAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progress Alerts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  _AlertItem(name: 'Marcus V.', msg: 'Hit 120kg Bench Press PR!', icon: Icons.military_tech, color: kPrimary),
                  SizedBox(height: 12),
                  _AlertItem(name: 'Sarah J.', msg: 'Missed 3 sessions this week.', icon: Icons.priority_high, color: kError),
                  SizedBox(height: 12),
                  _AlertItem(name: 'Elena R.', msg: 'Body fat decreased by 2.4%.', icon: Icons.trending_up, color: kSecondary),
                  SizedBox(height: 12),
                  _AlertItem(name: 'Jason K.', msg: 'Completed Advanced Program.', icon: Icons.star, color: kPrimary),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String name;
  final String msg;
  final IconData icon;
  final Color color;

  const _AlertItem({required this.name, required this.msg, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(msg, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- WIDGETS: SCHEDULE ---

class TodaysScheduleCard extends StatelessWidget {
  const TodaysScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Today\'s Schedule', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('8 Sessions Total', style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: const [
                _ScheduleItem(
                  time: '09:00 AM', 
                  name: 'Elena Rodriguez', 
                  type: 'Hypertrophy • Day 4', 
                  location: 'Area 51', 
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPJzqMbS6ybb_GeRzGvQbWycoIM3iEhPthEnhUQnNCbMbn-Al-nvVOO720oR_obfuBIz1L9Y4cQNOfpE1giKv9Dntej8Rjx5uBXhuou-A3ooWvjWIu-TJ6GioDWTNEHq_s1CCvJDniDEeqwMAHROKjuUy6W-wbbGosbANr95Sg2scPelpu_WPpXT45V2tRHhRB_1hGQVJvVPgxNkAkFWM5RESPJ97dY3VVar-mR8LulLW9EmfgPbyrjx0vD_RYse242YOQUteZV2w',
                  color: kPrimary
                ),
                SizedBox(width: 16),
                _ScheduleItem(
                  time: '10:30 AM', 
                  name: 'David Chen', 
                  type: 'Powerlifting • PR Day', 
                  location: 'The Pit', 
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDgz7sI0LKutM_AXud6N-Y81ARqT2fCaYVWrenxMh1jXpw8jstu7DmIxmX_FlWnvTtqMfUSul9o-M27Ib3Qa_bAWzTFk-AuFuYyactUqE5uZHZGXFlBrjOuVCvdCRD6dtQpd7T0FBKaUx2DKtZN6lWv18fTpr1ErwMCdxQnkXgN9s7ck2cSMAADgH5xWlhP6zoMpRFf3j4OD_IjfTcdjKd8T03e8-0l6SdDX2aIODrotThMDVDM-1hNRMNtQagM4KxPyybxh1zsbiY',
                  color: kSecondary
                ),
                SizedBox(width: 16),
                _ScheduleItem(
                  time: '01:00 PM', 
                  name: 'Sarah Jenkins', 
                  type: 'HIIT • Recovery Focus', 
                  location: 'Cardio Zone', 
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDdxXMFB4cKUGucjNQGDdpVcQtHWKxthVBqY7WKrzavz5UOPeFIcS-8kyrwyAji-HR6-L6IHpqNL2GQP_dIPaagPDv4AEdlzCGHOOU1UcDPnJhwW_qMU7-Ou5fQ40gWas_yJBDMX_XvTqP_8fdq2qGN3gm0n-ibmruUEJ-puDiLLx-jNUIVKzGmZzWMzGQlqCfyUN0r2u45EfMeHGjwLmz5RySNlWFBx1s0WUqjuz8P5UoBBrbbOKpix8PBOlfrfL6O8nYd02fBbHQ',
                  color: kPrimary
                ),
                SizedBox(width: 16),
                _ScheduleItem(
                  time: '03:30 PM', 
                  name: 'Marcus Vane', 
                  type: 'Conditioning • Stage 3', 
                  location: 'Area 51', 
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD6o2OzxlsG8Zi2rT43lih5bJW0QvD4Z1NkjuMfqDOwvf5N6oVzKMMfU5CXluK06J1eSpwG5rgqlLmswGbbgMIb6DSAfO9yDYkGlk3H0GQKh02SOr2Qp4J1Undn50xupQZtmkGBYAPZ0JK8fcq4MpcRSz9uR_rEhr1J0fvvZ6X6Q9mTs7ie78xRw8uTxKmIcJFZ2ulQ46BJI9K0lWyn6_BpVp6N6w1tagEHIOBTbA86OBTNb5ZWgwGPUqFW-AiLVn6Q2Hzh0DDieyY',
                  color: kPrimary
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String name;
  final String type;
  final String location;
  final String imgUrl;
  final Color color;

  const _ScheduleItem({
    required this.time,
    required this.name,
    required this.type,
    required this.location,
    required this.imgUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceHigh.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(time, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.more_vert, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(imgUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(type, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: kOnSurfaceVariant, size: 16),
                  const SizedBox(width: 4),
                  Text(location, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                ],
              ),
              const Text('START', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}


// --- APP BAR & NAVIGATION ---

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
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                          onPressed: () {},
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
                        )
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCjzl4XfVHHqXVUDG4BUeHX0aGqk82xG4gIlFYnVGPeqKwXG5N6AONOvWM8VDQ_hKVN3BVAtqYYpqGGEpjNKAZ4kTpaYOdBGozKT9CcHntNPIoB2Tta7w1ede4DTkTkREzp5EFfzaCtMLHn-BeSGJc8S7vM9-1nlqKL4NrOVxbUR8LaYgV5EJJQMmhwNBAEzUJYzg-R_iMo48EedShFiwcY5S9E5yd_HOfVKaZEVI9xI4wjL-qLj0fnxdchRVTLkz333bZy7c6gjk4'),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAfx7ZjsM7SSTvDEEuNeFv2Bb5sKeKYqgcMGKyPbKA5vGBW0zh671S6sS2WyZ2wNnoukqeic3Y8TIG9pp-nCMmZ2L5vmJmVBgwXjM8KiPs2u7qXt9dhAmiw4r0Y5C3lsjm5y520j9ACENz8yQ5DuOxx9yG7AtEYzBLV0IpjsKzyOMCF5rumIDJnK9nsxu6O-Smr2tIVY04ggiaPbXlKubGfjQYuhm_vO5sPHQ6y-vgM0zAGtMMhP6cejv46BNpFAtmhOkp0d-H2K0Y'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard', isActive: true),
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
  final bool isActive;

  const _NavTile({required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? kPrimary.withOpacity(0.2) : Colors.transparent,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
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