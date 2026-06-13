"""
Analytics API Views (Day 15)

Three role-scoped endpoints that return consolidated analytics data.
Each view enforces role checks and scopes data access appropriately.
"""

from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from core.responses import success_response, failure_response
from rest_framework import status

from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer
from .services import OwnerAnalyticsService, TrainerAnalyticsService, MemberAnalyticsService


class OwnerAnalyticsView(APIView):
    """
    GET /api/analytics/owner/

    Returns comprehensive gym-wide analytics for the authenticated owner.
    Includes revenue, memberships, attendance, trainers, member growth,
    revenue trend, and plan distribution.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != 'OWNER':
            return failure_response(
                "Only gym owners can access owner analytics.",
                status_code=status.HTTP_403_FORBIDDEN
            )

        gym = Gym.objects.filter(owner=request.user, is_deleted=False).first()
        if not gym:
            return failure_response(
                "No active gym found for this owner.",
                status_code=status.HTTP_404_NOT_FOUND
            )

        try:
            data = OwnerAnalyticsService.get_analytics(gym)
            return success_response("Owner analytics retrieved.", data=data)
        except Exception as e:
            return failure_response(
                f"Failed to generate analytics: {str(e)}",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class TrainerAnalyticsView(APIView):
    """
    GET /api/analytics/trainer/

    Returns analytics scoped to the authenticated trainer's assigned members.
    Includes client metrics, attendance rates, diet compliance, and progress stats.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != 'TRAINER':
            return failure_response(
                "Only trainers can access trainer analytics.",
                status_code=status.HTTP_403_FORBIDDEN
            )

        trainer = Trainer.objects.filter(
            user=request.user, is_deleted=False
        ).first()
        if not trainer:
            return failure_response(
                "Trainer profile not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )

        try:
            data = TrainerAnalyticsService.get_analytics(trainer)
            return success_response("Trainer analytics retrieved.", data=data)
        except Exception as e:
            return failure_response(
                f"Failed to generate analytics: {str(e)}",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class MemberAnalyticsView(APIView):
    """
    GET /api/analytics/member/

    Returns personal analytics for the authenticated member.
    Includes attendance streaks, diet compliance, weight trends,
    goal progress, and membership status.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != 'MEMBER':
            return failure_response(
                "Only members can access member analytics.",
                status_code=status.HTTP_403_FORBIDDEN
            )

        member = Member.objects.filter(
            email=request.user.email, is_deleted=False
        ).first()
        if not member:
            return failure_response(
                "Member profile not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )

        try:
            data = MemberAnalyticsService.get_analytics(member)
            return success_response("Member analytics retrieved.", data=data)
        except Exception as e:
            return failure_response(
                f"Failed to generate analytics: {str(e)}",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
