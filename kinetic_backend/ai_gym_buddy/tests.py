from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from gyms.models import Gym
from members.models import Member
from trainers.models import Trainer
from accounts.models import UserRole
from progress_tracking.models import ProgressMeasurement, FitnessGoal
from diets.models import DietPlan, MemberDietPlan
from gamification.models import Streak, MemberBadge, Badge

from .models import (
    KnowledgeCategory, KnowledgeArticle, ExerciseData,
    AIConversation, AIMessage, KnowledgeQA, AIInteractionLog
)
from .search_engine import KnowledgeBaseSearchEngine
from .context_engine import AIContextEngine
from .recommendation_engine import (
    ExerciseExplanationEngine, ExerciseAlternativeEngine,
    BeginnerCoachEngine, ProgressAnalysisEngine, GoalCoachingEngine
)
from .safety_guard import SafetyGuard
from .services import detect_intent, AIResponseEngine

User = get_user_model()

class AIBuddyUnitTests(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user(email="owner@test.com", password="password123", full_name="Gym Owner", role=UserRole.OWNER)
        self.gym = Gym.objects.create(
            gym_name="Victory Gym", owner=self.owner,
            address="100 Fitness Rd", city="Mumbai", state="MH",
            pincode="400001", contact_number="1234567890", email="victory@gym.com"
        )
        self.member_user = User.objects.create_user(email="member@test.com", password="password123", full_name="Gym Member", role=UserRole.MEMBER)
        self.member = Member.objects.create(
            gym=self.gym, full_name="Gym Member", email="member@test.com", phone_number="9876543210"
        )
        
        self.category = KnowledgeCategory.objects.create(name="Strength", slug="strength", gym=None)
        
        # Seed article
        self.article = KnowledgeArticle.objects.create(
            gym=None, category=self.category, title="Barbell Bench Press", slug="barbell-bench-press",
            summary="A classic chest pushing movement.", content="Lie on bench, press bar up.",
            article_type='EXERCISE', difficulty='INTERMEDIATE', tags='chest,press',
            muscle_groups='chest,triceps', equipment='barbell,bench', keywords='bench press chest push'
        )
        self.ex_data = ExerciseData.objects.create(
            article=self.article, primary_muscles="chest", secondary_muscles="triceps,deltoids",
            equipment_needed="barbell,bench", reps_range="8-12", rest_seconds=90, calories_per_minute=6.5
        )
        
        # Seed QA
        self.qa = KnowledgeQA.objects.create(
            gym=None, category=self.category, subcategory="Form",
            question="How do I breathe during squats?",
            answer="Inhale on the way down, exhale as you drive back up.",
            keywords="squat breathing inhale exhale", difficulty="BEGINNER",
            safety_notes="Do not hold your breath for extended periods.",
            related_topics="squat,breathing"
        )

    def test_intent_detection(self):
        self.assertEqual(detect_intent("What is an alternative to bench press?"), "exercise_alternative")
        self.assertEqual(detect_intent("Should I do keto diet for weight loss?"), "nutrition")
        self.assertEqual(detect_intent("Show me a beginner training plan"), "workout_plan")
        self.assertEqual(detect_intent("I am a beginner and new to the gym"), "beginner")
        self.assertEqual(detect_intent("Analyze my progress"), "progress")
        self.assertEqual(detect_intent("How can I recover from muscle soreness?"), "recovery")
        self.assertEqual(detect_intent("What is proper form for squats?"), "form")
        self.assertEqual(detect_intent("I feel tired and want to quit"), "motivation")

    def test_kb_search_engine(self):
        # Text search articles
        results = KnowledgeBaseSearchEngine.search("bench", gym=self.gym)
        self.assertGreater(len(results), 0)
        self.assertEqual(results[0]['title'], "Barbell Bench Press")

        # Text search QA
        results_qa = KnowledgeBaseSearchEngine.search("breathing", gym=self.gym)
        self.assertGreater(len(results_qa), 0)
        self.assertIn("breathe", results_qa[0]['title'].lower())

    def test_safety_guard(self):
        # Safe input
        safe = SafetyGuard.check_input("What is the best rep range for fat loss?")
        self.assertTrue(safe['is_safe'])
        
        # Unsafe chest pain trigger
        unsafe_pain = SafetyGuard.check_input("I have severe chest pain while doing squats")
        self.assertFalse(unsafe_pain['is_safe'])
        self.assertTrue(unsafe_pain['medical_flag'])

        # Unsafe substance trigger
        unsafe_substance = SafetyGuard.check_input("Should I take SARMs or steroids to get big?")
        self.assertFalse(unsafe_substance['is_safe'])
        self.assertTrue(unsafe_substance['needs_trainer_redirect'])

    def test_context_engine(self):
        # Create fitness goal
        FitnessGoal.objects.create(
            member=self.member, goal_type='FAT_LOSS', starting_weight=80.0,
            target_weight=75.0, target_date="2026-12-31", status='ACTIVE', current_progress_percentage=20.0
        )
        # Create streak
        Streak.objects.create(member=self.member, streak_type='ATTENDANCE', current_streak=5, longest_streak=10)

        context = AIContextEngine.get_member_context(self.member)
        self.assertEqual(context['full_name'], "Gym Member")
        self.assertTrue(context['has_active_goals'])
        self.assertEqual(context['attendance']['current_streak_days'], 5)

    def test_exercise_explanation(self):
        explanation = ExerciseExplanationEngine.explain("Barbell Bench Press", gym=self.gym)
        self.assertTrue(explanation['found'])
        self.assertEqual(explanation['title'], "Barbell Bench Press")
        self.assertIn("chest", explanation['muscles_worked']['primary'])

    def test_exercise_alternatives(self):
        alts = ExerciseAlternativeEngine.suggest_alternatives("Barbell Bench Press", constraint="dumbbell", gym=self.gym)
        self.assertEqual(alts['original_exercise'], "Barbell Bench Press")
        # Dumbbells should be filtered out by the constraint
        for a in alts['alternatives']:
            self.assertNotIn("dumbbell", a['title'].lower())

    def test_beginner_coach(self):
        plan = BeginnerCoachEngine.generate_coach_plan(goal="FAT_LOSS", fitness_level="BEGINNER", attendance_rate=80.0)
        self.assertIn("Welcome", plan['day_1_plan']['title'])
        self.assertIn("Building Consistency", plan['week_1_plan']['title'])

    def test_progress_analysis(self):
        # Setup context data
        context = {
            'progress': {
                'history': [
                    {'weight_kg': 78.0, 'recorded_date': '2026-06-15'},
                    {'weight_kg': 80.0, 'recorded_date': '2026-06-01'}
                ]
            },
            'attendance': {
                'consistency_rate_30d': 80.0,
                'current_streak_days': 5
            }
        }
        analysis = ProgressAnalysisEngine.analyze(context)
        self.assertIn("lost 2.0 kg", analysis['weight_trend'])
        self.assertIn("Excellent", analysis['attendance_grade'])


class AIWebAPISecurityTests(APITestCase):
    def setUp(self):
        self.owner = User.objects.create_user(email="owner@test.com", password="password123", full_name="Gym Owner", role=UserRole.OWNER)
        self.trainer = User.objects.create_user(email="trainer@test.com", password="password123", full_name="Gym Trainer", role=UserRole.TRAINER)
        self.member_user = User.objects.create_user(email="member@test.com", password="password123", full_name="Gym Member", role=UserRole.MEMBER)
        
        self.gym = Gym.objects.create(
            gym_name="Hardcore Gym", owner=self.owner,
            address="200 Muscle Blvd", city="Pune", state="MH",
            pincode="411001", contact_number="0987654321", email="hardcore@gym.com"
        )
        from datetime import date
        self.trainer_profile = Trainer.objects.create(
            user=self.trainer, gym=self.gym, specialization="Strength Coaching", experience_years=5,
            joining_date=date.today(), employee_id="EMP_AI"
        )
        self.member = Member.objects.create(
            gym=self.gym, full_name="Gym Member", email="member@test.com", phone_number="9876543210"
        )
        self.category = KnowledgeCategory.objects.create(name="Strength", slug="strength", gym=None)

    def test_rbac_chat_access(self):
        # 1. Anonymous Access Denied
        url = reverse('ai_chat')
        response = self.client.post(url, {'message': "Hello"})
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        # 2. Member Access Allowed
        self.client.force_authenticate(user=self.member_user)
        response = self.client.post(url, {'message': "Hello Gym Buddy!"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])

        # 3. Trainer Access Denied to Chat
        self.client.force_authenticate(user=self.trainer)
        response = self.client.post(url, {'message': "Hello Trainer Buddy"})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_rbac_progress_analysis_cross_tenant(self):
        # Create other gym, member
        other_owner = User.objects.create_user(email="other_owner@test.com", password="password123", role=UserRole.OWNER)
        other_gym = Gym.objects.create(
            gym_name="Other Gym", owner=other_owner, pincode="411002", contact_number="1111111111"
        )
        other_member = Member.objects.create(
            gym=other_gym, full_name="Other Member", email="other_member@test.com"
        )

        # Authenticate trainer from first gym
        self.client.force_authenticate(user=self.trainer)
        url = reverse('ai_progress_analysis')
        
        # Check cross-tenant query for other_member (should be forbidden or not found)
        response = self.client.post(url, {'member_id': str(other_member.id)})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        # Query member in same gym (allowed)
        response = self.client.post(url, {'member_id': str(self.member.id)})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_rbac_owner_analytics(self):
        url = reverse('ai_analytics')
        
        # Member access denied
        self.client.force_authenticate(user=self.member_user)
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

        # Owner access allowed
        self.client.force_authenticate(user=self.owner)
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue('total_interactions' in response.data['data'])
