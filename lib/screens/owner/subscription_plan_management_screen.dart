import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../components/kinetic_button.dart';
import '../../theme/app_theme.dart';

class SubscriptionPlanManagementScreen extends StatelessWidget {
  const SubscriptionPlanManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('SUBSCRIPTIONS & PLANS', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Active Tiers', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'Basic Kinetic', '\$49/mo', '120 Active Members', false),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'Pro Velocity', '\$99/mo', '150 Active Members', true),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'Elite Ecosystem', '\$199/mo', '72 Active Members', false),
            const SizedBox(height: 32),
            KineticButton(
              text: 'Create New Plan',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String name, String price, String members, bool isPopular) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text('MOST POPULAR', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: isPopular ? AppColors.primary : Colors.white)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(members, style: TextStyle(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
