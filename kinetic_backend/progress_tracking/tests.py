import datetime
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member
from accounts.models import UserRole
from .models import ProgressMeasurement, ProgressPhoto, FitnessGoal, ProgressMilestone, GoalStatus, GoalType

User = get_user_model()

class ProgressTrackingAPITests(APITestCase):
    def setUp(self):
        # 1. Setup Gyms and Users
        self.owner_user = User.objects.create_user(
            email='owner@test.com', username='owner@test.com', password='password123', role='OWNER'
        )
        self.gym_a = Gym.objects.create(gym_name='Gym A', owner=self.owner_user)
        
        self.trainer_user = User.objects.create_user(
            email='trainer@test.com', username='trainer@test.com', password='password123', role='TRAINER'
        )
        self.trainer_a = Trainer.objects.create(
            user=self.trainer_user, gym=self.gym_a, employee_id='EMP111', status='ACTIVE', joining_date=datetime.date.today()
        )

        self.member_user = User.objects.create_user(
            email='member@test.com', username='member_test', password='password123', role='MEMBER'
        )
        self.member_a = Member.objects.create(
            gym=self.gym_a, full_name='John Member', email='member@test.com', status='ACTIVE', weight_kg=85.0, height_cm=180.0
        )

        # Other Gym
        self.owner_user_b = User.objects.create_user(
            email='owner_b@test.com', username='owner_b@test.com', password='password123', role='OWNER'
        )
        self.gym_b = Gym.objects.create(gym_name='Gym B', owner=self.owner_user_b)
        
        self.member_user_b = User.objects.create_user(
            email='member_b@test.com', username='member_b_test', password='password123', role='MEMBER'
        )
        self.member_b = Member.objects.create(
            gym=self.gym_b, full_name='Jane Member B', email='member_b@test.com', status='ACTIVE', weight_kg=75.0, height_cm=170.0
        )

        # 2. Auth Login to get simplejwt tokens
        response = self.client.post('/api/auth/login/', {"email": "owner@test.com", "password": "password123"})
        self.owner_token = response.data['data']['access']
        
        response = self.client.post('/api/auth/login/', {"email": "trainer@test.com", "password": "password123"})
        self.trainer_token = response.data['data']['access']

        response = self.client.post('/api/auth/login/', {"email": "member@test.com", "password": "password123"})
        self.member_token = response.data['data']['access']

    def test_measurement_crud_and_bmi_calc(self):
        # 1. Post new measurement (weight 80kg, height 180cm -> BMI should be 24.7)
        data = {
            "weight_kg": 80.0,
            "body_fat_percentage": 22.0,
            "height_cm": 180.0,
            "chest_cm": 102.0,
            "waist_cm": 88.0,
            "recorded_date": "2026-06-10"
        }
        
        response = self.client.post(
            '/api/progress/measurements/',
            data,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['data']['bmi'], 24.7)
        m_id = response.data['data']['id']

        # 2. Get list of measurements
        response = self.client.get(
            '/api/progress/measurements/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['success'], True)

        # 3. Patch measurement (waist update)
        response = self.client.patch(
            f'/api/progress/measurements/{m_id}/',
            {"waist_cm": 86.0},
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['waist_cm'], 86.0)

        # 4. Delete measurement
        response = self.client.delete(
            f'/api/progress/measurements/{m_id}/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_fitness_goals_and_milestone_detection(self):
        # Create a measurement so we have a starting point (85kg)
        self.client.post(
            '/api/progress/measurements/',
            {"weight_kg": 85.0, "body_fat_percentage": 25.0, "height_cm": 180.0, "recorded_date": "2026-06-01"},
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )

        # Create Fitness Goal (Target 75kg, Fat Loss)
        goal_data = {
            "goal_type": "FAT_LOSS",
            "target_weight": 75.0,
            "target_body_fat": 15.0,
            "target_date": "2026-12-31"
        }
        response = self.client.post(
            '/api/progress/goals/',
            goal_data,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        goal_id = response.data['data']['id']
        self.assertEqual(response.data['data']['starting_weight'], 85.0)

        # Record new measurement (Weight 80kg - Lost 5kg! Progress = 50%)
        # This weight loss (5kg) should also trigger the "First 5kg Lost" milestone!
        meas_data = {
            "weight_kg": 80.0,
            "body_fat_percentage": 20.0,
            "height_cm": 180.0,
            "recorded_date": "2026-06-13"
        }
        self.client.post(
            '/api/progress/measurements/',
            meas_data,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )

        # Get updated Goal
        response = self.client.get(
            '/api/progress/goals/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        # Weight progress: (85-80)/(85-75) = 50%
        # Fat progress: (25-20)/(25-15) = 50%
        # Average: 50%
        self.assertEqual(response.data['data']['results'][0]['current_progress_percentage'], 50.0)

        # Verify Milestone "First 5kg Lost" was created
        milestones = ProgressMilestone.objects.filter(member=self.member_a)
        self.assertTrue(milestones.filter(milestone_name="First 5kg Lost").exists())

        # Achieve target (75kg)
        self.client.post(
            '/api/progress/measurements/',
            {"weight_kg": 75.0, "body_fat_percentage": 15.0, "height_cm": 180.0, "recorded_date": "2026-06-14"},
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        goal = FitnessGoal.objects.get(id=goal_id)
        self.assertEqual(goal.status, GoalStatus.ACHIEVED)

    def test_cross_gym_protection(self):
        # Trainer A tries to record measurement for Member B (Gym B)
        data = {
            "member": self.member_b.id,
            "weight_kg": 70.0,
            "body_fat_percentage": 15.0,
            "height_cm": 170.0,
            "recorded_date": "2026-06-13"
        }
        response = self.client.post(
            '/api/progress/measurements/',
            data,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}'
        )
        # Member B belongs to Gym B, but Trainer A belongs to Gym A -> should fail validation or return 404
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

        # Member A tries to get Member B's progress details
        response = self.client.get(
            f'/api/progress/measurements/?member_id={self.member_b.id}',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        # Should restrict member to own records
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_progress_photo_crud(self):
        # Prepare a valid 1x1 transparent GIF image
        gif_content = b'GIF89a\x01\x00\x01\x00\x80\x00\x00\x00\x00\x00\xff\xff\xff!\xf9\x04\x01\x00\x00\x00\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;'
        mock_image = SimpleUploadedFile("front.gif", gif_content, content_type="image/gif")
        data = {
            "photo_type": "FRONT",
            "image": mock_image,
            "notes": "Front view photo"
        }
        
        response = self.client.post(
            '/api/progress/photos/',
            data,
            format='multipart',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        if response.status_code != status.HTTP_201_CREATED:
            print("PHOTO_UPLOAD_ERROR_RESPONSE:", response.data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        photo_id = response.data['data']['id']

        # Get list
        response = self.client.get(
            '/api/progress/photos/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']), 1)

        # Delete
        response = self.client.delete(
            f'/api/progress/photos/{photo_id}/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_analytics_and_comparison(self):
        # Add historical measurements for Member A
        ProgressMeasurement.objects.create(
            member=self.member_a, weight_kg=85.0, body_fat_percentage=25.0, height_cm=180.0, recorded_date="2026-06-01"
        )
        ProgressMeasurement.objects.create(
            member=self.member_a, weight_kg=82.0, body_fat_percentage=22.0, height_cm=180.0, recorded_date="2026-06-10"
        )

        # 1. Fetch Analytics
        response = self.client.get(
            '/api/progress/analytics/',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['data']['weight_trend']), 2)
        self.assertEqual(response.data['data']['transformation_summary']['weight_change'], -3.0)

        # 2. Comparison Engine
        response = self.client.get(
            '/api/progress/compare/?start_date=2026-06-01&end_date=2026-06-10',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['differences']['weight_diff'], -3.0)
        self.assertEqual(response.data['data']['differences']['body_fat_diff'], -3.0)
