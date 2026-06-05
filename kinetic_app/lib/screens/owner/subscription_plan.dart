import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class SubscriptionPlan extends StatelessWidget {
  const SubscriptionPlan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('PLAN MANAGEMENT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildPlanCard('Basic Tier', '\$29.99/mo', 'Access to gym equipment, no classes.', true),
            const SizedBox(height: 16),
            _buildPlanCard('Premium Tier', '\$59.99/mo', 'Full gym access, group classes, 1 PT session.', true),
            const SizedBox(height: 16),
            _buildPlanCard('Elite VIP Tier', '\$99.99/mo', 'Unlimited PT sessions, spa access.', false),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create New Plan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryFixed,
                side: const BorderSide(color: AppColors.primaryFixed),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String desc, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? AppColors.primaryFixed : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Switch(value: isActive, onChanged: (v) {}, activeColor: AppColors.primaryFixed),
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
