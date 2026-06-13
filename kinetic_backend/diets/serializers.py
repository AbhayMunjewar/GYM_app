from rest_framework import serializers
from .models import Food, MealTemplate, MealFood, DietPlan, DietPlanMeal, MemberDietPlan, DietLog
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member
from .services import NutritionEngine
from datetime import date

class FoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = Food
        fields = [
            'id', 'food_name', 'category', 'serving_size', 'calories',
            'protein', 'carbohydrates', 'fats', 'fiber', 'description',
            'image_url', 'is_active', 'created_at', 'updated_at'
        ]

    def validate(self, data):
        # Validate macronutrient bounds
        for field in ['protein', 'carbohydrates', 'fats', 'fiber']:
            if field in data and data[field] < 0:
                raise serializers.ValidationError({field: f"{field.capitalize()} cannot be negative."})
        if 'calories' in data and data['calories'] < 0:
            raise serializers.ValidationError({"calories": "Calories cannot be negative."})
        return data


class MealFoodReadSerializer(serializers.ModelSerializer):
    food_name = serializers.CharField(source='food.food_name', read_only=True)
    category = serializers.CharField(source='food.category', read_only=True)
    calories_per_serving = serializers.IntegerField(source='food.calories', read_only=True)
    protein_per_serving = serializers.DecimalField(source='food.protein', max_digits=6, decimal_places=2, read_only=True)
    carbs_per_serving = serializers.DecimalField(source='food.carbohydrates', max_digits=6, decimal_places=2, read_only=True)
    fats_per_serving = serializers.DecimalField(source='food.fats', max_digits=6, decimal_places=2, read_only=True)

    class Meta:
        model = MealFood
        fields = [
            'id', 'food', 'food_name', 'category', 'quantity', 'serving_unit',
            'calories_per_serving', 'protein_per_serving', 'carbs_per_serving', 'fats_per_serving'
        ]


class MealFoodWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = MealFood
        fields = ['food', 'quantity', 'serving_unit']


class MealTemplateSerializer(serializers.ModelSerializer):
    meal_foods = MealFoodReadSerializer(many=True, read_only=True)
    meal_foods_write = MealFoodWriteSerializer(many=True, write_only=True, required=False, source='meal_foods')
    trainer_name = serializers.CharField(source='trainer.user.full_name', read_only=True)
    
    # Nutrition Engine summaries
    calculated_macros = serializers.SerializerMethodField()

    class Meta:
        model = MealTemplate
        fields = [
            'id', 'trainer', 'trainer_name', 'meal_name', 'meal_type',
            'description', 'meal_foods', 'meal_foods_write', 'calculated_macros',
            'created_at', 'updated_at'
        ]

    def get_calculated_macros(self, obj):
        return NutritionEngine.calculate_meal_macros(obj)

    def create(self, validated_data):
        meal_foods_data = validated_data.pop('meal_foods', [])
        meal_template = MealTemplate.objects.create(**validated_data)
        for mf_data in meal_foods_data:
            MealFood.objects.create(meal_template=meal_template, **mf_data)
        return meal_template

    def update(self, instance, validated_data):
        meal_foods_data = validated_data.pop('meal_foods', None)
        instance.meal_name = validated_data.get('meal_name', instance.meal_name)
        instance.meal_type = validated_data.get('meal_type', instance.meal_type)
        instance.description = validated_data.get('description', instance.description)
        instance.save()

        if meal_foods_data is not None:
            instance.meal_foods.all().delete()
            for mf_data in meal_foods_data:
                MealFood.objects.create(meal_template=instance, **mf_data)
        return instance


class DietPlanMealReadSerializer(serializers.ModelSerializer):
    meal_template = MealTemplateSerializer(read_only=True)

    class Meta:
        model = DietPlanMeal
        fields = ['id', 'meal_template', 'day_number', 'sequence_order']


class DietPlanMealWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = DietPlanMeal
        fields = ['meal_template', 'day_number', 'sequence_order']


