from django.test import TestCase
from django.contrib.auth import get_user_model
from gyms.models import Gym
from members.models import Member
from .models import KnowledgeCategory, KnowledgeArticle, AIConversation
from .services import KnowledgeBaseSearchService, detect_intent, AIResponseEngine

User = get_user_model()


class DetectIntentTestCase(TestCase):
    def test_exercise_alternative_intent(self):
        self.assertEqual(detect_intent("what are alternatives to bench press?"), "exercise_alternative")

    def test_nutrition_intent(self):
        self.assertIn(detect_intent("how much protein should I eat?"), ["nutrition", "general"])

    def test_beginner_intent(self):
        self.assertEqual(detect_intent("I am a beginner, where do I start?"), "beginner")

    def test_progress_intent(self):
        self.assertIn(detect_intent("how is my weight loss progress?"), ["progress", "general"])

    def test_motivation_intent(self):
        self.assertEqual(detect_intent("I feel like giving up"), "motivation")

    def test_general_intent(self):
        self.assertEqual(detect_intent("hello there"), "general")


class KBSearchTestCase(TestCase):
    def setUp(self):
        self.owner = User.objects.create_user(email="owner@test.com", password="pass", full_name="Owner", role='OWNER')
        self.gym = Gym.objects.create(
            gym_name="Test Gym", owner=self.owner,
            address="123 St", city="Mumbai", state="MH",
            pincode="400001", contact_number="9876543210", email="gym@test.com"
        )
        cat = KnowledgeCategory.objects.create(name="Exercises", slug="exercises", gym=None)
        self.article = KnowledgeArticle.objects.create(
            gym=None, category=cat,
            title="Barbell Squat",
            slug="barbell-squat",
            summary="A fundamental lower-body strength exercise.",
            content="The barbell squat is a compound movement targeting the quadriceps, glutes, and hamstrings.",
            article_type='EXERCISE',
            difficulty='INTERMEDIATE',
            tags=['squat', 'legs', 'compound'],
            muscle_groups=['quadriceps', 'glutes'],
            keywords='squat legs compound barbell strength',
        )

    def test_search_returns_results(self):
        svc = KnowledgeBaseSearchService()
        results = svc.search("squat", limit=5)
        self.assertGreater(len(list(results)), 0)

    def test_search_by_muscle_group(self):
        svc = KnowledgeBaseSearchService()
        results = svc.search("quadriceps", limit=5)
        self.assertGreater(len(list(results)), 0)

    def test_empty_search_returns_featured(self):
        svc = KnowledgeBaseSearchService()
        results = svc.search("", limit=10)
        self.assertIsNotNone(results)
