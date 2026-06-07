from datetime import timedelta
from django.utils import timezone
from django.db.models import Sum, Count, Q
from .models import MembershipPlan, Membership
from members.models import Member
from rest_framework.exceptions import ValidationError

class MembershipService:
    @staticmethod
    def assign_membership(member_id, plan_id, notes=None):
        try:
            member = Member.objects.get(id=member_id)
            plan = MembershipPlan.objects.get(id=plan_id, is_deleted=False)
        except Member.DoesNotExist:
            raise ValidationError("Member does not exist.")
        except MembershipPlan.DoesNotExist:
            raise ValidationError("Membership Plan does not exist or is deleted.")

        if member.gym != plan.gym:
            raise ValidationError("Cannot assign a membership plan from a different gym.")

        if not plan.is_active:
            raise ValidationError("Cannot assign an inactive membership plan.")

        # Logic to assign dates
        start_date = timezone.now().date()
        end_date = start_date + timedelta(days=plan.duration_days)

        # Create membership
        membership = Membership.objects.create(
            member=member,
            membership_plan=plan,
            start_date=start_date,
            end_date=end_date,
            status='ACTIVE',
            notes=notes
        )

        return membership

    @staticmethod
    def get_dashboard_stats(gym_id):
        # Total Active Memberships
        active_memberships = Membership.objects.filter(
            member__gym_id=gym_id, 
            status='ACTIVE', 
            member__is_deleted=False
        )
        total_active = active_memberships.count()

        # Total Expired Memberships
        total_expired = Membership.objects.filter(
            member__gym_id=gym_id, 
            status='EXPIRED',
            member__is_deleted=False
        ).count()

        # Memberships Expiring Soon (in next 7 days)
        today = timezone.now().date()
        next_week = today + timedelta(days=7)
        expiring_soon = active_memberships.filter(end_date__lte=next_week).count()

        # Membership Revenue Summary
        # Simple sum of prices for active memberships
        revenue_sum = active_memberships.aggregate(
            total_revenue=Sum('membership_plan__price')
        )['total_revenue'] or 0

        return {
            "total_active_memberships": total_active,
            "total_expired_memberships": total_expired,
            "expiring_soon": expiring_soon,
            "total_revenue": revenue_sum,
        }

    @staticmethod
    def update_expired_memberships():
        """
        Utility function to auto-expire memberships.
        Can be called by Celery or a management command.
        """
        today = timezone.now().date()
        expired_memberships = Membership.objects.filter(
            status='ACTIVE',
            end_date__lt=today
        )
        count = expired_memberships.update(status='EXPIRED')
        return count
