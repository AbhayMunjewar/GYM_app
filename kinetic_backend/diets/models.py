import uuid
from django.db import models
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member

class Food(models.Model):
    CATEGORY_CHOICES = [
        ('PROTEIN', 'Protein'),
        ('CARBOHYDRATE', 'Carbohydrate'),
        ('FAT', 'Fat'),
        ('VEGETABLE', 'Vegetable'),
        ('FRUIT', 'Fruit'),
        ('DAIRY', 'Dairy'),
        ('SUPPLEMENT', 'Supplement'),
        ('BEVERAGE', 'Beverage'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    food_name = models.CharField(max_length=255)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    serving_size = models.CharField(max_length=50)  # e.g., "100g", "1 scoop"
    calories = models.PositiveIntegerField()
    protein = models.DecimalField(max_digits=6, decimal_places=2)
    carbohydrates = models.DecimalField(max_digits=6, decimal_places=2)
    fats = models.DecimalField(max_digits=6, decimal_places=2)
    fiber = models.DecimalField(max_digits=6, decimal_places=2, default=0.0)
    description = models.TextField(blank=True, null=True)
    image_url = models.URLField(blank=True, null=True, max_length=500)
    
    is_active = models.BooleanField(default=True)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'foods'
        ordering = ['food_name']
        indexes = [
            models.Index(fields=['food_name']),
            models.Index(fields=['category']),
            models.Index(fields=['is_active', 'is_deleted']),
        ]

    def __str__(self):
        return f"{self.food_name} ({self.category})"


class MealTemplate(models.Model):
    MEAL_TYPE_CHOICES = [
        ('BREAKFAST', 'Breakfast'),
        ('LUNCH', 'Lunch'),
        ('DINNER', 'Dinner'),
        ('SNACK', 'Snack'),
        ('PRE_WORKOUT', 'Pre Workout'),
        ('POST_WORKOUT', 'Post Workout'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    trainer = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='meal_templates')
    meal_name = models.CharField(max_length=150)
    meal_type = models.CharField(max_length=50, choices=MEAL_TYPE_CHOICES)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'meal_templates'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['trainer']),
            models.Index(fields=['meal_type']),
        ]

    def __str__(self):
        return f"{self.meal_name} ({self.meal_type})"


class MealFood(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    meal_template = models.ForeignKey(MealTemplate, on_delete=models.CASCADE, related_name='meal_foods')
    food = models.ForeignKey(Food, on_delete=models.CASCADE)
    quantity = models.FloatField()  # Multiplier of serving size
    serving_unit = models.CharField(max_length=50, default='g')

    class Meta:
        db_table = 'meal_foods'
        indexes = [
            models.Index(fields=['meal_template']),
            models.Index(fields=['food']),
        ]

    def __str__(self):
        return f"{self.quantity} x {self.food.food_name} in {self.meal_template.meal_name}"


class DietPlan(models.Model):
    GOAL_CHOICES = [
        ('FAT_LOSS', 'Fat Loss'),
        ('MUSCLE_GAIN', 'Muscle Gain'),
        ('MAINTENANCE', 'Maintenance'),
        ('WEIGHT_GAIN', 'Weight Gain'),
        ('ATHLETIC_PERFORMANCE', 'Athletic Performance'),
    ]

    STATUS_CHOICES = [
        ('DRAFT', 'Draft'),
        ('ACTIVE', 'Active'),
        ('ARCHIVED', 'Archived'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    trainer = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='diet_plans')
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='diet_plans')
    plan_name = models.CharField(max_length=150)
    goal = models.CharField(max_length=50, choices=GOAL_CHOICES)
    description = models.TextField(blank=True, null=True)
    
    target_calories = models.PositiveIntegerField()
    target_protein = models.PositiveIntegerField()
    target_carbs = models.PositiveIntegerField()
    target_fats = models.PositiveIntegerField()
    
    duration_days = models.PositiveIntegerField(default=7)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='DRAFT')
    
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'diet_plans'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['trainer']),
            models.Index(fields=['gym', 'is_deleted']),
            models.Index(fields=['goal']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return self.plan_name


class DietPlanMeal(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    diet_plan = models.ForeignKey(DietPlan, on_delete=models.CASCADE, related_name='plan_meals')
    meal_template = models.ForeignKey(MealTemplate, on_delete=models.CASCADE, related_name='plan_meals')
    day_number = models.PositiveIntegerField()  # Day 1, Day 2, etc.
    sequence_order = models.PositiveIntegerField()  # Order within the day (1, 2, 3...)

    class Meta:
        db_table = 'diet_plan_meals'
        ordering = ['day_number', 'sequence_order']
        indexes = [
            models.Index(fields=['diet_plan']),
            models.Index(fields=['meal_template']),
            models.Index(fields=['day_number']),
        ]
        unique_together = ('diet_plan', 'day_number', 'sequence_order')

    def __str__(self):
        return f"Day {self.day_number} - Meal {self.sequence_order}: {self.meal_template.meal_name}"


class MemberDietPlan(models.Model):
    STATUS_CHOICES = [
        ('ACTIVE', 'Active'),
        ('COMPLETED', 'Completed'),
        ('CANCELLED', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='diet_plans')
    diet_plan = models.ForeignKey(DietPlan, on_delete=models.CASCADE, related_name='member_assignments')
    assigned_by = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='diet_assignments')
    assigned_date = models.DateField(auto_now_add=True)
    start_date = models.DateField()
    end_date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'member_diet_plans'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['member', 'status']),
            models.Index(fields=['diet_plan']),
            models.Index(fields=['assigned_by']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.diet_plan.plan_name} ({self.status})"


class DietLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='diet_logs')
    assigned_diet = models.ForeignKey(MemberDietPlan, on_delete=models.CASCADE, related_name='logs')
    meal = models.ForeignKey(DietPlanMeal, on_delete=models.CASCADE, related_name='logs')
    completed = models.BooleanField(default=True)
    completion_time = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'diet_logs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['member']),
            models.Index(fields=['assigned_diet']),
            models.Index(fields=['meal']),
            models.Index(fields=['created_at']),
        ]
        unique_together = ('assigned_diet', 'meal', 'created_at')

    def __str__(self):
        status_str = "Completed" if self.completed else "Skipped"
        return f"{self.member.full_name} - {self.meal.meal_template.meal_name} ({status_str})"
