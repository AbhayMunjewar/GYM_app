"""
AI Buddy Services
=================
Knowledge Base Search → Context Engine → Response Engine pipeline.
Works without any LLM configured (KB-only mode).
"""
import time
import logging
import re
from datetime import date, timedelta
from typing import Optional

from django.db.models import Q, F

from .models import (
    KnowledgeArticle, KnowledgeCategory, ExerciseData,
    AIConversation, AIMessage, AIInteractionLog,
    ConversationType, MessageRole, ResponseSource,
)
from members.models import Member

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Intent Detection
# ---------------------------------------------------------------------------

INTENT_PATTERNS = {
    'exercise_alternative': [
        r'alternative[s]? (to|for)', r'replace\b', r'swap\b', r'instead of', r'substitute',
        r'can.t do', r'cannot do', r'shoulder (pain|injury|hurt)', r'knee (pain|injury|hurt)',
        r'back (pain|injury)', r'different exercise',
    ],
    'nutrition': [
        r'diet\b', r'calori', r'protein\b', r'carb\b', r'fat\b', r'meal\b', r'eat\b',
        r'nutrition', r'food\b', r'supplement', r'macro', r'bulking', r'cutting',
    ],
    'workout_plan': [
        r'workout plan', r'training plan', r'program\b', r'routine\b', r'schedule\b',
        r'ppl\b', r'push.pull', r'full body', r'split\b', r'how many days',
    ],
    'beginner': [
        r'beginner', r'new to gym', r'just started', r'first time', r'never worked out',
        r'where do i start', r'how do i start', r'starting out',
    ],
    'progress': [
        r'progress\b', r'weight loss', r'losing weight', r'gaining muscle', r'plateau',
        r'not seeing result', r'measurement', r'body fat', r'transformation',
    ],
    'recovery': [
        r'recovery\b', r'rest day', r'sore\b', r'soreness', r'doms\b', r'sleep\b',
        r'overtraining', r'injury\b', r'stretching', r'foam roll',
    ],
    'form': [
        r'form\b', r'technique\b', r'how to (do|perform)', r'proper form', r'tips for',
        r'correct way', r'common mistake',
    ],
    'motivation': [
        r'motivat', r'demotivat', r'give up', r'quit\b', r'tired of', r'bored\b',
    ],
}


def detect_intent(query: str) -> str:
    """Return the most likely intent for a user query."""
    query_lower = query.lower()
    scores = {intent: 0 for intent in INTENT_PATTERNS}
    for intent, patterns in INTENT_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, query_lower):
                scores[intent] += 1
    best = max(scores, key=scores.get)
    return best if scores[best] > 0 else 'general'


# ---------------------------------------------------------------------------
# Knowledge Base Search Service
# ---------------------------------------------------------------------------

class KnowledgeBaseSearchService:
    """Full-text keyword search with TF-IDF-like scoring across KnowledgeArticles."""

    @staticmethod
    def search(query: str, gym=None, article_type: str = None,
               difficulty: str = None, limit: int = 5):
        """
        Search articles using keyword matching.
        Returns a queryset ordered by relevance (approximated by annotation).
        """
        qs = KnowledgeArticle.objects.filter(is_active=True)
        # Include global articles OR gym-specific ones
        if gym:
            qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qs = qs.filter(gym__isnull=True)

        if article_type:
            qs = qs.filter(article_type=article_type)
        if difficulty:
            qs = qs.filter(difficulty=difficulty)

        # Keyword-based scoring: search in title, keywords, tags, content
        tokens = [t.strip().lower() for t in query.split() if len(t) > 2]
        if not tokens:
            return qs.order_by('-is_featured', '-view_count')[:limit]

        # Build Q filter across searchable fields
        q_filter = Q()
        for token in tokens:
            q_filter |= (
                Q(title__icontains=token) |
                Q(keywords__icontains=token) |
                Q(summary__icontains=token) |
                Q(tags__icontains=token) |
                Q(muscle_groups__icontains=token)
            )
        qs = qs.filter(q_filter)

        # Boost featured and popular articles
        qs = qs.order_by('-is_featured', '-view_count', 'title')
        return qs[:limit]

    @staticmethod
    def get_exercise_by_name(name: str, gym=None):
        """Fuzzy-find an exercise article by name."""
        qs = KnowledgeArticle.objects.filter(
            article_type='EXERCISE', is_active=True
        )
        if gym:
            qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qs = qs.filter(gym__isnull=True)

        # Exact match first
        exact = qs.filter(title__iexact=name).first()
        if exact:
            return exact
        # Partial match
        return qs.filter(title__icontains=name).first()


