import os

buddy_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AIGymBuddy extends StatelessWidget {
  const AIGymBuddy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('AI GYM BUDDY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildMessage('Hey! Ready for your Upper Body Power session?', isAI: true),
                  _buildMessage('Yeah, but my left shoulder feels a bit tight today.', isAI: false),
                  _buildMessage('Got it. Let\\'s swap the Barbell Bench Press for Dumbbell Floor Presses to reduce shoulder strain. Sounds good?', isAI: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask Velocity AI...',
                        filled: true,
                        fillColor: const Color(0xFF201F1F),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primaryFixed, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: AppColors.onPrimaryFixed), onPressed: () {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, {required bool isAI}) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF201F1F) : AppColors.primaryFixed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: !isAI ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(color: isAI ? Colors.transparent : AppColors.primaryFixed.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: TextStyle(color: isAI ? AppColors.white : AppColors.primaryFixed)),
      ),
    );
  }
}
"""

form_check_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AIFormCheck extends StatelessWidget {
  const AIFormCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('AI FORM CHECK', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.onSurfaceVariant, size: 64),
                        SizedBox(height: 16),
                        Text('Camera Preview', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('START RECORDING', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"""

progress_dart = """import 'package:flutter/material.dart';
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
"""

membership_dart = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MembershipCenter extends StatelessWidget {
  const MembershipCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('MEMBERSHIP', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryFixed.withValues(alpha: 0.2), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('ELITE TIER', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    SizedBox(height: 8),
                    Text('Alex Velocity', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 24),
                    Text('Valid until: Dec 31, 2026', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payment, color: AppColors.white),
                title: const Text('Billing History', style: TextStyle(color: AppColors.white)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                onTap: () {},
              ),
              const Divider(color: AppColors.white10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings, color: AppColors.white),
                title: const Text('App Settings', style: TextStyle(color: AppColors.white)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => context.go('/auth/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB4AB),
                  side: const BorderSide(color: Color(0xFFFFB4AB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"""

challenges_dart = """import 'package:flutter/material.dart';
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
"""

with open('d:/GYM/kinetic_app/lib/screens/member/ai_gym_buddy.dart', 'w') as f: f.write(buddy_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/ai_form_check.dart', 'w') as f: f.write(form_check_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/progress_tracker.dart', 'w') as f: f.write(progress_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/membership_center.dart', 'w') as f: f.write(membership_dart)
with open('d:/GYM/kinetic_app/lib/screens/member/challenges_leaderboard.dart', 'w') as f: f.write(challenges_dart)
print("Part 2 generated")
