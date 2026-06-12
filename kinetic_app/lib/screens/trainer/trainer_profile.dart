import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class TrainerProfile extends StatelessWidget {
  const TrainerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final name = authService.fullName ?? 'Trainer Staff';
    final email = authService.email ?? 'trainer@gym.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'TRAINER PROFILE',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryFixed,
                  child: Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'STAFF PERSONAL TRAINER',
                    style: TextStyle(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    context.go('/auth/login');
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB4AB),
                  side: const BorderSide(color: Color(0xFFFFB4AB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
