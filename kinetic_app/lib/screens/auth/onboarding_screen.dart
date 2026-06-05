import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: step > 1 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => setState(() => step--))
          : IconButton(icon: const Icon(Icons.close, color: AppColors.white), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              Row(
                children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 1 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 2 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: step >= 3 ? AppColors.primaryFixed : AppColors.white10, borderRadius: BorderRadius.circular(2)))),
                ],
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: step == 1 ? _buildStep1() : (step == 2 ? _buildStep2() : _buildStep3()),
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (step < 3) {
                    setState(() => step++);
                  } else {
                    context.go('/member/dashboard');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.onPrimaryFixed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(step < 3 ? 'NEXT STEP' : 'COMPLETE PROFILE', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Data', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Required for baseline calculations.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        Text('AGE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
        const SizedBox(height: 8),
        TextField(decoration: InputDecoration(hintText: '28', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEIGHT (KG)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
                  const SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: '82', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEIGHT (CM)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF8F9378))),
                  const SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: '185', filled: true, fillColor: const Color(0xFF201F1F), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary Goal', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('What are we optimizing for?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        _GoalCard(title: 'HYPERTROPHY', desc: 'Maximized muscle gain', icon: Icons.fitness_center, isSelected: true),
        const SizedBox(height: 16),
        _GoalCard(title: 'ENDURANCE', desc: 'Aerobic capacity & stamina', icon: Icons.directions_run, isSelected: false),
        const SizedBox(height: 16),
        _GoalCard(title: 'STRENGTH', desc: 'Maximal force production', icon: Icons.line_weight, isSelected: false),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Experience', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40, color: AppColors.white)),
        const SizedBox(height: 8),
        Text('Calibrating AI logic models.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        
        _GoalCard(title: 'NOVICE', desc: '< 1 year of consistent training', icon: Icons.trending_up, isSelected: false),
        const SizedBox(height: 16),
        _GoalCard(title: 'INTERMEDIATE', desc: '1-3 years of programming', icon: Icons.bolt, isSelected: true),
        const SizedBox(height: 16),
        _GoalCard(title: 'ELITE', desc: '3+ years, competitive', icon: Icons.military_tech, isSelected: false),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isSelected;

  const _GoalCard({required this.title, required this.desc, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryFixed.withValues(alpha: 0.1) : const Color(0xFF201F1F),
        border: Border.all(color: isSelected ? AppColors.primaryFixed : Colors.transparent),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryFixed : AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isSelected ? AppColors.primaryFixed : AppColors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryFixed),
        ],
      ),
    );
  }
}
