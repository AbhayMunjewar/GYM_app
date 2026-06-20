import time
import logging
import re
from datetime import date
from typing import Optional

from django.db.models import Q

from .models import (
    KnowledgeArticle, KnowledgeCategory, ExerciseData,
    AIConversation, AIMessage, AIInteractionLog,
    ConversationType, MessageRole, ResponseSource,
)
from members.models import Member
from .search_engine import KnowledgeBaseSearchEngine
from .context_engine import AIContextEngine
from .recommendation_engine import (
    ExerciseExplanationEngine, ExerciseAlternativeEngine,
    BeginnerCoachEngine, ProgressAnalysisEngine, GoalCoachingEngine
)
from .safety_guard import SafetyGuard

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
        r'motivat', r'demotivat', r'give up', r'giving up', r'quit\b', r'tired of', r'bored\b',
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
# AI Response Engine (KB-first, with safety and disclaimers)
# ---------------------------------------------------------------------------

class AIResponseEngine:
    """
    Orchestrates intent detection, safety guarding, context loading, 
    KB search, recommendation engines, and output formatting.
    """

    def __init__(self, gym, member: Member):
        self.gym = gym
        self.member = member

    def process_message(self, message: str, conversation: AIConversation) -> dict:
        start_time = time.time()

        # 1. Run safety check
        safety_status = SafetyGuard.check_input(message)
        if not safety_status['is_safe']:
            latency_ms = int((time.time() - start_time) * 1000)
            # Log interaction
            try:
                AIInteractionLog.objects.create(
                    gym=self.gym,
                    member=self.member,
                    query=message[:500],
                    detected_intent='unsafe',
                    response_source=ResponseSource.TEMPLATE,
                    latency_ms=latency_ms,
                )
            except Exception as e:
                logger.error(f"Failed to log interaction: {e}")

            return {
                'content': safety_status['message'],
                'sources': [],
                'response_source': ResponseSource.TEMPLATE,
                'detected_intent': 'unsafe',
                'context_used': {},
            }

        # 2. Detect Intent and Build context
        intent = detect_intent(message)
        context = AIContextEngine.get_member_context(self.member)

        response_text = ''
        sources = []
        source_type = ResponseSource.KB

        # 3. Route by intent
        if intent == 'exercise_alternative':
            exercise_name = self._extract_exercise_name(message)
            constraint = self._extract_constraint(message)
            alt_result = ExerciseAlternativeEngine.suggest_alternatives(
                exercise_name, constraint=constraint, gym=self.gym
            )
            sources = [a['id'] for a in alt_result['alternatives'] if a['id']]
            
            if alt_result['alternatives']:
                response_text = f"{alt_result['reasoning']}\n\n"
                for i, alt in enumerate(alt_result['alternatives'], 1):
                    response_text += f"**{i}. {alt['title']}** ({alt['difficulty']})\n"
                    response_text += f"   {alt['summary']}\n\n"
            else:
                response_text = (
                    f"I couldn't find specific alternatives for '{exercise_name}' in our knowledge base. "
                    "Please ask your trainer or check the Exercise Library for similar movements."
                )
                source_type = ResponseSource.TEMPLATE

        elif intent == 'beginner':
            # Use BeginnerCoachEngine
            goal = context.get('active_goals', [{'goal_type': 'FAT_LOSS'}])[0]['goal_type']
            attendance_rate = context.get('attendance', {}).get('consistency_rate_30d', 100.0)
            coach_plan = BeginnerCoachEngine.generate_coach_plan(
                goal=goal,
                attendance_rate=attendance_rate
            )
            
            response_text = (
                f"Welcome to your beginner coach guide, {self.member.full_name}! 👋\n\n"
                f"**DAY 1 FOCUS: {coach_plan['day_1_plan']['title']}**\n"
                f"• Guidance: {coach_plan['day_1_plan']['guidance']}\n"
                f"• Workout: {coach_plan['day_1_plan']['workout']}\n"
                f"• Nutrition: {coach_plan['day_1_plan']['nutrition']}\n\n"
                f"**WEEK 1 SCHEDULE: {coach_plan['week_1_plan']['title']}**\n"
                f"• Guidance: {coach_plan['week_1_plan']['guidance']}\n"
            )
            for item in coach_plan['week_1_plan']['schedule']:
                response_text += f"  - {item['day']}: {item['activity']} ({item['duration']})\n"
            response_text += f"\n*Coaching Tip: {coach_plan['week_1_plan']['coaching_tip']}*\n"
            
            source_type = ResponseSource.CONTEXT

        elif intent == 'progress':
            # Use ProgressAnalysisEngine
            analysis = ProgressAnalysisEngine.analyze(context)
            response_text = (
                f"📊 **Progress Analysis Snapshot**\n\n"
                f"• **Weight Trend**: {analysis['weight_trend']}\n"
                f"• **Attendance Consistency**: {analysis['attendance_grade']}\n"
                f"• **Diet Compliance**: {analysis['diet_compliance_grade']}\n"
                f"• **Goal Progress**: {analysis['goal_status']}\n\n"
                f"💡 **Actionable Recommendations**:\n"
            )
            for rec in analysis['recommendations']:
                response_text += f"- {rec}\n"
            
            source_type = ResponseSource.CONTEXT

        elif intent == 'form':
            exercise_name = self._extract_exercise_name(message)
            explanation = ExerciseExplanationEngine.explain(exercise_name, gym=self.gym)
            if explanation['found']:
                response_text = (
                    f"🏋️ **Guide: {explanation['title']}**\n\n"
                    f"• **Purpose**: {explanation['purpose']}\n"
                    f"• **Muscles Worked**: {explanation['muscles_worked']}\n"
                    f"• **Execution**: {explanation['instructions']}\n\n"
                    f"⚠️ **Common Mistakes**: {explanation['common_mistakes']}\n"
                    f"🛡️ **Safety Notes**: {explanation['safety_tips']}\n"
                )
                if explanation['alternatives']:
                    response_text += "\n🔄 **Alternatives**: " + ", ".join([a['title'] for a in explanation['alternatives']])
            else:
                response_text = explanation['message']
                source_type = ResponseSource.TEMPLATE

        elif intent == 'nutrition':
            articles = KnowledgeBaseSearchEngine.search(message, gym=self.gym, category_slug='nutrition-diet', limit=3)
            sources = [art['id'] for art in articles]
            diet_note = ''
            diet_info = context.get('diet', {})
            if diet_info.get('has_active_diet'):
                diet_note = f"\n\nI see you're currently on the **{diet_info['plan_name']}** plan. Your daily target is {diet_info['target_calories']} kcal."
            response_text = (
                f"Great question about nutrition, {self.member.full_name}!{diet_note}\n\n"
                "Here are some key principles:\n"
                "• **Protein**: Aim for 1.6–2.2g per kg of bodyweight to support muscle preservation and growth.\n"
                "• **Calories**: Track your intake relative to your goals (deficit for fat loss, surplus for muscle gain).\n"
                "• **Hydration**: Drink 2–3 liters of water daily.\n\n"
            )
            if articles:
                response_text += "📚 From our Nutrition Knowledge Base:\n"
                for a in articles:
                    response_text += f"• **{a['title']}** — {a['summary']}\n"

        elif intent == 'workout_plan':
            articles = KnowledgeBaseSearchEngine.search(message, gym=self.gym, category_slug='workout-programs', limit=3)
            sources = [art['id'] for art in articles]
            response_text = (
                "Let me help you with a workout program!\n\n"
                "Popular training approaches in our community:\n"
                "• **PPL (Push-Pull-Legs)**: 6 days/week, great for intermediate lifters\n"
                "• **Full Body**: 3 days/week, ideal for beginners and busy schedules\n"
                "• **Upper/Lower Split**: 4 days/week, highly balanced approach\n\n"
            )
            if articles:
                response_text += "📚 Recommended programs:\n"
                for a in articles:
                    response_text += f"• **{a['title']}** — {a['summary']}\n"

        elif intent == 'motivation':
            # Use GoalCoachingEngine
            goal = context.get('active_goals', [{'goal_type': 'FAT_LOSS'}])[0]['goal_type']
            coaching = GoalCoachingEngine.generate_coaching(goal)
            response_text = (
                f"Keep up the hard work, {self.member.full_name}! 💪\n\n"
                f"**This Week's Focus**: {coaching['weekly_focus']}\n"
                f"**Recommendations**: {coaching['progress_recommendations']}\n\n"
                f"🔥 *Motivation*: {coaching['motivation_guidance']}*"
            )
            source_type = ResponseSource.CONTEXT

        else:
            # General: search KB
            articles = KnowledgeBaseSearchEngine.search(message, gym=self.gym, limit=4)
            sources = [art['id'] for art in articles]
            if articles:
                response_text = f"Hey {self.member.full_name}! Here's what I found in our Fitness Knowledge Base:\n\n"
                for a in articles:
                    response_text += f"• **{a['title']}** ({a['difficulty']}) — {a['summary']}\n"
                response_text += "\nWant more details on any of these topics? Just ask!"
            else:
                response_text = (
                    f"Hi {self.member.full_name}! I'm your AI Gym Buddy, here to help with workouts, nutrition, "
                    "exercise form, recovery, and progress tracking!\n\n"
                    "Try asking me:\n"
                    "• 'What are alternatives to bench press?'\n"
                    "• 'How much protein should I eat?'\n"
                    "• 'Show me a beginner workout plan'\n"
                    "• 'How is my progress going?'"
                )
                source_type = ResponseSource.TEMPLATE

        # 4. Clean output and append disclaimer
        response_text = SafetyGuard.clean_and_wrap_output(response_text, intent=intent)

        latency_ms = int((time.time() - start_time) * 1000)

        # 5. Log the interaction
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
            logger.error(f"Failed to log AI interaction: {e}")

        return {
            'content': response_text,
            'sources': sources,
            'response_source': source_type,
            'detected_intent': intent,
            'context_used': context,
        }

    def _extract_exercise_name(self, message: str) -> str:
        patterns = [
            r'alternative[s]? (?:to|for) (.+?)(?:\?|$|,|\band\b)',
            r'replace (.+?)(?:\?|$|,|\bwith\b)',
            r'instead of (.+?)(?:\?|$|,)',
            r'substitute (?:for )?(.+?)(?:\?|$|,)',
            r"can'?t? do (.+?)(?:\?|$|,|due to)",
            r'how to (?:do|perform) (.+?)(?:\?|$|,)',
            r'guide on (.+?)(?:\?|$|,)',
        ]
        for pattern in patterns:
            match = re.search(pattern, message, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        words = message.split()
        return ' '.join(words[:3]) if words else 'exercise'

    def _extract_constraint(self, message: str) -> Optional[str]:
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

        related_article = None
        try:
            articles = KnowledgeBaseSearchEngine.search(tip_title, gym=gym, limit=1)
            if articles:
                a = articles[0]
                related_article = {'id': a['id'], 'title': a['title']}
        except Exception:
            pass

        return {
            'tip_title': tip_title,
            'tip_content': tip_content,
            'related_article': related_article,
        }
