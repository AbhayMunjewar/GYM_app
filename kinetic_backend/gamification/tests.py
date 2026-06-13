from datetime import date, timedelta
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from accounts.models import User
from gyms.models import Gym
from members.models import Member
from attendance.models import Attendance
from progress_tracking.models import FitnessGoal, GoalStatus, GoalType
from memberships.models import MembershipPlan, Membership
from .models import (
    ActivityType, PointRule, RewardPointTransaction,
    Streak, StreakType, Badge, MemberBadge,
    Challenge, ChallengeParticipation, ChallengeStatus,
    RewardCatalog, RewardRedemption, RedemptionStatus
)
from .services import (
    PointsService, StreakService, BadgeService, ChallengeService,
    LeaderboardService, RedemptionService, GamificationEngine
)

class GamificationTestBase(TestCase):
    def setUp(self):
        # Users
        self.owner_user = User.objects.create_user(
            email='owner@test.com', password='TestPass123!',
            full_name='Test Owner', role='OWNER', is_verified=True
        )
        self.member_user = User.objects.create_user(
            email='member@test.com', password='TestPass123!',
            full_name='Test Member', role='MEMBER', is_verified=True
        )
        self.member_user_2 = User.objects.create_user(
            email='member2@test.com', password='TestPass123!',
            full_name='Test Member 2', role='MEMBER', is_verified=True
        )

        # Gym
        self.gym = Gym.objects.create(
            owner=self.owner_user, gym_name='Kinetic Gym',
            address='123 main st', city='TestCity', state='TS', pincode='12345',
            contact_number='9876543210', email='gym@test.com'
        )

        # Members
        self.member = Member.objects.create(
            gym=self.gym, full_name='Test Member',
            email='member@test.com', phone_number='1234567890', status='ACTIVE'
        )
        self.member_2 = Member.objects.create(
            gym=self.gym, full_name='Test Member 2',
            email='member2@test.com', phone_number='9876543210', status='ACTIVE'
        )

        # Membership setup for testing
        self.plan = MembershipPlan.objects.create(
            gym=self.gym, plan_name='Basic Plan', duration_days=30, price=1000.0
        )
        self.membership = Membership.objects.create(
            member=self.member, membership_plan=self.plan,
            start_date=timezone.localdate() - timedelta(days=5),
            end_date=timezone.localdate() + timedelta(days=25),
            status='ACTIVE'
        )

        # Point Rules
        PointRule.objects.create(activity_type=ActivityType.ATTENDANCE, points_value=10)
        PointRule.objects.create(activity_type=ActivityType.WORKOUT_COMPLETION, points_value=20)
        PointRule.objects.create(activity_type=ActivityType.DIET_COMPLETION, points_value=15)
        PointRule.objects.create(activity_type=ActivityType.GOAL_ACHIEVEMENT, points_value=200)
        PointRule.objects.create(activity_type=ActivityType.CHALLENGE_COMPLETION, points_value=300)
        PointRule.objects.create(activity_type=ActivityType.BADGE_UNLOCKED, points_value=50)

        # Badges
        BadgeService.initialize_default_badges()

        # Challenges
        self.challenge = Challenge.objects.create(
            challenge_name='30-Day Attendance',
            challenge_type='ATTENDANCE',
            description='Check-in 30 times.',
            target_value=30.0,
            start_date=timezone.localdate() - timedelta(days=5),
            end_date=timezone.localdate() + timedelta(days=25),
            reward_points=300,
            status=ChallengeStatus.ACTIVE
        )

        # Reward Catalog
        self.catalog_item = RewardCatalog.objects.create(
            title='Free PT Session',
            description='1-on-1 personal training.',
            points_cost=100
        )

        self.client = APIClient()

class PointsAndStreakTests(GamificationTestBase):
    def test_award_points(self):
        txn = PointsService.award_points(self.member, ActivityType.ATTENDANCE)
        self.assertIsNotNone(txn)
        self.assertEqual(txn.points_earned, 10)
        self.assertEqual(PointsService.get_points_balance(self.member), 10)

    def test_prevent_duplicate_rewards(self):
        ref = "unique_checkin_123"
        txn1 = PointsService.award_points(self.member, ActivityType.ATTENDANCE, reference_id=ref)
        self.assertIsNotNone(txn1)
        
        # Second attempt with same reference_id
        txn2 = PointsService.award_points(self.member, ActivityType.ATTENDANCE, reference_id=ref)
        self.assertIsNone(txn2)
        self.assertEqual(PointsService.get_points_balance(self.member), 10)

    def test_streak_calculations(self):
        today = timezone.localdate()
        yesterday = today - timedelta(days=1)
        
        # Day 1
        StreakService.update_streak(self.member, StreakType.ATTENDANCE, yesterday)
        streak = Streak.objects.get(member=self.member, streak_type=StreakType.ATTENDANCE)
        self.assertEqual(streak.current_streak, 1)
        self.assertEqual(streak.longest_streak, 1)

        # Day 2 (Consecutive)
        StreakService.update_streak(self.member, StreakType.ATTENDANCE, today)
        streak.refresh_from_db()
        self.assertEqual(streak.current_streak, 2)
        self.assertEqual(streak.longest_streak, 2)

    def test_streak_break_and_decay(self):
        today = timezone.localdate()
        three_days_ago = today - timedelta(days=3)
        yesterday = today - timedelta(days=1)

        # Init streak three days ago
        StreakService.update_streak(self.member, StreakType.ATTENDANCE, three_days_ago)
        
        # Decay check
        streak = Streak.objects.get(member=self.member, streak_type=StreakType.ATTENDANCE)
        StreakService.check_and_decay_streak(streak)
        self.assertEqual(streak.current_streak, 0) # Missed consecutive days decay to 0

        # Start new streak today
        StreakService.update_streak(self.member, StreakType.ATTENDANCE, today)
        streak.refresh_from_db()
        self.assertEqual(streak.current_streak, 1)
        self.assertEqual(streak.longest_streak, 1) # Retains longest_streak history

