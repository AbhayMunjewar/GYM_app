from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.utils import timezone
from datetime import date

from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer
from gamification.models import Badge, MemberBadge, Streak, StreakType, Challenge, ChallengeParticipation
from progress_tracking.models import FitnessGoal, GoalStatus
from notifications.models import Notification
from .models import (
    CommunityPost, PostReaction, PostComment, CommunityEvent, Follow,
    PostType, PostVisibility, PostStatus, ReactionType, CommunityEventType
)
from .services import CommunityService

User = get_user_model()

class CommunityAPITestCase(APITestCase):
    def setUp(self):
        # 1. Create Gyms
        self.owner_user = User.objects.create_user(
            email='owner@test.com',
            password='password123',
            role='OWNER',
            full_name='Gym Owner'
        )
        self.gym_a = Gym.objects.create(
            gym_name='Gym Alpha',
            owner=self.owner_user,
            address='123 Alpha St',
            city='Alpha City',
            state='Alpha State',
            pincode='123456',
            contact_number='1234567890',
            email='alpha@gym.com'
        )
        self.gym_b = Gym.objects.create(
            gym_name='Gym Beta',
            owner=self.owner_user,
            address='456 Beta St',
            city='Beta City',
            state='Beta State',
            pincode='654321',
            contact_number='0987654321',
            email='beta@gym.com'
        )

        # 2. Create Users for Gym A
        self.member_user_a = User.objects.create_user(
            email='membera@test.com',
            password='password123',
            role='MEMBER',
            full_name='Member A'
        )
        self.member_a = Member.objects.create(
            gym=self.gym_a,
            email=self.member_user_a.email,
            full_name=self.member_user_a.full_name,
            phone_number='1112223333'
        )

        self.trainer_user_a = User.objects.create_user(
            email='trainera@test.com',
            password='password123',
            role='TRAINER',
            full_name='Trainer A'
        )
        self.trainer_a = Trainer.objects.create(
            user=self.trainer_user_a,
            gym=self.gym_a,
            employee_id='TRAIN_A_001',
            joining_date=date.today()
        )

        # 3. Create Users for Gym B
        self.member_user_b = User.objects.create_user(
            email='memberb@test.com',
            password='password123',
            role='MEMBER',
            full_name='Member B'
        )
        self.member_b = Member.objects.create(
            gym=self.gym_b,
            email=self.member_user_b.email,
            full_name=self.member_user_b.full_name,
            phone_number='4445556666'
        )

    # --- API SECURITY TESTS ---
    def test_unauthenticated_blocked(self):
        url = reverse('post-list')
        response = self.client.get(url)
        self.assertEqual(response.statusCode if hasattr(response, 'statusCode') else response.status_code, status.HTTP_401_UNAUTHORIZED)

    # --- POST CREATION AND SCROLL TESTS ---
    def test_member_create_post(self):
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('post-list')
        data = {
            'post_type': 'GENERAL',
            'title': 'Crushing it!',
            'content': 'Just finished a heavy leg session.',
            'visibility': 'GYM_ONLY'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(CommunityPost.objects.filter(author=self.member_user_a).count(), 1)
        post = CommunityPost.objects.first()
        self.assertEqual(post.gym, self.gym_a)

    def test_trainer_create_announcement_triggers_notifications(self):
        self.client.force_authenticate(user=self.trainer_user_a)
        url = reverse('post-list')
        data = {
            'post_type': 'ANNOUNCEMENT',
            'title': 'New Gym Hours',
            'content': 'We are open 24/7 now!',
            'visibility': 'GYM_ONLY'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Member A of Gym A should get a notification
        notifications = Notification.objects.filter(recipient=self.member_user_a)
        self.assertEqual(notifications.count(), 1)
        self.assertIn("Trainer A", notifications.first().message)

    # --- MULTI-TENANCY / GYM ISOLATION TESTS ---
    def test_gym_isolation_feed(self):
        # Create a post in Gym A by Member A
        CommunityPost.objects.create(
            author=self.member_user_a,
            gym=self.gym_a,
            post_type=PostType.GENERAL,
            title='Gym A Post',
            content='Alpha gym only',
            visibility=PostVisibility.GYM_ONLY
        )
        # Create a post in Gym B by Member B
        CommunityPost.objects.create(
            author=self.member_user_b,
            gym=self.gym_b,
            post_type=PostType.GENERAL,
            title='Gym B Post',
            content='Beta gym only',
            visibility=PostVisibility.GYM_ONLY
        )

        # Authenticate Member A ➔ Should only see Gym A post in feed
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('feed')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['title'], 'Gym A Post')

        # Authenticate Member B ➔ Should only see Gym B post in feed
        self.client.force_authenticate(user=self.member_user_b)
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['title'], 'Gym B Post')

    # --- REACTION TESTS ---
    def test_react_to_post_and_duplicate_prevention(self):
        post = CommunityPost.objects.create(
            author=self.trainer_user_a,
            gym=self.gym_a,
            post_type=PostType.GENERAL,
            title='Trainer Post',
            content='Hello'
        )

        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('post-react', args=[post.id])
        
        # Add reaction
        response = self.client.post(url, {'reaction_type': 'FIRE'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(PostReaction.objects.filter(post=post).count(), 1)
        self.assertEqual(PostReaction.objects.first().reaction_type, 'FIRE')

        # Verify post author got notified
        notif = Notification.objects.filter(recipient=self.trainer_user_a)
        self.assertEqual(notif.count(), 1)
        self.assertIn("reacted fire", notif.first().message.lower())

        # Update reaction (duplicate prevention / update)
        response = self.client.post(url, {'reaction_type': 'STRONG'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(PostReaction.objects.filter(post=post).count(), 1)
        self.assertEqual(PostReaction.objects.first().reaction_type, 'STRONG')

        # Delete reaction
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(PostReaction.objects.filter(post=post).count(), 0)

    # --- COMMENT TESTS ---
    def test_nested_comments_flow(self):
        post = CommunityPost.objects.create(
            author=self.member_user_a,
            gym=self.gym_a,
            post_type=PostType.GENERAL,
            title='Leg Day',
            content='Squats 150kg'
        )

        self.client.force_authenticate(user=self.trainer_user_a)
        url = reverse('post-comments', args=[post.id])
        
        # 1. Create top-level comment
        response = self.client.post(url, {'content': 'Excellent form!'})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        parent_comment = PostComment.objects.first()
        self.assertEqual(parent_comment.content, 'Excellent form!')

        # 2. Create nested comment reply
        response = self.client.post(url, {
            'content': 'Thanks coach!',
            'parent_comment_id': parent_comment.id
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        reply = PostComment.objects.exclude(id=parent_comment.id).first()
        self.assertEqual(reply.parent_comment, parent_comment)

        # 3. Retrieve comments
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Verify replies are returned nested inside parent comment
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 1)
        self.assertEqual(len(results[0]['replies']), 1)
        self.assertEqual(results[0]['replies'][0]['content'], 'Thanks coach!')

    # --- ACHIEVEMENT AUTO-SHARING TESTS ---
    def test_badge_unlocked_signals_automatic_post(self):
        badge = Badge.objects.create(
            badge_name='Super Supporter',
            badge_type='ATTENDANCE',
            description='Check-in first time',
            icon='star',
            points_reward=50,
            criteria='check_ins_1'
        )

        # Triggers signal post_save on MemberBadge
        MemberBadge.objects.create(
            member=self.member_a,
            badge=badge
        )

        # Verify Event is created
        events = CommunityEvent.objects.filter(member=self.member_a)
        self.assertEqual(events.count(), 1)
        self.assertEqual(events.first().event_type, CommunityEventType.BADGE_UNLOCKED)

        # Verify Community Post is created automatically
        posts = CommunityPost.objects.filter(author=self.member_user_a)
        self.assertEqual(posts.count(), 1)
        self.assertEqual(posts.first().post_type, PostType.ACHIEVEMENT)
        self.assertIn("Super Supporter", posts.first().title)

    # --- ANALYTICS TESTS ---
    def test_community_analytics_endpoint(self):
        target_gym = self.owner_user.gyms.first()
        post = CommunityPost.objects.create(
            author=self.member_user_a,
            gym=target_gym,
            post_type=PostType.GENERAL,
            title='Gym A Post',
            content='Alpha gym only'
        )
        PostReaction.objects.create(post=post, member=self.trainer_user_a, reaction_type='FIRE')
        PostComment.objects.create(post=post, author=self.trainer_user_a, content='Nice')

        self.client.force_authenticate(user=self.owner_user)
        url = reverse('analytics')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data.get('data', response.data)
        self.assertEqual(data['posts_count'], 1)
        self.assertEqual(data['comments_count'], 1)
        self.assertEqual(data['reactions_count'], 1)
        self.assertTrue(data['engagement_rate'] > 0.0)
