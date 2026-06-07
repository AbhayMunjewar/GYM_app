from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from datetime import timedelta
from django.utils import timezone
from accounts.models import User
from gyms.models import Gym
from members.models import Member
from .models import MembershipPlan, Membership
from .services import MembershipService

class MembershipModuleTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        
        # User 1 and Gym 1
        self.owner1 = User.objects.create_user(email='owner1@test.com', password='password123', role='OWNER')
        self.gym1 = Gym.objects.create(gym_name='Gym 1', owner=self.owner1, address='123 St', city='City', state='State', pincode='12345', contact_number='1234567890', email='gym1@test.com')
        self.member1 = Member.objects.create(gym=self.gym1, full_name='Member 1', email='m1@test.com', phone_number='111')
        
        # User 2 and Gym 2
        self.owner2 = User.objects.create_user(email='owner2@test.com', password='password123', role='OWNER')
        self.gym2 = Gym.objects.create(gym_name='Gym 2', owner=self.owner2, address='456 St', city='City', state='State', pincode='12345', contact_number='0987654321', email='gym2@test.com')
        self.member2 = Member.objects.create(gym=self.gym2, full_name='Member 2', email='m2@test.com', phone_number='222')
        
        # Membership Plans
        self.plan1 = MembershipPlan.objects.create(gym=self.gym1, plan_name='Basic', duration_days=30, price=1000)
        self.plan2 = MembershipPlan.objects.create(gym=self.gym2, plan_name='Premium', duration_days=90, price=2500)

    def test_create_membership_plan(self):
        self.client.force_authenticate(user=self.owner1)
        data = {
            'gym_id': str(self.gym1.id),
            'plan_name': 'Pro Plan',
            'duration_days': 365,
            'price': '9000.00'
        }
        response = self.client.post('/api/memberships/plans/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(MembershipPlan.objects.count(), 3)

    def test_cross_gym_plan_creation_prevented(self):
        self.client.force_authenticate(user=self.owner1)
        data = {
            'gym_id': str(self.gym2.id), # Trying to create plan for other owner's gym
            'plan_name': 'Hacked Plan',
            'duration_days': 30,
            'price': '100.00'
        }
        response = self.client.post('/api/memberships/plans/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_soft_delete_membership_plan(self):
        self.client.force_authenticate(user=self.owner1)
        response = self.client.delete(f'/api/memberships/plans/{self.plan1.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.plan1.refresh_from_db()
        self.assertTrue(self.plan1.is_deleted)
        self.assertFalse(self.plan1.is_active)

    def test_assign_membership(self):
        self.client.force_authenticate(user=self.owner1)
        data = {
            'member_id': self.member1.id,
            'membership_plan_id': self.plan1.id
        }
        response = self.client.post('/api/memberships/assignments/', data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        membership = Membership.objects.get(member=self.member1)
        self.assertEqual(membership.status, 'ACTIVE')
        self.assertEqual(membership.end_date, membership.start_date + timedelta(days=30))

    def test_assign_membership_cross_gym_prevented(self):
        self.client.force_authenticate(user=self.owner1)
        # Try to assign a plan from gym2 to member in gym1
        data = {
            'member_id': self.member1.id,
            'membership_plan_id': self.plan2.id
        }
        response = self.client.post('/api/memberships/assignments/', data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_auto_expire_memberships(self):
        # Create an expired membership manually
        past_date = timezone.now().date() - timedelta(days=31)
        expired_membership = Membership.objects.create(
            member=self.member1,
            membership_plan=self.plan1,
            start_date=past_date,
            end_date=past_date + timedelta(days=30),
            status='ACTIVE'
        )
        
        count = MembershipService.update_expired_memberships()
        self.assertEqual(count, 1)
        
        expired_membership.refresh_from_db()
        self.assertEqual(expired_membership.status, 'EXPIRED')

    def test_dashboard_stats(self):
        self.client.force_authenticate(user=self.owner1)
        # Assign plan to member 1
        Membership.objects.create(
            member=self.member1,
            membership_plan=self.plan1,
            start_date=timezone.now().date(),
            end_date=timezone.now().date() + timedelta(days=30),
            status='ACTIVE'
        )
        
        response = self.client.get(f'/api/memberships/assignments/dashboard-stats/?gym_id={self.gym1.id}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['total_active_memberships'], 1)
        self.assertEqual(response.data['data']['total_revenue'], 1000)
