from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()

class AuthenticationTests(APITestCase):
    def setUp(self):
        self.register_url = reverse('auth_register')
        self.login_url = reverse('auth_login')
        self.refresh_url = reverse('auth_token_refresh')
        self.logout_url = reverse('auth_logout')
        self.me_url = reverse('auth_me')

        self.user_data = {
            "full_name": "Test User",
            "username": "testuser",
            "email": "test@gmail.com",
            "password": "SecurePassword123",
            "phone_number": "9876543210",
            "role": "OWNER"
        }

    def test_registration_success(self):
        response = self.client.post(self.register_url, self.user_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        self.assertEqual(response.data['message'], "User registered successfully")

    def test_registration_invalid_password(self):
        # Weak password (missing uppercase)
        invalid_data = self.user_data.copy()
        invalid_data["password"] = "weakpass123"
        response = self.client.post(self.register_url, invalid_data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(response.data['success'])

    def test_login_success(self):
        # Register
        self.client.post(self.register_url, self.user_data)

        # Login
        login_data = {
            "email": self.user_data["email"],
            "password": self.user_data["password"]
        }
        response = self.client.post(self.login_url, login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn("access", response.data['data'])
        self.assertIn("refresh", response.data['data'])
        self.assertEqual(response.data['data']['user']['email'], self.user_data["email"])

    def test_login_failure(self):
        login_data = {
            "email": "wrong@gmail.com",
            "password": "WrongPassword123"
        }
        response = self.client.post(self.login_url, login_data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(response.data['success'])

    def test_current_user_me(self):
        # Register & Login
        self.client.post(self.register_url, self.user_data)
        login_data = {
            "email": self.user_data["email"],
            "password": self.user_data["password"]
        }
        login_resp = self.client.post(self.login_url, login_data)
        access_token = login_resp.data['data']['access']

        # Add Bearer Token header
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}')
        response = self.client.get(self.me_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertEqual(response.data['data']['email'], self.user_data["email"])

    def test_rbac_access_control(self):
        owner_data = {
            "full_name": "Owner User",
            "email": "owner@gmail.com",
            "password": "SecurePassword123",
            "role": "OWNER"
        }
        trainer_data = {
            "full_name": "Trainer User",
            "email": "trainer@gmail.com",
            "password": "SecurePassword123",
            "role": "TRAINER"
        }
        member_data = {
            "full_name": "Member User",
            "email": "member@gmail.com",
            "password": "SecurePassword123",
            "role": "MEMBER"
        }

        self.client.post(self.register_url, owner_data)
        self.client.post(self.register_url, trainer_data)
        self.client.post(self.register_url, member_data)

        owner_token = self.client.post(self.login_url, {"email": "owner@gmail.com", "password": "SecurePassword123"}).data['data']['access']
        trainer_token = self.client.post(self.login_url, {"email": "trainer@gmail.com", "password": "SecurePassword123"}).data['data']['access']
        member_token = self.client.post(self.login_url, {"email": "member@gmail.com", "password": "SecurePassword123"}).data['data']['access']

        owner_dash = reverse('owner_dashboard')
        trainer_dash = reverse('trainer_dashboard')
        member_dash = reverse('member_dashboard')

        # 1. Owner accessing Owner dashboard (OK)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {owner_token}')
        res = self.client.get(owner_dash)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['role'], 'OWNER')

        # 2. Trainer accessing Trainer dashboard (OK)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {trainer_token}')
        res = self.client.get(trainer_dash)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['role'], 'TRAINER')

        # 3. Member accessing Member dashboard (OK)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {member_token}')
        res = self.client.get(member_dash)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['data']['role'], 'MEMBER')

        # 4. Trainer accessing Owner dashboard (Forbidden)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {trainer_token}')
        res = self.client.get(owner_dash)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.data['success'])
        self.assertEqual(res.data['message'], "You do not have permission to access this resource.")

        # 5. Member accessing Trainer dashboard (Forbidden)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {member_token}')
        res = self.client.get(trainer_dash)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)
        self.assertFalse(res.data['success'])
        self.assertEqual(res.data['message'], "You do not have permission to access this resource.")

