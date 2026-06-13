import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from members.models import Member

class ActivityType(models.TextChoices):
    ATTENDANCE = 'ATTENDANCE', 'Attendance'
    WORKOUT_COMPLETION = 'WORKOUT_COMPLETION', 'Workout Completion'
    DIET_COMPLETION = 'DIET_COMPLETION', 'Diet Completion'
    GOAL_ACHIEVEMENT = 'GOAL_ACHIEVEMENT', 'Goal Achievement'
    MEMBERSHIP_RENEWAL = 'MEMBERSHIP_RENEWAL', 'Membership Renewal'
    CHALLENGE_COMPLETION = 'CHALLENGE_COMPLETION', 'Challenge Completion'
    BADGE_UNLOCKED = 'BADGE_UNLOCKED', 'Badge Unlocked'

class PointRule(models.Model):
    activity_type = models.CharField(max_length=50, choices=ActivityType.choices, unique=True)
    points_value = models.PositiveIntegerField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gamification_point_rules'

    def __str__(self):
        return f"{self.activity_type} - {self.points_value} pts"

class RewardPointTransaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='point_transactions')
    activity_type = models.CharField(max_length=50, choices=ActivityType.choices)
    points_earned = models.IntegerField()  # Negative for redemptions
    points_balance = models.PositiveIntegerField()
    reference_id = models.CharField(max_length=255, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gamification_point_transactions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['member', '-created_at']),
            models.Index(fields=['activity_type', 'reference_id']),
        ]

    def __str__(self):
        return f"{self.member.full_name}: {self.points_earned} pts ({self.activity_type})"

class StreakType(models.TextChoices):
    ATTENDANCE = 'ATTENDANCE', 'Attendance'
    WORKOUT = 'WORKOUT', 'Workout'
    DIET = 'DIET', 'Diet'

class Streak(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='streaks')
    streak_type = models.CharField(max_length=20, choices=StreakType.choices)
    current_streak = models.PositiveIntegerField(default=0)
    longest_streak = models.PositiveIntegerField(default=0)
    last_activity_date = models.DateField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gamification_streaks'
        unique_together = ('member', 'streak_type')
        indexes = [
            models.Index(fields=['member', 'streak_type']),
        ]

    def __str__(self):
        return f"{self.member.full_name} - {self.streak_type}: {self.current_streak} days"

class Badge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    badge_name = models.CharField(max_length=100, unique=True)
    badge_type = models.CharField(max_length=50)  # ATTENDANCE, WORKOUT, DIET, PROGRESS, GOAL
    description = models.TextField()
    icon = models.CharField(max_length=100)  # e.g., 'star', 'fire', 'gym'
    points_reward = models.PositiveIntegerField(default=50)
    criteria = models.CharField(max_length=255)  # e.g., 'streak_7', 'workouts_100', 'weight_loss_5'
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gamification_badges'

    def __str__(self):
        return self.badge_name

class MemberBadge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE, related_name='unlocked_by')
    unlocked_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gamification_member_badges'
        unique_together = ('member', 'badge')
        indexes = [
            models.Index(fields=['member', '-unlocked_at']),
        ]

    def __str__(self):
        return f"{self.member.full_name} unlocked {self.badge.badge_name}"

class ChallengeStatus(models.TextChoices):
    UPCOMING = 'UPCOMING', 'Upcoming'
    ACTIVE = 'ACTIVE', 'Active'
    COMPLETED = 'COMPLETED', 'Completed'
    EXPIRED = 'EXPIRED', 'Expired'

class Challenge(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    challenge_name = models.CharField(max_length=150)
    challenge_type = models.CharField(max_length=50)  # ATTENDANCE, WORKOUT, DIET, WEIGHT_LOSS
    description = models.TextField()
    target_value = models.FloatField()  # Days, Count, or kg
    start_date = models.DateField()
    end_date = models.DateField()
    reward_points = models.PositiveIntegerField(default=100)
    status = models.CharField(max_length=20, choices=ChallengeStatus.choices, default=ChallengeStatus.ACTIVE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gamification_challenges'
        ordering = ['-start_date']

    def __str__(self):
        return self.challenge_name

class ChallengeParticipation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='challenge_participations')
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE, related_name='participants')
    progress = models.FloatField(default=0.0)
    completion_percentage = models.FloatField(default=0.0)
    joined_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'gamification_challenge_participations'
        unique_together = ('member', 'challenge')
        indexes = [
            models.Index(fields=['member', 'challenge']),
        ]

    def __str__(self):
        return f"{self.member.full_name} in {self.challenge.challenge_name} ({self.completion_percentage}%)"

class RewardCatalog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=150)
    description = models.TextField()
    points_cost = models.PositiveIntegerField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'gamification_reward_catalog'

    def __str__(self):
        return f"{self.title} - {self.points_cost} pts"

class RedemptionStatus(models.TextChoices):
    PENDING = 'PENDING', 'Pending'
    APPROVED = 'APPROVED', 'Approved'
    REJECTED = 'REJECTED', 'Rejected'

class RewardRedemption(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='redemptions')
    reward = models.ForeignKey(RewardCatalog, on_delete=models.CASCADE, related_name='claims')
    points_spent = models.PositiveIntegerField()
    status = models.CharField(max_length=20, choices=RedemptionStatus.choices, default=RedemptionStatus.PENDING)
    approved_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='approved_redemptions')
    redemption_date = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'gamification_reward_redemptions'
        ordering = ['-redemption_date']

    def __str__(self):
        return f"{self.member.full_name} redeemed {self.reward.title} ({self.status})"
