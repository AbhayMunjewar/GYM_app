from rest_framework import serializers
from members.models import Member
from .models import (
    RewardPointTransaction, Streak, Badge, MemberBadge,
    Challenge, ChallengeParticipation, RewardCatalog, RewardRedemption
)

class RewardPointTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = RewardPointTransaction
        fields = ['id', 'activity_type', 'points_earned', 'points_balance', 'reference_id', 'description', 'created_at']

class StreakSerializer(serializers.ModelSerializer):
    class Meta:
        model = Streak
        fields = ['id', 'streak_type', 'current_streak', 'longest_streak', 'last_activity_date']

class BadgeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Badge
        fields = ['id', 'badge_name', 'badge_type', 'description', 'icon', 'points_reward', 'criteria', 'created_at']

class MemberBadgeSerializer(serializers.ModelSerializer):
    badge = BadgeSerializer(read_only=True)
    class Meta:
        model = MemberBadge
        fields = ['id', 'badge', 'unlocked_at']

class ChallengeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Challenge
        fields = ['id', 'challenge_name', 'challenge_type', 'description', 'target_value', 'start_date', 'end_date', 'reward_points', 'status', 'created_at']

class ChallengeParticipationSerializer(serializers.ModelSerializer):
    challenge = ChallengeSerializer(read_only=True)
    class Meta:
        model = ChallengeParticipation
        fields = ['id', 'challenge', 'progress', 'completion_percentage', 'joined_at', 'completed_at']

class RewardCatalogSerializer(serializers.ModelSerializer):
    class Meta:
        model = RewardCatalog
        fields = ['id', 'title', 'description', 'points_cost', 'is_active', 'created_at']

class RewardRedemptionSerializer(serializers.ModelSerializer):
    reward = RewardCatalogSerializer(read_only=True)
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    class Meta:
        model = RewardRedemption
        fields = ['id', 'member_id', 'member_name', 'reward', 'points_spent', 'status', 'redemption_date', 'updated_at']
