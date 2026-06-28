import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ----------------------------------------------------
// NUTRITION PROFILE PROVIDER
// ----------------------------------------------------
class NutritionProfileState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? profile;

  NutritionProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
  });

  NutritionProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? profile,
  }) {
    return NutritionProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
    );
  }
}

class NutritionProfileNotifier extends StateNotifier<NutritionProfileState> {
  final ApiClient _apiClient;
  NutritionProfileNotifier(this._apiClient) : super(NutritionProfileState()) {
    // Optionally auto-load or fetch on demand
  }

  Future<bool> setupProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiClient.generatePlan(data);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        state = state.copyWith(isLoading: false, profile: body['data']);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Failed to setup plan');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final nutritionProfileProvider = StateNotifierProvider<NutritionProfileNotifier, NutritionProfileState>((ref) {
  return NutritionProfileNotifier(ref.watch(apiClientProvider));
});


// ----------------------------------------------------
// MEAL PLAN STATE PROVIDER
// ----------------------------------------------------
class MealPlanState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? meals; // contains breakfast, lunch, dinner, etc.

  MealPlanState({
    this.isLoading = false,
    this.errorMessage,
    this.meals,
  });

  MealPlanState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? meals,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      meals: meals ?? this.meals,
    );
  }
}

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final ApiClient _apiClient;
  MealPlanNotifier(this._apiClient) : super(MealPlanState());

  Future<void> fetchMeals(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiClient.generateMeals(profileData);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        state = state.copyWith(isLoading: false, meals: body['data']);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Failed to generate meals');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> regenerateSingleMeal(String mealKey, Map<String, dynamic> profileData) async {
    // Regenerates only one meal slot (e.g. breakfast) by re-calling API and blending the new result.
    if (state.meals == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiClient.generateMeals(profileData);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final newMeals = Map<String, dynamic>.from(state.meals!);
        if (body['data'] != null && body['data'][mealKey] != null) {
          newMeals[mealKey] = body['data'][mealKey];
        }
        state = state.copyWith(isLoading: false, meals: newMeals);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Failed to regenerate meal');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
  return MealPlanNotifier(ref.watch(apiClientProvider));
});


// ----------------------------------------------------
// GROCERY LIST STATE PROVIDER
// ----------------------------------------------------
class GroceryListState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? groceryData; // daily/weekly/monthly grouped list

  GroceryListState({
    this.isLoading = false,
    this.errorMessage,
    this.groceryData,
  });

  GroceryListState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? groceryData,
  }) {
    return GroceryListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      groceryData: groceryData ?? this.groceryData,
    );
  }
}

class GroceryListNotifier extends StateNotifier<GroceryListState> {
  final ApiClient _apiClient;
  GroceryListNotifier(this._apiClient) : super(GroceryListState());

  Future<void> fetchGroceryList(Map<String, dynamic> meals, String duration) async {
    state = state.copyWith(isLoading: true);
    try {
      final payload = {
        'meal_plan': jsonEncode(meals),
        'duration': duration,
      };
      final res = await _apiClient.getGroceryList(payload);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        state = state.copyWith(isLoading: false, groceryData: body['data']);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Failed to generate grocery list');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final groceryListProvider = StateNotifierProvider<GroceryListNotifier, GroceryListState>((ref) {
  return GroceryListNotifier(ref.watch(apiClientProvider));
});


// ----------------------------------------------------
// DIET COMPLIANCE PROVIDER
// ----------------------------------------------------
class DietComplianceState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? complianceData;

  DietComplianceState({
    this.isLoading = false,
    this.errorMessage,
    this.complianceData,
  });

  DietComplianceState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? complianceData,
  }) {
    return DietComplianceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      complianceData: complianceData ?? this.complianceData,
    );
  }
}

class DietComplianceNotifier extends StateNotifier<DietComplianceState> {
  final ApiClient _apiClient;
  DietComplianceNotifier(this._apiClient) : super(DietComplianceState());

  Future<void> fetchCompliance(String period) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiClient.getDietCompliance(period);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        state = state.copyWith(isLoading: false, complianceData: body['data']);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: body['message'] ?? 'Failed to load compliance details');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> logDietMeal(Map<String, dynamic> logPayload, String period) async {
    try {
      final res = await _apiClient.logDiet(logPayload);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        await fetchCompliance(period);
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final dietComplianceProvider = StateNotifierProvider<DietComplianceNotifier, DietComplianceState>((ref) {
  return DietComplianceNotifier(ref.watch(apiClientProvider));
});


// ----------------------------------------------------
// DIET COACH PROVIDER
// ----------------------------------------------------
class CoachMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  CoachMessage({required this.text, required this.isUser, required this.timestamp});
}

class DietCoachState {
  final bool isTyping;
  final List<CoachMessage> messages;

  DietCoachState({this.isTyping = false, this.messages = const []});

  DietCoachState copyWith({bool? isTyping, List<CoachMessage>? messages}) {
    return DietCoachState(
      isTyping: isTyping ?? this.isTyping,
      messages: messages ?? this.messages,
    );
  }
}

class DietCoachNotifier extends StateNotifier<DietCoachState> {
  final ApiClient _apiClient;
  DietCoachNotifier(this._apiClient) : super(DietCoachState(messages: [
    CoachMessage(
      text: "Namaste! I'm NutriCoach, your personal AI sports nutritionist. Ask me anything about Indian food swaps, workout meals, macros, or diet goals!",
      isUser: false,
      timestamp: DateTime.now()
    )
  ]));

  Future<void> sendMessage(String text, Map<String, dynamic> context) async {
    final userMsg = CoachMessage(text: text, isUser: true, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, userMsg], isTyping: true);

    try {
      final res = await _apiClient.chatDietCoach(text, context);
      final body = jsonDecode(res.body);
      state = state.copyWith(isTyping: false);
      if (res.statusCode == 200 && body['success'] == true) {
        final coachMsg = CoachMessage(
          text: body['data']['reply'] ?? "I'm sorry, I couldn't generate a reply.",
          isUser: false,
          timestamp: DateTime.now()
        );
        state = state.copyWith(messages: [...state.messages, coachMsg]);
      } else {
        final errMsg = CoachMessage(
          text: "Sorry, I had trouble connecting. Let's try again in a bit.",
          isUser: false,
          timestamp: DateTime.now()
        );
        state = state.copyWith(messages: [...state.messages, errMsg]);
      }
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        messages: [
          ...state.messages,
          CoachMessage(text: "Error: ${e.toString()}", isUser: false, timestamp: DateTime.now())
        ]
      );
    }
  }
}

final dietCoachProvider = StateNotifierProvider<DietCoachNotifier, DietCoachState>((ref) {
  return DietCoachNotifier(ref.watch(apiClientProvider));
});
