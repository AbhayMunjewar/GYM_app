// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../theme/app_theme.dart';

// class WorkoutCenterScreen extends StatelessWidget {
//   const WorkoutCenterScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'WORKOUT CENTER',
//           style: Theme.of(context).textTheme.labelLarge,
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Your Plan',
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             const SizedBox(height: 24),
//             GlassCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Day 3: Pull Day',
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyLarge
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: AppColors.primary),
//                         ),
//                         child: Text(
//                           'AI GENERATED',
//                           style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                                 color: AppColors.primary,
//                                 fontSize: 10,
//                               ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Divider(color: Colors.white24),
//                   const SizedBox(height: 16),
//                   _buildExerciseRow(context, 'Deadlift', '4 sets x 8 reps'),
//                   _buildExerciseRow(context, 'Pull-ups', '3 sets x 10 reps'),
//                   _buildExerciseRow(context, 'Barbell Rows', '3 sets x 12 reps'),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       child: const Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Text('START WORKOUT'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               'AI Form Check',
//               style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
//             ),
//             const SizedBox(height: 16),
//             GlassCard(
//               child: Column(
//                 children: [
//                   const Icon(Icons.video_camera_front, size: 48, color: AppColors.secondary),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Record your set for AI analysis of your biomechanics.',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExerciseRow(BuildContext context, String name, String details) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(name, style: Theme.of(context).textTheme.bodyLarge),
//           Text(
//             details,
//             style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                   color: AppColors.onSurfaceVariant,
//                 ),
//           ),
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
      title: 'Velocity AI - Workout Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const WorkoutCenterScreen(),
    );
  }
}

// --- MAIN LAYOUT ---
class WorkoutCenterScreen extends StatelessWidget {
  const WorkoutCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopAppBar(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24.0, 100.0, 24.0, isDesktop ? 40.0 : 120.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const WelcomeSection(),
                const SizedBox(height: 48),
                const MainDashboardGrid(),
                const SizedBox(height: 48),
                const ProgramsHeader(),
                const SizedBox(height: 24),
                const ProgramsGrid(),
                const SizedBox(height: 48),
                const Text(
                  'Workout History',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const HistoryTable(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kPrimary,
        foregroundColor: Colors.black,
        elevation: 12,
        child: const Icon(Icons.add, size: 32, weight: 700),
      ),
      bottomNavigationBar: !isDesktop ? const MobileBottomNav() : null,
    );
  }
}

// --- WIDGETS: APP BAR & NAV ---
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
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: kOnSurfaceVariant),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDEzFQUHrCohOo2Q0ZO08qL6kI6BVKv6Vc0tF-s-o6F0iab7G6D5oX783KesSyz4G2VT2ptbEEDWn7z9acMnLdGZmJeVgRErmH0SXZMYXctj7tIwDxRs_TrdFrok9wSAYQ40v8QSpPZicXMu9FSvrlCVk-r8_8ptyvypfJTZlRaAVuHGYXPPBycWhN3rml4p-RoYa6Er2ZkfAqz2gZoM2jXPs0cBWa-sZO8JASzTqr4y3S_6J1PVubT9lJvqZ2sJfccxPfO3f-7TS0'),
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
              _BottomNavIcon(icon: Icons.home, title: 'Home'),
              _BottomNavIcon(icon: Icons.fitness_center, title: 'Workouts', isActive: true),
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

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PEAK PERFORMANCE HUB',
              style: TextStyle(color: kPrimary, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              'WORKOUT CENTER',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 700 ? 40 : 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              const Text('Current Streak: 12 Days', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}

class MainDashboardGrid extends StatelessWidget {
  const MainDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Expanded(flex: 8, child: ActiveSessionCard()),
          SizedBox(width: 16),
          Expanded(flex: 4, child: WeeklyProgressCard()),
        ],
      );
    }
    return Column(
      children: const [
        ActiveSessionCard(),
        SizedBox(height: 16),
        WeeklyProgressCard(),
      ],
    );
  }
}