class BadgeAndChallengeTests(GamificationTestBase):
    def test_automatic_badge_unlock(self):
        # Create 1 check-in to trigger 'First Gym Visit' criteria
        PointsService.award_points(self.member, ActivityType.ATTENDANCE)
        Attendance.objects.create(
            gym=self.gym, member=self.member, membership=self.membership,
            attendance_date=timezone.localdate(),
            attendance_status='PRESENT'
        )

        BadgeService.evaluate_badges(self.member)
        unlocked = MemberBadge.objects.filter(member=self.member, badge__criteria='check_ins_1').exists()
        self.assertTrue(unlocked)
        # Verify points awarded for unlock
        self.assertGreater(PointsService.get_points_balance(self.member), 10)

    def test_challenge_participation_and_progress(self):
        ChallengeService.join_challenge(self.member, self.challenge.id)
        part = ChallengeParticipation.objects.get(member=self.member, challenge=self.challenge)
        self.assertEqual(part.progress, 0.0)

        # Trigger progress increment
        ChallengeService.update_challenge_progress(self.member, 'ATTENDANCE', increment=5.0)
        part.refresh_from_db()
        self.assertEqual(part.progress, 5.0)
        self.assertEqual(part.completion_percentage, 16.7)

    def test_challenge_autocompletion(self):
        ChallengeService.join_challenge(self.member, self.challenge.id)
        # Completes target of 30
        ChallengeService.update_challenge_progress(self.member, 'ATTENDANCE', increment=30.0)
        part = ChallengeParticipation.objects.get(member=self.member, challenge=self.challenge)
        self.assertEqual(part.completion_percentage, 100.0)
        self.assertIsNotNone(part.completed_at)
        
        # Check challenge reward points awarded
        balance = PointsService.get_points_balance(self.member)
        self.assertGreaterEqual(balance, 300)

class LeaderboardAndRedemptionTests(GamificationTestBase):
    def test_leaderboard_rankings(self):
        # Member 1 earns 100 points
        PointsService.award_points(self.member, ActivityType.WORKOUT_COMPLETION, points=100)
        # Member 2 earns 200 points
        PointsService.award_points(self.member_2, ActivityType.WORKOUT_COMPLETION, points=200)

        leaderboard = LeaderboardService.get_leaderboard(self.gym, period='all_time')
        self.assertEqual(len(leaderboard), 2)
        # Member 2 must be rank 1
        self.assertEqual(leaderboard[0]['member_id'], str(self.member_2.id))
        self.assertEqual(leaderboard[0]['total_points'], 200)

    def test_reward_redemption_workflow(self):
        # Earn points first
        PointsService.award_points(self.member, ActivityType.GOAL_ACHIEVEMENT, points=150)
        
        # Claim reward
        redemption = RedemptionService.redeem_reward(self.member, self.catalog_item.id)
        self.assertEqual(redemption.status, RedemptionStatus.PENDING)
        self.assertEqual(PointsService.get_points_balance(self.member), 50) # deducted 100

        # Approve redemption
        RedemptionService.approve_redemption(redemption.id, self.owner_user)
        redemption.refresh_from_db()
        self.assertEqual(redemption.status, RedemptionStatus.APPROVED)

    def test_insufficient_points_fails(self):
        with self.assertRaises(ValueError):
            RedemptionService.redeem_reward(self.member, self.catalog_item.id)

    def test_reject_redemption_refunds_points(self):
        PointsService.award_points(self.member, ActivityType.GOAL_ACHIEVEMENT, points=150)
        redemption = RedemptionService.redeem_reward(self.member, self.catalog_item.id)
        self.assertEqual(PointsService.get_points_balance(self.member), 50)

        # Reject redemption
        RedemptionService.reject_redemption(redemption.id, self.owner_user, reason="Out of stock")
        redemption.refresh_from_db()
        self.assertEqual(redemption.status, RedemptionStatus.REJECTED)
        self.assertEqual(PointsService.get_points_balance(self.member), 150) # refunded 100

class APIViewsTests(GamificationTestBase):
    def test_points_balance_api(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/rewards/points/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['data']['balance'], 0)

    def test_join_challenge_api(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.post('/api/challenges/join/', {'challenge_id': str(self.challenge.id)})
        self.assertEqual(response.status_code, 201)
        self.assertTrue(ChallengeParticipation.objects.filter(member=self.member, challenge=self.challenge).exists())

    def test_leaderboard_api_rbac(self):
        # Members can access leaderboard
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/leaderboards/')
        self.assertEqual(response.status_code, 200)

        # Owner can access leaderboard
        self.client.force_authenticate(user=self.owner_user)
        response = self.client.get('/api/leaderboards/')
        self.assertEqual(response.status_code, 200)