class DietPlanSerializer(serializers.ModelSerializer):
    plan_meals = DietPlanMealReadSerializer(many=True, read_only=True)
    plan_meals_write = DietPlanMealWriteSerializer(many=True, write_only=True, required=False, source='plan_meals')
    trainer_name = serializers.CharField(source='trainer.user.full_name', read_only=True)
    gym_name = serializers.CharField(source='gym.gym_name', read_only=True)
    
    # Nutrition aggregates
    calculated_daily_macros = serializers.SerializerMethodField()
    calculated_average_macros = serializers.SerializerMethodField()

    class Meta:
        model = DietPlan
        fields = [
            'id', 'trainer', 'trainer_name', 'gym', 'gym_name', 'plan_name',
            'goal', 'description', 'target_calories', 'target_protein',
            'target_carbs', 'target_fats', 'duration_days', 'status',
            'plan_meals', 'plan_meals_write', 'calculated_daily_macros',
            'calculated_average_macros', 'created_at', 'updated_at'
        ]

    def get_calculated_daily_macros(self, obj):
        return NutritionEngine.get_diet_plan_daily_macros(obj)

    def get_calculated_average_macros(self, obj):
        return NutritionEngine.get_diet_plan_average_daily_macros(obj)

    def validate(self, data):
        trainer = data.get('trainer')
        gym = data.get('gym')
        if trainer and gym:
            if trainer.gym != gym:
                raise serializers.ValidationError({"trainer": "Trainer must belong to the selected gym."})
        return data

    def create(self, validated_data):
        plan_meals_data = validated_data.pop('plan_meals', [])
        diet_plan = DietPlan.objects.create(**validated_data)
        for pm_data in plan_meals_data:
            DietPlanMeal.objects.create(diet_plan=diet_plan, **pm_data)
        return diet_plan

    def update(self, instance, validated_data):
        plan_meals_data = validated_data.pop('plan_meals', None)
        
        instance.plan_name = validated_data.get('plan_name', instance.plan_name)
        instance.goal = validated_data.get('goal', instance.goal)
        instance.description = validated_data.get('description', instance.description)
        instance.target_calories = validated_data.get('target_calories', instance.target_calories)
        instance.target_protein = validated_data.get('target_protein', instance.target_protein)
        instance.target_carbs = validated_data.get('target_carbs', instance.target_carbs)
        instance.target_fats = validated_data.get('target_fats', instance.target_fats)
        instance.duration_days = validated_data.get('duration_days', instance.duration_days)
        instance.status = validated_data.get('status', instance.status)
        instance.save()

        if plan_meals_data is not None:
            instance.plan_meals.all().delete()
            for pm_data in plan_meals_data:
                DietPlanMeal.objects.create(diet_plan=instance, **pm_data)
        return instance


class MemberDietPlanSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    plan_name = serializers.CharField(source='diet_plan.plan_name', read_only=True)
    assigned_by_name = serializers.CharField(source='assigned_by.user.full_name', read_only=True)

    class Meta:
        model = MemberDietPlan
        fields = [
            'id', 'member', 'member_name', 'diet_plan', 'plan_name',
            'assigned_by', 'assigned_by_name', 'assigned_date',
            'start_date', 'end_date', 'status', 'notes', 'created_at'
        ]

    def validate(self, data):
        member = data.get('member')
        diet_plan = data.get('diet_plan')
        assigned_by = data.get('assigned_by')
        start_date = data.get('start_date')
        end_date = data.get('end_date')

        # 1. Validation: date bounds
        if start_date and end_date and end_date < start_date:
            raise serializers.ValidationError({"end_date": "End date must be after or equal to start date."})

        # 2. Validation: same gym constraint
        if member and diet_plan and member.gym != diet_plan.gym:
            raise serializers.ValidationError({"member": "Member and Diet Plan must belong to the same gym."})

        if assigned_by and member and assigned_by.gym != member.gym:
            raise serializers.ValidationError({"assigned_by": "Trainer must belong to the same gym as the member."})

        # 3. Validation: prevent duplicate active assignments
        # Query active assignments for this member
        active_query = MemberDietPlan.objects.filter(member=member, status='ACTIVE')
        if self.instance:
            active_query = active_query.exclude(id=self.instance.id)
            
        if active_query.exists():
            raise serializers.ValidationError({"member": "Member already has an active diet plan assigned."})

        return data


class DietLogSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    meal_name = serializers.CharField(source='meal.meal_template.meal_name', read_only=True)
    meal_type = serializers.CharField(source='meal.meal_template.meal_type', read_only=True)

    class Meta:
        model = DietLog
        fields = [
            'id', 'member', 'member_name', 'assigned_diet', 'meal',
            'meal_name', 'meal_type', 'completed', 'completion_time', 'notes', 'created_at'
        ]

    def validate(self, data):
        assigned_diet = data.get('assigned_diet')
        meal = data.get('meal')
        member = data.get('member')

        # Verify meal belongs to assigned diet's plan
        if assigned_diet and meal and meal.diet_plan != assigned_diet.diet_plan:
            raise serializers.ValidationError({"meal": "The selected meal does not belong to this diet plan."})

        # Verify member ownership
        if assigned_diet and member and assigned_diet.member != member:
            raise serializers.ValidationError({"member": "This diet plan is not assigned to this member."})

        return data
