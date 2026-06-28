from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.shortcuts import get_object_or_404
from django.utils import timezone
from datetime import timedelta

from core.responses import success_response, failure_response
from members.models import Member
from .services.nutrition_calculator import calculate_nutrition
from .services.ai_nutrition_service import call_nutrition_ai, call_coach
from .models import NutritionProfile, DietLog

class GeneratePlanView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        member = get_object_or_404(Member, email=request.user.email)
        data = request.data
        
        # Calculate targets using Mifflin-St Jeor BMR/TDEE formula
        try:
            targets = calculate_nutrition(data)
        except KeyError as e:
            return failure_response(f"Missing required input parameter: {str(e)}", status_code=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return failure_response(f"Error calculating nutrition metrics: {str(e)}", status_code=status.HTTP_400_BAD_REQUEST)

        # Map to save NutritionProfile matching model keys
        profile_data = {
            'goal': data.get('goal', 'maintenance'),
            'age': int(data.get('age', 25)),
            'height_cm': float(data.get('height_cm', 170.0)),
            'weight_kg': float(data.get('weight_kg', 70.0)),
            'gender': data.get('gender', 'Male'),
            'activity_level': data.get('activity_level', 'moderately_active'),
            'workout_days_per_week': int(data.get('workout_days_per_week', 3)),
            'budget_inr': int(data.get('budget_inr', 250)),
            'food_preference': data.get('food_preference', 'veg'),
            'allergies': data.get('allergies', ''),
            'medical_restrictions': data.get('medical_restrictions', '')
        }

        profile, _ = NutritionProfile.objects.update_or_create(
            member=member,
            defaults={**profile_data, **targets}
        )
        return success_response("Nutrition targets calculated and profile updated successfully", data=targets)


class GenerateMealsView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data
        system = (
            "You are a certified sports nutritionist AI for an Indian gym management app. "
            "Generate a full day meal plan strictly in JSON. "
            "Respect food preferences (veg/non-veg/vegan/eggetarian), allergies, medical restrictions, "
            "budget in INR per day, and macro targets. Use realistic Indian food items "
            "(dal, roti, rice, paneer, curd, eggs, chicken, sabzi, sprouts, etc.). "
            "Return ONLY valid JSON, no markdown, no extra text."
        )
        user = (
            f"Target: {data.get('target_calories')} kcal | Protein: {data.get('protein_g')}g | "
            f"Carbs: {data.get('carbs_g')}g | Fat: {data.get('fat_g')}g\n"
            f"Budget: ₹{data.get('budget_inr')}/day | Preference: {data.get('food_preference')} | "
            f"Allergies: {data.get('allergies','none')}\n"
            f"Goal: {data.get('goal')} | Workout days: {data.get('workout_days_per_week')}/week\n\n"
            "Generate meals: breakfast, lunch, dinner, snacks (morning + evening), pre_workout, post_workout.\n"
            "Each meal: { name, items: [{food, quantity, calories, protein_g, carbs_g, fat_g, cost_inr}], total_calories, total_protein_g }"
        )
        result = call_nutrition_ai(system, user, max_tokens=2000)
        return success_response("Meal plan generated successfully", data=result)


class GroceryListView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        meal_plan = request.data.get('meal_plan')
        duration = request.data.get('duration', 'weekly')  # daily/weekly/monthly

        system = (
            "You are a nutritionist assistant. Generate a consolidated grocery list from a meal plan. "
            "Return ONLY valid JSON, no markdown."
        )
        user = (
            f"From this meal plan, generate a grocery list for {duration}.\n"
            f"Meal Plan: {meal_plan}\n"
            "Group by category: Proteins, Vegetables, Grains & Cereals, Dairy, Fruits, Condiments & Spices.\n"
            "Each item: { name, quantity, unit, estimated_cost_inr }\n"
            "Also include: total_estimated_cost_inr"
        )
        result = call_nutrition_ai(system, user, max_tokens=1500)
        return success_response("Grocery list generated successfully", data=result)


class FoodReplacementView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data
        system = (
            "You are a sports nutritionist. Suggest Indian food replacements. "
            "Return ONLY valid JSON array, no markdown."
        )
        user = (
            f"Suggest 3 Indian food replacements for: {data.get('original_food')}\n"
            f"Reason: {data.get('reason')} | Preference: {data.get('preference')} | Goal: {data.get('goal')}\n"
            "For each: { food, quantity_per_100g_equivalent, calories, protein_g, carbs_g, fat_g, similarity_score, notes }"
        )
        result = call_nutrition_ai(system, user, max_tokens=800)
        return success_response("Replacement alternatives retrieved successfully", data=result)


class DietLogView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        member = get_object_or_404(Member, email=request.user.email)
        data = request.data
        
        # Support either string or date object
        log_date = data.get('log_date')
        if not log_date:
            log_date = timezone.now().date()
            
        log, _ = DietLog.objects.update_or_create(
            member=member,
            log_date=log_date,
            defaults={
                'breakfast_done': data.get('breakfast_done', False),
                'lunch_done': data.get('lunch_done', False),
                'dinner_done': data.get('dinner_done', False),
                'snacks_done': data.get('snacks_done', False),
                'pre_workout_done': data.get('pre_workout_done', False),
                'post_workout_done': data.get('post_workout_done', False),
                'calories_consumed': int(data.get('calories_consumed', 0)),
                'protein_consumed_g': int(data.get('protein_consumed_g', 0)),
                'notes': data.get('notes', ''),
            }
        )
        
        # Trigger gamification events if available
        try:
            completed_meals = sum([
                log.breakfast_done, log.lunch_done, log.dinner_done, 
                log.snacks_done, log.pre_workout_done, log.post_workout_done
            ])
            if completed_meals > 0:
                from gamification.services import GamificationEngine, ActivityType
                GamificationEngine.trigger_event(member, ActivityType.DIET_COMPLETION, reference_id=log.id)
        except Exception:
            pass
            
        return success_response("Diet meal tracked successfully", data={'status': 'logged', 'date': str(log.log_date)})


class ComplianceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        member = get_object_or_404(Member, email=request.user.email)
        period = request.query_params.get('period', 'weekly')
        days = 7 if period == 'weekly' else 30
        since = timezone.now().date() - timedelta(days=days)

        logs = DietLog.objects.filter(member=member, log_date__gte=since)
        total_logged = logs.count()
        if total_logged == 0:
            return success_response("No compliance history found", data={
                'compliance_score': 0,
                'days_logged': 0,
                'period': period,
                'total_days': days,
                'avg_calories': 0,
                'avg_protein_g': 0,
                'meal_completion_rate': 0.0,
                'protein_target_hit_days': 0,
            })

        meal_fields = ['breakfast_done', 'lunch_done', 'dinner_done', 'snacks_done', 'pre_workout_done', 'post_workout_done']
        total_meals_possible = total_logged * len(meal_fields)
        meals_done = sum(getattr(log, f) for log in logs for f in meal_fields)

        avg_calories = sum(l.calories_consumed for l in logs) // total_logged
        avg_protein = sum(l.protein_consumed_g for l in logs) // total_logged

        profile = getattr(member, 'nutrition_profile', None)
        protein_target_hit = 0
        if profile and profile.protein_g:
            protein_target_hit = sum(1 for l in logs if l.protein_consumed_g >= profile.protein_g * 0.9)

        compliance_score = int((meals_done / total_meals_possible) * 100)

        # Assemble logs details for TableCalendar display in Flutter
        logs_detail = {}
        for l in logs:
            logs_detail[str(l.log_date)] = {
                'breakfast': l.breakfast_done,
                'lunch': l.lunch_done,
                'dinner': l.dinner_done,
                'snacks': l.snacks_done,
                'pre_workout': l.pre_workout_done,
                'post_workout': l.post_workout_done,
                'compliance_pct': int((sum(getattr(l, f) for f in meal_fields) / len(meal_fields)) * 100)
            }

        return success_response("Compliance stats retrieved successfully", data={
            'period': period,
            'total_days': days,
            'days_logged': total_logged,
            'avg_calories': avg_calories,
            'avg_protein_g': avg_protein,
            'meal_completion_rate': round(meals_done / total_meals_possible, 2),
            'protein_target_hit_days': protein_target_hit,
            'compliance_score': compliance_score,
            'logs_detail': logs_detail
        })


class DietCoachView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        message = request.data.get('message', '')
        ctx = request.data.get('member_context', {})

        system = (
            "You are NutriCoach, an AI-powered sports nutritionist in an Indian gym app. "
            "You specialize in Indian foods, budget-friendly nutrition, muscle building, and fat loss. "
            f"Member context: {ctx}. "
            "Answer concisely in max 150 words. Use Indian food examples. "
            "If question involves disease or medication, always say: 'Please consult your doctor.' "
            "Never prescribe supplements without disclaimer."
        )
        response = call_coach(
            system_prompt=system,
            user_prompt=message,
            max_tokens=300
        )
        return success_response("Coach response retrieved successfully", data={'reply': response})
