// import 'package:flutter/material.dart';
// import '../../components/glass_card.dart';
// import '../../components/kinetic_button.dart';
// import '../../components/kinetic_input.dart';
// import '../../theme/app_theme.dart';

// class WorkoutAssignmentScreen extends StatelessWidget {
//   const WorkoutAssignmentScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text('ASSIGN WORKOUT', style: Theme.of(context).textTheme.labelLarge),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const KineticInput(hintText: 'Search Client...'),
//             const SizedBox(height: 24),
//             GlassCard(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Program Details', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
//                   const SizedBox(height: 16),
//                   const KineticInput(hintText: 'Program Title (e.g. 12-Week Shred)'),
//                   const SizedBox(height: 16),
//                   const KineticInput(hintText: 'Notes for Client...'),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Exercise Block'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.surface,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             KineticButton(
//               text: 'Send to Client',
//               onPressed: () {},
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
  runApp(const VelocityAIWorkoutAssignmentApp());
}

// --- CONSTANTS & THEME ---
const Color kBackground = Color(0xFF0A0A0A);
const Color kPrimary = Color(0xFFCAF300);
const Color kSecondaryContainer = Color(0xFF4B8EFF);
const Color kSurface = Color(0xFF1C1C1E);
const Color kSurfaceLow = Color(0xFF131313);
const Color kSurfaceHigh = Color(0xFF2A2A2A);
const Color kOnSurfaceVariant = Color(0xFFC5C9AC);

class VelocityAIWorkoutAssignmentApp extends StatelessWidget {
  const VelocityAIWorkoutAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velocity AI - Workout Assignment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const WorkoutAssignmentScreen(),
    );
  }
}

// --- MAIN SCREEN ---
class WorkoutAssignmentScreen extends StatelessWidget {
  const WorkoutAssignmentScreen({super.key});

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
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 8, child: RoutineCreatorColumn()),
          SizedBox(width: 24),
          Expanded(flex: 4, child: CompletionTrackerColumn()),
        ],
      );
    }
    return Column(
      children: const [
        RoutineCreatorColumn(),
        SizedBox(height: 24),
        CompletionTrackerColumn(),
      ],
    );
  }
}

// --- WIDGETS: CONTENT COMPONENTS ---

class PageHeader extends StatelessWidget {
  const PageHeader({super.key});

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
            Text('Workout Assignment', style: TextStyle(color: Colors.white, fontSize: isMobile ? 32 : 40, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.1)),
            const SizedBox(height: 8),
            const Text('Architect elite performance routines and distribute them across your roster of athletes.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 16)),
          ],
        ),
        if (isMobile) const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
              onPressed: () {},
              child: const Text('SAVE DRAFT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 12,
                shadowColor: kPrimary.withOpacity(0.4),
              ),
              onPressed: () {},
              child: const Text('PUBLISH ROUTINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        )
      ],
    );
  }
}

// --- LEFT COLUMN: ROUTINE CREATOR ---
class RoutineCreatorColumn extends StatelessWidget {
  const RoutineCreatorColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RoutineIdentityCard(),
        SizedBox(height: 32),
        ExerciseSequenceCard(),
      ],
    );
  }
}

