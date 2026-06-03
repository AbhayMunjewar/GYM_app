import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class BillingPaymentsScreen extends StatelessWidget {
  const BillingPaymentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('BILLING & PAYMENTS', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NEXT PAYOUT', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text('\$4,250.00', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary)),
                  ],
                ),
                Text('in 3 days', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Recent Transactions', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white54),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Membership Renewal', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Alex Walker', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('+\$99.00', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
