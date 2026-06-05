import 'package:flutter/material.dart';
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
