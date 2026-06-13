from django.db.models import Sum, Count, Q
from datetime import date, datetime
from django.utils import timezone
from .models import Food, MealTemplate, MealFood, DietPlan, DietPlanMeal, MemberDietPlan, DietLog
from members.models import Member
from trainers.models import Trainer
from decimal import Decimal

class NutritionEngine:
    @staticmethod
    def calculate_meal_macros(meal_template):
        """
        Calculate total calories, protein, carbs, fats, and fiber for a meal template.
        """
        totals = {
            'calories': 0,
            'protein': 0.0,
            'carbohydrates': 0.0,
            'fats': 0.0,
            'fiber': 0.0
        }
        
        # Prefetch or select related foods
        meal_foods = meal_template.meal_foods.select_related('food')
        for mf in meal_foods:
            qty = mf.quantity
            totals['calories'] += int(mf.food.calories * qty)
            totals['protein'] += float(mf.food.protein) * qty
            totals['carbohydrates'] += float(mf.food.carbohydrates) * qty
            totals['fats'] += float(mf.food.fats) * qty
            totals['fiber'] += float(mf.food.fiber) * qty
            
        # Round decimals
        totals['protein'] = round(totals['protein'], 1)
        totals['carbohydrates'] = round(totals['carbohydrates'], 1)
        totals['fats'] = round(totals['fats'], 1)
        totals['fiber'] = round(totals['fiber'], 1)
        
        return totals

    @staticmethod
    def get_diet_plan_daily_macros(diet_plan):
        """
        Calculate macro totals for each day in a diet plan.
        Returns a dict: {day_number: {calories, protein, carbs, fats, fiber}}
        """
        daily_macros = {}
        for day in range(1, diet_plan.duration_days + 1):
            daily_macros[day] = {
                'calories': 0,
                'protein': 0.0,
                'carbohydrates': 0.0,
                'fats': 0.0,
                'fiber': 0.0
            }
            
        plan_meals = diet_plan.plan_meals.select_related('meal_template').prefetch_related('meal_template__meal_foods__food')
        for pm in plan_meals:
            day = pm.day_number
            if day not in daily_macros:
                daily_macros[day] = {
                    'calories': 0,
                    'protein': 0.0,
                    'carbohydrates': 0.0,
                    'fats': 0.0,
                    'fiber': 0.0
                }
            meal_totals = NutritionEngine.calculate_meal_macros(pm.meal_template)
            daily_macros[day]['calories'] += meal_totals['calories']
            daily_macros[day]['protein'] += meal_totals['protein']
            daily_macros[day]['carbohydrates'] += meal_totals['carbohydrates']
            daily_macros[day]['fats'] += meal_totals['fats']
            daily_macros[day]['fiber'] += meal_totals['fiber']
            
        # Round all values
        for day in daily_macros:
            daily_macros[day]['protein'] = round(daily_macros[day]['protein'], 1)
            daily_macros[day]['carbohydrates'] = round(daily_macros[day]['carbohydrates'], 1)
            daily_macros[day]['fats'] = round(daily_macros[day]['fats'], 1)
            daily_macros[day]['fiber'] = round(daily_macros[day]['fiber'], 1)
            
        return daily_macros

    @staticmethod
    def get_diet_plan_average_daily_macros(diet_plan):
        """
        Get the average daily calories, protein, carbs, fats, and fiber of a diet plan.
        """
        daily_macros = NutritionEngine.get_diet_plan_daily_macros(diet_plan)
        duration = max(1, diet_plan.duration_days)
        
        avg = {
            'calories': 0,
            'protein': 0.0,
            'carbohydrates': 0.0,
            'fats': 0.0,
            'fiber': 0.0
        }
        
        for macros in daily_macros.values():
            avg['calories'] += macros['calories']
            avg['protein'] += macros['protein']
            avg['carbohydrates'] += macros['carbohydrates']
            avg['fats'] += macros['fats']
            avg['fiber'] += macros['fiber']
            
        avg['calories'] = int(avg['calories'] / duration)
        avg['protein'] = round(avg['protein'] / duration, 1)
        avg['carbohydrates'] = round(avg['carbohydrates'] / duration, 1)
        avg['fats'] = round(avg['fats'] / duration, 1)
        avg['fiber'] = round(avg['fiber'] / duration, 1)
        
        return avg

    @staticmethod
    def get_member_diet_progress_stats(member, assigned_diet):
        """
        Returns compliance metrics, remaining and consumed macros for a member's assigned diet.
        """
        today = timezone.localdate()
        
        # 1. Total meals in the active plan
        total_plan_meals = DietPlanMeal.objects.filter(diet_plan=assigned_diet.diet_plan).count()
        
        # 2. Number of completed and skipped logs
        logs = DietLog.objects.filter(assigned_diet=assigned_diet)
        completed_count = logs.filter(completed=True).count()
        skipped_count = logs.filter(completed=False).count()
        
        compliance_pct = 0.0
        if total_plan_meals > 0:
            compliance_pct = round((completed_count / total_plan_meals) * 100.0, 1)
            
        # 3. Target macros for "today"
        # Determine day number: (today - start_date).days + 1
        day_number = (today - assigned_diet.start_date).days + 1
        
        # Default fallback to average target macros of diet plan
        avg_target = NutritionEngine.get_diet_plan_average_daily_macros(assigned_diet.diet_plan)
        target_calories = assigned_diet.diet_plan.target_calories or avg_target['calories']
        target_protein = assigned_diet.diet_plan.target_protein or avg_target['protein']
        target_carbs = assigned_diet.diet_plan.target_carbs or avg_target['carbohydrates']
        target_fats = assigned_diet.diet_plan.target_fats or avg_target['fats']
        
        # If active day is in range, get specific day's meals
        today_meals = []
        if 1 <= day_number <= assigned_diet.diet_plan.duration_days:
            today_meals = DietPlanMeal.objects.filter(
                diet_plan=assigned_diet.diet_plan,
                day_number=day_number
            ).select_related('meal_template').prefetch_related('meal_template__meal_foods__food')
            
            # Recalculate today's target if meals are defined
            if today_meals.exists():
                cal_sum = 0
                prot_sum = 0.0
                carb_sum = 0.0
                fat_sum = 0.0
                for m in today_meals:
                    m_totals = NutritionEngine.calculate_meal_macros(m.meal_template)
                    cal_sum += m_totals['calories']
                    prot_sum += m_totals['protein']
                    carb_sum += m_totals['carbohydrates']
                    fat_sum += m_totals['fats']
                target_calories = cal_sum
                target_protein = int(prot_sum)
                target_carbs = int(carb_sum)
                target_fats = int(fat_sum)
                
        # 4. Consumed macros today
        today_logs = DietLog.objects.filter(
            assigned_diet=assigned_diet,
            completed=True,
            created_at__date=today
        ).select_related('meal__meal_template').prefetch_related('meal__meal_template__meal_foods__food')
        
        consumed_calories = 0
        consumed_protein = 0.0
        consumed_carbs = 0.0
        consumed_fats = 0.0
        
        for l in today_logs:
            m_totals = NutritionEngine.calculate_meal_macros(l.meal.meal_template)
            consumed_calories += m_totals['calories']
            consumed_protein += m_totals['protein']
            consumed_carbs += m_totals['carbohydrates']
            consumed_fats += m_totals['fats']
            
        remaining_calories = max(0, target_calories - consumed_calories)
        
        return {
            'compliance_percentage': compliance_pct,
            'target_calories': target_calories,
            'target_protein': target_protein,
            'target_carbs': target_carbs,
            'target_fats': target_fats,
            'consumed_calories': consumed_calories,
            'consumed_protein': round(consumed_protein, 1),
            'consumed_carbs': round(consumed_carbs, 1),
            'consumed_fats': round(consumed_fats, 1),
            'remaining_calories': remaining_calories,
            'completed_meals_count': completed_count,
            'skipped_meals_count': skipped_count,
            'total_plan_meals': total_plan_meals,
            'current_day_number': day_number if (1 <= day_number <= assigned_diet.diet_plan.duration_days) else None
        }