# ---------------------------------------------------------------------------
# Context Engine
# ---------------------------------------------------------------------------

class AIContextEngine:
    """
    Aggregates member data for personalizing AI responses.
    Reads from existing Workout, Diet, Progress, Gamification modules.
    """

    @staticmethod
    def build_context(member: Member) -> dict:
        """Return a dict summarising the member's current fitness state."""
        ctx = {
            'member_name': member.full_name,
            'gender': member.gender,
            'weight_kg': member.weight_kg,
            'height_cm': member.height_cm,
            'join_date': str(member.join_date),
        }

        # --- Progress Measurements ---
        try:
            from progress_tracking.models import ProgressMeasurement, FitnessGoal
            latest_measurement = ProgressMeasurement.objects.filter(
                member=member
            ).order_by('-recorded_date').first()
            if latest_measurement:
                ctx['current_weight_kg'] = latest_measurement.weight_kg
                ctx['body_fat_percentage'] = latest_measurement.body_fat_percentage
                ctx['bmi'] = latest_measurement.bmi

            active_goals = FitnessGoal.objects.filter(
                member=member, status='ACTIVE'
            ).values('goal_type', 'target_weight', 'target_body_fat', 'current_progress_percentage')
            ctx['active_goals'] = list(active_goals)
        except Exception as e:
            logger.debug(f"Context engine - progress error: {e}")

        # --- Gamification Streaks ---
        try:
            from gamification.models import Streak, RewardPointTransaction
            streak = Streak.objects.filter(member=member, streak_type='ATTENDANCE').first()
            if streak:
                ctx['current_streak'] = streak.current_streak
                ctx['longest_streak'] = streak.longest_streak
            total_points = sum(
                t.points_earned
                for t in RewardPointTransaction.objects.filter(member=member)
            )
            ctx['total_points'] = total_points
        except Exception as e:
            logger.debug(f"Context engine - gamification error: {e}")

        # --- Diet Plan ---
        try:
            from diets.models import MemberDietPlan
            active_diet = MemberDietPlan.objects.filter(
                member=member, is_active=True
            ).select_related('diet_plan').first()
            if active_diet:
                ctx['active_diet_plan'] = active_diet.diet_plan.plan_name
                ctx['daily_calories_target'] = active_diet.diet_plan.daily_calories
        except Exception as e:
            logger.debug(f"Context engine - diet error: {e}")

        # --- Workout Plan ---
        try:
            from workout_sessions.models import SessionBooking
            upcoming_sessions = SessionBooking.objects.filter(
                member=member, status='booked'
            ).select_related('session').order_by('session__session_date')[:3]
            if upcoming_sessions:
                ctx['upcoming_sessions'] = [
                    {'title': b.session.title, 'date': str(b.session.session_date)}
                    for b in upcoming_sessions
                ]
        except Exception as e:
            logger.debug(f"Context engine - workout error: {e}")

        return ctx


# ---------------------------------------------------------------------------
# Exercise Alternative Engine
# ---------------------------------------------------------------------------

