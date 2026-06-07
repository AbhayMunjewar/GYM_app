from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from accounts.models import User
from gyms.models import Gym
from members.models import Member
import json

class MemberTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        
        # Create Owner 1 and Gym 1
        self.owner1 = User.objects.create_user(email='owner1@test.com', password='password123', role='OWNER')
        self.gym1 = Gym.objects.create(gym_name='Gym 1', owner=self.owner1, address='123 St', city='City', state='State', pincode='123456')
        
        # Create Owner 2 and Gym 2
        self.owner2 = User.objects.create_user(email='owner2@test.com', password='password123', role='OWNER')
        self.gym2 = Gym.objects.create(gym_name='Gym 2', owner=self.owner2, address='456 St', city='City', state='State', pincode='654321')
        
        # Create Member for Gym 1
        self.member1 = Member.objects.create(gym=self.gym1, full_name='Alice', email='alice@test.com', phone_number='111111')
        
        # Create Trainer and Member accounts
        self.trainer = User.objects.create_user(email='trainer@test.com', password='password123', role='TRAINER')
        self.member_user = User.objects.create_user(email='member@test.com', password='password123', role='MEMBER')

    def get_jwt(self, user):
        response = self.client.post(reverse('auth_login'), {
            'email': user.email,
            'password': 'password123'
        })
        return response.data['data']['access']

    def test_owner_can_create_member(self):
        token = self.get_jwt(self.owner1)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        response = self.client.post(reverse('member-list'), {
            'full_name': 'Bob',
            'email': 'bob@test.com',
            'phone_number': '222222',
            'status': 'ACTIVE'
        })
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['data']['full_name'], 'Bob')
        self.assertEqual(response.data['data']['gym'], self.gym1.id)

    def test_owner_can_list_only_own_members(self):
        token = self.get_jwt(self.owner2)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        response = self.client.get(reverse('member-list'))
        self.assertEqual(response.status_code, 200)
        # Owner 2 should not see Alice (who belongs to Gym 1)
        # Handle pagination format
        data = response.data['data']['results'] if 'results' in response.data['data'] else response.data['data']
        self.assertEqual(len(data), 0)

    def test_cross_gym_access_prevented(self):
        token = self.get_jwt(self.owner2)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        response = self.client.get(reverse('member-detail', kwargs={'pk': self.member1.pk}))
        self.assertEqual(response.status_code, 404) # Not found because queryset is filtered by gym owner

    def test_trainer_member_cannot_access(self):
        token = self.get_jwt(self.trainer)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        response = self.client.get(reverse('member-list'))
        self.assertEqual(response.status_code, 403) # Forbidden

    def test_soft_delete_member(self):
        token = self.get_jwt(self.owner1)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        response = self.client.delete(reverse('member-detail', kwargs={'pk': self.member1.pk}))
        self.assertEqual(response.status_code, 200)
        
        # Verify it's soft deleted
        self.member1.refresh_from_db()
        self.assertTrue(self.member1.is_deleted)
        self.assertFalse(self.member1.is_active)
        
        # Verify it doesn't appear in list
        list_response = self.client.get(reverse('member-list'))
        data = list_response.data['data']['results'] if 'results' in list_response.data['data'] else list_response.data['data']
        self.assertEqual(len(data), 0)
