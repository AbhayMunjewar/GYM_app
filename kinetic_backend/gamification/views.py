from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.utils import timezone

from core.responses import success_response, failure_response
from core.permissions import IsGymOwner, IsTrainer, IsMember
from members.models import Member
from gyms.models import Gym

from .models import (
    RewardPointTransaction, Streak, Badge, MemberBadge,
    Challenge, ChallengeParticipation, RewardCatalog, RewardRedemption,
    RedemptionStatus
)
from .serializers import (
    RewardPointTransactionSerializer, StreakSerializer, BadgeSerializer,
    MemberBadgeSerializer, ChallengeSerializer, ChallengeParticipationSerializer,
    RewardCatalogSerializer, RewardRedemptionSerializer
)
from .services import (
    PointsService, StreakService, BadgeService, ChallengeService,
    LeaderboardService, RedemptionService
)

def get_member_profile(user):
    return Member.objects.filter(email=user.email, is_deleted=False).first()

# ==========================================
# POINTS APIs
# ==========================================
class PointsBalanceView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        balance = PointsService.get_points_balance(member)
        return success_response("Points balance retrieved", data={"balance": balance})

class PointsHistoryView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        txns = RewardPointTransaction.objects.filter(member=member).order_by('-created_at')
        serializer = RewardPointTransactionSerializer(txns, many=True)
        return success_response("Points transaction history retrieved", data=serializer.data)

# ==========================================
# STREAKS APIs
# ==========================================
class StreaksListView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        streaks = StreakService.get_member_streaks(member)
        serializer = StreakSerializer(streaks, many=True)
        return success_response("Member streaks retrieved", data=serializer.data)

# ==========================================
# BADGES APIs
# ==========================================
class BadgeListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Initialize default badges if empty
        BadgeService.initialize_default_badges()
        badges = Badge.objects.all()
        serializer = BadgeSerializer(badges, many=True)
        return success_response("Badge catalog retrieved", data=serializer.data)

class MyBadgesListView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        # Make sure badges are updated
        BadgeService.evaluate_badges(member)
        
        my_badges = MemberBadge.objects.filter(member=member).order_by('-unlocked_at')
        serializer = MemberBadgeSerializer(my_badges, many=True)
        return success_response("Member unlocked badges retrieved", data=serializer.data)

# ==========================================
# CHALLENGES APIs
# ==========================================
class ChallengeListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        challenges = ChallengeService.get_active_challenges()
        serializer = ChallengeSerializer(challenges, many=True)
        
        # If logged in as member, enrich response with registration status
        member = get_member_profile(request.user)
        response_data = serializer.data
        if member:
            participations = ChallengeParticipation.objects.filter(member=member)
            joined_challenges = {str(p.challenge_id): p.completion_percentage for p in participations}
            for row in response_data:
                row['is_joined'] = row['id'] in joined_challenges
                row['completion_percentage'] = joined_challenges.get(row['id'], 0.0)
                
        return success_response("Active challenges retrieved", data=response_data)

class ChallengeDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        challenge = get_object_or_404(Challenge, id=id)
        serializer = ChallengeSerializer(challenge)
        response_data = serializer.data
        
        member = get_member_profile(request.user)
        if member:
            part = ChallengeParticipation.objects.filter(member=member, challenge=challenge).first()
            response_data['is_joined'] = part is not None
            response_data['completion_percentage'] = part.completion_percentage if part else 0.0
            response_data['progress'] = part.progress if part else 0.0
            response_data['completed_at'] = part.completed_at.strftime('%Y-%m-%d %H:%M:%S') if part and part.completed_at else None
            
        return success_response("Challenge details retrieved", data=response_data)

