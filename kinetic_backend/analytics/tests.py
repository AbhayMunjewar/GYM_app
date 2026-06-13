"""
Unit tests for the Analytics & Reporting module (Day 15).

Tests cover:
- RBAC enforcement (Owner, Trainer, Member can only access their own endpoint)
- Service layer data aggregation
- Response structure validation
"""

from datetime import date, timedelta
from decimal import Decimal
from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient

from accounts.models import User
from gyms.models import Gym
from members.models import Member
from memberships.models import MembershipPlan, Membership
from trainers.models import Trainer, TrainerAssignment
from attendance.models import Attendance
from billing.models import GymPaymentSettings, Invoice, Payment
from progress_tracking.models import ProgressMeasurement, FitnessGoal
from .services import OwnerAnalyticsService, TrainerAnalyticsService, MemberAnalyticsService


class AnalyticsTestBase(TestCase):
    """Shared setup for analytics tests."""

    def setUp(self):
        # Create users
        self.owner_user = User.objects.create_user(
            email='owner@test.com', password='TestPass123!',
            full_name='Test Owner', role='OWNER', is_verified=True
        )
        self.trainer_user = User.objects.create_user(
            email='trainer@test.com', password='TestPass123!',
            full_name='Test Trainer', role='TRAINER', is_verified=True
        )
        self.member_user = User.objects.create_user(
            email='member@test.com', password='TestPass123!',
            full_name='Test Member', role='MEMBER', is_verified=True
        )

        # Create gym
        self.gym = Gym.objects.create(
            owner=self.owner_user, gym_name='Test Gym',
            address='123 Test St', city='TestCity',
            state='TS', pincode='12345',
            contact_number='9876543210', email='gym@test.com'
        )

        # Create member
        self.member = Member.objects.create(
            gym=self.gym, full_name='Test Member',
            email='member@test.com', phone_number='1234567890',
            status='ACTIVE', weight_kg=75.0
        )

        # Create trainer
        self.trainer = Trainer.objects.create(
            user=self.trainer_user, gym=self.gym,
            employee_id='TR001', specialization='Strength',
            experience_years=3, status='ACTIVE',
            joining_date=date.today()
        )

        # Assign member to trainer
        self.assignment = TrainerAssignment.objects.create(
            trainer=self.trainer, member=self.member,
            assigned_by=self.owner_user, status='ACTIVE',
            assigned_date=date.today()
        )

        # Create membership plan + assignment
        self.plan = MembershipPlan.objects.create(
            gym=self.gym, plan_name='Gold Plan',
            duration_days=30, price=Decimal('99.99')
        )
        self.membership = Membership.objects.create(
            member=self.member, membership_plan=self.plan,
            start_date=date.today() - timedelta(days=15),
            end_date=date.today() + timedelta(days=15),
            status='ACTIVE'
        )

        # Create attendance
        Attendance.objects.create(
            gym=self.gym, member=self.member,
            membership=self.membership,
            attendance_date=date.today(),
            attendance_status='PRESENT',
            check_in_time=timezone.now()
        )

        # Create billing data
        self.settings = GymPaymentSettings.objects.create(gym=self.gym)
        self.invoice = Invoice.objects.create(
            gym=self.gym, member=self.member,
            amount=Decimal('99.99'), total_amount=Decimal('99.99'),
            due_date=date.today() + timedelta(days=5),
            status='PAID'
        )
        Payment.objects.create(
            invoice=self.invoice, gym=self.gym, member=self.member,
            amount_paid=Decimal('99.99'), payment_method='UPI',
            status='ACKNOWLEDGED'
        )

        # Create progress data
        ProgressMeasurement.objects.create(
            member=self.member, weight_kg=75.0,
            body_fat_percentage=20.0, height_cm=180.0,
            recorded_date=date.today() - timedelta(days=30)
        )
        ProgressMeasurement.objects.create(
            member=self.member, weight_kg=73.5,
            body_fat_percentage=19.0, height_cm=180.0,
            recorded_date=date.today()
        )

        self.client = APIClient()


