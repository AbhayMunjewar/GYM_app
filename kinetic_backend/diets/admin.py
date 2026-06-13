from django.contrib import admin
from .models import Food, MealTemplate, MealFood, DietPlan, DietPlanMeal, MemberDietPlan, DietLog

class MealFoodInline(admin.TabularInline):
    model = MealFood
    extra = 1

class DietPlanMealInline(admin.TabularInline):
    model = DietPlanMeal
    extra = 1

@admin.register(Food)
class FoodAdmin(admin.ModelAdmin):
    list_display = ('food_name', 'category', 'serving_size', 'calories', 'protein', 'carbohydrates', 'fats', 'is_active', 'is_deleted')
    list_filter = ('category', 'is_active', 'is_deleted')
    search_fields = ('food_name', 'description')
    ordering = ('food_name',)

@admin.register(MealTemplate)
class MealTemplateAdmin(admin.ModelAdmin):
    list_display = ('meal_name', 'meal_type', 'trainer', 'created_at')
    list_filter = ('meal_type', 'trainer')
    search_fields = ('meal_name', 'description')
    inlines = [MealFoodInline]

@admin.register(DietPlan)
class DietPlanAdmin(admin.ModelAdmin):
    list_display = ('plan_name', 'goal', 'trainer', 'gym', 'target_calories', 'status', 'is_deleted')
    list_filter = ('goal', 'status', 'is_deleted', 'gym', 'trainer')
    search_fields = ('plan_name', 'description')
    inlines = [DietPlanMealInline]

@admin.register(MemberDietPlan)
class MemberDietPlanAdmin(admin.ModelAdmin):
    list_display = ('member', 'diet_plan', 'assigned_by', 'start_date', 'end_date', 'status')
    list_filter = ('status', 'start_date', 'end_date')
    search_fields = ('member__full_name', 'diet_plan__plan_name', 'notes')

@admin.register(DietLog)
class DietLogAdmin(admin.ModelAdmin):
    list_display = ('member', 'assigned_diet', 'meal', 'completed', 'completion_time')
    list_filter = ('completed', 'completion_time')
    search_fields = ('member__full_name', 'meal__meal_template__meal_name')
