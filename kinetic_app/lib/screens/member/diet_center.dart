import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/diet_models.dart';

class DietCenter extends StatefulWidget {
  const DietCenter({super.key});

  @override
  State<DietCenter> createState() => _DietCenterState();
}

class _DietCenterState extends State<DietCenter> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String? _errorMessage;
  int? _memberId;
  DietAssignment? _activeAssignment;
  DietProgress? _progress;
  DietPlan? _dietPlan;
  List<DietPlanMeal> _todayMeals = [];
  final Map<String, bool> _mealCompletionStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDietData();
  }

  Future<void> _loadDietData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch Member ID
      final attRes = await _apiClient.getMemberDashboardAttendance();
      if (attRes.statusCode != 200) {
        throw 'Failed to load member info';
      }
      final attData = jsonDecode(attRes.body);
      if (attData['success'] != true) {
        throw attData['message'] ?? 'Failed to load member info';
      }
      _memberId = attData['data']['member_id'];

      if (_memberId == null) {
        throw 'No member profile found';
      }

      // 2. Fetch Active Assignments
      final assignRes = await _apiClient.getDietAssignments();
      if (assignRes.statusCode != 200) {
        throw 'Failed to load assignments';
      }
      final assignData = jsonDecode(assignRes.body);
      if (assignData['success'] != true) {
        throw assignData['message'] ?? 'Failed to load assignments';
      }

      final List results = assignData['data'] ?? [];
      final assignments = results.map((x) => DietAssignment.fromJson(x)).toList();
      
      _activeAssignment = assignments.firstWhere(
        (a) => a.status == 'ACTIVE',
        orElse: () => throw 'No active diet plan assigned.',
      );

      // 3. Fetch progress
      final progressRes = await _apiClient.getMemberDietProgress(_memberId!);
      if (progressRes.statusCode == 200) {
        final progressData = jsonDecode(progressRes.body);
        if (progressData['success'] == true) {
          _progress = DietProgress.fromJson(progressData['data']);
        }
      }

      // 4. Fetch diet plan
      final planRes = await _apiClient.getDietPlan(_activeAssignment!.dietPlanId);
      if (planRes.statusCode == 200) {
        final planData = jsonDecode(planRes.body);
        if (planData['success'] == true) {
          _dietPlan = DietPlan.fromJson(planData['data']);
        }
      }

      // 5. Fetch logs for today to determine completed meals
      final logsRes = await _apiClient.getDietLogs();
      final List logsList = [];
      if (logsRes.statusCode == 200) {
        final logsData = jsonDecode(logsRes.body);
        if (logsData['success'] == true) {
          logsList.addAll(logsData['data'] ?? []);
        }
      }

      // Filter today's meals based on current day number (defaults to 1 if null)
      final currentDay = _progress?.currentDayNumber ?? 1;
      if (_dietPlan != null) {
        _todayMeals = _dietPlan!.planMeals.where((pm) => pm.dayNumber == currentDay).toList();
        _todayMeals.sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
      }

      // Map today's meal logs
      _mealCompletionStatus.clear();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      for (var log in logsList) {
        final logDate = log['created_at']?.toString().substring(0, 10);
        if (logDate == todayStr) {
          final mealId = log['meal']?.toString();
          final completed = log['completed'] ?? false;
          if (mealId != null) {
            _mealCompletionStatus[mealId] = completed;
          }
        }
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleMealLog(DietPlanMeal meal, bool currentStatus) async {
    if (_activeAssignment == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.logDietMeal({
        'assigned_diet': _activeAssignment!.id,
        'meal': meal.id,
        'completed': !currentStatus,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(!currentStatus ? 'Meal marked consumed!' : 'Meal logged as skipped/removed!'),
              backgroundColor: AppColors.primaryFixed,
            ),
          );
          await _loadDietData();
          return;
        }
      }
      final errBody = jsonDecode(res.body);
      throw errBody['message'] ?? 'Failed to update log';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  IconData _getMealIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.free_breakfast;
      case 'LUNCH':
        return Icons.lunch_dining;
      case 'DINNER':
        return Icons.dinner_dining;
      default:
        return Icons.cookie;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'DIET CENTER',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadDietData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _progress == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : _errorMessage != null && _activeAssignment == null
                ? _buildErrorOrEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadDietData,
                    color: AppColors.primaryFixed,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCalorieCard(),
                          const SizedBox(height: 24),
                          _buildMacrosSection(),
                          const SizedBox(height: 32),
                          _buildTodayMealsSection(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorOrEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 24),
            Text(
              _errorMessage ?? 'No Active Diet Plan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your trainer has not assigned an active diet plan yet. Ask them to configure one in their dashboard!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDietData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryFixed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Check Again', style: TextStyle(color: AppColors.onPrimaryFixed)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    final target = _progress?.targetCalories ?? 0;
    final consumed = _progress?.consumedCalories ?? 0;
    final remaining = _progress?.remainingCalories ?? 0;
    final percent = target > 0 ? (consumed / target) : 0.0;

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
                  'Calories Remaining',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  '$remaining kcal',
                  style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: AppColors.primaryFixed, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Target: $target kcal',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Consumed: $consumed kcal',
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
                  value: percent.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: AppColors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryFixed),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'completed',
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

  Widget _buildMacrosSection() {
    final pConsumed = _progress?.consumedProtein ?? 0.0;
    final pTarget = _progress?.targetProtein ?? 0;
    final cConsumed = _progress?.consumedCarbs ?? 0.0;
    final cTarget = _progress?.targetCarbs ?? 0;
    final fConsumed = _progress?.consumedFats ?? 0.0;
    final fTarget = _progress?.targetFats ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DAILY MACROS',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF201F1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildMacroProgressRow('Protein', pConsumed, pTarget, const Color(0xFF4B8EFF), 'g'),
              const SizedBox(height: 16),
              _buildMacroProgressRow('Carbs', cConsumed, cTarget, const Color(0xFFCAF300), 'g'),
              const SizedBox(height: 16),
              _buildMacroProgressRow('Fats', fConsumed, fTarget, const Color(0xFFFFB4AB), 'g'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgressRow(String title, double current, int target, Color color, String unit) {
    final progress = target > 0 ? (current / target) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 14)),
            Text(
              '${current.toStringAsFixed(0)}g / ${target}g',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMealsSection() {
    final currentDay = _progress?.currentDayNumber ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S MEALS (DAY $currentDay)',
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2),
            ),
            if (_todayMeals.isEmpty)
              const Text('No meals scheduled', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))
          ],
        ),
        const SizedBox(height: 16),
        if (_todayMeals.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No meals scheduled for today in this plan.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayMeals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pm = _todayMeals[index];
              final template = pm.mealTemplate;
              final isCompleted = _mealCompletionStatus[pm.id] ?? false;

              // Read template macros
              final macros = template.calculatedMacros;
              final cal = macros['calories'] ?? 0;
              final prot = macros['protein'] ?? 0.0;
              final carb = macros['carbohydrates'] ?? 0.0;
              final fat = macros['fats'] ?? 0.0;

              return Container(
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF1B2A1E) : const Color(0xFF201F1F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted ? Colors.green.withOpacity(0.3) : AppColors.white.withOpacity(0.05),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isCompleted ? Colors.green.withOpacity(0.2) : AppColors.white10,
                      child: Icon(
                        isCompleted ? Icons.check : _getMealIcon(template.mealType),
                        color: isCompleted ? Colors.green : AppColors.primaryFixed,
                      ),
                    ),
                    title: Text(
                      template.mealName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${template.mealType} • $cal kcal',
                      style: TextStyle(
                        color: isCompleted ? Colors.green.withOpacity(0.7) : AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isCompleted,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (_) => _toggleMealLog(pm, isCompleted),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(color: AppColors.white10),
                            const SizedBox(height: 8),
                            const Text(
                              'Foods Included:',
                              style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...template.mealFoods.map((mf) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${mf.foodName} (${mf.category})',
                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                    ),
                                    Text(
                                      '${mf.quantity.toStringAsFixed(1)} ${mf.servingUnit}',
                                      style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.white10),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMealMacroSummary('Prot', prot, const Color(0xFF4B8EFF)),
                                _buildMealMacroSummary('Carbs', carb, const Color(0xFFCAF300)),
                                _buildMealMacroSummary('Fats', fat, const Color(0xFFFFB4AB)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMealMacroSummary(String label, double val, Color color) {
    return Column(
      children: [
        Text(
          '${val.toStringAsFixed(1)}g',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }
}