class OwnerAnalyticsViewTest(AnalyticsTestBase):
    """Tests for GET /api/analytics/owner/"""

    def test_owner_analytics_success(self):
        self.client.force_authenticate(user=self.owner_user)
        response = self.client.get('/api/analytics/owner/')
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('revenue', data['data'])
        self.assertIn('memberships', data['data'])
        self.assertIn('attendance', data['data'])
        self.assertIn('trainers', data['data'])
        self.assertIn('members', data['data'])
        self.assertIn('revenue_trend', data['data'])
        self.assertIn('plan_distribution', data['data'])

    def test_owner_analytics_revenue_values(self):
        self.client.force_authenticate(user=self.owner_user)
        response = self.client.get('/api/analytics/owner/')
        data = response.json()['data']
        self.assertEqual(data['revenue']['total_revenue'], '99.99')
        self.assertEqual(data['memberships']['active_memberships'], 1)

    def test_owner_analytics_forbidden_for_trainer(self):
        self.client.force_authenticate(user=self.trainer_user)
        response = self.client.get('/api/analytics/owner/')
        self.assertEqual(response.status_code, 403)

    def test_owner_analytics_forbidden_for_member(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/analytics/owner/')
        self.assertEqual(response.status_code, 403)

    def test_owner_analytics_unauthenticated(self):
        response = self.client.get('/api/analytics/owner/')
        self.assertEqual(response.status_code, 401)


class TrainerAnalyticsViewTest(AnalyticsTestBase):
    """Tests for GET /api/analytics/trainer/"""

    def test_trainer_analytics_success(self):
        self.client.force_authenticate(user=self.trainer_user)
        response = self.client.get('/api/analytics/trainer/')
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('clients', data['data'])
        self.assertIn('attendance', data['data'])
        self.assertIn('diet', data['data'])
        self.assertIn('progress', data['data'])

    def test_trainer_analytics_client_count(self):
        self.client.force_authenticate(user=self.trainer_user)
        response = self.client.get('/api/analytics/trainer/')
        data = response.json()['data']
        self.assertEqual(data['clients']['total_assigned'], 1)
        self.assertEqual(data['clients']['active_clients'], 1)

    def test_trainer_analytics_forbidden_for_owner(self):
        self.client.force_authenticate(user=self.owner_user)
        response = self.client.get('/api/analytics/trainer/')
        self.assertEqual(response.status_code, 403)

    def test_trainer_analytics_forbidden_for_member(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/analytics/trainer/')
        self.assertEqual(response.status_code, 403)


class MemberAnalyticsViewTest(AnalyticsTestBase):
    """Tests for GET /api/analytics/member/"""

    def test_member_analytics_success(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/analytics/member/')
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('attendance', data['data'])
        self.assertIn('diet', data['data'])
        self.assertIn('progress', data['data'])
        self.assertIn('membership', data['data'])

    def test_member_analytics_membership_info(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/analytics/member/')
        data = response.json()['data']
        self.assertTrue(data['membership']['has_active_membership'])
        self.assertEqual(data['membership']['plan_name'], 'Gold Plan')
        self.assertGreater(data['membership']['days_remaining'], 0)

    def test_member_analytics_progress_trend(self):
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get('/api/analytics/member/')
        data = response.json()['data']
        self.assertEqual(len(data['progress']['weight_trend']), 2)

    def test_member_analytics_forbidden_for_owner(self):
        self.client.force_authenticate(user=self.owner_user)
        response = self.client.get('/api/analytics/member/')
        self.assertEqual(response.status_code, 403)

    def test_member_analytics_forbidden_for_trainer(self):
        self.client.force_authenticate(user=self.trainer_user)
        response = self.client.get('/api/analytics/member/')
        self.assertEqual(response.status_code, 403)


class OwnerAnalyticsServiceTest(AnalyticsTestBase):
    """Direct service layer tests for OwnerAnalyticsService."""

    def test_revenue_metrics(self):
        today = timezone.localdate()
        first_of_month = today.replace(day=1)
        result = OwnerAnalyticsService._revenue_metrics(self.gym, today, first_of_month)
        self.assertEqual(result['total_revenue'], '99.99')
        self.assertEqual(result['overdue_invoices'], 0)

    def test_membership_metrics(self):
        today = timezone.localdate()
        first_of_month = today.replace(day=1)
        prev_month_end = first_of_month - timedelta(days=1)
        prev_month_start = prev_month_end.replace(day=1)
        result = OwnerAnalyticsService._membership_metrics(
            self.gym, today, first_of_month, prev_month_start, prev_month_end
        )
        self.assertEqual(result['active_memberships'], 1)
        self.assertEqual(result['active_members'], 1)

    def test_attendance_metrics(self):
        today = timezone.localdate()
        result = OwnerAnalyticsService._attendance_metrics(self.gym, today)
        self.assertEqual(result['today_check_ins'], 1)

    def test_trainer_metrics(self):
        result = OwnerAnalyticsService._trainer_metrics(self.gym)
        self.assertEqual(result['total_trainers'], 1)
        self.assertEqual(result['active_trainers'], 1)

    def test_plan_distribution(self):
        result = OwnerAnalyticsService._plan_distribution(self.gym)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['plan_name'], 'Gold Plan')
        self.assertEqual(result[0]['active_count'], 1)
