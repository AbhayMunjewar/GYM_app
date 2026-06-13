from django.contrib import admin
from .models import ProgressMeasurement, ProgressPhoto, FitnessGoal, ProgressMilestone

@admin.register(ProgressMeasurement)
class ProgressMeasurementAdmin(admin.ModelAdmin):
    list_display = ('member', 'weight_kg', 'body_fat_percentage', 'bmi', 'height_cm', 'recorded_date')
    list_filter = ('recorded_date', 'member__gym')
    search_fields = ('member__full_name', 'member__email', 'notes')
    ordering = ('-recorded_date', '-created_at')


@admin.register(ProgressPhoto)
class ProgressPhotoAdmin(admin.ModelAdmin):
    list_display = ('member', 'photo_type', 'uploaded_at')
    list_filter = ('photo_type', 'uploaded_at', 'member__gym')
    search_fields = ('member__full_name', 'notes')
    ordering = ('-uploaded_at',)


@admin.register(FitnessGoal)
class FitnessGoalAdmin(admin.ModelAdmin):
    list_display = ('member', 'goal_type', 'target_weight', 'target_body_fat', 'target_date', 'status', 'current_progress_percentage')
    list_filter = ('goal_type', 'status', 'target_date', 'member__gym')
    search_fields = ('member__full_name', 'member__email')
    ordering = ('-created_at',)


@admin.register(ProgressMilestone)
class ProgressMilestoneAdmin(admin.ModelAdmin):
    list_display = ('member', 'milestone_name', 'achieved_date', 'achievement_value')
    list_filter = ('achieved_date', 'milestone_name', 'member__gym')
    search_fields = ('member__full_name', 'milestone_name')
    ordering = ('-achieved_date',)
