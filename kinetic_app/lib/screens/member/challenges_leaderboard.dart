import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ChallengesLeaderboard extends StatelessWidget {
  const ChallengesLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('CHALLENGES', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                    const Icon(Icons.emoji_events, color: AppColors.primaryFixed, size: 48),
                    const SizedBox(height: 16),
                    const Text('Summer Shred', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Top 10% in the gym!', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(value: 0.8, backgroundColor: AppColors.white10, valueColor: const AlwaysStoppedAnimation(AppColors.primaryFixed)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('LEADERBOARD', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildRank(1, 'Sarah K.', '12,500 pts'),
              _buildRank(2, 'Mike T.', '11,200 pts'),
              _buildRank(3, 'Alex V. (You)', '10,800 pts', isMe: true),
              _buildRank(4, 'David R.', '9,500 pts'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRank(int rank, String name, String score, {bool isMe = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryFixed.withValues(alpha: 0.1) : const Color(0xFF201F1F),
        border: Border.all(color: isMe ? AppColors.primaryFixed : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('#$rank', style: TextStyle(color: isMe ? AppColors.primaryFixed : AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))),
          Text(score, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
