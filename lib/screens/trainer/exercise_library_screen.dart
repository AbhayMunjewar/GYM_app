import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../components/kinetic_input.dart';
import '../../theme/app_theme.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('EXERCISE LIBRARY', style: Theme.of(context).textTheme.labelLarge),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: KineticInput(hintText: 'Search Exercises...'),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final exercises = ['Squat', 'Bench Press', 'Deadlift', 'Overhead Press', 'Barbell Row', 'Pull-up'];
                final muscles = ['Quads/Glutes', 'Chest/Triceps', 'Hamstrings/Back', 'Shoulders', 'Back', 'Lats/Biceps'];
                
                return GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.fitness_center, color: AppColors.secondary, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(exercises[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(muscles[index], style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