class ExerciseAlternativeEngine:
    """
    Returns alternative exercises for a given exercise name,
    optionally filtered by a constraint (e.g. injury, equipment).
    """

    @staticmethod
    def get_alternatives(exercise_name: str, constraint: Optional[str] = None, gym=None) -> dict:
        """
        Returns:
        {
          'original_exercise': {...},
          'alternatives': [...],
          'reasoning': '...'
        }
        """
        search_service = KnowledgeBaseSearchService()
        original = search_service.get_exercise_by_name(exercise_name, gym=gym)

        result = {
            'original_exercise': None,
            'alternatives': [],
            'reasoning': '',
        }

        if original:
            result['original_exercise'] = {
                'id': str(original.id),
                'title': original.title,
                'summary': original.summary,
                'difficulty': original.difficulty,
                'muscle_groups': original.muscle_groups,
            }
            # Try to get M2M alternatives from ExerciseData
            try:
                ex_data = original.exercise_data
                movement = ex_data.movement_pattern
                muscles = ex_data.primary_muscles

                # Get alternatives stored in DB
                alts_qs = ex_data.alternatives.filter(is_active=True)
                if constraint:
                    # Filter out exercises requiring constrained equipment
                    alts_qs = alts_qs.exclude(equipment__icontains=constraint)

                if alts_qs.exists():
                    for alt in alts_qs[:5]:
                        result['alternatives'].append({
                            'id': str(alt.id),
                            'title': alt.title,
                            'summary': alt.summary,
                            'difficulty': alt.difficulty,
                            'muscle_groups': alt.muscle_groups,
                        })
                else:
                    # Fallback: search by same movement pattern / muscle group
                    fallback_q = Q(article_type='EXERCISE', is_active=True)
                    if gym:
                        fallback_q &= Q(Q(gym__isnull=True) | Q(gym=gym))
                    else:
                        fallback_q &= Q(gym__isnull=True)
                    fallback_q &= ~Q(id=original.id)

                    if muscles:
                        fallback_q &= Q(muscle_groups__icontains=muscles[0])

                    fallback_arts = KnowledgeArticle.objects.filter(fallback_q)[:5]
                    for alt in fallback_arts:
                        result['alternatives'].append({
                            'id': str(alt.id),
                            'title': alt.title,
                            'summary': alt.summary,
                            'difficulty': alt.difficulty,
                            'muscle_groups': alt.muscle_groups,
                        })

                constraint_note = f" that don't require {constraint}" if constraint else ''
                result['reasoning'] = (
                    f"These exercises target similar muscle groups as {original.title}"
                    f"{constraint_note} and can serve as effective substitutes."
                )
            except ExerciseData.DoesNotExist:
                # No extended data, do a text search
                fallback = search_service.search(exercise_name, gym=gym, article_type='EXERCISE', limit=5)
                for alt in fallback:
                    if str(alt.id) != str(original.id):
                        result['alternatives'].append({
                            'id': str(alt.id),
                            'title': alt.title,
                            'summary': alt.summary,
                            'difficulty': alt.difficulty,
                            'muscle_groups': alt.muscle_groups,
                        })
                result['reasoning'] = f"Here are exercises similar to {original.title}."
        else:
            # Exercise not found in KB – search for closest match
            fallback = search_service.search(exercise_name, gym=gym, article_type='EXERCISE', limit=5)
            for alt in fallback:
                result['alternatives'].append({
                    'id': str(alt.id),
                    'title': alt.title,
                    'summary': alt.summary,
                    'difficulty': alt.difficulty,
                    'muscle_groups': alt.muscle_groups,
                })
            result['reasoning'] = (
                f"I couldn't find \"{exercise_name}\" in the knowledge base, "
                f"but here are some exercises you might find useful."
            )
        return result


# ---------------------------------------------------------------------------
# Beginner Coach Service
# ---------------------------------------------------------------------------

