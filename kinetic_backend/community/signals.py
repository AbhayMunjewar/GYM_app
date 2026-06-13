import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone

from gamification.models import MemberBadge, ChallengeParticipation, Streak, StreakType
from progress_tracking.models import FitnessGoal, ProgressMilestone, GoalStatus
from .services import CommunityService
from .models import CommunityEventType, CommunityEvent

logger = logging.getLogger(__name__)

@receiver(post_save, sender=MemberBadge)
def handle_badge_unlocked(sender, instance, created, **kwargs):
    """
    Spawns community event when a member unlocks a badge.
    """
    if created:
        try:
            CommunityService.create_event_from_milestone(
                member=instance.member,
                event_type=CommunityEventType.BADGE_UNLOCKED,
                title=f"Unlocked Badge: {instance.badge.badge_name}! 🏆",
                description=f"{instance.member.full_name} unlocked the '{instance.badge.badge_name}' badge for completing criteria: {instance.badge.description}.",
                metadata={
                    "badge_id": str(instance.badge.id),
                    "badge_name": instance.badge.badge_name,
                    "points_reward": instance.badge.points_reward
                }
            )
        except Exception as e:
            logger.error(f"Error sharing badge achievement signal: {e}")


@receiver(post_save, sender=ChallengeParticipation)
def handle_challenge_completed(sender, instance, created, **kwargs):
    """
    Spawns community event when a challenge is successfully completed.
    """
    # Trigger only when completed_at becomes set (meaning they just completed the challenge)
    if instance.completed_at and not created:
        # Check python-side for duplicates to avoid SQL path lookups
        events = CommunityEvent.objects.filter(
            member=instance.member,
            event_type=CommunityEventType.CHALLENGE_COMPLETED
        )
        duplicate = any(e.metadata.get('challenge_id') == str(instance.challenge.id) for e in events)
        
        if not duplicate:
            try:
                CommunityService.create_event_from_milestone(
                    member=instance.member,
                    event_type=CommunityEventType.CHALLENGE_COMPLETED,
                    title=f"Completed Challenge: {instance.challenge.challenge_name}! 🎉",
                    description=f"{instance.member.full_name} completed the '{instance.challenge.challenge_name}' challenge! Target achieved: {instance.challenge.target_value}.",
                    metadata={
                        "challenge_id": str(instance.challenge.id),
                        "challenge_name": instance.challenge.challenge_name,
                        "reward_points": instance.challenge.reward_points
                    }
                )
            except Exception as e:
                logger.error(f"Error sharing challenge completion signal: {e}")


@receiver(post_save, sender=FitnessGoal)
def handle_goal_achieved(sender, instance, created, **kwargs):
    """
    Spawns community event when a member achieves a fitness goal.
    """
    if instance.status == GoalStatus.ACHIEVED:
        events = CommunityEvent.objects.filter(
            member=instance.member,
            event_type=CommunityEventType.GOAL_ACHIEVED
        )
        duplicate = any(e.metadata.get('goal_id') == str(instance.id) for e in events)

        if not duplicate:
            try:
                CommunityService.create_event_from_milestone(
                    member=instance.member,
                    event_type=CommunityEventType.GOAL_ACHIEVED,
                    title=f"Achieved Fitness Goal! 💪",
                    description=f"{instance.member.full_name} achieved their fitness goal: {instance.get_goal_type_display()}.",
                    metadata={
                        "goal_id": str(instance.id),
                        "goal_type": instance.goal_type,
                        "target_weight": instance.target_weight,
                        "target_body_fat": instance.target_body_fat
                    }
                )
            except Exception as e:
                logger.error(f"Error sharing goal achievement signal: {e}")


@receiver(post_save, sender=ProgressMilestone)
def handle_milestone_achieved(sender, instance, created, **kwargs):
    """
    Spawns community event when a general progress milestone (like weight loss milestone) is achieved.
    """
    if created:
        try:
            CommunityService.create_event_from_milestone(
                member=instance.member,
                event_type=CommunityEventType.WEIGHT_LOSS_MILESTONE,
                title=f"Milestone Achieved: {instance.milestone_name}! 🚀",
                description=f"{instance.member.full_name} reached a new milestone: {instance.milestone_name} ({instance.achievement_value}).",
                metadata={
                    "milestone_id": str(instance.id),
                    "milestone_name": instance.milestone_name,
                    "achievement_value": instance.achievement_value
                }
            )
        except Exception as e:
            logger.error(f"Error sharing milestone achievement signal: {e}")


@receiver(post_save, sender=Streak)
def handle_streak_milestone(sender, instance, created, **kwargs):
    """
    Spawns community event when a member hits a streak milestone (e.g. 7, 30, 50, 100 days).
    """
    milestones = [7, 15, 30, 50, 100, 200, 365]
    if instance.current_streak in milestones:
        today = timezone.localdate()
        events = CommunityEvent.objects.filter(
            member=instance.member,
            event_type=CommunityEventType.STREAK_ACHIEVED,
            created_at__date=today
        )
        duplicate = any(
            e.metadata.get('streak_count') == instance.current_streak and 
            e.metadata.get('streak_type') == instance.streak_type
            for e in events
        )

        if not duplicate:
            try:
                type_display = instance.streak_type.lower().capitalize()
                CommunityService.create_event_from_milestone(
                    member=instance.member,
                    event_type=CommunityEventType.STREAK_ACHIEVED,
                    title=f"{instance.current_streak} Day {type_display} Streak! 🔥",
                    description=f"{instance.member.full_name} achieved an impressive {instance.current_streak}-day {instance.streak_type.lower()} streak! Keep the momentum going!",
                    metadata={
                        "streak_id": str(instance.id),
                        "streak_count": instance.current_streak,
                        "streak_type": instance.streak_type
                    }
                )
            except Exception as e:
                logger.error(f"Error sharing streak milestone signal: {e}")
