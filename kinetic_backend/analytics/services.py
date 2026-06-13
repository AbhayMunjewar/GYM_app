"""
Analytics & Reporting Service Layer (Day 15)

Centralized analytics engine that aggregates data from:
- Billing (revenue, payments, invoices)
- Attendance (check-ins, peak hours, streaks)
- Memberships (active, churn, growth)
- Trainers (utilization, performance)
- Diets (compliance, plan coverage)
- Progress Tracking (transformation, goals)

All methods enforce RBAC by accepting scoped objects (gym, trainer, member).
"""

from datetime import date, timedelta
from decimal import Decimal
from django.db.models import Sum, Count, Avg, Q, F
from django.utils import timezone

from billing.models import Invoice, Payment
from attendance.models import Attendance
from attendance.services import StreakService
from memberships.models import Membership, MembershipPlan
from members.models import Member
from trainers.models import Trainer, TrainerAssignment, TrainerStatus, AssignmentStatus
from progress_tracking.models import ProgressMeasurement, FitnessGoal, GoalStatus
from diets.models import MemberDietPlan, DietLog


class OwnerAnalyticsService:
    """Gym-wide analytics for the Owner role."""

    @staticmethod
    def get_analytics(gym):
        today = timezone.localdate()
        first_of_month = today.replace(day=1)
        prev_month_end = first_of_month - timedelta(days=1)
        prev_month_start = prev_month_end.replace(day=1)

        return {
            'revenue': OwnerAnalyticsService._revenue_metrics(gym, today, first_of_month),
            'memberships': OwnerAnalyticsService._membership_metrics(gym, today, first_of_month, prev_month_start, prev_month_end),
            'attendance': OwnerAnalyticsService._attendance_metrics(gym, today),
            'trainers': OwnerAnalyticsService._trainer_metrics(gym),
            'members': OwnerAnalyticsService._member_growth_metrics(gym, first_of_month, prev_month_start, prev_month_end),
            'revenue_trend': OwnerAnalyticsService._revenue_trend(gym, today),
            'plan_distribution': OwnerAnalyticsService._plan_distribution(gym),
        }

    @staticmethod
    def _revenue_metrics(gym, today, first_of_month):
        """Revenue KPIs from acknowledged payments."""
        acked = Payment.objects.filter(gym=gym, status='ACKNOWLEDGED')

        total_revenue = acked.aggregate(
            total=Sum('amount_paid')
        )['total'] or Decimal('0.00')

        monthly_revenue = acked.filter(
            payment_date__gte=first_of_month
        ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')

        # Pending dues from unpaid invoices
        pending_invoices = Invoice.objects.filter(
            gym=gym, status__in=['PENDING', 'OVERDUE']
        )
        pending_dues = Decimal('0.00')
        for inv in pending_invoices:
            paid = inv.payments.filter(status='ACKNOWLEDGED').aggregate(
                total=Sum('amount_paid')
            )['total'] or Decimal('0.00')
            pending_dues += (inv.total_amount - paid)

        overdue_count = Invoice.objects.filter(
            gym=gym, status='OVERDUE'
        ).count()

        return {
            'total_revenue': f"{total_revenue:.2f}",
            'monthly_revenue': f"{monthly_revenue:.2f}",
            'pending_dues': f"{pending_dues:.2f}",
            'overdue_invoices': overdue_count,
        }

    @staticmethod
    def _membership_metrics(gym, today, first_of_month, prev_month_start, prev_month_end):
        """Membership KPIs: active, new, churn, expiring soon."""
        members_qs = Member.objects.filter(gym=gym, is_deleted=False)
        total_members = members_qs.count()
        active_members = members_qs.filter(status='ACTIVE').count()

        # Active memberships
        active_memberships = Membership.objects.filter(
            member__gym=gym, status='ACTIVE'
        ).count()

        # New members this month
        new_this_month = members_qs.filter(
            join_date__gte=first_of_month
        ).count()

        # New members last month
        new_last_month = members_qs.filter(
            join_date__gte=prev_month_start,
            join_date__lte=prev_month_end
        ).count()

        # Churn: memberships that expired this month
        expired_this_month = Membership.objects.filter(
            member__gym=gym,
            status='EXPIRED',
            end_date__gte=first_of_month,
            end_date__lte=today
        ).values('member').distinct().count()

        churn_rate = 0.0
        if active_members > 0:
            churn_rate = round((expired_this_month / active_members) * 100, 1)

        # Expiring in 7 days
        exp_date = today + timedelta(days=7)
        expiring_soon = Membership.objects.filter(
            member__gym=gym,
            status='ACTIVE',
            end_date__range=[today, exp_date]
        ).count()

        return {
            'total_members': total_members,
            'active_members': active_members,
            'active_memberships': active_memberships,
            'new_this_month': new_this_month,
            'new_last_month': new_last_month,
            'churn_rate': churn_rate,
            'expired_this_month': expired_this_month,
            'expiring_soon': expiring_soon,
        }

    @staticmethod
    def _attendance_metrics(gym, today):
        """Today's attendance and weekly average."""
        today_count = Attendance.objects.filter(
            gym=gym, attendance_date=today, is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        # Weekly average (last 7 days)
        week_ago = today - timedelta(days=7)
        weekly_records = Attendance.objects.filter(
            gym=gym, attendance_date__range=[week_ago, today], is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        )
        weekly_total = weekly_records.count()
        weekly_avg = round(weekly_total / 7.0, 1)

        # Peak hours (reuse attendance service logic)
        from attendance.services import AttendanceService
        peak_hours = AttendanceService.get_peak_hours(gym.id)

        return {
            'today_check_ins': today_count,
            'weekly_average': weekly_avg,
            'weekly_total': weekly_total,
            'peak_hours': peak_hours,
        }

    @staticmethod
    def _trainer_metrics(gym):
        """Trainer utilization summary."""
        trainers = Trainer.objects.filter(gym=gym, is_deleted=False)
        total = trainers.count()
        active = trainers.filter(status=TrainerStatus.ACTIVE).count()

        total_assigned = TrainerAssignment.objects.filter(
            trainer__gym=gym,
            status=AssignmentStatus.ACTIVE,
            member__status='ACTIVE'
        ).values('member').distinct().count()

        utilization = 0.0
        if active > 0:
            utilization = round(float(total_assigned) / active, 2)

        return {
            'total_trainers': total,
            'active_trainers': active,
            'trainer_utilization': utilization,
            'total_assigned_members': total_assigned,
        }

    @staticmethod
    def _member_growth_metrics(gym, first_of_month, prev_month_start, prev_month_end):
        """Member growth comparison: this month vs last month."""
        qs = Member.objects.filter(gym=gym, is_deleted=False)
        this_month = qs.filter(join_date__gte=first_of_month).count()
        last_month = qs.filter(
            join_date__gte=prev_month_start,
            join_date__lte=prev_month_end
        ).count()

        growth_pct = 0.0
        if last_month > 0:
            growth_pct = round(((this_month - last_month) / last_month) * 100, 1)

        return {
            'new_this_month': this_month,
            'new_last_month': last_month,
            'growth_percentage': growth_pct,
        }

    @staticmethod
    def _revenue_trend(gym, today):
        """Monthly revenue for the last 6 months."""
        trend = []
        for i in range(5, -1, -1):
            month_start = (today.replace(day=1) - timedelta(days=30 * i)).replace(day=1)
            if month_start.month == 12:
                month_end = month_start.replace(year=month_start.year + 1, month=1, day=1) - timedelta(days=1)
            else:
                month_end = month_start.replace(month=month_start.month + 1, day=1) - timedelta(days=1)

            revenue = Payment.objects.filter(
                gym=gym, status='ACKNOWLEDGED',
                payment_date__gte=month_start,
                payment_date__lte=month_end
            ).aggregate(total=Sum('amount_paid'))['total'] or Decimal('0.00')

            trend.append({
                'month': month_start.strftime('%b %Y'),
                'revenue': f"{revenue:.2f}",
            })

        return trend

    @staticmethod
    def _plan_distribution(gym):
        """Count of active memberships per plan."""
        plans = MembershipPlan.objects.filter(gym=gym, is_deleted=False)
        distribution = []
        for plan in plans:
            count = Membership.objects.filter(
                membership_plan=plan, status='ACTIVE'
            ).count()
            distribution.append({
                'plan_name': plan.plan_name,
                'plan_id': str(plan.id),
                'active_count': count,
                'price': f"{plan.price:.2f}",
            })
        return distribution


class TrainerAnalyticsService:
    """Analytics scoped to a trainer's assigned members."""

    @staticmethod
    def get_analytics(trainer):
        today = timezone.localdate()

        active_assignments = TrainerAssignment.objects.filter(
            trainer=trainer, status=AssignmentStatus.ACTIVE
        )
        member_ids = list(active_assignments.values_list('member_id', flat=True))

        return {
            'clients': TrainerAnalyticsService._client_metrics(member_ids, today),
            'attendance': TrainerAnalyticsService._attendance_metrics(member_ids, today),
            'diet': TrainerAnalyticsService._diet_metrics(trainer, member_ids),
            'progress': TrainerAnalyticsService._progress_metrics(member_ids),
        }

    @staticmethod
    def _client_metrics(member_ids, today):
        """Client counts and membership status."""
        total = len(member_ids)
        active = Member.objects.filter(
            id__in=member_ids, status='ACTIVE', is_deleted=False
        ).count()

        exp_date = today + timedelta(days=7)
        expiring = Membership.objects.filter(
            member_id__in=member_ids, status='ACTIVE',
            end_date__range=[today, exp_date]
        ).count()

        return {
            'total_assigned': total,
            'active_clients': active,
            'expiring_memberships': expiring,
        }

    @staticmethod
    def _attendance_metrics(member_ids, today):
        """Attendance rates for assigned members."""
        if not member_ids:
            return {'today_present': 0, 'attendance_rate_30d': 0.0}

        today_present = Attendance.objects.filter(
            member_id__in=member_ids,
            attendance_date=today,
            is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        # 30-day attendance rate
        thirty_days_ago = today - timedelta(days=30)
        total_possible = len(member_ids) * 30
        actual_attendance = Attendance.objects.filter(
            member_id__in=member_ids,
            attendance_date__range=[thirty_days_ago, today],
            is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        rate = 0.0
        if total_possible > 0:
            rate = round((actual_attendance / total_possible) * 100, 1)

        return {
            'today_present': today_present,
            'attendance_rate_30d': rate,
        }

    @staticmethod
    def _diet_metrics(trainer, member_ids):
        """Diet plan compliance across assigned members."""
        active_assignments = MemberDietPlan.objects.filter(
            member_id__in=member_ids, status='ACTIVE'
        ).count()

        # Diet log compliance (last 7 days)
        seven_days_ago = timezone.now() - timedelta(days=7)
        logs = DietLog.objects.filter(
            member_id__in=member_ids,
            created_at__gte=seven_days_ago
        )
        total_logs = logs.count()
        completed_logs = logs.filter(completed=True).count()

        compliance_rate = 0.0
        if total_logs > 0:
            compliance_rate = round((completed_logs / total_logs) * 100, 1)

        return {
            'active_diet_assignments': active_assignments,
            'diet_logs_last_7d': total_logs,
            'diet_compliance_rate': compliance_rate,
            'members_with_diet': active_assignments,
        }

    @staticmethod
    def _progress_metrics(member_ids):
        """Transformation progress across assigned members."""
        if not member_ids:
            return {
                'members_improving': 0,
                'members_stagnating': 0,
                'goal_completion_rate': 0.0,
                'active_goals': 0,
            }

        improving = 0
        stagnating = 0

        for mid in member_ids:
            measurements = ProgressMeasurement.objects.filter(
                member_id=mid
            ).order_by('recorded_date')

            if measurements.count() >= 2:
                first = measurements.first()
                latest = measurements.last()
                # "Improving" = weight change in any direction of > 0.5kg
                if abs(latest.weight_kg - first.weight_kg) > 0.5:
                    improving += 1
                else:
                    stagnating += 1
            else:
                stagnating += 1

        total_goals = FitnessGoal.objects.filter(member_id__in=member_ids).count()
        achieved_goals = FitnessGoal.objects.filter(
            member_id__in=member_ids, status=GoalStatus.ACHIEVED
        ).count()
        active_goals = FitnessGoal.objects.filter(
            member_id__in=member_ids, status=GoalStatus.ACTIVE
        ).count()

        completion_rate = 0.0
        if total_goals > 0:
            completion_rate = round((achieved_goals / total_goals) * 100, 1)

        return {
            'members_improving': improving,
            'members_stagnating': stagnating,
            'goal_completion_rate': completion_rate,
            'active_goals': active_goals,
        }


class MemberAnalyticsService:
    """Personal analytics for the Member role."""

    @staticmethod
    def get_analytics(member):
        today = timezone.localdate()

        return {
            'attendance': MemberAnalyticsService._attendance_metrics(member, today),
            'diet': MemberAnalyticsService._diet_metrics(member),
            'progress': MemberAnalyticsService._progress_metrics(member),
            'membership': MemberAnalyticsService._membership_metrics(member, today),
        }

    @staticmethod
    def _attendance_metrics(member, today):
        """Streak, consistency rate (last 30 days), monthly attendance count."""
        streak = StreakService.calculate_streak(member.id)

        thirty_days_ago = today - timedelta(days=30)
        attendance_count = Attendance.objects.filter(
            member=member,
            attendance_date__range=[thirty_days_ago, today],
            is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        consistency_rate = round((attendance_count / 30.0) * 100, 1)

        this_month_count = Attendance.objects.filter(
            member=member,
            attendance_date__month=today.month,
            attendance_date__year=today.year,
            is_deleted=False,
            attendance_status__in=['PRESENT', 'LATE']
        ).count()

        return {
            'current_streak': streak.get('current_streak', 0),
            'longest_streak': streak.get('longest_streak', 0),
            'consistency_rate_30d': consistency_rate,
            'attendance_last_30d': attendance_count,
            'attendance_this_month': this_month_count,
        }

    @staticmethod
    def _diet_metrics(member):
        """Diet compliance and calorie tracking."""
        active_diet = MemberDietPlan.objects.filter(
            member=member, status='ACTIVE'
        ).first()

        if not active_diet:
            return {
                'has_active_diet': False,
                'consumed_calories': 0,
                'target_calories': 0,
                'logs_this_week': 0,
            }

        seven_days_ago = timezone.now() - timedelta(days=7)
        logs = DietLog.objects.filter(
            member=member, created_at__gte=seven_days_ago
        )
        logs_count = logs.count()
        completed_count = logs.filter(completed=True).count()

        compliance_rate = 0.0
        if logs_count > 0:
            compliance_rate = round((completed_count / logs_count) * 100, 1)

        target_calories = 0
        if hasattr(active_diet, 'diet_plan') and active_diet.diet_plan:
            target_calories = getattr(active_diet.diet_plan, 'target_calories', 0) or 0

        return {
            'has_active_diet': True,
            'diet_plan_name': active_diet.diet_plan.plan_name if active_diet.diet_plan else None,
            'compliance_rate': compliance_rate,
            'target_calories': target_calories,
            'logs_this_week': logs_count,
            'completed_this_week': completed_count,
        }

    @staticmethod
    def _progress_metrics(member):
        """Weight trend and goal progress."""
        measurements = ProgressMeasurement.objects.filter(
            member=member
        ).order_by('-recorded_date')[:5]

        weight_trend = [
            {
                'date': m.recorded_date.strftime('%Y-%m-%d'),
                'weight_kg': m.weight_kg,
                'body_fat': m.body_fat_percentage,
            }
            for m in reversed(list(measurements))
        ]

        active_goals = FitnessGoal.objects.filter(
            member=member, status=GoalStatus.ACTIVE
        )
        goals_data = [
            {
                'goal_type': goal.goal_type,
                'target_weight': goal.target_weight,
                'progress': goal.current_progress_percentage,
            }
            for goal in active_goals
        ]

        return {
            'weight_trend': weight_trend,
            'active_goals': goals_data,
            'active_goals_count': active_goals.count(),
        }

    @staticmethod
    def _membership_metrics(member, today):
        """Current membership status and expiry info."""
        active_membership = Membership.objects.filter(
            member=member, status='ACTIVE'
        ).order_by('-end_date').first()

        if not active_membership:
            return {
                'has_active_membership': False,
                'plan_name': None,
                'days_remaining': 0,
            }

        days_remaining = (active_membership.end_date - today).days

        return {
            'has_active_membership': True,
            'plan_name': active_membership.membership_plan.plan_name,
            'start_date': active_membership.start_date.strftime('%Y-%m-%d'),
            'end_date': active_membership.end_date.strftime('%Y-%m-%d'),
            'days_remaining': max(0, days_remaining),
        }