class ActiveSessionCard extends StatelessWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(Icons.fitness_center, size: 160, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(20)),
                        child: const Text('ACTIVE SESSION', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      const Text('45 mins elapsed', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('High Intensity Power Blast', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Focusing on explosive posterior chain movements and core stability. You are 65% through your session.',
                    style: TextStyle(color: kOnSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          color: Colors.white.withOpacity(0.05),
                        ),
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const SweepGradient(
                              startAngle: 0.0,
                              endAngle: 3.14 * 2,
                              colors: [kSecondary, kPrimary],
                              stops: [0.0, 1.0],
                            ).createShader(rect);
                          },
                          child: const CircularProgressIndicator(
                            value: 0.65,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const Center(
                          child: Text('65%', style: TextStyle(color: kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('NEXT UP: KETTLEBELL SWINGS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            Text('SET 3/4', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {},
                            child: const Text('RESUME SESSION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Plan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _PlanDay(day: 'MON', date: '12', title: 'Hypertrophy Upper', subtitle: 'Completed • 72 min', isCompleted: true),
          const SizedBox(height: 12),
          _PlanDay(day: 'TUE', date: '13', title: 'Active Recovery', subtitle: 'Completed • 30 min', isCompleted: true),
          const SizedBox(height: 12),
          _PlanDay(day: 'WED', date: '14', title: 'Power & Speed', subtitle: 'Today', isToday: true),
          const SizedBox(height: 12),
          _PlanDay(day: 'THU', date: '15', title: 'Leg Overload', subtitle: 'Scheduled', isFuture: true),
        ],
      ),
    );
  }
}

class _PlanDay extends StatelessWidget {
  final String day;
  final String date;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;

  const _PlanDay({
    required this.day,
    required this.date,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isToday = false,
    this.isFuture = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday ? kPrimary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isToday ? const Color(0xFF4B8EFF) : isCompleted ? kPrimary : Colors.transparent, width: 4)),
      ),
      child: Opacity(
        opacity: isFuture ? 0.4 : 1.0,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Text(day, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(date, style: TextStyle(color: isToday ? Colors.white : kPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isToday ? kPrimary : kOnSurfaceVariant,
                    fontSize: 12,
                    fontStyle: isToday ? FontStyle.italic : FontStyle.normal,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ProgramsHeader extends StatelessWidget {
  const ProgramsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('Training Programs', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          child: const Text('VIEW ALL', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )
      ],
    );
  }
}

class ProgramsGrid extends StatelessWidget {
  const ProgramsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    final cards = [
      const ProgramCard(
        title: 'Strength King',
        desc: 'Focused on heavy compounds and metabolic conditioning.',
        imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDDTX5KOE_I45HxmvCa7vMDUt4yacJro5qSeLtq-LPVfPC-n2DOC4C-9z-gCiue6nD4bmL1FpXf6OvESvrmMI4675WSSwwan8Xvwrh1JC_xafna3dEmtmomNoroZ-gRWX-8NapLIHHrgfmtEofoPiQkf7ufLaSBEgGBY5--MDD-SEQDAnXKyRmJvBN2xm0fzr00D91eY3ICOwrEMnz6P6FkS_ncSeDSItdKrwWGyjbLdvdSZTI6dY-3oMmhZ7KU8twDpcErRI3nHEQ',
        tags: ['Strength', 'Advanced'],
        duration: '12 Weeks',
        focus: 'Full Body',
      ),
      const ProgramCard(
        title: 'Metabolic Shred',
        desc: 'High intensity circuits designed to maximize calorie burn and endurance.',
        imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAb447ektAihmfLS_4hBlZXObUdg0j09yG8RzeeI6LewaH16beZLA-WI88jg-cu8_vx-UadHsYSsL75kLjPJCVYyOMO-DcLbzEOKqak2DtRC3ulRegljjbtU77-EbigPkv3KXev24uVNFJsUwrgBijvVqohgZ9AOzYre-6xaCrDGWCD217QH0f786PcaqjaCwpClkHOUUmKzPpNGC4vEgXRiblxIepTh9MgbIthHZTRG_bKRVReaO0Ubml4AL9vd3hz4a0aBedpOrw',
        tags: ['Fat Loss', 'Intermediate'],
        duration: '8 Weeks',
        focus: 'Cardio/Core',
      ),
      const ProgramCard(
        title: 'Hypertrophy Pro',
        desc: 'Science-backed volume tracking for maximum muscle development.',
        imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB7eaZ5wl8h2_WS5iaAmPYcgnanHklwrzU-ns1ar1QwkDHVscHOabHqqctXPx2qt3eFrE9e7PFfdVrYTjPYEAsgrXM0eoHzXzLI79SjdZ4JCg7IyJf2YLUA6OvtlDHNeKlSBqofZq4Zx2iDhmyIfEz6zg_L8OgSlbD7Ss9mGT3aAm_k7RovJ9Ow4-HHOw9B1sVZ85IVtXxZJ3_DlWBK3MUo1FOL92C-ndPxH8XEgJ3dvgK24afYFCmkpUMLrqbVR4O0_z0f6riFVrY',
        tags: ['Muscle Gain', 'Advanced'],
        duration: '16 Weeks',
        focus: 'Upper/Lower',
      ),
      const ProgramCard(
        title: 'Foundation AI',
        desc: 'Perfect starting point for mastering form and building consistency.',
        imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVjUWBmQ7tYu-iruoopmIs5gVIvFP8kJX2yRbP996xflCR3thJtIn0hK7IjKsfFw2rT1S6FvitIQ_P6BdYv4diythCOLdlhqSmBdaKm1C_U3cN1bjj66TbWWi_RueNWnfTopxaXS423kmcqPWn6h8qKbL9QFbuD_0BZirZr-UdBV9QPJ-4yB8HTSZnBW9u5miw-lXY9swSTH_kdgdJ9OLxZna_NZLyaRrTNbvkUtcMe8MSTZuqbbJcl7cSNoMsEYhUIClENwHXQxs',
        tags: ['Beginner', 'Novice'],
        duration: '6 Weeks',
        focus: 'Mobility',
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: card == cards.last ? 0 : 16.0),
            child: card,
          ),
        )).toList(),
      );
    }
    
    return Column(
      children: cards.map((card) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: card,
      )).toList(),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imgUrl;
  final List<String> tags;
  final String duration;
  final String focus;

  const ProgramCard({
    super.key,
    required this.title,
    required this.desc,
    required this.imgUrl,
    required this.tags,
    required this.duration,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imgUrl, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [kBackground.withOpacity(0.9), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: tags.map((tag) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: kOnSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(duration, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, size: 16, color: kPrimary),
                        const SizedBox(width: 4),
                        Text(focus, style: const TextStyle(color: kPrimary, fontSize: 14)),
                      ],
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

class HistoryTable extends StatelessWidget {
  const HistoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            dividerThickness: 1,
            dataRowMaxHeight: 70,
            dataRowMinHeight: 70,
            columns: const [
              DataColumn(label: Text('DATE', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('WORKOUT', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('VOLUME', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('INTENSITY', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PRS', style: TextStyle(color: kOnSurfaceVariant, fontWeight: FontWeight.bold)), numeric: true),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Oct 12, 2023', style: TextStyle(color: Colors.white))),
                const DataCell(Text('Hypertrophy Upper B', style: TextStyle(color: Colors.white))),
                const DataCell(Text('12,450 kg', style: TextStyle(color: Colors.white))),
                DataCell(_IntensityBars(bars: 3)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF4B8EFF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.stars, size: 12, color: kSecondary),
                        SizedBox(width: 4),
                        Text('2 NEW', style: TextStyle(color: kSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ),
              ]),
              DataRow(cells: [
                const DataCell(Text('Oct 10, 2023', style: TextStyle(color: Colors.white))),
                const DataCell(Text('Power Clean Focus', style: TextStyle(color: Colors.white))),
                const DataCell(Text('8,900 kg', style: TextStyle(color: Colors.white))),
                DataCell(_IntensityBars(bars: 4)),
                const DataCell(Text('---', style: TextStyle(color: kOnSurfaceVariant))),
              ]),
              DataRow(cells: [
                const DataCell(Text('Oct 08, 2023', style: TextStyle(color: Colors.white))),
                const DataCell(Text('Zone 2 Recovery', style: TextStyle(color: Colors.white))),
                const DataCell(Text('N/A', style: TextStyle(color: Colors.white))),
                DataCell(_IntensityBars(bars: 1)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF4B8EFF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.stars, size: 12, color: kSecondary),
                        SizedBox(width: 4),
                        Text('1 NEW', style: TextStyle(color: kSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityBars extends StatelessWidget {
  final int bars;
  const _IntensityBars({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 6,
          height: 16,
          decoration: BoxDecoration(
            color: index < bars ? kPrimary : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
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