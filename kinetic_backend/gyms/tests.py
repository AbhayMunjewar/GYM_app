from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.urls import reverse
from accounts.models import User, UserRole
from gyms.models import Gym

class GymTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.owner = User.objects.create_user(
            email='owner@test.com',
            password='password123',
            full_name='Test Owner',
            role=UserRole.OWNER,
            is_verified=True,
            is_active=True
        )
        self.member = User.objects.create_user(
            email='member@test.com',
            password='password123',
            full_name='Test Member',
            role=UserRole.MEMBER,
            is_verified=True,
            is_active=True
        )
        self.trainer = User.objects.create_user(
            email='trainer@test.com',
            password='password123',
            full_name='Test Trainer',
            role=UserRole.TRAINER,
            is_verified=True,
            is_active=True
        )

        self.gym_data = {
            'gym_name': 'Test Gym',
            'address': '123 Test St',
            'city': 'Test City',
            'state': 'Test State',
            'pincode': '123456',
            'contact_number': '1234567890',
            'email': 'gym@test.com'
        }

    def get_jwt(self, user):
        response = self.client.post(reverse('auth_login'), {
            'email': user.email,
            'password': 'password123'
        })
        return response.data['data']['access']

    def test_owner_can_create_gym(self):
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.post(reverse('gym-list'), self.gym_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Gym.objects.count(), 1)
        self.assertEqual(Gym.objects.first().owner, self.owner)

    def test_trainer_member_cannot_create_gym(self):
        token = self.get_jwt(self.trainer)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.post(reverse('gym-list'), self.gym_data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        token = self.get_jwt(self.member)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        response = self.client.post(reverse('gym-list'), self.gym_data)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_owner_can_update_gym(self):
        gym = Gym.objects.create(owner=self.owner, **self.gym_data)
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        url = reverse('gym-detail', args=[gym.id])
        response = self.client.patch(url, {'gym_name': 'Updated Gym Name'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        gym.refresh_from_db()
        self.assertEqual(gym.gym_name, 'Updated Gym Name')

    def test_soft_delete_gym(self):
        gym = Gym.objects.create(owner=self.owner, **self.gym_data)
        token = self.get_jwt(self.owner)
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        url = reverse('gym-detail', args=[gym.id])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        gym.refresh_from_db()
        self.assertTrue(gym.is_deleted)
        self.assertFalse(gym.is_active)

        # GET should not return soft-deleted gym
        list_response = self.client.get(reverse('gym-list'))
        self.assertEqual(list_response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(list_response.data['data']), 0)