class BeginnerCoachService:
    """Generates a 7-day beginner workout + nutrition guidance using KB articles."""

    @staticmethod
    def generate_beginner_plan(member: Member, gym=None) -> dict:
        """
        Returns a structured 7-day plan with workout suggestions, nutrition tips,
        and recovery guidance sourced from the Knowledge Base.
        """
        search = KnowledgeBaseSearchService()

        # Fetch relevant articles
        workout_articles = list(search.search('beginner full body workout', gym=gym, difficulty='BEGINNER', limit=6))
        nutrition_articles = list(search.search('beginner nutrition protein calories', gym=gym, article_type='NUTRITION', limit=3))
        recovery_articles = list(search.search('recovery rest sleep beginner', gym=gym, article_type='RECOVERY', limit=2))

        # Build 7-day structure (Workout / Rest pattern)
        week_plan = [
            {'day': 1, 'day_name': 'Monday', 'type': 'workout', 'focus': 'Full Body A'},
            {'day': 2, 'day_name': 'Tuesday', 'type': 'rest', 'focus': 'Active Recovery'},
            {'day': 3, 'day_name': 'Wednesday', 'type': 'workout', 'focus': 'Full Body B'},
            {'day': 4, 'day_name': 'Thursday', 'type': 'rest', 'focus': 'Rest Day'},
            {'day': 5, 'day_name': 'Friday', 'type': 'workout', 'focus': 'Full Body A'},
            {'day': 6, 'day_name': 'Saturday', 'type': 'cardio', 'focus': 'Light Cardio / Walk'},
            {'day': 7, 'day_name': 'Sunday', 'type': 'rest', 'focus': 'Complete Rest'},
        ]

        return {
            'member_name': member.full_name,
            'week_plan': week_plan,
            'recommended_exercises': [
                {'id': str(a.id), 'title': a.title, 'summary': a.summary, 'difficulty': a.difficulty}
                for a in workout_articles
            ],
            'nutrition_tips': [
                {'id': str(a.id), 'title': a.title, 'summary': a.summary}
                for a in nutrition_articles
            ],
            'recovery_tips': [
                {'id': str(a.id), 'title': a.title, 'summary': a.summary}
                for a in recovery_articles
            ],
            'key_advice': [
                'Start with compound movements: squats, deadlifts, bench press, rows.',
                'Aim for 3 full-body sessions per week with rest days in between.',
                'Eat enough protein: aim for 1.6–2g per kg of bodyweight.',
                'Sleep 7–9 hours to allow muscle recovery and growth.',
                'Track your workouts and increase weight gradually (progressive overload).',
                'Stay consistent — results come from weeks and months of effort, not single sessions.',
            ],
        }


# ---------------------------------------------------------------------------
# Progress Analysis Service
# ---------------------------------------------------------------------------

