from django.contrib import admin
from .models import (
    PointRule, RewardPointTransaction, Streak, Badge,
    MemberBadge, Challenge, ChallengeParticipation,
    RewardCatalog, RewardRedemption
)

@admin.register(PointRule)
class PointRuleAdmin(admin.ModelAdmin):
    list_display = ('activity_type', 'points_value', 'is_active')
    list_filter = ('is_active',)

@admin.register(RewardPointTransaction)
class RewardPointTransactionAdmin(admin.ModelAdmin):
    list_display = ('member', 'activity_type', 'points_earned', 'points_balance', 'created_at')
    list_filter = ('activity_type', 'created_at')
    search_fields = ('member__full_name', 'reference_id')

@admin.register(Streak)
class StreakAdmin(admin.ModelAdmin):
    list_display = ('member', 'streak_type', 'current_streak', 'longest_streak', 'last_activity_date')
    list_filter = ('streak_type',)
    search_fields = ('member__full_name',)

@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ('badge_name', 'badge_type', 'points_reward', 'criteria')
    list_filter = ('badge_type',)

@admin.register(MemberBadge)
class MemberBadgeAdmin(admin.ModelAdmin):
    list_display = ('member', 'badge', 'unlocked_at')
    list_filter = ('unlocked_at',)
    search_fields = ('member__full_name', 'badge__badge_name')

@admin.register(Challenge)
class ChallengeAdmin(admin.ModelAdmin):
    list_display = ('challenge_name', 'challenge_type', 'target_value', 'status', 'start_date', 'end_date')
    list_filter = ('challenge_type', 'status')

@admin.register(ChallengeParticipation)
class ChallengeParticipationAdmin(admin.ModelAdmin):
    list_display = ('member', 'challenge', 'progress', 'completion_percentage', 'joined_at', 'completed_at')
    list_filter = ('joined_at', 'completed_at')
    search_fields = ('member__full_name', 'challenge__challenge_name')

@admin.register(RewardCatalog)
class RewardCatalogAdmin(admin.ModelAdmin):
    list_display = ('title', 'points_cost', 'is_active')
    list_filter = ('is_active',)

@admin.register(RewardRedemption)
class RewardRedemptionAdmin(admin.ModelAdmin):
    list_display = ('member', 'reward', 'points_spent', 'status', 'redemption_date')
    list_filter = ('status', 'redemption_date')
    search_fields = ('member__full_name', 'reward__title')