class RoutineIdentityCard extends StatelessWidget {
  const RoutineIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassCard(
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: isMobile ? 0 : 1,
            child: const _InputField(
              label: 'ROUTINE NAME', 
              hintText: 'e.g. Hypertrophy Phase 1 - Upper Body'
            ),
          ),
          SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 24 : 0),
          Expanded(
            flex: isMobile ? 0 : 1,
            child: const _DropdownField(
              label: 'TARGET GROUP/CLIENT', 
              items: ['Select Group or Client...', 'Elite Performance Squad', 'Individual: Marcus Thorne', 'Individual: Sarah Jenkins', 'Recovery Group A'],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseSequenceCard extends StatelessWidget {
  const ExerciseSequenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exercise Sequence', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: kPrimary, size: 18),
                  label: const Text('Add Exercise', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: const [
                _ExerciseRow(
                  index: '1',
                  isActive: true,
                  initialExercise: 'Barbell Back Squat',
                  sets: '4',
                  reps: '8-10',
                  rest: '120',
                ),
                SizedBox(height: 24),
                _ExerciseRow(
                  index: '2',
                  isActive: false,
                  initialExercise: 'Romanian Deadlift',
                  sets: '3',
                  reps: '12',
                  rest: '90',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final String index;
  final bool isActive;
  final String initialExercise;
  final String sets;
  final String reps;
  final String rest;

  const _ExerciseRow({
    required this.index,
    required this.isActive,
    required this.initialExercise,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceHigh.withOpacity(0.4),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? kPrimary : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(index, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _DropdownField(items: [initialExercise, 'Deadlift', 'Leg Press', 'Pull-ups'])),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: Row(
                    children: [
                      Expanded(child: _CompactInput(label: 'SETS', value: sets, isPrimary: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _CompactInput(label: 'REPS', value: reps)),
                      const SizedBox(width: 16),
                      Expanded(child: _CompactInput(label: 'REST (S)', value: rest)),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (isMobile) const SizedBox(height: 16),
          Flex(
            direction: isMobile ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.content_copy, color: kOnSurfaceVariant, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, color: kOnSurfaceVariant, size: 20), hoverColor: Colors.red.withOpacity(0.1), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }
}

// --- RIGHT COLUMN: COMPLETION TRACKER ---
class CompletionTrackerColumn extends StatelessWidget {
  const CompletionTrackerColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        KpiCompletionSummary(),
        SizedBox(height: 32),
        RosterStatusCard(),
        SizedBox(height: 32),
        ActivityLogButton(),
      ],
    );
  }
}

class KpiCompletionSummary extends StatelessWidget {
  const KpiCompletionSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Stack(
        children: [
          // Sparkline background graphic placeholder
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: SparklinePainter(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT COMPLETION', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 16),
              const Text('74%', style: TextStyle(color: kPrimary, fontSize: 40, fontWeight: FontWeight.w800, height: 1)),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  widthFactor: 0.74,
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
              const Text('24/32 athletes completed today\'s block.', style: TextStyle(color: kOnSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kSecondaryContainer
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.25);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RosterStatusCard extends StatelessWidget {
  const RosterStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('ROSTER STATUS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: const [
                _RosterItem(
                  name: 'Liam Vance',
                  status: 'FINISHED • 52m ago',
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAsTVt16hMDPPlrMAL09Rx3kFzeOBOp5XopsF0JnSHNFa9vIfvLbD4WS8Zqxlnlb06fsAdnYBho7JkxO9R0eiRKaZ3BWtxhF7LWCCOLFphNWJJlhlpY9Hhb16aV4n1xVcVDFXGrt86swFLK0Ysq-ZyqwDh_pn7BXW8wS5Imwyl7m8RkjbsgUtpOfAJY7dI6lCpRwPY3CJnD6OIOqzm4wcdfMXlab_OaZXHiKu2r1NyW79yzXspn8MOLYkCQIHNm2-kf5N8CNUDk_RM',
                  icon: Icons.check_circle,
                  iconColor: kPrimary,
                  dotColor: kPrimary,
                  isGrayscale: true,
                ),
                Divider(color: Colors.white10),
                _RosterItem(
                  name: 'Maya Sterling',
                  status: 'IN PROGRESS • Ex. 4',
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJJdZv6Y1KozHcIxJzEsR005TzSXDTvHnjzQuKm7JATDT2dpkjaUDFgJfNvFI1VxYofo-S5Tvwz5u2vsyO_CnIEzMnZYEw9KdtuMMmQrwVeegu25qH0RdLtbfrLbnn922cg2qrODlnYq5qWksPfjm3iM55jt2l6Xr0_VAMYiOCYpQUTRyD00LAoQCLn0BKkpy3g1Nm4V5L9mzaU8sVVcHHVT-_bdUQ_fl5k-qAsUBan_c2elnkRHCMRg-UcOdaXgKg7MtzyEYWDE8',
                  icon: Icons.timer,
                  iconColor: kSecondaryContainer,
                  dotColor: kSecondaryContainer,
                  isGrayscale: true,
                ),
                Divider(color: Colors.white10),
                _RosterItem(
                  name: 'Jordan Blake',
                  status: 'NOT STARTED',
                  imgUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNx4RAs_RWV3SC-02UC8SGlLPVpxeXAhI1qYvj9G5PLLIo_FZMytOOVhTTdQFtIkdAx8wx7VylAZfFbU3tWRD4bx6V_-Jo_SpUKVHUQt_wAcFXPV5KitTfif9Zca88_yWX-0jqivHJMOWg8zBj511sZ4cOPxDsFN4QUuHpyi6uLxIFTkV8dnV3A-Zpeout-LFZ71YqynQEO32EMyVGrCWbSsorGnIO151t_AILH3FvlaAeP64SDdhJujUDeNIDmjSCXaNWhPis0yE',
                  icon: Icons.cancel,
                  iconColor: kOnSurfaceVariant,
                  dotColor: kOnSurfaceVariant,
                  isGrayscale: true,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RosterItem extends StatelessWidget {
  final String name;
  final String status;
  final String imgUrl;
  final IconData icon;
  final Color iconColor;
  final Color dotColor;
  final bool isGrayscale;

  const _RosterItem({
    required this.name,
    required this.status,
    required this.imgUrl,
    required this.icon,
    required this.iconColor,
    required this.dotColor,
    this.isGrayscale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ColorFiltered(
                    colorFilter: isGrayscale 
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: kBackground, width: 2)),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(status, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10)),
                ],
              )
            ],
          ),
          Icon(icon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}

class ActivityLogButton extends StatelessWidget {
  const ActivityLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.history, color: kOnSurfaceVariant, size: 20),
              SizedBox(width: 12),
              Text('VIEW HISTORY LOG', style: TextStyle(color: kOnSurfaceVariant, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}


// --- UTILITY WIDGETS ---

class _InputField extends StatelessWidget {
  final String label;
  final String hintText;

  const _InputField({required this.label, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: kOnSurfaceVariant),
            filled: true,
            fillColor: kSurfaceLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary)),
            contentPadding: const EdgeInsets.all(16),
          ),
        )
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? label;
  final List<String> items;

  const _DropdownField({this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: items.first,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: kSurfaceHigh,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: kSurfaceLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimary)),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        )
      ],
    );
  }
}

class _CompactInput extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _CompactInput({required this.label, required this.value, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          textAlign: TextAlign.center,
          style: TextStyle(color: isPrimary ? kPrimary : Colors.white, fontSize: 14, fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            filled: true,
            fillColor: kBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
        )
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
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
                    Text('VELOCITY AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: kPrimary, letterSpacing: -1)),
                  ],
                ),
                Row(
                  children: [
                    if (MediaQuery.of(context).size.width > 768) ...[
                      const Text('Dashboard', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Training', style: TextStyle(color: kOnSurfaceVariant)),
                      const SizedBox(width: 32),
                      const Text('Members', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 32),
                      const Text('Settings', style: TextStyle(color: kOnSurfaceVariant)),
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
                        border: Border.all(color: kPrimary, width: 2),
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
                        Text('Alex Rivers', style: TextStyle(color: kPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Pro Athlete • Level 42', style: TextStyle(color: kOnSurfaceVariant, fontSize: 10, letterSpacing: 1)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                _NavTile(icon: Icons.dashboard, title: 'Dashboard'),
                _NavTile(icon: Icons.fitness_center, title: 'Training'),
                _NavTile(icon: Icons.group, title: 'Members', isActive: true),
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
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
        border: isActive ? const Border(right: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
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
              _BottomNavIcon(icon: Icons.group, title: 'Clients'),
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