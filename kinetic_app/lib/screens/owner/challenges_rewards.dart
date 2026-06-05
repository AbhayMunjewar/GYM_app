import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ChallengesRewards extends StatelessWidget {
  const ChallengesRewards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('CHALLENGES', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.primaryFixed), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 2,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Summer Shred ${index + 1}', style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                      const Text('Active', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Participants: 142', style: TextStyle(color: AppColors.white)),
                      const SizedBox(height: 8),
                      const Text('Reward: 1 Month Free Premium', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: 0.6, backgroundColor: AppColors.white10, valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
