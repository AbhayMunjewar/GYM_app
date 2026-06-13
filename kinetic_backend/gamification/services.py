from datetime import date, timedelta
from django.db.models import Sum, Count, Q
from django.utils import timezone
from django.db import transaction

from members.models import Member
from accounts.models import User
from notifications.services import NotificationService
from notifications.models import NotificationType, NotificationPriority

from .models import (
    ActivityType, PointRule, RewardPointTransaction,
    Streak, StreakType, Badge, MemberBadge,
    Challenge, ChallengeParticipation, ChallengeStatus,
    RewardCatalog, RewardRedemption, RedemptionStatus
)

class PointsService:
    @staticmethod
    def get_points_balance(member):
        """Returns the current points balance of a member."""
        agg = RewardPointTransaction.objects.filter(member=member).aggregate(total=Sum('points_earned'))
        return agg['total'] if agg['total'] is not None else 0

    @staticmethod
    @transaction.atomic
    def award_points(member, activity_type, points=None, reference_id=None, description=""):
        """
        Awards points to a member, creating a transaction ledger entry.
        Prevents double-awarding for same activity/reference (e.g. check-in on same day).
        """
        # Prevent duplicate awarding if reference_id is provided
        if reference_id:
            duplicate = RewardPointTransaction.objects.filter(
                member=member,
                activity_type=activity_type,
                reference_id=str(reference_id)
            ).exists()
            if duplicate:
                return None

        # Resolve point value
        if points is None:
            rule = PointRule.objects.filter(activity_type=activity_type, is_active=True).first()
            points = rule.points_value if rule else 0

        if points == 0:
            return None

        current_balance = PointsService.get_points_balance(member)
        new_balance = max(0, current_balance + points)

        txn = RewardPointTransaction.objects.create(
            member=member,
            activity_type=activity_type,
            points_earned=points,
            points_balance=new_balance,
            reference_id=str(reference_id) if reference_id else None,
            description=description
        )

        # Send notification
        user = User.objects.filter(email=member.email).first()
        if user and points > 0:
            NotificationService.create_notification(
                recipient=user,
                title="Points Earned!",
                message=f"You earned {points} points for {activity_type.replace('_', ' ').title()}. Balance: {new_balance} pts.",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.LOW
            )

        return txn

class StreakService:
    @staticmethod
    def check_and_decay_streak(streak):
        """Sets current streak to 0 if the last activity was before yesterday."""
        today = timezone.localdate()
        if streak.last_activity_date and streak.last_activity_date < today - timedelta(days=1):
            streak.current_streak = 0
            streak.save(update_fields=['current_streak'])
        return streak

    @staticmethod
    def get_member_streaks(member):
        """Returns all streaks for a member, decaying them first."""
        streaks = list(Streak.objects.filter(member=member))
        for s in streaks:
            StreakService.check_and_decay_streak(s)
        return streaks

    @staticmethod
    def update_streak(member, streak_type, activity_date):
        """
        Increments, retains, or resets a streak based on activity date.
        """
        streak, created = Streak.objects.get_or_create(
            member=member,
            streak_type=streak_type,
            defaults={'current_streak': 0, 'longest_streak': 0}
        )

        StreakService.check_and_decay_streak(streak)

        if not streak.last_activity_date:
            streak.current_streak = 1
            streak.last_activity_date = activity_date
            streak.longest_streak = max(streak.longest_streak, 1)
        elif streak.last_activity_date == activity_date:
            # Already logged today
            pass
        elif streak.last_activity_date == activity_date - timedelta(days=1):
            # Consecutive day
            streak.current_streak += 1
            streak.last_activity_date = activity_date
            streak.longest_streak = max(streak.longest_streak, streak.current_streak)
        else:
            # Broken streak (decayed or missed a day)
            streak.current_streak = 1
            streak.last_activity_date = activity_date
            streak.longest_streak = max(streak.longest_streak, 1)

        streak.save()

        # Handle streak bonus triggers
        if streak.current_streak == 7:
            PointsService.award_points(
                member=member,
                activity_type=ActivityType.BADGE_UNLOCKED,
                points=50,
                reference_id=f"streak_7_bonus_{streak_type}_{activity_date}",
                description=f"7-Day {streak_type.title()} Streak Bonus!"
            )

        return streak