class DietService:
    @staticmethod
    def get_trainer_dashboard_stats(trainer):
        """
        Get dashboard metrics for trainer.
        """
        gym = trainer.gym
        active_assignments = MemberDietPlan.objects.filter(assigned_by=trainer, status='ACTIVE')
        active_members_count = active_assignments.values('member').distinct().count()
        total_plans_count = DietPlan.objects.filter(trainer=trainer, is_deleted=False).count()
        
        # Calculate overall compliance percentage for all members under trainer
        total_meals = 0
        completed_meals = 0
        
        for assignment in active_assignments:
            meals_count = DietPlanMeal.objects.filter(diet_plan=assignment.diet_plan).count()
            total_meals += meals_count
            completed_meals += DietLog.objects.filter(assigned_diet=assignment, completed=True).count()
            
        compliance_pct = 0.0
        if total_meals > 0:
            compliance_pct = round((completed_meals / total_meals) * 100.0, 1)
            
        # Top compliance members list
        top_performers = []
        for assignment in active_assignments[:5]:
            stats = NutritionEngine.get_member_diet_progress_stats(assignment.member, assignment)
            top_performers.append({
                'member_id': assignment.member.id,
                'member_name': assignment.member.full_name,
                'compliance': stats['compliance_percentage']
            })
            
        top_performers = sorted(top_performers, key=lambda x: x['compliance'], reverse=True)
            
        return {
            'active_diet_plans_count': total_plans_count,
            'assigned_members_count': active_members_count,
            'overall_compliance_percentage': compliance_pct,
            'completed_meals_count': completed_meals,
            'top_performing_members': top_performers
        }

    @staticmethod
    def get_owner_dashboard_stats(gym):
        """
        Get dashboard metrics for gym owner.
        """
        active_assignments = MemberDietPlan.objects.filter(member__gym=gym, status='ACTIVE')
        total_assignments_count = MemberDietPlan.objects.filter(member__gym=gym).count()
        total_plans_count = DietPlan.objects.filter(gym=gym, is_deleted=False).count()
        
        total_meals = 0
        completed_meals = 0
        for assignment in active_assignments:
            meals_count = DietPlanMeal.objects.filter(diet_plan=assignment.diet_plan).count()
            total_meals += meals_count
            completed_meals += DietLog.objects.filter(assigned_diet=assignment, completed=True).count()
            
        compliance_pct = 0.0
        if total_meals > 0:
            compliance_pct = round((completed_meals / total_meals) * 100.0, 1)
            
        return {
            'active_diet_plans_count': total_plans_count,
            'total_diet_assignments_count': total_assignments_count,
            'active_diet_assignments_count': active_assignments.count(),
            'overall_compliance_percentage': compliance_pct
        }
