import logging
from django.db.models import Q
from .models import KnowledgeArticle, ExerciseData, KnowledgeDifficulty
from .search_engine import KnowledgeBaseSearchEngine

logger = logging.getLogger(__name__)

class ExerciseExplanationEngine:
    """
    Module 5 — Explains a given exercise: Purpose, Muscles Worked, Benefits, Common Mistakes, Alternatives, Safety Tips.
    """
    
    @staticmethod
    def explain(exercise_name: str, gym=None) -> dict:
        # Search the knowledge base for the exercise
        articles = KnowledgeBaseSearchEngine.search(exercise_name, gym=gym, limit=3)
        exercise_article = None
        for art in articles:
            if art['type'] == 'article' and art['title'].lower() == exercise_name.lower():
                # Exact match
                exercise_article = KnowledgeArticle.objects.filter(id=art['id']).first()
                break
        
        if not exercise_article:
            # Fuzzy match first article of type EXERCISE
            exercise_article = KnowledgeArticle.objects.filter(
                Q(title__icontains=exercise_name) | Q(keywords__icontains=exercise_name),
                article_type='EXERCISE',
                is_active=True
            ).first()

        if not exercise_article:
            return {
                'found': False,
                'message': f"I couldn't find a detailed guide for '{exercise_name}' in our fitness library. Feel free to ask a trainer at the gym!"
            }

        explanation = {
            'found': True,
            'title': exercise_article.title,
            'purpose': exercise_article.summary,
            'instructions': exercise_article.content,
            'muscles_worked': exercise_article.muscle_groups,
            'equipment': exercise_article.equipment,
            'difficulty': exercise_article.difficulty,
            'benefits': "Builds target muscle strength, improves bone density, coordinates core stabilizers, and translates to functional daily movement patterns.",
            'common_mistakes': "Performing the movement too fast, lifting with momentum, and rounding the back during lifts.",
            'safety_tips': "Start with a warm-up. Focus on proper form before adding heavy weights. Enlist a spotter if attempting maximum loads.",
            'alternatives': []
        }

        # Load extended exercise data if available
        try:
            ex_data = exercise_article.exercise_data
            explanation['muscles_worked'] = {
                'primary': ex_data.primary_muscles,
                'secondary': ex_data.secondary_muscles
            }
            explanation['common_mistakes'] = ex_data.common_mistakes or explanation['common_mistakes']
            explanation['safety_tips'] = ex_data.cues or explanation['safety_tips']
            
            # Alternatives
            alts = ex_data.alternatives.all()
            for alt in alts:
                explanation['alternatives'].append({
                    'id': str(alt.id),
                    'title': alt.title,
                    'summary': alt.summary
                })
        except ExerciseData.DoesNotExist:
            pass

        # Fallback alternatives search if none mapped
        if not explanation['alternatives']:
            fallback_alts = KnowledgeArticle.objects.filter(
                article_type='EXERCISE',
                category=exercise_article.category,
                is_active=True
            ).exclude(id=exercise_article.id)[:3]
            for alt in fallback_alts:
                explanation['alternatives'].append({
                    'id': str(alt.id),
                    'title': alt.title,
                    'summary': alt.summary
                })

        return explanation


class ExerciseAlternativeEngine:
    """
    Module 6 — Suggests alternative exercises (swaps) when an exercise is unavailable.
    """

    @staticmethod
    def suggest_alternatives(exercise_name: str, constraint: str = None, gym=None) -> dict:
        """
        Suggests substitute exercises (e.g. Pushups, DB Bench Press when Bench Press is unavailable).
        """
        # Hardcoded premium mapping rules for common exercises
        SWAP_RULES = {
            'barbell back squat': ['dumbbell goblet squat', 'leg press machine', 'lunges', 'bulgarian split squat'],
            'barbell bench press': ['push-ups', 'dumbbell bench press', 'chest press machine', 'incline dumbbell press'],
            'conventional deadlift': ['romanian deadlift (rdl)', 'trap bar deadlift', 'kettlebell swings', 'hyper-extensions'],
            'barbell row': ['dumbbell row', 'lat pulldown', 'seated cable row', 't-bar row'],
            'overhead press': ['dumbbell overhead press', 'dumbbell lateral raise', 'shoulder press machine', 'arnold press'],
            'pull-up': ['lat pulldown', 'chin-up', 'assisted pull-up machine', 'inverted bodyweight row'],
            'bicep curl': ['hammer curl', 'incline dumbbell curl', 'cable curl', 'preacher curl'],
            'tricep pushdown': ['overhead tricep extension', 'dips', 'close grip bench press', 'skull crushers']
        }

        exercise_key = exercise_name.lower().strip()
        matched_swaps = []

        # Check in rule map
        for key, swaps in SWAP_RULES.items():
            if key in exercise_key or exercise_key in key:
                matched_swaps = swaps
                break

        # Fallback to category / muscle group lookup if not in rules
        if not matched_swaps:
            articles = KnowledgeBaseSearchEngine.search(exercise_name, gym=gym, limit=3)
            if articles:
                best_match_id = articles[0]['id']
                art = KnowledgeArticle.objects.filter(id=best_match_id).first()
                if art:
                    qs = KnowledgeArticle.objects.filter(
                        article_type='EXERCISE',
                        category=art.category,
                        is_active=True
                    ).exclude(id=art.id)
                    matched_swaps = [a.title for a in qs[:3]]

        # Exclude swaps matching constraint (e.g. if constraint is 'dumbbell', avoid dumbbells)
        if constraint:
            c_clean = constraint.lower()
            matched_swaps = [s for s in matched_swaps if c_clean not in s.lower()]

        # Find actual DB links for these swaps if possible
        recommendations = []
        for swap_name in matched_swaps:
            art = KnowledgeArticle.objects.filter(title__iexact=swap_name, is_active=True).first()
            if art:
                recommendations.append({
                    'id': str(art.id),
                    'title': art.title,
                    'summary': art.summary,
                    'difficulty': art.difficulty
                })
            else:
                recommendations.append({
                    'id': None,
                    'title': swap_name,
                    'summary': 'Effective alternative targeting similar primary muscle groups.',
                    'difficulty': 'BEGINNER'
                })

        return {
            'original_exercise': exercise_name,
            'constraint': constraint,
            'alternatives': recommendations[:3],
            'reasoning': f"Here are chest/upper body pushing alternatives to {exercise_name} that target matching stabilizers." if "press" in exercise_key or "bench" in exercise_key else f"Here are effective swaps for {exercise_name} that suit your training goals."
        }


