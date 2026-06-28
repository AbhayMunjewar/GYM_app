import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_replacement_widget.dart';

class NutritionDashboardScreen extends ConsumerStatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  ConsumerState<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends ConsumerState<NutritionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch today's compliance to display summary trackers
    Future.microtask(() {
      ref.read(dietComplianceProvider.notifier).fetchCompliance('weekly');
    });
  }

  void _openFoodSwapsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: FoodReplacementWidget(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(nutritionProfileProvider);
    final complianceState = ref.watch(dietComplianceProvider);

    final hasProfile = profileState.profile != null;
    final profile = profileState.profile;
    
    // Extrapolate values
    final calTarget = profile?['target_calories'] ?? 2000;
    final protTarget = profile?['protein_g'] ?? 140;
    final carbTarget = profile?['carbs_g'] ?? 200;
    final fatTarget = profile?['fat_g'] ?? 60;
    final waterTarget = profile?['water_liters'] ?? 3.0;

    final compData = complianceState.complianceData;
    final calConsumed = compData?['avg_calories'] ?? 0;
    final protConsumed = compData?['avg_protein_g'] ?? 0;
    final complianceScore = compData?['compliance_score'] ?? 0;

    final calPct = calTarget > 0 ? (calConsumed / calTarget) : 0.0;
    final protPct = protTarget > 0 ? (protConsumed / protTarget) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.go('/member/dashboard'),
        ),
        title: const Text(
          'AI NUTRITION DASHBOARD',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          if (hasProfile)
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppColors.primaryFixed),
              onPressed: () => context.push('/member/diet-setup'),
            )
        ],
      ),
      body: SafeArea(
        child: profileState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : !hasProfile
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMacroTrackerCard(calTarget, calConsumed, calPct, complianceScore),
                        const SizedBox(height: 24),
                        _buildProfileDetailsPanel(profile!),
                        const SizedBox(height: 24),
                        _buildSectionHeader('NUTRITION SUITE'),
                        const SizedBox(height: 16),
                        _buildGridMenu(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 24),
            const Text(
              'No AI Diet Plan Configured',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unlock customized daily meals, shopping lists, compliance trackers, and immediate AI coaching optimized for your body profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/member/diet-setup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Setup My AI Diet Plan',
                style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTrackerCard(int targetCal, int consumedCal, double calPct, int complianceScore) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Calorie Breakdown',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  '$targetCal kcal',
                  style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.insights, color: AppColors.primaryFixed, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Avg Consumed: $consumedCal kcal',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: complianceScore >= 80 ? Colors.green : (complianceScore >= 60 ? Colors.yellow : Colors.red),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Compliance Score: $complianceScore%',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: calPct.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: AppColors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryFixed),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(calPct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'hit rate',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsPanel(Map<String, dynamic> profile) {
    final foodPref = profile['food_preference']?.toString().toUpperCase() ?? 'VEG';
    final goal = profile['goal']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'FAT LOSS';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE DIET PROFILE',
            style: TextStyle(color: AppColors.primaryFixed, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          _buildProfileItem('Goal Mode', goal, Icons.track_changes),
          _buildProfileItem('Diet Preference', foodPref, Icons.restaurant),
          _buildProfileItem('Daily Budget', '₹${profile['budget_inr']}/day', Icons.wallet),
          _buildProfileItem(
            'Physique Stats',
            '${profile['age']} yo • ${profile['height_cm']} cm • ${profile['weight_kg']} kg',
            Icons.scale,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard(
          title: 'Meal Planner',
          subtitle: 'Generated Meals',
          icon: Icons.calendar_today,
          color: const Color(0xFF4B8EFF),
          onTap: () {
            // Pre-fetch meals using profile context
            final profile = ref.read(nutritionProfileProvider).profile;
            if (profile != null) {
              ref.read(mealPlanProvider.notifier).fetchMeals(profile);
            }
            context.push('/member/meal-plan');
          },
        ),
        _buildMenuCard(
          title: 'Grocery List',
          subtitle: 'Shopping Checklist',
          icon: Icons.shopping_basket,
          color: const Color(0xFFCAF300),
          onTap: () {
            // Trigger pre-load if meals are available
            final meals = ref.read(mealPlanProvider).meals;
            if (meals != null) {
              ref.read(groceryListProvider.notifier).fetchGroceryList(meals, 'weekly');
            }
            context.push('/member/grocery-list');
          },
        ),
        _buildMenuCard(
          title: 'Swaps Finder',
          subtitle: 'Healthy Alternatives',
          icon: Icons.swap_horiz,
          color: const Color(0xFFFFB4AB),
          onTap: _openFoodSwapsModal,
        ),
        _buildMenuCard(
          title: 'Compliance',
          subtitle: 'Consistency Score',
          icon: Icons.calendar_month,
          color: const Color(0xFF00E676),
          onTap: () => context.push('/member/compliance'),
        ),
        _buildMenuCard(
          title: 'Diet Coach',
          subtitle: 'AI Consultation',
          icon: Icons.smart_toy,
          color: const Color(0xFFE040FB),
          onTap: () => context.push('/member/diet-coach'),
        ),
        _buildMenuCard(
          title: 'Diet Center',
          subtitle: 'Trainer Assigned',
          icon: Icons.apple,
          color: Colors.amber,
          onTap: () => context.push('/member/diet-center'),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
