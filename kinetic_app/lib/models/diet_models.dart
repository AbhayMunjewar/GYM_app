class Food {
  final String id;
  final String foodName;
  final String category;
  final String servingSize;
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fats;
  final double fiber;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  Food({
    required this.id,
    required this.foodName,
    required this.category,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
    required this.fiber,
    this.description,
    this.imageUrl,
    required this.isActive,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      category: json['category'] ?? '',
      servingSize: json['serving_size'] ?? '',
      calories: json['calories'] ?? 0,
      protein: double.tryParse(json['protein']?.toString() ?? '') ?? 0.0,
      carbohydrates: double.tryParse(json['carbohydrates']?.toString() ?? '') ?? 0.0,
      fats: double.tryParse(json['fats']?.toString() ?? '') ?? 0.0,
      fiber: double.tryParse(json['fiber']?.toString() ?? '') ?? 0.0,
      description: json['description'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_name': foodName,
      'category': category,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'fiber': fiber,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}

class MealFood {
  final String id;
  final String foodId;
  final String foodName;
  final String category;
  final double quantity;
  final String servingUnit;
  final int caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatsPerServing;

  MealFood({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.servingUnit,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatsPerServing,
  });

  factory MealFood.fromJson(Map<String, dynamic> json) {
    return MealFood(
      id: json['id']?.toString() ?? '',
      foodId: json['food']?.toString() ?? '',
      foodName: json['food_name'] ?? '',
      category: json['category'] ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 1.0,
      servingUnit: json['serving_unit'] ?? 'g',
      caloriesPerServing: json['calories_per_serving'] ?? 0,
      proteinPerServing: double.tryParse(json['protein_per_serving']?.toString() ?? '') ?? 0.0,
      carbsPerServing: double.tryParse(json['carbs_per_serving']?.toString() ?? '') ?? 0.0,
      fatsPerServing: double.tryParse(json['fats_per_serving']?.toString() ?? '') ?? 0.0,
    );
  }
}

class MealTemplate {
  final String id;
  final String trainerId;
  final String trainerName;
  final String mealName;
  final String mealType;
  final String? description;
  final List<MealFood> mealFoods;
  final Map<String, dynamic> calculatedMacros;

  MealTemplate({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.mealName,
    required this.mealType,
    this.description,
    required this.mealFoods,
    required this.calculatedMacros,
  });

  factory MealTemplate.fromJson(Map<String, dynamic> json) {
    var list = json['meal_foods'] as List? ?? [];
    return MealTemplate(
      id: json['id']?.toString() ?? '',
      trainerId: json['trainer']?.toString() ?? '',
      trainerName: json['trainer_name'] ?? '',
      mealName: json['meal_name'] ?? '',
      mealType: json['meal_type'] ?? '',
      description: json['description'],
      mealFoods: list.map((item) => MealFood.fromJson(item)).toList(),
      calculatedMacros: json['calculated_macros'] ?? {},
    );
  }
}

class DietPlanMeal {
  final String id;
  final MealTemplate mealTemplate;
  final int dayNumber;
  final int sequenceOrder;

  DietPlanMeal({
    required this.id,
    required this.mealTemplate,
    required this.dayNumber,
    required this.sequenceOrder,
  });

  factory DietPlanMeal.fromJson(Map<String, dynamic> json) {
    return DietPlanMeal(
      id: json['id']?.toString() ?? '',
      mealTemplate: MealTemplate.fromJson(json['meal_template'] ?? {}),
      dayNumber: json['day_number'] ?? 1,
      sequenceOrder: json['sequence_order'] ?? 1,
    );
  }
}

class DietPlan {
  final String id;
  final String trainerId;
  final String trainerName;
  final String gymId;
  final String gymName;
  final String planName;
  final String goal;
  final String? description;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFats;
  final int durationDays;
  final String status;
  final List<DietPlanMeal> planMeals;
  final Map<String, dynamic> calculatedAverageMacros;

  DietPlan({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.gymId,
    required this.gymName,
    required this.planName,
    required this.goal,
    this.description,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.durationDays,
    required this.status,
    required this.planMeals,
    required this.calculatedAverageMacros,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    var list = json['plan_meals'] as List? ?? [];
    return DietPlan(
      id: json['id']?.toString() ?? '',
      trainerId: json['trainer']?.toString() ?? '',
      trainerName: json['trainer_name'] ?? '',
      gymId: json['gym']?.toString() ?? '',
      gymName: json['gym_name'] ?? '',
      planName: json['plan_name'] ?? '',
      goal: json['goal'] ?? '',
      description: json['description'],
      targetCalories: json['target_calories'] ?? 0,
      targetProtein: json['target_protein'] ?? 0,
      targetCarbs: json['target_carbs'] ?? 0,
      targetFats: json['target_fats'] ?? 0,
      durationDays: json['duration_days'] ?? 7,
      status: json['status'] ?? 'DRAFT',
      planMeals: list.map((item) => DietPlanMeal.fromJson(item)).toList(),
      calculatedAverageMacros: json['calculated_average_macros'] ?? {},
    );
  }
}

class DietAssignment {
  final String id;
  final int memberId;
  final String memberName;
  final String dietPlanId;
  final String planName;
  final String assignedById;
  final String assignedByName;
  final String assignedDate;
  final String startDate;
  final String endDate;
  final String status;
  final String? notes;

  DietAssignment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.dietPlanId,
    required this.planName,
    required this.assignedById,
    required this.assignedByName,
    required this.assignedDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
  });

  factory DietAssignment.fromJson(Map<String, dynamic> json) {
    return DietAssignment(
      id: json['id']?.toString() ?? '',
      memberId: json['member'] is int ? json['member'] : int.tryParse(json['member']?.toString() ?? '') ?? 0,
      memberName: json['member_name'] ?? '',
      dietPlanId: json['diet_plan']?.toString() ?? '',
      planName: json['plan_name'] ?? '',
      assignedById: json['assigned_by']?.toString() ?? '',
      assignedByName: json['assigned_by_name'] ?? '',
      assignedDate: json['assigned_date'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      notes: json['notes'],
    );
  }
}

class DietProgress {
  final double compliancePercentage;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFats;
  final int consumedCalories;
  final double consumedProtein;
  final double consumedCarbs;
  final double consumedFats;
  final int remainingCalories;
  final int completedMealsCount;
  final int skippedMealsCount;
  final int totalPlanMeals;
  final int? currentDayNumber;

  DietProgress({
    required this.compliancePercentage,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedCarbs,
    required this.consumedFats,
    required this.remainingCalories,
    required this.completedMealsCount,
    required this.skippedMealsCount,
    required this.totalPlanMeals,
    this.currentDayNumber,
  });

  factory DietProgress.fromJson(Map<String, dynamic> json) {
    return DietProgress(
      compliancePercentage: double.tryParse(json['compliance_percentage']?.toString() ?? '') ?? 0.0,
      targetCalories: json['target_calories'] ?? 0,
      targetProtein: json['target_protein'] ?? 0,
      targetCarbs: json['target_carbs'] ?? 0,
      targetFats: json['target_fats'] ?? 0,
      consumedCalories: json['consumed_calories'] ?? 0,
      consumedProtein: double.tryParse(json['consumed_protein']?.toString() ?? '') ?? 0.0,
      consumedCarbs: double.tryParse(json['consumed_carbs']?.toString() ?? '') ?? 0.0,
      consumedFats: double.tryParse(json['consumed_fats']?.toString() ?? '') ?? 0.0,
      remainingCalories: json['remaining_calories'] ?? 0,
      completedMealsCount: json['completed_meals_count'] ?? 0,
      skippedMealsCount: json['skipped_meals_count'] ?? 0,
      totalPlanMeals: json['total_plan_meals'] ?? 0,
      currentDayNumber: json['current_day_number'],
    );
  }
}
