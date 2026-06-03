import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class AnalyticsReportsScreen extends StatelessWidget {
  const AnalyticsReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('ANALYTICS & REPORTS', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Retention Metrics', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 16),
            GlassCard(
              height: 200,
              child: Center(
                child: Text(
                  'Retention Chart Placeholder\n(Month over Month)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Class Attendance', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _buildStatRow(context, 'Morning HIIT', '85% Capacity', '+5%'),
                  const Divider(color: Colors.white24),
                  _buildStatRow(context, 'Evening Yoga', '92% Capacity', '+2%'),
                  const Divider(color: Colors.white24),
                  _buildStatRow(context, 'Lunch Powerlift', '60% Capacity', '-3%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String title, String stat, String change) {
    final isPositive = change.startsWith('+');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stat, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(change, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10,
                color: isPositive ? AppColors.primary : Colors.red,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
