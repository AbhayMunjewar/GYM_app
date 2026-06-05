import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('OWNER HQ', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: AppColors.white), onPressed: () => context.push('/owner/settings')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricCard(context, 'Total Revenue', '\$124,500', Icons.attach_money),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMetricCard(context, 'Members', '1,240', Icons.people)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard(context, 'Check-ins', '342 Today', Icons.how_to_reg)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('OPERATIONS', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavCard(context, 'Members', Icons.people, '/owner/members'),
                  _buildNavCard(context, 'Trainers', Icons.sports, '/owner/trainers'),
                  _buildNavCard(context, 'Attendance', Icons.how_to_reg, '/owner/attendance'),
                  _buildNavCard(context, 'Billing', Icons.payment, '/owner/billing'),
                  _buildNavCard(context, 'Analytics', Icons.bar_chart, '/owner/analytics'),
                  _buildNavCard(context, 'Challenges', Icons.emoji_events, '/owner/challenges'),
                  _buildNavCard(context, 'Comms', Icons.campaign, '/owner/communication'),
                  _buildNavCard(context, 'Plans', Icons.card_membership, '/owner/subscription'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryFixed, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
