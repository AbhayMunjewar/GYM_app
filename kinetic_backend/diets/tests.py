from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member
from accounts.models import UserRole
from .models import Food, MealTemplate, MealFood, DietPlan, DietPlanMeal, MemberDietPlan, DietLog
from .services import NutritionEngine, DietService
import datetime

User = get_user_model()

class DietModelsAndServicesTests(TestCase):
    def setUp(self):
        # 1. Setup Gym and Users
        self.owner_user = User.objects.create_user(
            email='owner@test.com', username='owner@test.com', password='password123', role='OWNER'
        )
        self.gym_a = Gym.objects.create(gym_name='Gym A', owner=self.owner_user)
        
        self.trainer_user = User.objects.create_user(
            email='trainer@test.com', username='trainer@test.com', password='password123', role='TRAINER'
        )
        self.trainer_a = Trainer.objects.create(
            user=self.trainer_user, gym=self.gym_a, employee_id='EMP999', salary=3000.0, status='ACTIVE', joining_date=datetime.date.today()
        )

        self.member_user = User.objects.create_user(
            email='member@test.com', username='member_test', password='password123', role='MEMBER'
        )
        self.member_a = Member.objects.create(
            gym=self.gym_a, full_name='John Member', email='member@test.com', status='ACTIVE'
        )

        # 2. Setup Foods
        self.food_chicken = Food.objects.create(
            food_name='Chicken Breast', category='PROTEIN', serving_size='100g',
            calories=165, protein=31.0, carbohydrates=0.0, fats=3.6, fiber=0.0
        )
        self.food_rice = Food.objects.create(
            food_name='White Rice', category='CARBOHYDRATE', serving_size='100g',
            calories=130, protein=2.7, carbohydrates=28.0, fats=0.3, fiber=0.4
        )

    def test_meal_macros_calculation(self):
        meal_template = MealTemplate.objects.create(
            trainer=self.trainer_a, meal_name='Chicken and Rice', meal_type='LUNCH'
        )
        MealFood.objects.create(meal_template=meal_template, food=self.food_chicken, quantity=1.5, serving_unit='g')
        MealFood.objects.create(meal_template=meal_template, food=self.food_rice, quantity=2.0, serving_unit='g')

        totals = NutritionEngine.calculate_meal_macros(meal_template)
        # Chicken: 1.5 * 165 = 247.5 cal, 1.5 * 31 = 46.5g prot, 1.5 * 3.6 = 5.4g fat
        # Rice: 2 * 130 = 260 cal, 2 * 2.7 = 5.4g prot, 2 * 28 = 56g carb, 2 * 0.3 = 0.6g fat
        # Sum Cal: 247 + 260 = 507
        # Sum Prot: 46.5 + 5.4 = 51.9
        # Sum Carb: 0 + 56 = 56
        # Sum Fat: 5.4 + 0.6 = 6.0
        self.assertEqual(totals['calories'], 507)
        self.assertEqual(totals['protein'], 51.9)
        self.assertEqual(totals['carbohydrates'], 56.0)
        self.assertEqual(totals['fats'], 6.0)

    def test_diet_plan_macros(self):
        diet_plan = DietPlan.objects.create(
            trainer=self.trainer_a, gym=self.gym_a, plan_name='Cut Plan', goal='FAT_LOSS',
            target_calories=2000, target_protein=150, target_carbs=150, target_fats=60, duration_days=2
        )
        
        meal_template = MealTemplate.objects.create(
            trainer=self.trainer_a, meal_name='Chicken and Rice', meal_type='LUNCH'
        )
        MealFood.objects.create(meal_template=meal_template, food=self.food_chicken, quantity=1.0, serving_unit='g')
        
        # Add meal to diet plan: Day 1
        DietPlanMeal.objects.create(diet_plan=diet_plan, meal_template=meal_template, day_number=1, sequence_order=1)
        
        daily_macros = NutritionEngine.get_diet_plan_daily_macros(diet_plan)
        self.assertEqual(daily_macros[1]['calories'], 165)
        self.assertEqual(daily_macros[1]['protein'], 31.0)
        self.assertEqual(daily_macros[2]['calories'], 0) # No meals scheduled for Day 2 yet

        avg_macros = NutritionEngine.get_diet_plan_average_daily_macros(diet_plan)
        # (165 + 0) / 2 = 82.5 cal -> rounded or casted
        self.assertEqual(avg_macros['calories'], 82)


