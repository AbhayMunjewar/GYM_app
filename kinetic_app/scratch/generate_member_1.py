import os

dashboard_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MEMBER DASHBOARD', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person, color: AppColors.white), onPressed: () => context.push('/member/membership')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricCard(context, 'Next Session', 'Upper Body Power', Icons.fitness_center),
              const SizedBox(height: 16),
              _buildMetricCard(context, 'Nutrition', '1,850 / 2,400 kcal', Icons.restaurant),
              const SizedBox(height: 32),
              const Text('MODULES', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Workout Center', Icons.fitness_center, '/member/workout-center'),
                  _buildNavCard(context, 'Diet Center', Icons.apple, '/member/diet-center'),
                  _buildNavCard(context, 'Exercise Library', Icons.menu_book, '/member/exercise-library'),
                  _buildNavCard(context, 'AI Gym Buddy', Icons.smart_toy, '/member/ai-buddy'),
                  _buildNavCard(context, 'AI Form Check', Icons.camera_alt, '/member/ai-form-check'),
                  _buildNavCard(context, 'Progress Tracker', Icons.trending_up, '/member/progress-tracker'),
                  _buildNavCard(context, 'Challenges', Icons.emoji_events, '/member/challenges'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 32),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primaryFixed,
      unselectedItemColor: AppColors.onSurfaceVariant,
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 0) context.go('/member/dashboard');
        if (i == 1) context.push('/member/workout-center');
        if (i == 2) context.push('/member/diet-center');
        if (i == 3) context.push('/member/progress-tracker');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
      ],
    );
  }
}
"""

workout_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class WorkoutCenter extends StatelessWidget {
  const WorkoutCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('WORKOUT CENTER', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center, color: AppColors.primaryFixed, size: 48),
                    const SizedBox(height: 16),
                    const Text('Today\\'s Plan', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Upper Body Hypertrophy', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed, foregroundColor: AppColors.onPrimaryFixed),
                      child: const Text('START WORKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('UPCOMING', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.calendar_today, color: AppColors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Leg Day Power', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                              Text('Tomorrow, 8:00 AM', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"""

diet_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class DietCenter extends StatelessWidget {
  const DietCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('DIET CENTER', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Daily Calories', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        Text('1,850 / 2,400', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: 1850/2400, backgroundColor: AppColors.white10, valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('MACROS', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMacroCard('Protein', '120g', '150g', const Color(0xFF4B8EFF)),
                  const SizedBox(width: 12),
                  _buildMacroCard('Carbs', '180g', '200g', const Color(0xFFCAF300)),
                  const SizedBox(width: 12),
                  _buildMacroCard('Fats', '45g', '60g', const Color(0xFFFFB4AB)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(String title, String current, String target, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text(current, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('of $target', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
"""

exercise_lib_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ExerciseLibrary extends StatelessWidget {
  const ExerciseLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('EXERCISE LIBRARY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.play_arrow, color: AppColors.white),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barbell Bench Press', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                            Text('Chest, Triceps', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

with open('d:/GYM/kinetic_app/lib/screens/member/member_dashboard.dart', 'w') as f: f.write(dashboard_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/workout_center.dart', 'w') as f: f.write(workout_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/diet_center.dart', 'w') as f: f.write(diet_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/exercise_library.dart', 'w') as f: f.write(exercise_lib_dart)
print("Part 1 generated")