class ProgressAnalysisService:
    """Generates text-based insights from member progress data."""

    @staticmethod
    def generate_insights(member: Member) -> dict:
        """
        Returns a dict with textual insights and trend data.
        """
        insights = {
            'weight_trend': None,
            'body_fat_trend': None,
            'streak_insight': None,
            'goal_insights': [],
            'recommendations': [],
            'overall_summary': '',
        }

        try:
            from progress_tracking.models import ProgressMeasurement, FitnessGoal
            measurements = ProgressMeasurement.objects.filter(
                member=member
            ).order_by('-recorded_date')[:10]

            if measurements.count() >= 2:
                recent = measurements[0]
                older = measurements[measurements.count() - 1]
                weight_diff = recent.weight_kg - older.weight_kg
                fat_diff = recent.body_fat_percentage - older.body_fat_percentage

                # Weight trend
                if weight_diff < -0.5:
                    insights['weight_trend'] = {
                        'direction': 'down',
                        'change': round(abs(weight_diff), 1),
                        'message': f"You've lost {abs(weight_diff):.1f} kg — great progress! Keep up the consistency."
                    }
                elif weight_diff > 0.5:
                    insights['weight_trend'] = {
                        'direction': 'up',
                        'change': round(weight_diff, 1),
                        'message': f"You've gained {weight_diff:.1f} kg. This could be muscle gain — check your body fat trend."
                    }
                else:
                    insights['weight_trend'] = {
                        'direction': 'stable',
                        'change': 0,
                        'message': "Your weight has been stable. If losing fat is your goal, consider reviewing your caloric deficit."
                    }

                # Body fat trend
                if fat_diff < -0.5:
                    insights['body_fat_trend'] = {
                        'direction': 'down',
                        'message': f"Body fat reduced by {abs(fat_diff):.1f}% — excellent! You're building a leaner physique."
                    }
                elif fat_diff > 0.5:
                    insights['body_fat_trend'] = {
                        'direction': 'up',
                        'message': f"Body fat increased by {fat_diff:.1f}%. Consider reviewing nutrition and cardio frequency."
                    }

            elif measurements.count() == 1:
                insights['overall_summary'] = (
                    "Good start! Log more measurements over time to see meaningful trends and insights."
                )

            # Goals
            active_goals = FitnessGoal.objects.filter(member=member, status='ACTIVE')
            for goal in active_goals:
                pct = goal.current_progress_percentage
                if pct >= 75:
                    insights['goal_insights'].append({
                        'goal_type': goal.goal_type,
                        'progress': pct,
                        'message': f"Almost there! You're {pct:.0f}% through your {goal.goal_type.replace('_', ' ').title()} goal."
                    })
                elif pct >= 25:
                    insights['goal_insights'].append({
                        'goal_type': goal.goal_type,
                        'progress': pct,
                        'message': f"Solid progress at {pct:.0f}%! Keep pushing toward your {goal.goal_type.replace('_', ' ').title()} goal."
                    })
                else:
                    insights['goal_insights'].append({
                        'goal_type': goal.goal_type,
                        'progress': pct,
                        'message': f"You've just begun your {goal.goal_type.replace('_', ' ').title()} journey. Every step counts!"
                    })

        except Exception as e:
            logger.debug(f"ProgressAnalysisService error: {e}")

        # Streak insight
        try:
            from gamification.models import Streak
            streak = Streak.objects.filter(member=member, streak_type='ATTENDANCE').first()
            if streak:
                if streak.current_streak >= 7:
                    insights['streak_insight'] = f"Incredible! You're on a {streak.current_streak}-day streak! 🔥 Consistency is your superpower."
                elif streak.current_streak >= 3:
                    insights['streak_insight'] = f"On fire with a {streak.current_streak}-day streak! Keep it going."
                elif streak.current_streak > 0:
                    insights['streak_insight'] = f"You're building momentum with a {streak.current_streak}-day streak. Don't break the chain!"
                else:
                    insights['streak_insight'] = "Start your streak today! Show up and build momentum."
        except Exception as e:
            logger.debug(f"Streak insight error: {e}")

        # General recommendations
        if not insights['weight_trend'] and not insights['goal_insights']:
            insights['recommendations'] = [
                "Log your first body measurement to start tracking your transformation.",
                "Set a clear fitness goal (Fat Loss, Muscle Gain, or Maintenance) to get personalized insights.",
                "Aim for at least 3 gym sessions per week to build momentum.",
            ]
        else:
            insights['recommendations'] = [
                "Continue logging measurements every 2 weeks for accurate trend analysis.",
                "Pair your training with consistent nutrition tracking for best results.",
                "Ask your AI Gym Buddy for exercise alternatives or nutrition tips anytime.",
            ]

        if not insights['overall_summary']:
            insights['overall_summary'] = (
                f"Hi {member.full_name}! Here's your progress snapshot. "
                "Remember: consistency over intensity — small daily improvements add up."
            )

        return insights


# ---------------------------------------------------------------------------
# AI Response Engine (KB-first, no LLM required)
# ---------------------------------------------------------------------------