class BadgeService:
    @staticmethod
    def initialize_default_badges():
        """Creates the initial set of default badges if they do not exist."""
        default_badges = [
            {
                'badge_name': 'First Gym Visit',
                'badge_type': 'ATTENDANCE',
                'description': 'Welcome to the gym! Checked in for the first time.',
                'icon': 'check_circle',
                'points_reward': 20,
                'criteria': 'check_ins_1'
            },
            {
                'badge_name': '7-Day Streak',
                'badge_type': 'ATTENDANCE',
                'description': 'Maintained a 7-day attendance streak.',
                'icon': 'local_fire_department',
                'points_reward': 50,
                'criteria': 'attendance_streak_7'
            },
            {
                'badge_name': '30-Day Streak',
                'badge_type': 'ATTENDANCE',
                'description': 'Maintained a 30-day attendance streak.',
                'icon': 'workspace_premium',
                'points_reward': 150,
                'criteria': 'attendance_streak_30'
            },
            {
                'badge_name': 'First Workout Done',
                'badge_type': 'WORKOUT',
                'description': 'Completed your first scheduled workout session.',
                'icon': 'fitness_center',
                'points_reward': 20,
                'criteria': 'workouts_1'
            },
            {
                'badge_name': 'First Meal Logged',
                'badge_type': 'DIET',
                'description': 'Completed your first diet meal entry.',
                'icon': 'apple',
                'points_reward': 20,
                'criteria': 'diets_1'
            },
            {
                'badge_name': 'Goal Crusher',
                'badge_type': 'GOAL',
                'description': 'Achieved your first fitness goal.',
                'icon': 'emoji_events',
                'points_reward': 200,
                'criteria': 'goals_1'
            },
            {
                'badge_name': 'Centurion',
                'badge_type': 'WORKOUT',
                'description': 'Completed 100 workout sessions.',
                'icon': 'shield',
                'points_reward': 500,
                'criteria': 'workouts_100'
            }
        ]

        for b in default_badges:
            Badge.objects.get_or_create(badge_name=b['badge_name'], defaults=b)

    @staticmethod
    def evaluate_badges(member):
        """
        Evaluates criteria metrics for a member and unlocks any earned badges.
        """
        # Ensure default badges are present
        BadgeService.initialize_default_badges()

        # Gather metrics
        total_checkins = member.attendances.filter(attendance_status='PRESENT', is_deleted=False).count()
        attendance_streak = Streak.objects.filter(member=member, streak_type=StreakType.ATTENDANCE).first()
        attendance_streak_val = attendance_streak.longest_streak if attendance_streak else 0

        workout_bookings = member.bookings.filter(status='completed').count()
        diet_logs = member.diet_logs.filter(completed=True).count()
        goals_achieved = member.fitness_goals.filter(status='ACHIEVED').count()

        unlocked_badges = list(MemberBadge.objects.filter(member=member).values_list('badge_id', flat=True))
        all_badges = Badge.objects.exclude(id__in=unlocked_badges)

        for badge in all_badges:
            crit = badge.criteria
            should_unlock = False

            if crit == 'check_ins_1' and total_checkins >= 1:
                should_unlock = True
            elif crit == 'attendance_streak_7' and attendance_streak_val >= 7:
                should_unlock = True
            elif crit == 'attendance_streak_30' and attendance_streak_val >= 30:
                should_unlock = True
            elif crit == 'workouts_1' and workout_bookings >= 1:
                should_unlock = True
            elif crit == 'workouts_100' and workout_bookings >= 100:
                should_unlock = True
            elif crit == 'diets_1' and diet_logs >= 1:
                should_unlock = True
            elif crit == 'goals_1' and goals_achieved >= 1:
                should_unlock = True

            if should_unlock:
                MemberBadge.objects.create(member=member, badge=badge)
                # Award badge points
                PointsService.award_points(
                    member=member,
                    activity_type=ActivityType.BADGE_UNLOCKED,
                    points=badge.points_reward,
                    reference_id=badge.id,
                    description=f"Unlocked Badge: {badge.badge_name}!"
                )
                # Notification
                user = User.objects.filter(email=member.email).first()
                if user:
                    NotificationService.create_notification(
                        recipient=user,
                        title="New Badge Unlocked! 🏆",
                        message=f"Congratulations! You unlocked the '{badge.badge_name}' badge and earned {badge.points_reward} points.",
                        notification_type=NotificationType.ACHIEVEMENT,
                        priority=NotificationPriority.HIGH
                    )

