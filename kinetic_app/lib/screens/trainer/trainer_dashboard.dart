import 'package:flutter/material.dart';
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
