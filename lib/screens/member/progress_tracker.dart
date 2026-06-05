import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('PROGRESS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: const Text('Volume Graph Placeholder', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(height: 32),
              const Text('PERSONAL RECORDS', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildPrCard('Bench Press', '100 kg', '+5 kg this month'),
              const SizedBox(height: 12),
              _buildPrCard('Squat', '140 kg', '+10 kg this month'),
              const SizedBox(height: 12),
              _buildPrCard('Deadlift', '160 kg', 'No change'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrCard(String lift, String weight, String diff) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lift, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weight, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(diff, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
