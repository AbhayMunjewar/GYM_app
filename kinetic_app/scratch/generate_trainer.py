import os

dashboard_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TRAINER HQ', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person, color: AppColors.white), onPressed: () => context.push('/trainer/profile')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricCard(context, 'Next Client', 'John Doe (10:00 AM)', Icons.schedule),
              const SizedBox(height: 16),
              _buildMetricCard(context, 'Active Clients', '14 Assigned', Icons.people),
              const SizedBox(height: 32),
              const Text('MANAGEMENT', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Client Mgmt', Icons.people, '/trainer/clients'),
                  _buildNavCard(context, 'Schedule', Icons.calendar_month, '/trainer/schedule'),
                  _buildNavCard(context, 'Workout Assign', Icons.fitness_center, '/trainer/workout-assign'),
                  _buildNavCard(context, 'Diet Assign', Icons.restaurant, '/trainer/diet-assign'),
                ],
              ),
            ],
          ),
        ),
      ),
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
}
"""

clients_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ClientManagement extends StatelessWidget {
  const ClientManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('CLIENTS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search clients...',
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
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: AppColors.primaryFixed),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('John Doe', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                            Text('Hypertrophy Program', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
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

schedule_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ScheduleCalendar extends StatelessWidget {
  const ScheduleCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('SCHEDULE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text('Calendar Strip Placeholder', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    border: Border(left: BorderSide(color: AppColors.primaryFixed, width: 4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('10:00 AM - 11:00 AM', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 8),
                      Text('1-on-1 with John Doe', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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

workout_assign_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class WorkoutAssignment extends StatelessWidget {
  const WorkoutAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ASSIGN WORKOUT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Workout Builder Interface', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
"""

diet_assign_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class DietAssignment extends StatelessWidget {
  const DietAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ASSIGN DIET', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: Text('Diet Builder Interface', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
"""

profile_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TrainerProfile extends StatelessWidget {
  const TrainerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('PROFILE', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: OutlinedButton(
            onPressed: () => context.go('/auth/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFB4AB),
              side: const BorderSide(color: Color(0xFFFFB4AB)),
            ),
            child: const Text('LOG OUT'),
          ),
        ),
      ),
    );
  }
}
"""

with open('d:/GYM/kinetic_app/lib/screens/trainer/trainer_dashboard.dart', 'w') as f: f.write(dashboard_dart)
with open('d:/GYM/kinetic_app/lib/screens/trainer/client_management.dart', 'w') as f: f.write(clients_dart)
with open('d:/GYM/kinetic_app/lib/screens/trainer/schedule_calendar.dart', 'w') as f: f.write(schedule_dart)
with open('d:/GYM/kinetic_app/lib/screens/trainer/workout_assignment.dart', 'w') as f: f.write(workout_assign_dart)
with open('d:/GYM/kinetic_app/lib/screens/trainer/diet_assignment.dart', 'w') as f: f.write(diet_assign_dart)
with open('d:/GYM/kinetic_app/lib/screens/trainer/trainer_profile.dart', 'w') as f: f.write(profile_dart)
print("Trainer screens generated")
