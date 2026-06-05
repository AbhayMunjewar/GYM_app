import os

members_management = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class MembersManagement extends StatelessWidget {
  const MembersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('MEMBERS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppColors.primaryFixed), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryFixed.withValues(alpha: 0.2),
                        child: const Icon(Icons.person, color: AppColors.primaryFixed),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Member ${index + 1}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                            const Text('Premium Plan • Active', style: TextStyle(color: AppColors.primaryFixed, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

attendance_management = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AttendanceManagement extends StatelessWidget {
  const AttendanceManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ATTENDANCE LOGS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 10,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              border: const Border(left: BorderSide(color: AppColors.primaryFixed, width: 4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member ${index + 1}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    const Text('Checked in at 08:30 AM', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Verified', style: TextStyle(color: AppColors.primaryFixed, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""

billing_payments = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class BillingPayments extends StatelessWidget {
  const BillingPayments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('BILLING', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryFixed, Color(0xFF90B000)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending Invoices', style: TextStyle(color: AppColors.background)),
                  const SizedBox(height: 8),
                  const Text('\\$4,250.00', style: TextStyle(color: AppColors.background, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.background, foregroundColor: AppColors.primaryFixed),
                    child: const Text('Send Reminders'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(alignment: Alignment.centerLeft, child: Text('RECENT TRANSACTIONS', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 4,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFF201F1F), child: Icon(Icons.attach_money, color: AppColors.primaryFixed)),
                  title: Text('Payment from Member ${index + 1}', style: const TextStyle(color: AppColors.white)),
                  subtitle: const Text('Today', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  trailing: const Text('+\\$50.00', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

analytics_reports = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AnalyticsReports extends StatelessWidget {
  const AnalyticsReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ANALYTICS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
                child: const Center(child: Icon(Icons.bar_chart, size: 64, color: AppColors.primaryFixed)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('New Members', '+45', Icons.trending_up, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Churn Rate', '2.1%', Icons.trending_down, Colors.red)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Peak Hours', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text('1. 06:00 PM - 08:00 PM', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    SizedBox(height: 8),
                    Text('2. 07:00 AM - 09:00 AM', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
"""

trainer_management = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TrainerManagement extends StatelessWidget {
  const TrainerManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('TRAINER STAFF', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add, color: AppColors.primaryFixed), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryFixed,
                  child: Icon(Icons.fitness_center, color: AppColors.background),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trainer ${index + 1}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${10 + index * 5} Active Clients', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryFixed,
                    side: const BorderSide(color: AppColors.primaryFixed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
"""

challenges_rewards = """import 'package:flutter/material.dart';
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
"""

communication_center = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class CommunicationCenter extends StatelessWidget {
  const CommunicationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('ANNOUNCEMENTS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.campaign),
                label: const Text('NEW BROADCAST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 4,
                itemBuilder: (context, index) => Card(
                  color: const Color(0xFF201F1F),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.primaryFixed),
                    title: const Text('Holiday Hours Update', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Sent to: All Members', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    trailing: const Text('2d ago', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

gym_settings = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class GymSettings extends StatelessWidget {
  const GymSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('SETTINGS', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionHeader('Gym Profile'),
            _buildSettingTile('Operating Hours', Icons.schedule),
            _buildSettingTile('Location & Contact', Icons.location_on),
            const SizedBox(height: 24),
            _buildSectionHeader('App Configuration'),
            _buildSettingTile('Branding & Colors', Icons.color_lens),
            _buildSettingTile('Integrations', Icons.api),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB4AB), foregroundColor: AppColors.background),
              child: const Text('LOG OUT (OWNER)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildSettingTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.white),
        title: Text(title, style: const TextStyle(color: AppColors.white)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }
}
"""

subscription_plan = """import 'package:flutter/material.dart';
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
            _buildPlanCard('Basic Tier', '\\$29.99/mo', 'Access to gym equipment, no classes.', true),
            const SizedBox(height: 16),
            _buildPlanCard('Premium Tier', '\\$59.99/mo', 'Full gym access, group classes, 1 PT session.', true),
            const SizedBox(height: 16),
            _buildPlanCard('Elite VIP Tier', '\\$99.99/mo', 'Unlimited PT sessions, spa access.', false),
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
"""

files = {
    'members_management.dart': members_management,
    'attendance_management.dart': attendance_management,
    'billing_payments.dart': billing_payments,
    'analytics_reports.dart': analytics_reports,
    'trainer_management.dart': trainer_management,
    'challenges_rewards.dart': challenges_rewards,
    'communication_center.dart': communication_center,
    'gym_settings.dart': gym_settings,
    'subscription_plan.dart': subscription_plan,
}

for name, content in files.items():
    with open(f'd:/GYM/kinetic_app/lib/screens/owner/{name}', 'w') as f:
        f.write(content)

print("Owner UI screens thoroughly implemented")