class DietAPITestCase(APITestCase):
    def setUp(self):
        # Setup Gyms and Users
        self.owner_user = User.objects.create_user(
            email='owner@test.com', username='owner@test.com', password='password123', role='OWNER'
        )
        self.gym_a = Gym.objects.create(gym_name='Gym A', owner=self.owner_user)
        
        self.trainer_user = User.objects.create_user(
            email='trainer@test.com', username='trainer@test.com', password='password123', role='TRAINER'
        )
        self.trainer_a = Trainer.objects.create(
            user=self.trainer_user, gym=self.gym_a, employee_id='EMP999', salary=3000.0, status='ACTIVE', joining_date=datetime.date.today()
        )

        self.member_user = User.objects.create_user(
            email='member@test.com', username='member_test', password='password123', role='MEMBER'
        )
        self.member_a = Member.objects.create(
            gym=self.gym_a, full_name='John Member', email='member@test.com', status='ACTIVE'
        )

        # Gym B (Other Gym)
        self.owner_user_b = User.objects.create_user(
            email='owner_b@test.com', username='owner_b@test.com', password='password123', role='OWNER'
        )
        self.gym_b = Gym.objects.create(gym_name='Gym B', owner=self.owner_user_b)
        self.member_user_b = User.objects.create_user(
            email='member_b@test.com', username='member_b_test', password='password123', role='MEMBER'
        )
        self.member_b = Member.objects.create(
            gym=self.gym_b, full_name='Jane Member B', email='member_b@test.com', status='ACTIVE'
        )

        # Auth setup
        # Login owner
        response = self.client.post('/api/auth/login/', {"email": "owner@test.com", "password": "password123"})
        self.owner_token = response.data['data']['access']
        
        # Login trainer
        response = self.client.post('/api/auth/login/', {"email": "trainer@test.com", "password": "password123"})
        self.trainer_token = response.data['data']['access']

        # Login member
        response = self.client.post('/api/auth/login/', {"email": "member@test.com", "password": "password123"})
        self.member_token = response.data['data']['access']

        # Foods
        self.food = Food.objects.create(
            food_name='Oats', category='CARBOHYDRATE', serving_size='50g',
            calories=190, protein=7.0, carbohydrates=32.0, fats=3.0, fiber=5.0
        )

    def test_food_crud(self):
        # 1. List foods
        response = self.client.get('/api/foods/', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['success'], True)

        # 2. Create food
        food_data = {
            "food_name": "Egg White",
            "category": "PROTEIN",
            "serving_size": "1 large",
            "calories": 17,
            "protein": "3.6",
            "carbohydrates": "0.2",
            "fats": "0.1",
            "fiber": "0.0"
        }
        response = self.client.post('/api/foods/', food_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_diet_plan_crud_and_cross_gym(self):
        # Create meal template
        meal_template = MealTemplate.objects.create(
            trainer=self.trainer_a, meal_name='Oats Breakfast', meal_type='BREAKFAST'
        )
        MealFood.objects.create(meal_template=meal_template, food=self.food, quantity=1.0)

        # Create plan (Valid)
        plan_data = {
            "trainer": str(self.trainer_a.id),
            "gym": str(self.gym_a.id),
            "plan_name": "Trainer Fat Loss",
            "goal": "FAT_LOSS",
            "target_calories": 2000,
            "target_protein": 140,
            "target_carbs": 160,
            "target_fats": 55,
            "duration_days": 7,
            "status": "ACTIVE",
            "plan_meals_write": [
                {
                    "meal_template": str(meal_template.id),
                    "day_number": 1,
                    "sequence_order": 1
                }
            ]
        }
        
        response = self.client.post('/api/diet-plans/', plan_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        diet_plan_id = response.data['data']['id']

        # Try to create with Gym B (Cross Gym check)
        bad_plan_data = plan_data.copy()
        bad_plan_data["gym"] = str(self.gym_b.id)
        response = self.client.post('/api/diet-plans/', bad_plan_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_diet_assignment_rules(self):
        diet_plan = DietPlan.objects.create(
            trainer=self.trainer_a, gym=self.gym_a, plan_name='Cut Plan', goal='FAT_LOSS',
            target_calories=2000, target_protein=150, target_carbs=150, target_fats=60, duration_days=7, status='ACTIVE'
        )

        assignment_data = {
            "member": self.member_a.id,
            "diet_plan": str(diet_plan.id),
            "assigned_by": str(self.trainer_a.id),
            "start_date": "2026-06-15",
            "end_date": "2026-06-22",
            "status": "ACTIVE",
            "notes": "Follow strictly"
        }

        # 1. Valid assignment
        response = self.client.post('/api/diet-assignments/', assignment_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        assignment_id = response.data['data']['id']

        # 2. Duplicate active assignment check
        response = self.client.post('/api/diet-assignments/', assignment_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("already has an active diet plan", str(response.data['errors']))

        # 3. Cross gym member check (try to assign Gym A diet plan to Gym B member)
        bad_assignment_data = assignment_data.copy()
        bad_assignment_data["member"] = self.member_b.id
        # Need to login as Gym B Owner to try assigning (since Gym A Trainer can't read Gym B member anyway)
        response = self.client.post('/api/diet-assignments/', bad_assignment_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.trainer_token}')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("same gym", str(response.data['errors']))

    def test_diet_logging_and_progress(self):
        diet_plan = DietPlan.objects.create(
            trainer=self.trainer_a, gym=self.gym_a, plan_name='Cut Plan', goal='FAT_LOSS',
            target_calories=2000, target_protein=150, target_carbs=150, target_fats=60, duration_days=7, status='ACTIVE'
        )
        meal_template = MealTemplate.objects.create(
            trainer=self.trainer_a, meal_name='Oats Breakfast', meal_type='BREAKFAST'
        )
        MealFood.objects.create(meal_template=meal_template, food=self.food, quantity=1.0)
        plan_meal = DietPlanMeal.objects.create(
            diet_plan=diet_plan, meal_template=meal_template, day_number=1, sequence_order=1
        )

        assigned_diet = MemberDietPlan.objects.create(
            member=self.member_a, diet_plan=diet_plan, assigned_by=self.trainer_a,
            start_date=datetime.date.today(), end_date=datetime.date.today() + datetime.timedelta(days=7),
            status='ACTIVE'
        )

        # 1. Log a meal
        log_data = {
            "member": self.member_a.id,
            "assigned_diet": str(assigned_diet.id),
            "meal": str(plan_meal.id),
            "completed": True,
            "notes": "Felt good"
        }
        response = self.client.post('/api/diet-logs/', log_data, format='json', HTTP_AUTHORIZATION=f'Bearer {self.member_token}')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        # 2. Get member progress
        response = self.client.get(f'/api/member-diets/{self.member_a.id}/progress/', HTTP_AUTHORIZATION=f'Bearer {self.member_token}')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['compliance_percentage'], 100.0)
        self.assertEqual(response.data['data']['consumed_calories'], 190)