class BeginnerCoachEngine:
    """
    Module 7 — Personalized beginner plans (Day 1, Week 1, Month 1).
    """

    @staticmethod
    def generate_coach_plan(goal: str, fitness_level: str = 'BEGINNER', attendance_rate: float = 100.0) -> dict:
        goal_upper = (goal or 'FAT_LOSS').upper()
        
        # Day 1
        day_1 = {
            'title': "Welcome & Gym Orientation",
            'guidance': "Keep intensity low. Focus on learning the gym layout, warm-ups, and form.",
            'workout': "10 min treadmill walk, 3 sets of Bodyweight Squats (10 reps), 3 sets of Wall Push-ups (10 reps), 3 sets of Plank (20 sec).",
            'nutrition': "Drink 500ml water before and after the workout. Eat a palm-sized portion of protein with dinner."
        }

        # Week 1
        week_1 = {
            'title': "Building Consistency",
            'guidance': "Schedule 3 workouts this week with at least one rest day between sessions.",
            'schedule': [
                {'day': 'Monday', 'activity': 'Full Body Strength (Light Squats, DB Press, Rows)', 'duration': '45 mins'},
                {'day': 'Wednesday', 'activity': 'LISS Cardio (Steady Walking/Cycling)', 'duration': '30 mins'},
                {'day': 'Friday', 'activity': 'Full Body Strength (Goblet Squats, Lat Pulldowns, Planks)', 'duration': '45 mins'},
                {'day': 'Weekend', 'activity': 'Active Rest (Stretching or light walk)', 'duration': 'Any'}
            ],
            'coaching_tip': "Write down your weights and reps in the app. Consistency is your goal this week!"
        }

        # Month 1
        month_1 = {
            'title': "Establishing Habit & Progression",
            'guidance': "Gradually introduce progressive overload (e.g. slightly more weight or another rep) while maintaining perfect form.",
            'milestones': [
                "Week 1-2: Complete 3 workouts per week consistently.",
                "Week 3: Add 2.5kg or 2 reps to your main compound lifts.",
                "Week 4: Log measurements in the Progress Tracker to evaluate your baseline."
            ],
            'focus': "Fat Loss & Conditioning" if "LOSS" in goal_upper else "Muscle & Strength Foundations"
        }

        return {
            'goal': goal,
            'fitness_level': fitness_level,
            'attendance_rating': f"{attendance_rate}%",
            'day_1_plan': day_1,
            'week_1_plan': week_1,
            'month_1_plan': month_1
        }