class AIResponseEngine:
    """
    Orchestrates: intent detection → context gathering → KB search → response formatting.
    Works fully without an LLM. LLM integration is a future enhancement.
    """

    def __init__(self, gym, member: Member):
        self.gym = gym
        self.member = member
        self.search = KnowledgeBaseSearchService()

    def process_message(self, message: str, conversation: AIConversation) -> dict:
        """
        Process a user message and return an AI response dict:
        {
          'content': '...',
          'sources': [...],
          'response_source': 'KB' | 'TEMPLATE',
          'detected_intent': '...',
        }
        """
        start_time = time.time()
        intent = detect_intent(message)
        context = AIContextEngine.build_context(self.member)

        response_text = ''
        sources = []
        source_type = ResponseSource.KB

        # Route by intent
        if intent == 'exercise_alternative':
            # Extract exercise name from query
            exercise_name = self._extract_exercise_name(message)
            constraint = self._extract_constraint(message)
            alt_result = ExerciseAlternativeEngine.get_alternatives(
                exercise_name, constraint=constraint, gym=self.gym
            )
            sources = [a['id'] for a in alt_result['alternatives']]
            if alt_result['alternatives']:
                response_text = f"{alt_result['reasoning']}\n\n"
                for i, alt in enumerate(alt_result['alternatives'][:4], 1):
                    response_text += f"**{i}. {alt['title']}** ({alt['difficulty']})\n"
                    response_text += f"   {alt['summary']}\n\n"
            else:
                response_text = (
                    f"I couldn't find specific alternatives for '{exercise_name}' in our knowledge base. "
                    "Please ask your trainer or check the Exercise Library for similar movements."
                )
                source_type = ResponseSource.TEMPLATE

        elif intent == 'beginner':
            articles = list(self.search.search(
                'beginner workout guide start gym', gym=self.gym,
                difficulty='BEGINNER', limit=4
            ))
            sources = [str(a.id) for a in articles]
            response_text = (
                f"Welcome to your fitness journey, {self.member.full_name}! 🎉\n\n"
                "Here's how to get started:\n\n"
                "1. **Start Simple**: Begin with 3 full-body workouts per week\n"
                "2. **Master Form First**: Learn proper technique before adding weight\n"
                "3. **Progressive Overload**: Gradually increase weight or reps each week\n"
                "4. **Nutrition Matters**: Eat enough protein (1.6-2g per kg of body weight)\n"
                "5. **Rest & Recover**: Sleep 7-9 hours; muscles grow during rest\n\n"
            )
            if articles:
                response_text += "📚 Recommended reading from our Knowledge Base:\n"
                for a in articles:
                    response_text += f"• **{a.title}** — {a.summary}\n"

        elif intent == 'nutrition':
            articles = list(self.search.search(message, gym=self.gym, article_type='NUTRITION', limit=4))
            sources = [str(a.id) for a in articles]
            member_name = self.member.full_name
            diet_note = ''
            if context.get('active_diet_plan'):
                diet_note = f"\n\nI see you're currently on the **{context['active_diet_plan']}** plan. "
                if context.get('daily_calories_target'):
                    diet_note += f"Your daily target is {context['daily_calories_target']} kcal."
            response_text = (
                f"Great question about nutrition, {member_name}!{diet_note}\n\n"
                "Here are some key principles:\n"
                "• **Protein**: Aim for 1.6–2g per kg of bodyweight for muscle preservation/gain\n"
                "• **Calories**: Track your intake relative to your goal (deficit for fat loss, surplus for muscle gain)\n"
                "• **Timing**: Pre-workout carbs for energy; post-workout protein for recovery\n"
                "• **Hydration**: Drink 2–3 liters of water daily\n\n"
            )
            if articles:
                response_text += "📚 From our Nutrition Knowledge Base:\n"
                for a in articles:
                    response_text += f"• **{a.title}** — {a.summary}\n"

        elif intent == 'workout_plan':
            articles = list(self.search.search(message, gym=self.gym, article_type='WORKOUT_PLAN', limit=4))
            if not articles:
                articles = list(self.search.search('workout program training', gym=self.gym, limit=4))
            sources = [str(a.id) for a in articles]
            streak = context.get('current_streak', 0)
            response_text = (
                f"Let me help you with a workout plan! "
                f"{'You have a great ' + str(streak) + '-day streak going! 🔥 ' if streak > 3 else ''}\n\n"
                "Popular training approaches:\n"
                "• **PPL (Push-Pull-Legs)**: 6 days/week, great for intermediate lifters\n"
                "• **Full Body**: 3 days/week, ideal for beginners and busy schedules\n"
                "• **Upper/Lower Split**: 4 days/week, balanced approach\n"
                "• **PHUL (Power Hypertrophy)**: 4 days/week, combines strength + size\n\n"
            )
            if articles:
                response_text += "📚 Training resources:\n"
                for a in articles:
                    response_text += f"• **{a.title}** — {a.summary}\n"

        elif intent == 'progress':
            insights = ProgressAnalysisService.generate_insights(self.member)
            response_text = insights['overall_summary'] + '\n\n'
            if insights['weight_trend']:
                response_text += f"⚖️ **Weight**: {insights['weight_trend']['message']}\n"
            if insights['streak_insight']:
                response_text += f"🔥 **Streak**: {insights['streak_insight']}\n"
            for gi in insights['goal_insights']:
                response_text += f"🎯 **{gi['goal_type'].replace('_', ' ').title()}**: {gi['message']}\n"
            if insights['recommendations']:
                response_text += "\n💡 **Recommendations**:\n"
                for rec in insights['recommendations']:
                    response_text += f"• {rec}\n"
            source_type = ResponseSource.CONTEXT

        elif intent == 'recovery':
            articles = list(self.search.search(message, gym=self.gym, article_type='RECOVERY', limit=4))
            sources = [str(a.id) for a in articles]
            response_text = (
                "Recovery is where the real gains happen! 💤\n\n"
                "Key recovery principles:\n"
                "• **Sleep**: 7–9 hours of quality sleep is non-negotiable\n"
                "• **Active Recovery**: Light walks, yoga, or stretching on rest days\n"
                "• **Nutrition**: Prioritize protein and carbs post-workout\n"
                "• **Foam Rolling**: Reduces muscle soreness and improves flexibility\n"
                "• **Hydration**: Stay hydrated throughout the day\n"
                "• **Deload Weeks**: Every 4–6 weeks, reduce training volume by 40-50%\n\n"
            )
            if articles:
                response_text += "📚 Recovery resources:\n"
                for a in articles:
                    response_text += f"• **{a.title}** — {a.summary}\n"

        elif intent == 'form':
            articles = list(self.search.search(message, gym=self.gym, limit=4))
            sources = [str(a.id) for a in articles]
            response_text = (
                "Proper form is the foundation of safe, effective training! 🏋️\n\n"
                "General form tips:\n"
                "• Always warm up (5–10 min light cardio + dynamic stretching)\n"
                "• Master bodyweight movements before adding load\n"
                "• Record yourself to identify form breakdown points\n"
                "• Ask your trainer for a form check session\n"
                "• If pain occurs — stop, rest, and consult a professional\n\n"
            )
            if articles:
                response_text += "📚 Related guides:\n"
                for a in articles:
                    response_text += f"• **{a.title}** — {a.summary}\n"

        elif intent == 'motivation':
            streak = context.get('current_streak', 0)
            points = context.get('total_points', 0)
            response_text = (
                f"Every champion was once a beginner, {self.member.full_name}! 💪\n\n"
            )
            if streak > 0:
                response_text += f"You've maintained a {streak}-day streak — that's proof of your commitment!\n\n"
            if points > 0:
                response_text += f"You've earned {points} points so far — keep collecting them!\n\n"
            response_text += (
                "Remember:\n"
                "• Progress isn't always visible — trust the process\n"
                "• Bad days happen; what matters is showing up anyway\n"
                "• Compare yourself to who you were yesterday, not to others\n"
                "• Your consistency will compound into incredible results\n\n"
                "What's one small thing you can do today? Let's focus on that! 🎯"
            )
            source_type = ResponseSource.TEMPLATE

        else:
            # General: search KB
            articles = list(self.search.search(message, gym=self.gym, limit=4))
            sources = [str(a.id) for a in articles]
            member_name = self.member.full_name
            response_text = f"Hey {member_name}! "
            if articles:
                response_text += "Here's what I found in our Fitness Knowledge Base:\n\n"
                for a in articles:
                    response_text += f"• **{a.title}** ({a.difficulty}) — {a.summary}\n"
                response_text += "\nWant more details on any of these topics? Just ask!"
            else:
                response_text += (
                    "I'm your AI Gym Buddy, here to help with workouts, nutrition, "
                    "exercise form, recovery, and progress tracking!\n\n"
                    "Try asking me:\n"
                    "• 'What are alternatives to bench press?'\n"
                    "• 'How much protein should I eat?'\n"
                    "• 'Show me a beginner workout plan'\n"
                    "• 'How is my progress going?'\n"
                    "• 'Tips for recovering after a hard session'"
                )
                source_type = ResponseSource.TEMPLATE

        latency_ms = int((time.time() - start_time) * 1000)

        # Log the interaction
        try:
            AIInteractionLog.objects.create(
                gym=self.gym,
                member=self.member,
                query=message[:500],
                detected_intent=intent,
                response_source=source_type,
                latency_ms=latency_ms,
            )
        except Exception as e:
            logger.debug(f"Failed to log AI interaction: {e}")

        return {
            'content': response_text,
            'sources': sources,
            'response_source': source_type,
            'detected_intent': intent,
            'context_used': context,
        }

    def _extract_exercise_name(self, message: str) -> str:
        """Extract an exercise name from a message string."""
        # Try to find "alternative to X" / "replace X" patterns
        patterns = [
            r'alternative[s]? (?:to|for) (.+?)(?:\?|$|,|\band\b)',
            r'replace (.+?)(?:\?|$|,|\bwith\b)',
            r'instead of (.+?)(?:\?|$|,)',
            r'substitute (?:for )?(.+?)(?:\?|$|,)',
            r"can'?t? do (.+?)(?:\?|$|,|due to)",
        ]
        for pattern in patterns:
            match = re.search(pattern, message, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        # Default: take the first substantial noun phrase
        words = message.split()
        return ' '.join(words[:3]) if words else 'exercise'

    def _extract_constraint(self, message: str) -> Optional[str]:
        """Extract constraints like injury or equipment from message."""
        pain_patterns = [
            r'(shoulder|knee|back|wrist|elbow|ankle|hip)\s*(pain|injury|hurt|problem)',
            r'no\s+(barbell|dumbbell|machine|cable|rack|equipment|gym)',
            r'without\s+(a |the )?(barbell|dumbbell|machine|rack)',
        ]
        for pattern in pain_patterns:
            match = re.search(pattern, message, re.IGNORECASE)
            if match:
                return match.group(0).strip()
        return None


# ---------------------------------------------------------------------------
# Dashboard Tip Service
# ---------------------------------------------------------------------------

class DashboardTipService:
    """Returns a single daily motivational tip + relevant KB article."""

    TIPS = [
        ("Progressive Overload", "The key to continuous progress is adding more weight, reps, or sets each week."),
        ("Protein First", "Build your meals around protein to stay full and support muscle recovery."),
        ("Sleep to Grow", "Your muscles grow during sleep, not in the gym. Prioritize 7-9 hours."),
        ("Track Your Lifts", "What gets measured gets managed. Log every session to see your progress clearly."),
        ("Hydration Boost", "Even 2% dehydration can drop performance by 10%. Drink water throughout the day."),
        ("Form Before Weight", "Perfect your technique before adding load. Ego lifting leads to injuries."),
        ("Rest Days Win", "Rest days are not lazy days — they're when your muscles repair and grow stronger."),
        ("Consistency Beats Intensity", "Showing up 3x/week for a year beats perfect training for one month."),
        ("Warm Up Always", "5-10 minutes of dynamic warm-up reduces injury risk and improves performance."),
        ("Compound Movements", "Squats, deadlifts, bench and rows give you the most bang for your training buck."),
    ]

    @staticmethod
    def get_daily_tip(gym=None) -> dict:
        day_of_year = date.today().timetuple().tm_yday
        tip_index = day_of_year % len(DashboardTipService.TIPS)
        tip_title, tip_content = DashboardTipService.TIPS[tip_index]

        # Try to find a related article
        related_article = None
        try:
            articles = KnowledgeBaseSearchService.search(
                KnowledgeBaseSearchService(), tip_title, gym=gym, limit=1
            )
            if articles:
                a = articles[0]
                related_article = {'id': str(a.id), 'title': a.title}
        except Exception:
            pass

        return {
            'tip_title': tip_title,
            'tip_content': tip_content,
            'related_article': related_article,
        }
