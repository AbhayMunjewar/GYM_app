import 'package:flutter/material.dart';
import '../../components/glass_card.dart';
import '../../theme/app_theme.dart';

class DietAssignmentScreen extends StatefulWidget {
  const DietAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<DietAssignmentScreen> createState() => _DietAssignmentScreenState();
}

class _DietAssignmentScreenState extends State<DietAssignmentScreen> {
  String _selectedGoal = 'Muscle Gain';
  final List<String> _goals = ['Muscle Gain', 'Fat Loss', 'Maintenance', 'Lean Bulk'];

  final List<Map<String, dynamic>> _mealTemplates = [
    {
      'name': 'High-Protein Bulk',
      'calories': 3200,
      'protein': 220,
      'carbs': 350,
      'fat': 90,
      'meals': 6,
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Lean Cut Plan',
      'calories': 2000,
      'protein': 180,
      'carbs': 150,
      'fat': 65,
      'meals': 5,
      'icon': Icons.local_fire_department,
    },
    {
      'name': 'Balanced Maintenance',
      'calories': 2500,
      'protein': 150,
      'carbs': 280,
      'fat': 80,
      'meals': 4,
      'icon': Icons.balance,
    },
    {
      'name': 'Keto Performance',
      'calories': 2200,
      'protein': 160,
      'carbs': 30,
      'fat': 170,
      'meals': 4,
      'icon': Icons.bolt,
    },
  ];

  final List<Map<String, String>> _recentClients = [
    {'name': 'Alex Walker', 'plan': 'High-Protein Bulk', 'status': 'Active'},
    {'name': 'Sarah Chen', 'plan': 'Lean Cut Plan', 'status': 'Active'},
    {'name': 'Mike Johnson', 'plan': 'Balanced Maintenance', 'status': 'Paused'},
    {'name': 'Priya Sharma', 'plan': 'Keto Performance', 'status': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DIET ASSIGNMENT', style: Theme.of(context).textTheme.labelLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Goal selector chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoal == goal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      goal,
                      style: TextStyle(
                        color: isSelected ? AppColors.background : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Meal Plan Templates
          Text('MEAL PLAN TEMPLATES', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ...List.generate(_mealTemplates.length, (index) {
            final template = _mealTemplates[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(template['icon'] as IconData, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(template['name'] as String, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text('${template['meals']} meals/day • ${template['calories']} kcal', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Assign', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Macro bar
                    Row(
                      children: [
                        _macroPill('P', '${template['protein']}g', const Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        _macroPill('C', '${template['carbs']}g', const Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        _macroPill('F', '${template['fat']}g', const Color(0xFFFF9800)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),
          // Recently assigned clients
          Text('ASSIGNED CLIENTS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          ...List.generate(_recentClients.length, (index) {
            final client = _recentClients[index];
            final isActive = client['status'] == 'Active';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        client['name']![0],
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client['name']!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(client['plan']!, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4CAF50).withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        client['status']!,
                        style: TextStyle(
                          color: isActive ? const Color(0xFF4CAF50) : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color.withOpacity(0.85), fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }
}
