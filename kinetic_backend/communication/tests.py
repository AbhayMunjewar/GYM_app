from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.utils import timezone
from datetime import date, timedelta

from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer
from notifications.models import Notification
from community.models import CommunityPost
from .models import (
    Question, Answer, QuestionStatus,
    Group, GroupMember, GroupPost, GroupType, GroupMemberRole,
    Announcement, AnnouncementPriority,
    ChatRoom, ChatParticipant, Message, MessageType,
    ForumCategory, ForumTopic, ForumReply,
    Event, EventRegistration, EventStatus,
    Report, ReportContentType, ReportStatus
)
from .services import (
    QAService, GroupService, AnnouncementService,
    ChatService, ForumService, EventService, ModerationService
)

User = get_user_model()

class CommunicationAPITestCase(APITestCase):
    def setUp(self):
        # 1. Create Owners
        self.owner_user = User.objects.create_user(
            email='owner@test.com',
            password='password123',
            role='OWNER',
            full_name='Gym Owner A'
        )
        self.owner_user_b = User.objects.create_user(
            email='ownerb@test.com',
            password='password123',
            role='OWNER',
            full_name='Gym Owner B'
        )

        # 2. Create Gyms
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
            owner=self.owner_user_b,
            address='456 Beta St',
            city='Beta City',
            state='Beta State',
            pincode='654321',
            contact_number='0987654321',
            email='beta@gym.com'
        )

        # 3. Create Users for Gym A (Member, Trainer)
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

        # 4. Create Users for Gym B (Member B)
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

    # --- API SECURITY & REGISTRATION TESTING ---

    def test_question_workflow(self):
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('question-list')
        
        # 1. Post a question
        data = {
            'title': 'How to perform deadlifts?',
            'question': 'I struggle keeping my back flat. Help!',
            'trainer': str(self.trainer_user_a.id)
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Question.objects.count(), 1)
        question = Question.objects.first()
        self.assertEqual(question.gym, self.gym_a)
        
        # Trainer A should have received a notification
        trainer_notifications = Notification.objects.filter(recipient=self.trainer_user_a)
        self.assertEqual(trainer_notifications.count(), 1)

        # 2. Trainer answers the question
        self.client.force_authenticate(user=self.trainer_user_a)
        answer_url = reverse('question-answers', args=[question.id])
        ans_data = {'answer': 'Ensure your shoulders are slightly in front of the bar, pull your chest up.'}
        response = self.client.post(answer_url, ans_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Question status should be ANSWERED
        question.refresh_from_db()
        self.assertEqual(question.status, QuestionStatus.ANSWERED)
        
        # Member A should get notified of the answer
        member_notifications = Notification.objects.filter(recipient=self.member_user_a)
        self.assertTrue(member_notifications.exists())

        # An automatic CommunityPost sharing the Q&A discussion should be published
        self.assertEqual(CommunityPost.objects.count(), 1)
        self.assertIn("Q&A: How to perform deadlifts?", CommunityPost.objects.first().title)

    def test_gym_isolation_qa(self):
        # Create a question in Gym B by Member B
        Question.objects.create(
            member=self.member_user_b,
            gym=self.gym_b,
            title='Beta Gym Question',
            question='Weight training help'
        )

        # Authenticate Member A (Gym A) ➔ Should not see Gym B question
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('question-list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Results should be empty since Member A has no questions of their own yet
        results = response.data.get('results', response.data)
        self.assertEqual(len(results), 0)

    # --- GROUPS SYSTEM TESTING ---

    def test_groups_system_flow(self):
        self.client.force_authenticate(user=self.trainer_user_a)
        url = reverse('group-list')
        
        # 1. Create a group (Trainers/Owners only)
        data = {
            'group_name': 'Muscle Builders',
            'description': 'For members targeting hypertrophy',
            'group_type': 'PUBLIC'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        group = Group.objects.first()
        self.assertEqual(group.created_by, self.trainer_user_a)

        # 2. Member A joins the group
        self.client.force_authenticate(user=self.member_user_a)
        join_url = reverse('group-join', args=[group.id])
        response = self.client.post(join_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(GroupMember.objects.filter(group=group, user=self.member_user_a).exists())

        # 3. Member A creates a group feed post
        posts_url = reverse('group-posts', args=[group.id])
        post_data = {'content': 'Log day hypertrophic curls 14kg'}
        response = self.client.post(posts_url, post_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(GroupPost.objects.count(), 1)

        # 4. Member A leaves the group
        leave_url = reverse('group-leave', args=[group.id])
        response = self.client.post(leave_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertFalse(GroupMember.objects.filter(group=group, user=self.member_user_a).exists())

    # --- ANNOUNCEMENTS TESTING ---

    def test_announcements_workflow(self):
        # 1. Owner creates announcement
        self.client.force_authenticate(user=self.owner_user)
        url = reverse('announcement-list')
        data = {
            'title': 'New Power Rack Added',
            'description': 'We have installed a state-of-the-art power rack in the weights area.',
            'priority': 'HIGH'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # All active gym members should be notified
        member_notifs = Notification.objects.filter(recipient=self.member_user_a)
        self.assertEqual(member_notifs.count(), 1)
        self.assertEqual(member_notifs.first().title, "Announcement: New Power Rack Added")

        # It should appear on the community feed
        self.assertTrue(CommunityPost.objects.filter(post_type='ANNOUNCEMENT').exists())

    # --- DISCUSSION FORUMS TESTING ---

    def test_discussion_forums_flow(self):
        category = ForumCategory.objects.create(gym=self.gym_a, name='Nutrition', description='Healthy diet discussions')
        
        # Member A creates topic
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('forumtopic-list')
        topic_data = {
            'category': str(category.id),
            'title': 'Best protein intake timing?',
            'content': 'Is it better to consume protein immediately post-workout?'
        }
        response = self.client.post(url, topic_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        topic = ForumTopic.objects.first()

        # Trainer replies to topic
        self.client.force_authenticate(user=self.trainer_user_a)
        reply_url = reverse('forumtopic-replies', args=[topic.id])
        reply_data = {'content': 'Within 2 hours is ideal, but total daily intake matters most!'}
        response = self.client.post(reply_url, reply_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(ForumReply.objects.count(), 1)

    # --- EVENTS SYSTEM TESTING ---

    def test_events_registration_workflow(self):
        event = Event.objects.create(
            gym=self.gym_a,
            title='Yoga Power Hour',
            description='Intense stretch training session',
            start_date=timezone.now() + timedelta(days=1),
            end_date=timezone.now() + timedelta(days=1, hours=1),
            capacity=1,  # Capacity limited to 1 member
            created_by=self.owner_user
        )

        # 1. Member A registers successfully
        self.client.force_authenticate(user=self.member_user_a)
        register_url = reverse('event-register', args=[event.id])
        response = self.client.post(register_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(EventRegistration.objects.count(), 1)

        # 2. Capacity constraint check (fails for another member)
        member_b_gym_a = User.objects.create_user(
            email='memberb_a@test.com',
            password='password123',
            role='MEMBER',
            full_name='Member B in Gym A'
        )
        Member.objects.create(
            gym=self.gym_a,
            email=member_b_gym_a.email,
            full_name=member_b_gym_a.full_name,
            phone_number='9990001111'
        )

        self.client.force_authenticate(user=member_b_gym_a)
        response = self.client.post(register_url)
        # Should fail with bad request since capacity is filled
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("fully booked", response.data.get('message', ''))

    # --- MODERATION SYSTEM TESTING ---

    def test_moderation_reporting_and_resolution(self):
        # Create a post
        post = CommunityPost.objects.create(
            author=self.member_user_a,
            gym=self.gym_a,
            title='Inappropriate Title',
            content='Spam content'
        )

        # 1. Member A reports the post
        self.client.force_authenticate(user=self.member_user_a)
        url = reverse('report-list')
        data = {
            'content_type': 'POST',
            'content_id': str(post.id),
            'reason': 'Contains spam advertising.'
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        report = Report.objects.first()

        # 2. Trainer reviews and resolves (hides) the post
        self.client.force_authenticate(user=self.trainer_user_a)
        resolve_url = reverse('report-detail', args=[report.id])
        resolve_data = {'action_taken': 'HIDE'}
        response = self.client.patch(resolve_url, resolve_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Post status should be HIDDEN / soft-deleted
        post.refresh_from_db()
        self.assertTrue(post.is_deleted)
        self.assertEqual(post.status, 'DELETED')

        # Report should be marked as RESOLVED
        report.refresh_from_db()
        self.assertEqual(report.status, ReportStatus.RESOLVED)
