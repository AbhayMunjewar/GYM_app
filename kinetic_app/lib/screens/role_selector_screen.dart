import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.hub, color: AppColors.primaryFixed, size: 64),
              const SizedBox(height: 24),
              Text('Select Portal', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
              const SizedBox(height: 8),
              Text('Choose your access level to proceed.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 48),
              
              _buildRoleCard(context, 'MEMBER', 'Access your workout hub', Icons.person, '/member/dashboard'),
              const SizedBox(height: 16),
              _buildRoleCard(context, 'TRAINER', 'Manage clients & schedules', Icons.fitness_center, '/trainer/dashboard'),
              const SizedBox(height: 16),
              _buildRoleCard(context, 'OWNER', 'Gym analytics & billing', Icons.business, '/owner/dashboard'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String subtitle, IconData icon, String targetRoute) {
    return InkWell(
      onTap: () {
        // Pass the target route to the login screen so it knows where to go after OTP
        context.push('/auth/login', extra: targetRoute);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          border: Border.all(color: AppColors.primaryFixed.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryFixed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primaryFixed, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 16),
          ],
        ),
      ),
    );
  }
}