class JoinChallengeView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def post(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        challenge_id = request.data.get('challenge_id')
        if not challenge_id:
            return failure_response("challenge_id is required.", status_code=400)
            
        try:
            part = ChallengeService.join_challenge(member, challenge_id)
            return success_response(
                "Joined challenge successfully",
                data=ChallengeParticipationSerializer(part).data,
                status_code=201
            )
        except ValueError as e:
            return failure_response(str(e), status_code=400)

class MyJoinedChallengesView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
            
        parts = ChallengeParticipation.objects.filter(member=member).order_by('-joined_at')
        serializer = ChallengeParticipationSerializer(parts, many=True)
        return success_response("Member challenge participations retrieved", data=serializer.data)

# ==========================================
# LEADERBOARD APIs
# ==========================================
class LeaderboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Resolve gym context
        if request.user.role == 'OWNER':
            gym = Gym.objects.filter(owner=request.user).first()
        elif request.user.role == 'TRAINER':
            trainer = get_object_or_404(Trainer, user=request.user)
            gym = trainer.gym
        else: # MEMBER
            member = get_member_profile(request.user)
            gym = member.gym if member else None

        if not gym:
            return failure_response("Gym context not found.", status_code=404)

        period = request.query_params.get('period', 'all_time').lower()
        if period not in ['daily', 'weekly', 'monthly', 'all_time']:
            return failure_response("Invalid period parameter. Must be daily, weekly, monthly, or all_time.", status_code=400)

        leaderboard = LeaderboardService.get_leaderboard(gym, period)
        
        # Include current member's personal rank if requested by Member
        my_rank_info = None
        if request.user.role == 'MEMBER':
            member = get_member_profile(request.user)
            if member:
                for row in leaderboard:
                    if row['member_id'] == str(member.id):
                        my_rank_info = row
                        break
        
        return success_response("Leaderboard rankings retrieved", data={
            "period": period,
            "my_rank": my_rank_info,
            "rankings": leaderboard
        })

# ==========================================
# REWARDS CATALOG & REDEMPTION APIs
# ==========================================
class RewardCatalogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        items = RewardCatalog.objects.filter(is_active=True).order_by('points_cost')
        serializer = RewardCatalogSerializer(items, many=True)
        return success_response("Rewards catalog retrieved", data=serializer.data)

class RedeemRewardView(APIView):
    permission_classes = [IsAuthenticated, IsMember]

    def post(self, request):
        member = get_member_profile(request.user)
        if not member:
            return failure_response("Member profile not found.", status_code=404)
        
        catalog_id = request.data.get('reward_id')
        if not catalog_id:
            return failure_response("reward_id is required.", status_code=400)
            
        try:
            redemption = RedemptionService.redeem_reward(member, catalog_id)
            return success_response(
                "Redemption claim submitted successfully",
                data=RewardRedemptionSerializer(redemption).data,
                status_code=201
            )
        except ValueError as e:
            return failure_response(str(e), status_code=400)

class RedemptionHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role == 'OWNER':
            gym = Gym.objects.filter(owner=request.user).first()
            claims = RewardRedemption.objects.filter(member__gym=gym).order_by('-redemption_date')
        elif request.user.role == 'MEMBER':
            member = get_member_profile(request.user)
            claims = RewardRedemption.objects.filter(member=member).order_by('-redemption_date')
        else:
            claims = RewardRedemption.objects.none()

        serializer = RewardRedemptionSerializer(claims, many=True)
        return success_response("Redemption claims retrieved", data=serializer.data)

class ApproveRedemptionView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    def post(self, request, id):
        try:
            redemption = RedemptionService.approve_redemption(id, request.user)
            return success_response("Redemption approved successfully", data=RewardRedemptionSerializer(redemption).data)
        except (ValueError, PermissionError) as e:
            return failure_response(str(e), status_code=400)

class RejectRedemptionView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    def post(self, request, id):
        reason = request.data.get('reason', '')
        try:
            redemption = RedemptionService.reject_redemption(id, request.user, reason)
            return success_response("Redemption rejected and points refunded", data=RewardRedemptionSerializer(redemption).data)
        except (ValueError, PermissionError) as e:
            return failure_response(str(e), status_code=400)
