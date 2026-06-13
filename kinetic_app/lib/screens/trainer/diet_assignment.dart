import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../models/diet_models.dart';
import '../../models/member.dart';

class DietAssignment extends StatefulWidget {
  const DietAssignment({super.key});

  @override
  State<DietAssignment> createState() => _DietAssignmentState();
}

class _DietAssignmentState extends State<DietAssignment> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;
  bool _isLoading = false;

  // Data Lists
  List<Food> _foods = [];
  List<MealTemplate> _templates = [];
  List<DietPlan> _plans = [];
  List<Member> _members = [];
  List<DietAssignmentModel> _assignments = [];

  // Filter & Search variables
  String _foodSearch = '';
  String _foodCategory = '';
  String _planSearch = '';
  String _planGoal = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchFoods(),
        _fetchTemplates(),
        _fetchPlans(),
        _fetchMembers(),
        _fetchAssignments(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFoods() async {
    final res = await _apiClient.getFoods(search: _foodSearch, category: _foodCategory);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List data = body['data'] is List 
            ? body['data'] 
            : (body['data']?['results'] ?? []);
        _foods = data.map((x) => Food.fromJson(x)).toList();
      }
    }
  }

  Future<void> _fetchTemplates() async {
    final res = await _apiClient.getMealTemplates();
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List data = body['data'] ?? [];
        _templates = data.map((x) => MealTemplate.fromJson(x)).toList();
      }
    }
  }

  Future<void> _fetchPlans() async {
    final res = await _apiClient.getDietPlans(search: _planSearch, goal: _planGoal);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List data = body['data'] is List 
            ? body['data'] 
            : (body['data']?['results'] ?? []);
        _plans = data.map((x) => DietPlan.fromJson(x)).toList();
      }
    }
  }

  Future<void> _fetchMembers() async {
    final res = await _apiClient.getMembers();
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List data = body['data'] is List 
            ? body['data'] 
            : (body['data']?['results'] ?? []);
        _members = data.map((x) => Member.fromJson(x)).toList();
      }
    }
  }

  Future<void> _fetchAssignments() async {
    final res = await _apiClient.getDietAssignments();
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final List data = body['data'] ?? [];
        _assignments = data.map((x) => DietAssignmentModel.fromJson(x)).toList();
      }
    }
  }

  // Dialog actions
  Future<void> _showAddFoodDialog() async {
    final nameController = TextEditingController();
    final servingController = TextEditingController(text: '100g');
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();
    final fibController = TextEditingController(text: '0.0');
    final descController = TextEditingController();
    String category = 'PROTEIN';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Add Food to Library', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Food Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      items: const [
                        DropdownMenuItem(value: 'PROTEIN', child: Text('Protein')),
                        DropdownMenuItem(value: 'CARBOHYDRATE', child: Text('Carbohydrates')),
                        DropdownMenuItem(value: 'FAT', child: Text('Fats')),
                        DropdownMenuItem(value: 'FIBER', child: Text('Fiber')),
                        DropdownMenuItem(value: 'MIXED', child: Text('Mixed')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => category = v);
                      },
                    ),
                    TextField(
                      controller: servingController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Serving Size (e.g. 100g)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: calController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Calories (kcal)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: protController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Protein (g)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: carbController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Carbohydrates (g)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Fats (g)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: fibController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Fiber (g)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || calController.text.isEmpty) return;
                    final foodData = {
                      'food_name': nameController.text,
                      'category': category,
                      'serving_size': servingController.text,
                      'calories': int.tryParse(calController.text) ?? 0,
                      'protein': double.tryParse(protController.text) ?? 0.0,
                      'carbohydrates': double.tryParse(carbController.text) ?? 0.0,
                      'fats': double.tryParse(fatController.text) ?? 0.0,
                      'fiber': double.tryParse(fibController.text) ?? 0.0,
                      'description': descController.text,
                    };
                    final res = await _apiClient.createFood(foodData);
                    if (res.statusCode == 201) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food created successfully!')));
                      _loadAllData();
                    } else {
                      final body = jsonDecode(res.body);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${body['message'] ?? res.body}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                  child: const Text('Add', style: TextStyle(color: AppColors.onPrimaryFixed)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateTemplateDialog() async {
    final nameController = TextEditingController();
    String mealType = 'BREAKFAST';
    final descController = TextEditingController();
    
    // Items builder state
    final List<Map<String, dynamic>> selectedFoods = [];
    Food? currentSelectedFood;
    final qtyController = TextEditingController(text: '1.0');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Recalculate current template totals
            double totalCal = 0;
            double totalProt = 0;
            double totalCarbs = 0;
            double totalFats = 0;

            for (var sf in selectedFoods) {
              final Food food = sf['food'];
              final double qty = sf['quantity'];
              totalCal += food.calories * qty;
              totalProt += food.protein * qty;
              totalCarbs += food.carbohydrates * qty;
              totalFats += food.fats * qty;
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Compose Meal Template', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Template Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      DropdownButtonFormField<String>(
                        value: mealType,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Meal Type', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                        items: const [
                          DropdownMenuItem(value: 'BREAKFAST', child: Text('Breakfast')),
                          DropdownMenuItem(value: 'LUNCH', child: Text('Lunch')),
                          DropdownMenuItem(value: 'DINNER', child: Text('Dinner')),
                          DropdownMenuItem(value: 'SNACK', child: Text('Snack')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => mealType = v);
                        },
                      ),
                      TextField(
                        controller: descController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.white10),
                      const Text('Add Foods to Template', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButton<Food>(
                              hint: const Text('Select Food', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              dropdownColor: const Color(0xFF1E1E1E),
                              value: currentSelectedFood,
                              isExpanded: true,
                              items: _foods.map((food) {
                                return DropdownMenuItem<Food>(
                                  value: food,
                                  child: Text(food.foodName, style: const TextStyle(color: AppColors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (f) {
                                setDialogState(() => currentSelectedFood = f);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: qtyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.white),
                              decoration: const InputDecoration(hintText: 'Qty', hintStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.primaryFixed),
                            onPressed: () {
                              if (currentSelectedFood != null) {
                                final qty = double.tryParse(qtyController.text) ?? 1.0;
                                setDialogState(() {
                                  selectedFoods.add({
                                    'food': currentSelectedFood,
                                    'quantity': qty,
                                    'serving_unit': currentSelectedFood!.servingSize,
                                  });
                                  currentSelectedFood = null;
                                  qtyController.text = '1.0';
                                });
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (selectedFoods.isNotEmpty) ...[
                        const Text('Foods Summary:', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        const SizedBox(height: 4),
                        ...selectedFoods.map((sf) {
                          final Food f = sf['food'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${f.foodName} x ${sf['quantity']}', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                  onPressed: () {
                                    setDialogState(() => selectedFoods.remove(sf));
                                  },
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Text('Estimated Template Totals:', style: TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('${totalCal.toStringAsFixed(0)} kcal', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                Text('${totalProt.toStringAsFixed(1)}g P', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                Text('${totalCarbs.toStringAsFixed(1)}g C', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                Text('${totalFats.toStringAsFixed(1)}g F', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedFoods.isEmpty) return;
                    final templateData = {
                      'meal_name': nameController.text,
                      'meal_type': mealType,
                      'description': descController.text,
                      'meal_foods_write': selectedFoods.map((sf) => {
                        'food': sf['food'].id,
                        'quantity': sf['quantity'],
                        'serving_unit': sf['serving_unit'],
                      }).toList(),
                    };
                    final res = await _apiClient.createMealTemplate(templateData);
                    if (res.statusCode == 201) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal template composed successfully!')));
                      _loadAllData();
                    } else {
                      final body = jsonDecode(res.body);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${body['message'] ?? res.body}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                  child: const Text('Create', style: TextStyle(color: AppColors.onPrimaryFixed)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreatePlanDialog() async {
    final nameController = TextEditingController();
    String goal = 'FAT_LOSS';
    final descController = TextEditingController();
    final durController = TextEditingController(text: '7');
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();

    // Scheduling composition variables
    final List<Map<String, dynamic>> scheduledMeals = [];
    int activeScheduleDay = 1;
    MealTemplate? selectedTemplateForSchedule;
    int activeSequenceOrder = 1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Create Diet Plan', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Plan Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      DropdownButtonFormField<String>(
                        value: goal,
                        dropdownColor: const Color(0xFF1E1E1E),
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Goal', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                        items: const [
                          DropdownMenuItem(value: 'FAT_LOSS', child: Text('Fat Loss')),
                          DropdownMenuItem(value: 'MUSCLE_GAIN', child: Text('Muscle Gain')),
                          DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                          DropdownMenuItem(value: 'RECOVERY', child: Text('Recovery')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => goal = v);
                        },
                      ),
                      TextField(
                        controller: durController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Duration (Days)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      TextField(
                        controller: calController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Calories (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      TextField(
                        controller: protController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Protein (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      TextField(
                        controller: carbController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Carbs (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Target Fats (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      TextField(
                        controller: descController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.white10),
                      const Text('Schedule Day Meals', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButton<int>(
                              value: activeScheduleDay,
                              dropdownColor: const Color(0xFF1E1E1E),
                              items: List.generate(
                                int.tryParse(durController.text) ?? 7,
                                (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1}', style: const TextStyle(color: AppColors.white, fontSize: 12))),
                              ),
                              onChanged: (d) {
                                if (d != null) setDialogState(() => activeScheduleDay = d);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: DropdownButton<MealTemplate>(
                              hint: const Text('Template', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              dropdownColor: const Color(0xFF1E1E1E),
                              value: selectedTemplateForSchedule,
                              isExpanded: true,
                              items: _templates.map((temp) {
                                return DropdownMenuItem<MealTemplate>(
                                  value: temp,
                                  child: Text(temp.mealName, style: const TextStyle(color: AppColors.white, fontSize: 12), overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (t) {
                                setDialogState(() => selectedTemplateForSchedule = t);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: DropdownButton<int>(
                              value: activeSequenceOrder,
                              dropdownColor: const Color(0xFF1E1E1E),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Bfast', style: TextStyle(color: AppColors.white, fontSize: 11))),
                                DropdownMenuItem(value: 2, child: Text('Lunch', style: TextStyle(color: AppColors.white, fontSize: 11))),
                                DropdownMenuItem(value: 3, child: Text('Dinner', style: TextStyle(color: AppColors.white, fontSize: 11))),
                                DropdownMenuItem(value: 4, child: Text('Snack', style: TextStyle(color: AppColors.white, fontSize: 11))),
                              ],
                              onChanged: (s) {
                                if (s != null) setDialogState(() => activeSequenceOrder = s);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryFixed),
                            onPressed: () {
                              if (selectedTemplateForSchedule != null) {
                                setDialogState(() {
                                  scheduledMeals.add({
                                    'template': selectedTemplateForSchedule,
                                    'day_number': activeScheduleDay,
                                    'sequence_order': activeSequenceOrder,
                                  });
                                  selectedTemplateForSchedule = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (scheduledMeals.isNotEmpty) ...[
                        const Text('Scheduled Meals Summary:', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        const SizedBox(height: 4),
                        ...scheduledMeals.map((sm) {
                          final MealTemplate t = sm['template'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Day ${sm['day_number']}: ${t.mealName} (${sm['sequence_order'] == 1 ? "Bfast" : sm['sequence_order'] == 2 ? "Lunch" : sm['sequence_order'] == 3 ? "Dinner" : "Snack"})',
                                    style: const TextStyle(color: AppColors.white, fontSize: 12)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                  onPressed: () {
                                    setDialogState(() => scheduledMeals.remove(sm));
                                  },
                                )
                              ],
                            ),
                          );
                        }),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final planData = {
                      'plan_name': nameController.text,
                      'goal': goal,
                      'description': descController.text,
                      'duration_days': int.tryParse(durController.text) ?? 7,
                      'target_calories': int.tryParse(calController.text),
                      'target_protein': int.tryParse(protController.text),
                      'target_carbs': int.tryParse(carbController.text),
                      'target_fats': int.tryParse(fatController.text),
                      'status': 'ACTIVE',
                      'plan_meals_write': scheduledMeals.map((sm) => {
                        'meal_template': sm['template'].id,
                        'day_number': sm['day_number'],
                        'sequence_order': sm['sequence_order'],
                      }).toList(),
                    };
                    final res = await _apiClient.createDietPlan(planData);
                    if (res.statusCode == 201) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diet plan created successfully!')));
                      _loadAllData();
                    } else {
                      final body = jsonDecode(res.body);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${body['message'] ?? res.body}')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                  child: const Text('Create', style: TextStyle(color: AppColors.onPrimaryFixed)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete methods
  Future<void> _deleteFood(String id) async {
    final res = await _apiClient.deleteFood(id);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food soft-deleted successfully!')));
      _loadAllData();
    } else {
      final body = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Delete failed')));
    }
  }

  Future<void> _deleteTemplate(String id) async {
    final res = await _apiClient.deleteMealTemplate(id);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal template deleted successfully!')));
      _loadAllData();
    } else {
      final body = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Delete failed')));
    }
  }

  Future<void> _deletePlan(String id) async {
    final res = await _apiClient.deleteDietPlan(id);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diet plan soft-deleted successfully!')));
      _loadAllData();
    } else {
      final body = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['message'] ?? 'Delete failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.white), onPressed: () => context.pop()),
        title: const Text('DIET MANAGEMENT', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.white), onPressed: _loadAllData),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryFixed,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primaryFixed,
          tabs: const [
            Tab(text: 'Foods'),
            Tab(text: 'Templates'),
            Tab(text: 'Plans'),
            Tab(text: 'Assign'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading && _foods.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildFoodsTab(),
                  _buildTemplatesTab(),
                  _buildPlansTab(),
                  _buildAssignTab(),
                ],
              ),
      ),
    );
  }

  // ==== FOODS TAB ====
  Widget _buildFoodsTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        backgroundColor: AppColors.primaryFixed,
        child: const Icon(Icons.add, color: AppColors.onPrimaryFixed),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Search Food...',
                hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
              ),
              onChanged: (v) {
                setState(() => _foodSearch = v);
                _fetchFoods().then((_) => setState(() {}));
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _foods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final food = _foods[index];
                return ListTile(
                  tileColor: const Color(0xFF201F1F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(food.foodName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${food.category} • ${food.servingSize} • ${food.calories} kcal',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                        child: Text('${food.protein}g P', style: const TextStyle(color: AppColors.white, fontSize: 11)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteFood(food.id),
                      ),
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

  // ==== TEMPLATES TAB ====
  Widget _buildTemplatesTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTemplateDialog,
        backgroundColor: AppColors.primaryFixed,
        child: const Icon(Icons.add, color: AppColors.onPrimaryFixed),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _templates.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final temp = _templates[index];
          final cal = temp.calculatedMacros['calories'] ?? 0;
          final prot = temp.calculatedMacros['protein'] ?? 0.0;
          final carbs = temp.calculatedMacros['carbohydrates'] ?? 0.0;
          final fats = temp.calculatedMacros['fats'] ?? 0.0;

          return Card(
            color: const Color(0xFF201F1F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              title: Text(temp.mealName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${temp.mealType} • $cal kcal',
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteTemplate(temp.id),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(color: AppColors.white10),
                      const Text('Foods Summary:', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      ...temp.mealFoods.map((mf) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${mf.foodName} (${mf.category})', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                Text('${mf.quantity} ${mf.servingUnit}', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Prot: ${prot}g', style: const TextStyle(color: Color(0xFF4B8EFF), fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Carbs: ${carbs}g', style: const TextStyle(color: Color(0xFFCAF300), fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Fats: ${fats}g', style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ==== PLANS TAB ====
  Widget _buildPlansTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        backgroundColor: AppColors.primaryFixed,
        child: const Icon(Icons.add, color: AppColors.onPrimaryFixed),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _plans.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final cal = plan.targetCalories;
          final duration = plan.durationDays;

          return Card(
            color: const Color(0xFF201F1F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              title: Text(plan.planName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Goal: ${plan.goal} • Target: $cal kcal • $duration Days',
                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deletePlan(plan.id),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (plan.description != null && plan.description!.isNotEmpty) ...[
                        Text(plan.description!, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        const SizedBox(height: 8),
                      ],
                      const Divider(color: AppColors.white10),
                      const Text('Schedule Builder overview:', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      ...plan.planMeals.map((pm) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Day ${pm.dayNumber}: ${pm.mealTemplate.mealName}', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                Text('Slot ${pm.sequenceOrder}', style: const TextStyle(color: AppColors.white, fontSize: 12)),
                              ],
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ==== ASSIGN TAB ====
  Widget _buildAssignTab() {
    Member? selectedMember;
    DietPlan? selectedPlan;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    final notesController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setAssignState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Assign Diet Plan to Member', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Member>(
                      hint: const Text('Select Member', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      value: selectedMember,
                      dropdownColor: const Color(0xFF201F1F),
                      style: const TextStyle(color: AppColors.white),
                      items: _members.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m.fullName));
                      }).toList(),
                      onChanged: (m) {
                        setAssignState(() => selectedMember = m);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DietPlan>(
                      hint: const Text('Select Diet Plan', style: TextStyle(color: AppColors.onSurfaceVariant)),
                      value: selectedPlan,
                      dropdownColor: const Color(0xFF201F1F),
                      style: const TextStyle(color: AppColors.white),
                      items: _plans.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p.planName));
                      }).toList(),
                      onChanged: (p) {
                        setAssignState(() => selectedPlan = p);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setAssignState(() => startDate = picked);
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.white10),
                                child: Text('${startDate.year}-${startDate.month}-${startDate.day}', style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setAssignState(() => endDate = picked);
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.white10),
                                child: Text('${endDate.year}-${endDate.month}-${endDate.day}', style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Special Notes', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedMember == null || selectedPlan == null) return;
                        final body = {
                          'member': int.tryParse(selectedMember!.id) ?? selectedMember!.id,
                          'diet_plan': selectedPlan!.id,
                          'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
                          'end_date': '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
                          'notes': notesController.text,
                        };
                        final res = await _apiClient.assignDietPlan(body);
                        if (res.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan assigned successfully!')));
                          notesController.clear();
                          _loadAllData();
                        } else {
                          final resBody = jsonDecode(res.body);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${resBody['message'] ?? res.body}'), backgroundColor: Colors.redAccent));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Submit Assignment', style: TextStyle(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Active Gym Assignments', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 16),
              ..._assignments.map((a) {
                return Card(
                  color: const Color(0xFF201F1F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(a.memberName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Plan: ${a.planName}\nUntil: ${a.endDate} (${a.status})', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    trailing: const Icon(Icons.assignment_ind, color: AppColors.primaryFixed),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// Inline Helper model to parse assignment structure from backend
class DietAssignmentModel {
  final String id;
  final String memberName;
  final String planName;
  final String startDate;
  final String endDate;
  final String status;

  DietAssignmentModel({
    required this.id,
    required this.memberName,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory DietAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DietAssignmentModel(
      id: json['id']?.toString() ?? '',
      memberName: json['member_name'] ?? '',
      planName: json['plan_name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }
}