class ChallengeService:
    @staticmethod
    def get_active_challenges():
        """Returns all challenges currently in active status and date bounds."""
        today = timezone.localdate()
        # Auto-update status of challenges
        Challenge.objects.filter(start_date__lte=today, end_date__gte=today, status=ChallengeStatus.UPCOMING).update(status=ChallengeStatus.ACTIVE)
        Challenge.objects.filter(end_date__lt=today, status=ChallengeStatus.ACTIVE).update(status=ChallengeStatus.EXPIRED)
        return Challenge.objects.filter(status=ChallengeStatus.ACTIVE)

    @staticmethod
    def join_challenge(member, challenge_id):
        """Allows a member to join an active challenge."""
        challenge = Challenge.objects.get(id=challenge_id)
        if challenge.status != ChallengeStatus.ACTIVE:
            raise ValueError("Challenge is not active.")

        today = timezone.localdate()
        if today > challenge.end_date:
            raise ValueError("Challenge has already ended.")

        participation, created = ChallengeParticipation.objects.get_or_create(
            member=member,
            challenge=challenge
        )
        return participation

    @staticmethod
    def update_challenge_progress(member, challenge_type, increment=1.0):
        """
        Increments challenge progress for a member based on challenge type.
        Automatically handles challenge completion and awards points.
        """
        today = timezone.localdate()
        participations = ChallengeParticipation.objects.filter(
            member=member,
            challenge__challenge_type=challenge_type,
            challenge__status=ChallengeStatus.ACTIVE,
            completed_at__isnull=True
        )

        for part in participations:
            challenge = part.challenge
            part.progress += increment
            pct = min(100.0, (part.progress / challenge.target_value) * 100.0)
            part.completion_percentage = round(pct, 1)

            if part.progress >= challenge.target_value:
                part.completed_at = timezone.now()
                part.completion_percentage = 100.0
                # Award Points
                PointsService.award_points(
                    member=member,
                    activity_type=ActivityType.CHALLENGE_COMPLETION,
                    points=challenge.reward_points,
                    reference_id=challenge.id,
                    description=f"Completed Challenge: {challenge.challenge_name}!"
                )
                # Notification
                user = User.objects.filter(email=member.email).first()
                if user:
                    NotificationService.create_notification(
                        recipient=user,
                        title="Challenge Completed! 🎉",
                        message=f"Outstanding! You've completed the '{challenge.challenge_name}' challenge and won {challenge.reward_points} points.",
                        notification_type=NotificationType.ACHIEVEMENT,
                        priority=NotificationPriority.HIGH
                    )
            part.save()

class LeaderboardService:
    @staticmethod
    def get_leaderboard(gym, period='all_time', limit=50):
        """
        Generates leaderboard rankings efficiently based on period.
        Daily, Weekly, Monthly, and All-Time are supported.
        """
        today = timezone.localdate()
        txns = RewardPointTransaction.objects.filter(member__gym=gym)

        if period == 'daily':
            txns = txns.filter(created_at__date=today)
        elif period == 'weekly':
            txns = txns.filter(created_at__date__gte=today - timedelta(days=7))
        elif period == 'monthly':
            txns = txns.filter(created_at__date__gte=today - timedelta(days=30))

        # Sum positive points earned grouped by member
        rankings = txns.filter(points_earned__gt=0).values('member').annotate(
            total_points=Sum('points_earned'),
            activities_count=Count('id')
        ).order_by('-total_points')[:limit]

        # Hydrate with Member details
        leaderboard = []
        for index, r in enumerate(rankings):
            m = Member.objects.get(id=r['member'])
            # Check consistency (attendance streak)
            streak_obj = Streak.objects.filter(member=m, streak_type=StreakType.ATTENDANCE).first()
            current_streak = streak_obj.current_streak if streak_obj else 0
            
            leaderboard.append({
                'rank': index + 1,
                'member_id': str(m.id),
                'member_name': m.full_name,
                'total_points': r['total_points'],
                'activities_count': r['activities_count'],
                'streak': current_streak
            })

        return leaderboard

