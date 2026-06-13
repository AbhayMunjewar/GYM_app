import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from members.models import Member
from trainers.models import Trainer

class ProgressMeasurement(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='measurements')
    trainer = models.ForeignKey(Trainer, on_delete=models.SET_NULL, null=True, blank=True, related_name='recorded_measurements')
    
    # Weight & Body composition
    weight_kg = models.FloatField()
    body_fat_percentage = models.FloatField()
    bmi = models.FloatField(blank=True, null=True)
    height_cm = models.FloatField()
    
    # Circumference measurements (cm)
    chest_cm = models.FloatField(blank=True, null=True)
    waist_cm = models.FloatField(blank=True, null=True)
    hips_cm = models.FloatField(blank=True, null=True)
    shoulders_cm = models.FloatField(blank=True, null=True)
    biceps_cm = models.FloatField(blank=True, null=True)
    forearms_cm = models.FloatField(blank=True, null=True)
    thighs_cm = models.FloatField(blank=True, null=True)
    calves_cm = models.FloatField(blank=True, null=True)
    neck_cm = models.FloatField(blank=True, null=True)
    
    notes = models.TextField(blank=True, null=True)
    recorded_date = models.DateField(default=timezone.localdate)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'progress_measurements'
        ordering = ['-recorded_date', '-created_at']
        indexes = [
            models.Index(fields=['member', 'recorded_date']),
            models.Index(fields=['recorded_date']),
        ]

    def save(self, *args, **kwargs):
        if self.weight_kg and self.height_cm:
            self.bmi = round(self.weight_kg / ((self.height_cm / 100.0) ** 2), 1)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.member.full_name} - {self.weight_kg}kg on {self.recorded_date}"


class ProgressPhotoType(models.TextChoices):
    FRONT = 'FRONT', 'Front'
    SIDE = 'SIDE', 'Side'
    BACK = 'BACK', 'Back'

class ProgressPhoto(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='progress_photos')
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='uploaded_progress_photos')
    
    photo_type = models.CharField(max_length=10, choices=ProgressPhotoType.choices, default=ProgressPhotoType.FRONT)
    image = models.ImageField(upload_to='progress_photos/')
    notes = models.TextField(blank=True, null=True)
    
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'progress_photos'
        ordering = ['-uploaded_at']
        indexes = [
            models.Index(fields=['member', 'photo_type']),
            models.Index(fields=['uploaded_at']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.photo_type} at {self.uploaded_at.date()}"


class GoalType(models.TextChoices):
    FAT_LOSS = 'FAT_LOSS', 'Fat Loss'
    MUSCLE_GAIN = 'MUSCLE_GAIN', 'Muscle Gain'
    WEIGHT_GAIN = 'WEIGHT_GAIN', 'Weight Gain'
    MAINTENANCE = 'MAINTENANCE', 'Maintenance'

class GoalStatus(models.TextChoices):
    ACTIVE = 'ACTIVE', 'Active'
    ACHIEVED = 'ACHIEVED', 'Achieved'
    FAILED = 'FAILED', 'Failed'
    CANCELLED = 'CANCELLED', 'Cancelled'

class FitnessGoal(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='fitness_goals')
    
    goal_type = models.CharField(max_length=20, choices=GoalType.choices, default=GoalType.FAT_LOSS)
    starting_weight = models.FloatField(blank=True, null=True)
    starting_body_fat = models.FloatField(blank=True, null=True)
    target_weight = models.FloatField(blank=True, null=True)
    target_body_fat = models.FloatField(blank=True, null=True)
    target_date = models.DateField()
    
    current_progress_percentage = models.FloatField(default=0.0)
    status = models.CharField(max_length=20, choices=GoalStatus.choices, default=GoalStatus.ACTIVE)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'fitness_goals'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['member', 'status']),
            models.Index(fields=['target_date']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.goal_type} ({self.status})"


class ProgressMilestone(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='progress_milestones')
    
    milestone_name = models.CharField(max_length=255)
    achieved_date = models.DateField(default=timezone.localdate)
    achievement_value = models.CharField(max_length=100)
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'progress_milestones'
        ordering = ['-achieved_date', '-created_at']
        unique_together = ('member', 'milestone_name')
        indexes = [
            models.Index(fields=['member', 'achieved_date']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.milestone_name}"
