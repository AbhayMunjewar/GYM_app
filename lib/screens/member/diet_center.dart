import 'package:flutter/material.dart';
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
