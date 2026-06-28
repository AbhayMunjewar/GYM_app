import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  String _formatMealKey(String key) {
    switch (key.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snacks':
        return 'Snacks';
      case 'pre_workout':
        return 'Pre-Workout';
      case 'post_workout':
        return 'Post-Workout';
      default:
        return key.toUpperCase();
    }
  }

  IconData _getMealIcon(String key) {
    switch (key.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snacks':
        return Icons.cookie;
      case 'pre_workout':
        return Icons.flash_on;
      case 'post_workout':
        return Icons.fitness_center;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(nutritionProfileProvider).profile;
    final mealState = ref.watch(mealPlanProvider);

    // Default macro targets
    final targetCal = profile?['target_calories'] ?? 2000;
    final targetProt = profile?['protein_g'] ?? 140;
    final targetCarb = profile?['carbs_g'] ?? 200;
    final targetFat = profile?['fat_g'] ?? 60;

    // Calc totals from generated meals
    int totalCal = 0;
    int totalProt = 0;
    int totalCarb = 0;
    int totalFat = 0;

    if (mealState.meals != null) {
      mealState.meals!.forEach((key, value) {
        final Map<String, dynamic> meal = value;
        totalCal += int.tryParse(meal['total_calories']?.toString() ?? '0') ?? 0;
        
        // Sum items
        final List items = meal['items'] ?? [];
        for (var item in items) {
          totalProt += int.tryParse(item['protein_g']?.toString() ?? '0') ?? 0;
          totalCarb += int.tryParse(item['carbs_g']?.toString() ?? '0') ?? 0;
          totalFat += int.tryParse(item['fat_g']?.toString() ?? '0') ?? 0;
        }
      });
    }

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
          'AI MEAL PLANNER',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: () {
              if (profile != null) {
                ref.read(mealPlanProvider.notifier).fetchMeals(profile);
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: mealState.isLoading
            ? _buildShimmerLoading()
            : mealState.meals == null
                ? _buildEmptyState(ref, profile)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMacroProgressBars(
                          targetCal, totalCal,
                          targetProt, totalProt,
                          targetCarb, totalCarb,
                          targetFat, totalFat,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'YOUR DAILY MEALS',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 16),
                        ...mealState.meals!.keys.map((mealKey) {
                          final Map<String, dynamic> meal = mealState.meals![mealKey];
                          return _buildMealAccordionCard(context, ref, profile, mealKey, meal);
                        }),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref, Map<String, dynamic>? profile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 70, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 24),
            const Text(
              'No Meal Plan Generated Yet',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Click below to generate a tailored full day meal plan using your nutritional target calories.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (profile != null) {
                  ref.read(mealPlanProvider.notifier).fetchMeals(profile);
                } else {
                  context.push('/member/diet-setup');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Generate Plan Now', style: TextStyle(color: AppColors.onPrimaryFixed)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryFixed),
          SizedBox(height: 16),
          Text('AI is crafting your meal recipe details...', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMacroProgressBars(
    int targetCal, int totalCal,
    int targetProt, int totalProt,
    int targetCarb, int totalCarb,
    int targetFat, int totalFat,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Macro Plan Summary', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('$totalCal / $targetCal kcal', style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: targetCal > 0 ? (totalCal / targetCal).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              backgroundColor: AppColors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryFixed),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMacroBar('Protein', totalProt, targetProt, const Color(0xFF4B8EFF))),
              const SizedBox(width: 12),
              Expanded(child: _buildMacroBar('Carbs', totalCarb, targetCarb, const Color(0xFFCAF300))),
              const SizedBox(width: 12),
              Expanded(child: _buildMacroBar('Fats', totalFat, targetFat, const Color(0xFFFFB4AB))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, int val, int target, Color color) {
    final pct = target > 0 ? (val / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
            Text('${val}g/${target}g', style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: AppColors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMealAccordionCard(BuildContext context, WidgetRef ref, Map<String, dynamic>? profile, String mealKey, Map<String, dynamic> meal) {
    final List items = meal['items'] ?? [];
    final name = meal['name'] ?? 'Custom Meal';
    final totalCalories = meal['total_calories'] ?? 0;
    final totalProtein = meal['total_protein_g'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.white10,
            child: Icon(_getMealIcon(mealKey), color: AppColors.primaryFixed, size: 20),
          ),
          title: Text(
            _formatMealKey(mealKey),
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '$totalCalories kcal • $totalProtein g protein',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant, size: 20),
                tooltip: 'Regenerate this meal',
                onPressed: () {
                  if (profile != null) {
                    ref.read(mealPlanProvider.notifier).regenerateSingleMeal(mealKey, profile);
                  }
                },
              ),
              const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: AppColors.white10),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  const Text('INGREDIENTS:', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '• ${item['food']}',
                              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${item['quantity']} (${item['calories']} cal)',
                            style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