class RedemptionService:
    @staticmethod
    @transaction.atomic
    def redeem_reward(member, catalog_id):
        """
        Redeems a prize from the catalog if points are sufficient.
        """
        reward = RewardCatalog.objects.get(id=catalog_id, is_active=True)
        balance = PointsService.get_points_balance(member)

        if balance < reward.points_cost:
            raise ValueError("Insufficient reward points balance.")

        # Record redemption
        redemption = RewardRedemption.objects.create(
            member=member,
            reward=reward,
            points_spent=reward.points_cost,
            status=RedemptionStatus.PENDING
        )

        # Deduct points from balance using PointsService
        PointsService.award_points(
            member=member,
            activity_type=ActivityType.BADGE_UNLOCKED, # generic category for deduction
            points=-reward.points_cost,
            reference_id=redemption.id,
            description=f"Redeemed catalog prize: {reward.title}"
        )

        # Notify Owner about pending redemption
        owner = member.gym.owner
        NotificationService.create_notification(
            recipient=owner,
            title="New Reward Redemption Claim",
            message=f"{member.full_name} has claimed '{reward.title}' for {reward.points_cost} points. Approval required.",
            notification_type=NotificationType.SYSTEM,
            priority=NotificationPriority.MEDIUM
        )

        return redemption

    @staticmethod
    @transaction.atomic
    def approve_redemption(redemption_id, owner_user):
        """Approves a pending redemption."""
        redemption = RewardRedemption.objects.get(id=redemption_id)
        if redemption.member.gym.owner != owner_user:
            raise PermissionError("Access denied.")

        if redemption.status != RedemptionStatus.PENDING:
            raise ValueError("Redemption status is not pending.")

        redemption.status = RedemptionStatus.APPROVED
        redemption.approved_by = owner_user
        redemption.save()

        # Notify Member
        user = User.objects.filter(email=redemption.member.email).first()
        if user:
            NotificationService.create_notification(
                recipient=user,
                title="Redemption Approved! 🎁",
                message=f"Your claim for '{redemption.reward.title}' has been approved by the gym owner.",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.HIGH
            )
        return redemption

    @staticmethod
    @transaction.atomic
    def reject_redemption(redemption_id, owner_user, reason=""):
        """Rejects a pending redemption and refunds points."""
        redemption = RewardRedemption.objects.get(id=redemption_id)
        if redemption.member.gym.owner != owner_user:
            raise PermissionError("Access denied.")

        if redemption.status != RedemptionStatus.PENDING:
            raise ValueError("Redemption status is not pending.")

        redemption.status = RedemptionStatus.REJECTED
        redemption.approved_by = owner_user
        redemption.save()

        # Refund points
        PointsService.award_points(
            member=redemption.member,
            activity_type=ActivityType.BADGE_UNLOCKED,
            points=redemption.points_spent,
            reference_id=f"refund_{redemption.id}",
            description=f"Refund: Rejected redemption of {redemption.reward.title}."
        )

        # Notify Member
        user = User.objects.filter(email=redemption.member.email).first()
        if user:
            NotificationService.create_notification(
                recipient=user,
                title="Redemption Rejected",
                message=f"Your claim for '{redemption.reward.title}' was rejected. Reason: {reason}. Points refunded.",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.MEDIUM
            )
        return redemption

class GamificationEngine:
    @staticmethod
    @transaction.atomic
    def trigger_event(member, activity_type, reference_id=None, value=1.0, description=""):
        """
        Master orchestrator trigger.
        1. Awards points.
        2. Updates streaks.
        3. Evaluates badges.
        4. Updates challenges.
        """
        # 1. Resolve points for this activity (if point rule is active)
        rule = PointRule.objects.filter(activity_type=activity_type, is_active=True).first()
        points = rule.points_value if rule else None
        
        # Award points via PointsService (handles duplicate protection)
        txn = PointsService.award_points(
            member=member,
            activity_type=activity_type,
            points=points,
            reference_id=reference_id,
            description=description
        )

        if txn is None and reference_id is not None:
            # Duplicate transaction, skip streaks/badges/challenges to prevent multiple awards
            return

        today = timezone.localdate()

        # 2. Update streaks based on activity type
        if activity_type == ActivityType.ATTENDANCE:
            StreakService.update_streak(member, StreakType.ATTENDANCE, today)
        elif activity_type == ActivityType.WORKOUT_COMPLETION:
            StreakService.update_streak(member, StreakType.WORKOUT, today)
        elif activity_type == ActivityType.DIET_COMPLETION:
            StreakService.update_streak(member, StreakType.DIET, today)

        # 3. Evaluate active challenges
        challenge_type = None
        if activity_type == ActivityType.ATTENDANCE:
            challenge_type = 'ATTENDANCE'
        elif activity_type == ActivityType.WORKOUT_COMPLETION:
            challenge_type = 'WORKOUT'
        elif activity_type == ActivityType.DIET_COMPLETION:
            challenge_type = 'DIET'
        elif activity_type == ActivityType.GOAL_ACHIEVEMENT:
            challenge_type = 'WEIGHT_LOSS'

        if challenge_type:
            ChallengeService.update_challenge_progress(member, challenge_type, increment=value)

        # 4. Evaluate and unlock badges
        BadgeService.evaluate_badges(member)
