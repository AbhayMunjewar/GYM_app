import logging
from datetime import date, timedelta
from django.db.models import Sum, Q, Count
from django.utils import timezone

from members.models import Member
from attendance.models import Attendance
from workout_sessions.models import SessionBooking
from diets.models import MemberDietPlan, DietLog
from progress_tracking.models import ProgressMeasurement, FitnessGoal
from gamification.models import Streak, RewardPointTransaction, MemberBadge, ChallengeParticipation

logger = logging.getLogger(__name__)

class AIContextEngine:
    """
    Consolidates the full tenant member data context:
    profile, goals, attendance, workouts, diets, progress, achievements, challenges.
    """

    @staticmethod
    def calculate_age(dob: date) -> int:
        if not dob:
            return 0
        today = date.today()
        return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))

    @classmethod
    def get_member_context(cls, member: Member) -> dict:
        """
        Gathers complete context about a member.
        Returns a dictionary.
        """
        now = timezone.now()
        today = date.today()
        thirty_days_ago = today - timedelta(days=30)

        # 1. Profile Context
        context = {
            'member_id': str(member.id),
            'full_name': member.full_name,
            'email': member.email,
            'gender': member.gender or 'Not Specified',
            'age': cls.calculate_age(member.date_of_birth),
            'height_cm': member.height_cm or 0.0,
            'weight_kg': member.weight_kg or 0.0,
            'join_date': str(member.join_date),
            'status': member.status,
        }

        # 2. Goals Context
        goals = FitnessGoal.objects.filter(member=member).order_by('-created_at')
        active_goals = goals.filter(status='ACTIVE')
        context['active_goals'] = [
            {
                'goal_type': g.goal_type,
                'starting_weight': g.starting_weight,
                'target_weight': g.target_weight,
                'starting_body_fat': g.starting_body_fat,
                'target_body_fat': g.target_body_fat,
                'target_date': str(g.target_date),
                'progress_percentage': g.current_progress_percentage,
            }
            for g in active_goals
        ]
        context['has_active_goals'] = len(context['active_goals']) > 0

        # 3. Attendance Context
        attendance_qs = Attendance.objects.filter(member=member, is_deleted=False)
        total_attendance = attendance_qs.count()
        last_30d_attendance = attendance_qs.filter(attendance_date__gte=thirty_days_ago).count()
        consistency_rate = (last_30d_attendance / 30.0) * 100.0

        attendance_streak = Streak.objects.filter(member=member, streak_type='ATTENDANCE').first()
        streak_days = attendance_streak.current_streak if attendance_streak else 0
        longest_streak = attendance_streak.longest_streak if attendance_streak else 0

        context['attendance'] = {
            'total_present_days': total_attendance,
            'last_30d_count': last_30d_attendance,
            'consistency_rate_30d': round(consistency_rate, 1),
            'current_streak_days': streak_days,
            'longest_streak_days': longest_streak,
        }

        # 4. Workout Plans Context
        bookings = SessionBooking.objects.filter(member=member).select_related('session')
        booked_sessions = bookings.filter(status='booked').order_by('session__session_date')
        completed_sessions = bookings.filter(status='completed').count()

        context['workouts'] = {
            'completed_sessions_count': completed_sessions,
            'upcoming_booked_sessions': [
                {
                    'title': b.session.title,
                    'description': b.session.description or '',
                    'date': str(b.session.session_date),
                    'time': f"{b.session.start_time}-{b.session.end_time}",
                    'trainer': b.session.trainer.user.get_full_name() if b.session.trainer else 'N/A'
                }
                for b in booked_sessions[:5]
            ]
        }

        # 5. Diet Plans Context
        active_diet = MemberDietPlan.objects.filter(member=member, status='ACTIVE').first()
        diet_context = {'has_active_diet': False}
        if active_diet:
            dp = active_diet.diet_plan
            diet_logs = DietLog.objects.filter(assigned_diet=active_diet)
            total_logged = diet_logs.count()
            completed_logs = diet_logs.filter(completed=True).count()
            compliance_rate = (completed_logs / total_logged * 100.0) if total_logged > 0 else 0.0

            diet_context = {
                'has_active_diet': True,
                'plan_name': dp.plan_name,
                'goal': dp.goal,
                'target_calories': dp.target_calories,
                'target_protein_g': dp.target_protein,
                'target_carbs_g': dp.target_carbs,
                'target_fats_g': dp.target_fats,
                'compliance_rate': round(compliance_rate, 1),
            }
        context['diet'] = diet_context

        # 6. Progress Context
        measurements = ProgressMeasurement.objects.filter(member=member).order_by('-recorded_date')
        progress_context = {
            'measurement_count': measurements.count(),
            'history': []
        }
        if measurements.exists():
            latest = measurements.first()
            progress_context['latest_measurement'] = {
                'weight_kg': latest.weight_kg,
                'body_fat_percentage': latest.body_fat_percentage,
                'bmi': latest.bmi,
                'recorded_date': str(latest.recorded_date),
            }
            # Historical trends (up to last 5)
            for m in measurements[:5]:
                progress_context['history'].append({
                    'weight_kg': m.weight_kg,
                    'body_fat_percentage': m.body_fat_percentage,
                    'bmi': m.bmi,
                    'recorded_date': str(m.recorded_date),
                })
        context['progress'] = progress_context

        # 7. Achievements Context
        badge_transactions = MemberBadge.objects.filter(member=member).select_related('badge')
        point_transactions = RewardPointTransaction.objects.filter(member=member)
        points_balance = point_transactions.aggregate(total=Sum('points_earned'))['total'] or 0

        context['achievements'] = {
            'points_balance': points_balance,
            'badges': [
                {
                    'name': b.badge.badge_name,
                    'description': b.badge.description,
                    'icon': b.badge.icon,
                    'unlocked_at': str(b.unlocked_at),
                }
                for b in badge_transactions
            ]
        }

        # 8. Challenges Context
        challenges = ChallengeParticipation.objects.filter(member=member).select_related('challenge')
        context['challenges'] = {
            'active': [
                {
                    'name': c.challenge.challenge_name,
                    'description': c.challenge.description,
                    'progress': c.progress,
                    'target': c.challenge.target_value,
                    'completion_percentage': c.completion_percentage,
                    'end_date': str(c.challenge.end_date),
                }
                for c in challenges.filter(completed_at__isnull=True)
            ],
            'completed_count': challenges.filter(completed_at__isnull=False).count(),
        }

        return context
