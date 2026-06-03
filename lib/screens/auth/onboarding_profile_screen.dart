import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/glass_card.dart';
import '../../components/kinetic_button.dart';
import '../../components/kinetic_input.dart';
import '../../theme/app_theme.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  String _selectedGoal = 'Hypertrophy';
  final List<String> _goals = ['Hypertrophy', 'Strength', 'Endurance', 'Weight Loss'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PROFILE SETUP',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Customize Your AI',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Help Kinetic AI understand your baseline to tailor your ecosystem.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            const KineticInput(hintText: 'Current Weight (kg)'),
            const SizedBox(height: 16),
            const KineticInput(hintText: 'Target Weight (kg)'),
            const SizedBox(height: 32),
            Text(
              'PRIMARY GOAL',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _goals.map((goal) {
                final isSelected = _selectedGoal == goal;
                return ChoiceChip(
                  label: Text(goal),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: AppColors.surface,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedGoal = goal);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            KineticButton(
              text: 'Complete Setup',
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
