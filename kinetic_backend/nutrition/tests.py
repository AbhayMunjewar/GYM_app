import datetime
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from gyms.models import Gym
from members.models import Member
from nutrition.models import NutritionProfile, DietLog
from nutrition.services.nutrition_calculator import calculate_nutrition

User = get_user_model()

class NutritionCalculatorTests(TestCase):
    def test_mifflin_st_jeor_formula(self):
        # Test BMR and TDEE calculation logic
        # Weight=70kg, Height=170cm, Age=25, Male, moderately_active, goal=maintenance, workouts=3/wk
        data = {
            'weight_kg': 70.0,
            'height_cm': 170.0,
            'age': 25,
            'gender': 'Male',
            'activity_level': 'moderately_active',
            'goal': 'maintenance',
            'workout_days_per_week': 3
        }
        res = calculate_nutrition(data)
        
        # BMR Male: 10 * 70 + 6.25 * 170 - 5 * 25 + 5 = 700 + 1062.5 - 125 + 5 = 1642.5
        # TDEE Moderately Active (x1.55): 1642.5 * 1.55 = 2545.875
        self.assertAlmostEqual(res['bmr'], 1642.5)
        self.assertAlmostEqual(res['tdee'], 2545.9)
        self.assertEqual(res['target_calories'], 2545)
        
        # Test deficit goal
        data['goal'] = 'fat_loss'
        res_fat = calculate_nutrition(data)
        self.assertEqual(res_fat['target_calories'], 2045)  # 2545 - 500

        # Test surplus goal
        data['goal'] = 'muscle_gain'
        res_muscle = calculate_nutrition(data)
        self.assertEqual(res_muscle['target_calories'], 2845)  # 2545 + 300


class NutritionAPITests(APITestCase):
    def setUp(self):
        # Create Owner and Gym
        self.owner_user = User.objects.create_user(
            email='owner@test.com', username='owner_test', password='password123', role='OWNER'
        )
        self.gym = Gym.objects.create(gym_name='Gym X', owner=self.owner_user)

        # Create Member and associated User
        self.member_user = User.objects.create_user(
            email='member@test.com', username='member_test', password='password123', role='MEMBER'
        )
        self.member = Member.objects.create(
            gym=self.gym, full_name='John Nutrition', email='member@test.com', status='ACTIVE'
        )

        # Log in Member to obtain JWT token
        response = self.client.post('/api/auth/login/', {"email": "member@test.com", "password": "password123"})
        self.member_token = response.data['data']['access']

    def test_onboarding_profile_generation(self):
        payload = {
            'goal': 'fat_loss',
            'age': 30,
            'height_cm': 175.0,
            'weight_kg': 85.0,
            'gender': 'Male',
            'activity_level': 'very_active',
            'workout_days_per_week': 5,
            'budget_inr': 300,
            'food_preference': 'non-veg',
            'allergies': 'peanuts',
            'medical_restrictions': 'none'
        }
        
        response = self.client.post(
            '/api/nutrition/generate-plan/', 
            payload, 
            format='json', 
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('target_calories', response.data['data'])
        self.assertIn('protein_g', response.data['data'])

        # Verify profile is saved in DB
        profile = NutritionProfile.objects.get(member=self.member)
        self.assertEqual(profile.age, 30)
        self.assertEqual(profile.goal, 'fat_loss')
        self.assertEqual(profile.food_preference, 'non-veg')

    def test_meals_generation_fallback(self):
        # We test with mock/fallback mode as key is empty/invalid
        payload = {
            'target_calories': 2000,
            'protein_g': 140,
            'carbs_g': 200,
            'fat_g': 60,
            'budget_inr': 250,
            'food_preference': 'veg',
            'goal': 'fat_loss',
            'workout_days_per_week': 3
        }

        response = self.client.post(
            '/api/nutrition/generate-meals/',
            payload,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        meals = response.data['data']
        self.assertIn('breakfast', meals)
        self.assertIn('lunch', meals)
        self.assertIn('dinner', meals)
        
        # Verify vegeterian fallback is used (e.g. Oats, Paneer/Tofu)
        items = meals['breakfast']['items']
        self.assertTrue(any("Oats" in x['food'] for x in items))

    def test_grocery_list_fallback(self):
        meal_plan = {
            "breakfast": {
                "name": "Oatmeal",
                "items": [{"food": "Rolled Oats", "quantity": "60g", "estimated_cost_inr": 15}]
            }
        }
        payload = {
            'meal_plan': meal_plan,
            'duration': 'weekly'
        }

        response = self.client.post(
            '/api/nutrition/grocery-list/',
            payload,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('total_estimated_cost_inr', response.data['data'])

    def test_food_replacement_fallback(self):
        payload = {
            'original_food': 'paneer',
            'reason': 'fat loss',
            'preference': 'veg',
            'goal': 'fat_loss'
        }

        response = self.client.post(
            '/api/nutrition/food-replacement/',
            payload,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        replacements = response.data['data']
        self.assertEqual(len(replacements), 3)
        self.assertEqual(replacements[0]['food'], 'Tofu (Firm)')

    def test_diet_logging_and_compliance(self):
        log_payload = {
            'breakfast_done': True,
            'lunch_done': True,
            'dinner_done': False,
            'calories_consumed': 1200,
            'protein_consumed_g': 80,
            'log_date': '2026-06-25'
        }

        response = self.client.post(
            '/api/nutrition/log/',
            log_payload,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])

        # Verify entry exists
        db_log = DietLog.objects.get(member=self.member, log_date='2026-06-25')
        self.assertTrue(db_log.breakfast_done)
        self.assertFalse(db_log.dinner_done)

        # Retrieve compliance statistics
        comp_response = self.client.get(
            '/api/nutrition/compliance/?period=weekly',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(comp_response.status_code, status.HTTP_200_OK)
        self.assertTrue(comp_response.data['success'])
        c_data = comp_response.data['data']
        self.assertEqual(c_data['days_logged'], 1)
        self.assertEqual(c_data['avg_calories'], 1200)
        self.assertIn('2026-06-25', c_data['logs_detail'])

    def test_coach_interaction_safety(self):
        # Standard query
        payload = {'message': 'What should I eat pre workout?'}
        response = self.client.post(
            '/api/nutrition/coach/chat/',
            payload,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('banana', response.data['data']['reply'].lower())

        # Safety query involving disease/medication
        payload_safety = {'message': 'I am taking diabetes medication metformin. What diet is safe?'}
        response_safety = self.client.post(
            '/api/nutrition/coach/chat/',
            payload_safety,
            format='json',
            HTTP_AUTHORIZATION=f'Bearer {self.member_token}'
        )
        self.assertEqual(response_safety.status_code, status.HTTP_200_OK)
        self.assertIn('consult your doctor', response_safety.data['data']['reply'].lower())
