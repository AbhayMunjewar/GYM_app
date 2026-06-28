from django.db import models
from members.models import Member

class NutritionProfile(models.Model):
    member = models.OneToOneField(Member, on_delete=models.CASCADE, related_name='nutrition_profile')
    goal = models.CharField(max_length=20, choices=[('fat_loss','Fat Loss'),('muscle_gain','Muscle Gain'),('maintenance','Maintenance')])
    age = models.IntegerField()
    height_cm = models.FloatField()
    weight_kg = models.FloatField()
    gender = models.CharField(max_length=10)
    activity_level = models.CharField(max_length=20)
    workout_days_per_week = models.IntegerField()
    budget_inr = models.IntegerField()
    food_preference = models.CharField(max_length=20)  # veg/non-veg/vegan/eggetarian
    allergies = models.TextField(blank=True)
    medical_restrictions = models.TextField(blank=True)
    bmr = models.FloatField(null=True)
    tdee = models.FloatField(null=True)
    target_calories = models.IntegerField(null=True)
    protein_g = models.IntegerField(null=True)
    carbs_g = models.IntegerField(null=True)
    fat_g = models.IntegerField(null=True)
    water_liters = models.FloatField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class DietLog(models.Model):
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='nutrition_diet_logs')
    log_date = models.DateField()
    breakfast_done = models.BooleanField(default=False)
    lunch_done = models.BooleanField(default=False)
    dinner_done = models.BooleanField(default=False)
    snacks_done = models.BooleanField(default=False)
    pre_workout_done = models.BooleanField(default=False)
    post_workout_done = models.BooleanField(default=False)
    calories_consumed = models.IntegerField(default=0)
    protein_consumed_g = models.IntegerField(default=0)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('member', 'log_date')