class ProgressAnalysisEngine:
    """
    Module 8 — Performs statistical/trend analysis on weight, attendance, diet, and goals.
    """

    @staticmethod
    def analyze(context: dict) -> dict:
        results = {
            'weight_trend': "No progress records registered yet.",
            'attendance_grade': "Needs consistency.",
            'diet_compliance_grade': "Awaiting logs.",
            'goal_status': "No active goals.",
            'recommendations': []
        }

        # 1. Weight Analysis
        progress = context.get('progress', {})
        history = progress.get('history', [])
        if len(history) >= 2:
            latest_w = history[0]['weight_kg']
            earliest_w = history[-1]['weight_kg']
            diff = latest_w - earliest_w
            if diff < -0.5:
                results['weight_trend'] = f"Downward trend. You have lost {abs(diff):.1f} kg over the last {len(history)} entries. Excellent progress!"
            elif diff > 0.5:
                results['weight_trend'] = f"Upward trend. You have gained {diff:.1f} kg. If your goal is muscle gain, this indicates success."
            else:
                results['weight_trend'] = "Your weight has remained stable (+/- 0.5 kg). Good for maintenance."
        elif len(history) == 1:
            results['weight_trend'] = "One measurement logged. Log another weight entry to see trend lines."

        # 2. Attendance Analysis
        attendance = context.get('attendance', {})
        consistency = attendance.get('consistency_rate_30d', 0.0)
        streak = attendance.get('current_streak_days', 0)
        if consistency >= 75:
            results['attendance_grade'] = f"Excellent! {consistency}% consistency rate in the last 30 days. Streak: {streak} days."
            results['recommendations'].append("Keep up your attendance pattern! You are in the optimal training frequency zone.")
        elif consistency >= 40:
            results['attendance_grade'] = f"Moderate. {consistency}% consistency. Streak: {streak} days."
            results['recommendations'].append("Aim to schedule your sessions in advance. Increasing consistency to 3x/week will accelerate gains.")
        else:
            results['attendance_grade'] = f"Low. {consistency}% consistency."
            results['recommendations'].append("Try blocking out just 2 sessions per week. Start small and build momentum.")

        # 3. Diet Analysis
        diet = context.get('diet', {})
        if diet.get('has_active_diet'):
            compliance = diet.get('compliance_rate', 0.0)
            results['diet_compliance_grade'] = f"{compliance}% compliance on the '{diet['plan_name']}' plan."
            if compliance >= 80:
                results['recommendations'].append("Highly compliant diet! Keep hitting your caloric and protein targets.")
            elif compliance >= 50:
                results['recommendations'].append("Good effort, but macro variance is high. Focus on meal prep to hit targets reliably.")
            else:
                results['recommendations'].append("Compliance is low. Speak to your trainer about adjusting calorie/macro targets to fit your lifestyle.")
        else:
            results['recommendations'].append("No active diet plan assigned. Ask a trainer to assign a customized diet plan.")

        # 4. Goals Analysis
        active_goals = context.get('active_goals', [])
        if active_goals:
            g = active_goals[0]
            results['goal_status'] = f"Active {g['goal_type']} goal, currently {g['progress_percentage']}% complete. Target date: {g['target_date']}."
            if g['progress_percentage'] > 90:
                results['recommendations'].append("You are close to achieving your goal! Keep pushing, then define your next target.")
        else:
            results['recommendations'].append("Set a target weight or body fat goal in the Progress Tracker to unlock tailored milestones.")

        return results


class GoalCoachingEngine:
    """
    Module 9 — Goal coaching advice (Fat Loss, Muscle Gain, Strength, Maintenance).
    """

    @staticmethod
    def generate_coaching(goal: str, progress_pct: float = 0.0) -> dict:
        g_clean = (goal or 'FAT_LOSS').upper().strip()

        coaching = {
            'weekly_focus': "Establish foundation lifts and build daily consistency.",
            'progress_recommendations': "Log weights, reps, and sets for every training session.",
            'motivation_guidance': "Success is the sum of small actions repeated daily. Focus on today's session."
        }

        if 'FAT_LOSS' in g_clean:
            coaching['weekly_focus'] = "Maintain a moderate 300-500 kcal deficit. Prioritize protein intake to protect lean mass."
            coaching['progress_recommendations'] = "Aim for a loss of 0.25 - 0.5 kg per week. If weight is flat, increase daily walking steps (NEAT)."
            coaching['motivation_guidance'] = "Fat loss is non-linear. Plateaus happen. Trust the caloric calculations and stay consistent."
        elif 'MUSCLE_GAIN' in g_clean:
            coaching['weekly_focus'] = "Aim for a small surplus (200-350 kcal) to fuel hypertrophy. Focus on progressive overload in the 8-12 rep range."
            coaching['progress_recommendations'] = "Limit weight gain to 0.5 - 1 kg per month to minimize fat accumulation."
            coaching['motivation_guidance'] = "Building muscle takes time and patience. Keep pushing close to failure on your working sets."
        elif 'STRENGTH' in g_clean:
            coaching['weekly_focus'] = "Prioritize compound lifts (Squats, Deadlifts, Bench, OHP). Allow 2-3 mins of rest between heavy sets."
            coaching['progress_recommendations'] = "Focus on linear progression. Keep reps in the 3-6 range and perfect your setup cue."
            coaching['motivation_guidance'] = "Strength is a skill. Master the movement patterns under tension and the numbers will follow."
        elif 'MAINTENANCE' in g_clean:
            coaching['weekly_focus'] = "Find your caloric equilibrium. Balance training volume with active lifestyle choices."
            coaching['progress_recommendations'] = "Track weights monthly. Focus on cardiovascular health and mobility milestones."
            coaching['motivation_guidance'] = "Maintenance is a healthy baseline. Celebrate the ability to move comfortably and feel energized."

        return coaching
