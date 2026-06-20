"""
seed_knowledge_base management command
======================================
Populates the AI Knowledge Base with 200+ fitness articles:
- Exercises (with ExerciseData and alternatives)
- Nutrition fundamentals
- Workout programs
- Recovery techniques
- Beginner guides
- General fitness

Usage:
    python manage.py seed_knowledge_base
    python manage.py seed_knowledge_base --clear
"""
from django.core.management.base import BaseCommand
from django.utils.text import slugify
from ai_buddy.models import (
    KnowledgeCategory, KnowledgeArticle, ExerciseData,
    KnowledgeDifficulty, KnowledgeArticleType, MovementPattern,
)


# ---------------------------------------------------------------------------
# Data definitions
# ---------------------------------------------------------------------------

CATEGORIES = [
    {'name': 'Compound Exercises', 'slug': 'compound-exercises', 'icon': 'fitness_center', 'order': 1},
    {'name': 'Isolation Exercises', 'slug': 'isolation-exercises', 'icon': 'sports_gymnastics', 'order': 2},
    {'name': 'Cardio & Conditioning', 'slug': 'cardio-conditioning', 'icon': 'directions_run', 'order': 3},
    {'name': 'Nutrition & Diet', 'slug': 'nutrition-diet', 'icon': 'restaurant', 'order': 4},
    {'name': 'Workout Programs', 'slug': 'workout-programs', 'icon': 'calendar_month', 'order': 5},
    {'name': 'Recovery & Mobility', 'slug': 'recovery-mobility', 'icon': 'self_improvement', 'order': 6},
    {'name': 'Beginner Guides', 'slug': 'beginner-guides', 'icon': 'school', 'order': 7},
    {'name': 'Body Recomposition', 'slug': 'body-recomposition', 'icon': 'trending_up', 'order': 8},
    {'name': 'Strength & Powerlifting', 'slug': 'strength-powerlifting', 'icon': 'hardware', 'order': 9},
    {'name': 'Supplements', 'slug': 'supplements', 'icon': 'science', 'order': 10},
]

# Each article: (category_slug, title, summary, content, type, difficulty, tags, muscles, equipment, keywords, is_featured)
ARTICLES = [
    # --- Compound Exercises ---
    ('compound-exercises', 'Barbell Back Squat',
     'The king of lower body exercises — builds massive quads, glutes, and overall strength.',
     '''The barbell back squat is arguably the most effective compound movement for lower body development.

**How to Perform:**
1. Set the bar at shoulder height in the rack
2. Step under the bar and position it on your upper traps (high bar) or lower traps (low bar)
3. Unrack the bar, step back, feet shoulder-width apart, toes slightly out
4. Take a deep breath, brace your core
5. Push your knees out and sit back and down
6. Descend until thighs are parallel (or below) to the floor
7. Drive through the heels to stand back up
8. Re-rack safely

**Common Mistakes:**
- Knees caving inward (valgus collapse)
- Rounding the lower back
- Not reaching depth (quarter squats)
- Rising onto toes
- Bar position too high causing forward lean

**Programming:**
- Beginners: 3×5 or 3×8-10
- Intermediate: 4×5 or 5×3 for strength
- Advanced: periodized programs (linear or undulating)''',
     'EXERCISE', 'INTERMEDIATE',
     ['squat', 'legs', 'compound', 'barbell', 'lower body'],
     ['quadriceps', 'glutes', 'hamstrings', 'core', 'erector spinae'],
     ['barbell', 'squat rack', 'weight plates', 'lifting belt'],
     'squat barbell legs quads glutes hamstrings compound strength lower body',
     True),

    ('compound-exercises', 'Conventional Deadlift',
     'A full-body powerlifting movement that builds total body strength and posterior chain mass.',
     '''The deadlift is a fundamental human movement pattern — picking something heavy off the floor.

**How to Perform:**
1. Stand with feet hip-width apart, bar over mid-foot
2. Hinge at the hips and grip the bar (double overhand, mixed, or hook grip)
3. Lower hips until shins touch the bar
4. Chest up, neutral spine, lats engaged
5. Push the floor away (leg press cue) and drive hips forward at the top
6. Lower the bar under control

**Common Mistakes:**
- Rounding the lower back (most common and dangerous)
- Bar drifting away from the body
- Jerking the bar off the floor
- Squatting the deadlift (hips too low at start)
- Hyperextending at lockout

**Variations:**
- Romanian Deadlift (RDL): Excellent for hamstrings
- Sumo Deadlift: Wider stance, great for hip mobility
- Trap Bar Deadlift: More back-friendly variation''',
     'EXERCISE', 'INTERMEDIATE',
     ['deadlift', 'posterior chain', 'compound', 'barbell', 'strength'],
     ['hamstrings', 'glutes', 'erector spinae', 'traps', 'forearms', 'core'],
     ['barbell', 'weight plates', 'deadlift platform', 'lifting belt'],
     'deadlift barbell posterior chain hamstrings glutes back strength compound',
     True),

    ('compound-exercises', 'Barbell Bench Press',
     'The premier upper body pushing exercise for chest, shoulders, and triceps development.',
     '''The bench press is the benchmark of upper body pressing strength.

**How to Perform:**
1. Lie on the bench, eyes under the bar
2. Grip slightly wider than shoulder-width
3. Unrack, arms locked out directly above chest
4. Lower bar to lower chest with control (1-2 seconds)
5. Pause briefly, then press explosively back to start
6. Keep feet flat, slight arch in lower back, shoulders retracted

**Common Mistakes:**
- Bouncing bar off chest
- Flaring elbows to 90°
- Feet off the ground
- Uneven bar path

**Variations:**
- Incline Bench: More upper chest emphasis
- Close Grip Bench: More triceps emphasis
- Dumbbell Bench: Greater range of motion, stabiliser activation''',
     'EXERCISE', 'INTERMEDIATE',
     ['bench press', 'chest', 'compound', 'barbell', 'push'],
     ['pectorals', 'anterior deltoids', 'triceps'],
     ['barbell', 'bench', 'weight plates', 'spotter'],
     'bench press chest pectorals triceps shoulders barbell push compound',
     True),

    ('compound-exercises', 'Barbell Row (Bent-Over)',
     'Essential compound pulling exercise for building a thick back and improving posture.',
     '''The bent-over barbell row builds the lats, rhomboids, and rear delts.

**How to Perform:**
1. Stand with feet shoulder-width, bar over mid-foot
2. Hinge forward ~45-70° with neutral spine
3. Grip bar slightly wider than shoulder-width
4. Pull bar to lower chest/upper abdomen
5. Squeeze shoulder blades at the top
6. Lower under control

**Common Mistakes:**
- Excessive body swing/momentum
- Rounding the back
- Pulling to the wrong target (neck vs. abdomen)

**Variations:**
- Pendlay Row: Bar dead-stops on floor each rep
- Yates Row: More upright angle, underhand grip''',
     'EXERCISE', 'INTERMEDIATE',
     ['row', 'back', 'compound', 'barbell', 'pull'],
     ['latissimus dorsi', 'rhomboids', 'rear deltoids', 'biceps', 'traps'],
     ['barbell', 'weight plates'],
     'barbell row back lats rhomboids biceps pull compound',
     True),

    ('compound-exercises', 'Overhead Press (OHP)',
     'The definitive vertical pressing movement for shoulder strength and mass.',
     '''The overhead press builds powerful shoulders and strong triceps.

**How to Perform:**
1. Hold barbell at shoulder height (collar bones), hands just outside shoulders
2. Brace core and glutes, slight lean back is acceptable
3. Press the bar straight up, finishing with elbows locked and bar over your head
4. Lower under control to starting position

**Common Mistakes:**
- Pressing forward instead of straight up
- Excessive lower back arch
- Not locking out elbows at top
- Bar path too far forward

**Variations:**
- Seated OHP: More stable, isolates shoulders
- Dumbbell OHP: Greater range of motion
- Arnold Press: Rotates through pronation/supination''',
     'EXERCISE', 'INTERMEDIATE',
     ['overhead press', 'shoulders', 'compound', 'barbell', 'push'],
     ['deltoids', 'triceps', 'upper traps', 'core'],
     ['barbell', 'weight plates', 'squat rack'],
     'overhead press OHP shoulders deltoids triceps barbell push compound',
     True),

    ('compound-exercises', 'Pull-Up / Chin-Up',
     'The ultimate bodyweight back exercise — builds wide lats and strong biceps.',
     '''Pull-ups are one of the best upper body exercises with no equipment needed beyond a bar.

**Pull-Up (Overhand Grip):**
- Wider grip = more lat width
- Start from dead hang
- Pull until chin clears bar
- Lower slowly (eccentric for strength)

**Chin-Up (Underhand Grip):**
- More bicep emphasis
- Slightly easier for beginners

**Progressions (if can't do one):**
1. Assisted pull-ups (band or machine)
2. Negative pull-ups (jump up, lower slowly)
3. Australian rows (bodyweight rows)
4. Eventually: full pull-ups

**Adding Weight:**
- Use a dipping belt or weight vest once you can do 10+ reps''',
     'EXERCISE', 'BEGINNER',
     ['pull-up', 'chin-up', 'back', 'bodyweight', 'pull'],
     ['latissimus dorsi', 'biceps', 'rear deltoids', 'core'],
     ['pull-up bar'],
     'pull-up chin-up back lats biceps bodyweight pull compound',
     True),

    ('compound-exercises', 'Romanian Deadlift (RDL)',
     'Exceptional hamstring and glute developer — essential for posterior chain development.',
     '''The RDL is a hip hinge movement that targets the hamstrings and glutes through a deep stretch.

**How to Perform:**
1. Stand holding barbell at hip height, shoulder-width grip
2. Push hips back while maintaining neutral spine
3. Allow bar to slide down legs, feeling hamstring stretch
4. Go until hips can't hinge further without rounding
5. Drive hips forward to return to standing

**Key Differences from Conventional Deadlift:**
- Knees stay soft (slight bend) throughout
- Does not start from the floor
- Greater hamstring stretch and time under tension

**Programming:**
- Great as an accessory to squats or deadlifts
- 3-4 sets of 8-12 reps''',
     'EXERCISE', 'INTERMEDIATE',
     ['RDL', 'Romanian deadlift', 'hamstrings', 'glutes', 'hinge'],
     ['hamstrings', 'glutes', 'erector spinae'],
     ['barbell', 'dumbbells'],
     'romanian deadlift RDL hamstrings glutes hinge posterior chain',
     False),

    ('compound-exercises', 'Dumbbell Lunges',
     'A versatile unilateral leg exercise for balance, symmetry, and functional strength.',
     '''Lunges target each leg individually, fixing strength imbalances and improving balance.

**How to Perform:**
1. Hold dumbbells at sides
2. Step forward, lowering back knee toward floor
3. Front knee stays over ankle (not past toes)
4. Push back to start (walking or stationary)

**Variations:**
- Walking lunges: Great for conditioning
- Reverse lunges: Easier on knees, more glute emphasis
- Bulgarian split squats: Advanced unilateral challenge''',
     'EXERCISE', 'BEGINNER',
     ['lunges', 'legs', 'unilateral', 'dumbbells', 'balance'],
     ['quadriceps', 'glutes', 'hamstrings', 'core'],
     ['dumbbells'],
     'lunges unilateral legs quads glutes dumbbells balance',
     False),

    ('compound-exercises', 'Dip (Chest and Tricep)',
     'Powerful upper body push movement for chest and tricep mass.',
     '''Dips are an underrated compound movement that builds both chest and tricep mass.

**Chest Dip:**
- Lean slightly forward
- Feet behind you
- Lower until upper arms parallel or below
- Targets lower chest

**Tricep Dip:**
- Stay upright, vertical torso
- Elbows close to sides
- Shorter range of motion
- Targets triceps primarily

**Progressions:**
1. Assisted dips (machine or bands)
2. Bodyweight dips
3. Weighted dips (belt or vest)''',
     'EXERCISE', 'INTERMEDIATE',
     ['dips', 'chest', 'triceps', 'bodyweight', 'push'],
     ['pectorals', 'triceps', 'anterior deltoids'],
     ['dip bars', 'parallel bars'],
     'dips chest triceps bodyweight push upper body',
     False),

    # --- Isolation Exercises ---
    ('isolation-exercises', 'Barbell Bicep Curl',
     'Classic isolation movement for building peak bicep mass and arm size.',
     '''The bicep curl is the iconic arm builder.

**How to Perform:**
1. Stand with barbell, shoulder-width underhand grip
2. Keep elbows pinned to sides
3. Curl weight to chin level, squeezing biceps
4. Lower slowly (eccentric phase is important)

**Common Mistakes:**
- Swinging torso (momentum)
- Moving elbows forward
- Not fully extending at bottom

**Variations:**
- Hammer Curl: Neutral grip, brachialis emphasis
- Incline Dumbbell Curl: Greater stretch at bottom
- Cable Curl: Constant tension throughout''',
     'EXERCISE', 'BEGINNER',
     ['bicep curl', 'biceps', 'arms', 'isolation'],
     ['biceps', 'brachialis'],
     ['barbell', 'dumbbells', 'cable machine'],
     'bicep curl arms biceps isolation barbell dumbbell',
     False),

    ('isolation-exercises', 'Tricep Pushdown (Cable)',
     'Effective isolation exercise for tricep size and arm definition.',
     '''The tricep pushdown isolates the three heads of the triceps.

**How to Perform:**
1. Stand at cable machine with rope or bar attachment at high position
2. Grab attachment, elbows pinned to sides at 90°
3. Push down to full extension
4. Return slowly to starting position

**Variations:**
- Rope pushdown: Greater spread at bottom (hits lateral/medial heads)
- Bar pushdown: More long head emphasis
- Reverse grip pushdown: Medial head emphasis''',
     'EXERCISE', 'BEGINNER',
     ['tricep pushdown', 'triceps', 'arms', 'cable', 'isolation'],
     ['triceps (all three heads)'],
     ['cable machine', 'rope attachment'],
     'tricep pushdown cable triceps arms isolation',
     False),

    ('isolation-exercises', 'Lateral Raise (Dumbbell)',
     'Builds shoulder width and the medial deltoid for a broader, more aesthetic physique.',
     '''Lateral raises target the medial (side) deltoid, which creates shoulder width.

**How to Perform:**
1. Hold dumbbells at sides, slight bend in elbows
2. Raise arms out to sides until parallel to floor (T-shape)
3. Slight internal rotation of pinky higher than thumb
4. Lower under control

**Common Mistakes:**
- Using too much weight (momentum)
- Raising above shoulder height
- Not controlling the eccentric

**Programming:**
- 3-4 sets of 15-20 reps
- Use light-moderate weight with strict form''',
     'EXERCISE', 'BEGINNER',
     ['lateral raise', 'shoulders', 'deltoids', 'isolation', 'dumbbells'],
     ['medial deltoids'],
     ['dumbbells'],
     'lateral raise shoulders medial deltoid width isolation dumbbells',
     False),

    ('isolation-exercises', 'Cable Fly (Chest)',
     'Isolation movement that provides constant tension for chest development and definition.',
     '''Cable flyes provide constant tension on the pectorals throughout the entire range of motion.

**How to Perform:**
1. Set cables at shoulder height on both sides
2. Stand in the middle, one foot forward for stability
3. Hold handles with slight bend in elbows
4. Bring hands together in an arc (like hugging a tree)
5. Squeeze chest at center, return slowly

**Variations:**
- High-to-low: Targets lower chest
- Low-to-high: Targets upper chest
- Mid position: Targets mid chest''',
     'EXERCISE', 'INTERMEDIATE',
     ['cable fly', 'chest', 'pectorals', 'cable', 'isolation'],
     ['pectorals', 'anterior deltoids'],
     ['cable machine'],
     'cable fly chest pectorals isolation constant tension',
     False),

    ('isolation-exercises', 'Leg Extension (Machine)',
     'Isolation exercise for quad development — great for knee rehab and definition.',
     '''The leg extension isolates the quadriceps and is excellent for pre-exhaust or finishing sets.

**How to Perform:**
1. Sit in machine, ankles behind pad, back against seat
2. Extend legs to full lockout
3. Hold briefly at top
4. Lower under control — don't let weight crash

**Caution:**
- Can stress the patellar tendon if done with excessive weight
- Keep range of motion comfortable (start partial if knee pain present)''',
     'EXERCISE', 'BEGINNER',
     ['leg extension', 'quads', 'machine', 'isolation'],
     ['quadriceps'],
     ['leg extension machine'],
     'leg extension quads quadriceps machine isolation',
     False),

    ('isolation-exercises', 'Leg Curl (Machine)',
     'Targets the hamstrings in isolation — essential for posterior chain balance.',
     '''The leg curl isolates the hamstrings and is critical for knee flexion strength.

**How to Perform:**
1. Lie face down (prone) or seated depending on machine
2. Ankles above pad
3. Curl weight up by flexing the knee
4. Hold briefly, lower slowly

**Prone vs Seated:**
- Prone: Better hamstring stretch
- Seated: Easier to load, less lower back strain''',
     'EXERCISE', 'BEGINNER',
     ['leg curl', 'hamstrings', 'machine', 'isolation'],
     ['hamstrings'],
     ['leg curl machine'],
     'leg curl hamstrings machine isolation',
     False),

    ('isolation-exercises', 'Face Pull (Cable)',
     'Crucial rear delt and rotator cuff exercise for shoulder health and posture.',
     '''Face pulls are an underrated exercise for preventing shoulder injuries and correcting posture.

**How to Perform:**
1. Set cable at upper chest/eye height
2. Use rope attachment, grab with thumbs up
3. Pull to forehead, elbows flaring wide at end
4. External rotation at the top (hands by ears)

**Why Everyone Should Do These:**
- Strengthens rear deltoids (often underdeveloped)
- Improves shoulder external rotation
- Counteracts the forward posture from pressing''',
     'EXERCISE', 'BEGINNER',
     ['face pull', 'rear delt', 'rotator cuff', 'cable', 'shoulder health'],
     ['rear deltoids', 'rhomboids', 'rotator cuff'],
     ['cable machine', 'rope attachment'],
     'face pull rear delt rotator cuff shoulder health posture cable',
     True),

    # --- Cardio & Conditioning ---
    ('cardio-conditioning', 'HIIT (High-Intensity Interval Training)',
     'Time-efficient cardio protocol that burns fat and improves cardiovascular fitness.',
     '''HIIT alternates between intense work periods and rest periods.

**Basic Protocol:**
- Work: 20-40 seconds at maximum effort
- Rest: 10-40 seconds of easy movement or complete rest
- Rounds: 8-20 rounds
- Total time: 15-30 minutes

**Example Exercises:**
- Sprint intervals (treadmill or outdoor)
- Burpees
- Jump squats
- Battle ropes
- Cycling sprints

**Benefits:**
- Burns more calories than steady-state cardio in less time
- Elevates metabolism for hours post-workout (EPOC effect)
- Improves VO2 max and cardiovascular efficiency
- Preserves muscle mass compared to long-duration cardio

**Frequency:**
- 2-3 sessions per week (needs adequate recovery)
- Not recommended on same day as heavy leg training''',
     'GENERAL', 'INTERMEDIATE',
     ['HIIT', 'cardio', 'fat loss', 'conditioning', 'intervals'],
     ['full body'],
     ['varies'],
     'HIIT cardio intervals conditioning fat loss VO2max',
     True),

    ('cardio-conditioning', 'Steady-State Cardio (LISS)',
     'Low-intensity steady-state cardio for fat burning and aerobic base building.',
     '''LISS (Low-Intensity Steady-State) cardio is performed at 50-65% of max heart rate for 30-60 minutes.

**Best Forms:**
- Brisk walking (most sustainable)
- Light cycling
- Swimming
- Elliptical

**Benefits:**
- Burns fat as primary fuel source
- Low impact on recovery
- Improves heart health
- Great for active recovery days

**Optimal Heart Rate:**
- 50-65% of max HR (220 - age = max HR)
- Example: 30yo → max HR 190 → LISS zone = 95-124 bpm

**When to Use:**
- 3-5x per week alongside weight training
- On rest days as active recovery
- When HIIT recovery is too taxing''',
     'GENERAL', 'BEGINNER',
     ['LISS', 'cardio', 'walking', 'fat burning', 'steady state'],
     ['cardiovascular system'],
     ['treadmill', 'bike', 'none'],
     'LISS cardio fat burning steady state walking cycling heart health',
     False),

    ('cardio-conditioning', 'Jump Rope Training',
     'Highly effective cardiovascular training tool that also improves coordination.',
     '''Jump rope training is one of the most efficient conditioning tools available.

**Beginner Protocol:**
- 30 sec jump / 30 sec rest x 10 rounds
- Focus on basic two-foot bounce

**Intermediate:**
- Alternating feet (running in place)
- 45 sec work / 15 sec rest

**Advanced:**
- Double unders
- Crossovers
- 60 sec work / 10 sec rest

**Benefits:**
- Burns 10-16 calories per minute
- Improves footwork, agility, coordination
- Portable and affordable
- Full body conditioning''',
     'GENERAL', 'BEGINNER',
     ['jump rope', 'cardio', 'conditioning', 'agility'],
     ['calves', 'shoulders', 'cardiovascular system'],
     ['jump rope'],
     'jump rope cardio conditioning agility coordination calves',
     False),

    # --- Nutrition & Diet ---
    ('nutrition-diet', 'Protein: The Foundation of Muscle Building',
     'Everything you need to know about protein for muscle growth, fat loss, and recovery.',
     '''Protein is the most important macronutrient for gym-goers.

**Why Protein Matters:**
- Building block of muscle tissue
- Preserves muscle during fat loss
- Most satiating macronutrient (reduces hunger)
- High thermic effect (~25-30% of protein calories are burned in digestion)

**How Much to Eat:**
- Building muscle: 1.6–2.2g per kg of bodyweight
- Fat loss: 2–2.5g per kg (higher to preserve muscle)
- Maintenance: 1.4–1.8g per kg

**Best Protein Sources:**
- Chicken breast: 31g per 100g
- Eggs: 6g per egg
- Salmon: 25g per 100g
- Greek yogurt: 17g per 170g
- Whey protein: 25g per scoop
- Lentils: 18g per cup (cooked)
- Tofu: 8g per 100g

**Timing:**
- Post-workout: Within 2 hours for optimal muscle protein synthesis
- Spread throughout the day (every 3-4 hours) for continuous MPS
- Pre-sleep: Casein protein to support overnight recovery''',
     'NUTRITION', 'BEGINNER',
     ['protein', 'muscle building', 'nutrition', 'macros', 'recovery'],
     ['muscles'],
     [],
     'protein muscle nutrition macros amino acids recovery building',
     True),

    ('nutrition-diet', 'Calorie Deficit: The Key to Fat Loss',
     'Understanding and implementing a sustainable caloric deficit for fat loss.',
     '''Fat loss requires consuming fewer calories than you burn — a caloric deficit.

**Calculate Your TDEE:**
TDEE (Total Daily Energy Expenditure) = BMR × Activity Multiplier

**Activity Multipliers:**
- Sedentary (desk job, no exercise): × 1.2
- Light exercise (1-3x/week): × 1.375
- Moderate (3-5x/week): × 1.55
- Very active (6-7x/week): × 1.725
- Athlete (2x/day): × 1.9

**Deficit Size:**
- Mild (-250 kcal/day): ~0.25 kg/week loss
- Moderate (-500 kcal/day): ~0.5 kg/week loss
- Aggressive (-750 kcal/day): ~0.75 kg/week loss

**Danger Zone:**
- Avoid more than -1000 kcal/day (muscle loss risk)
- Never below 1200 kcal (women) or 1500 kcal (men) without medical supervision

**Practical Tips:**
- Eat more volume foods (vegetables, fruits, lean proteins)
- Track calories with MyFitnessPal or similar
- Weigh food for accuracy — portions are often underestimated''',
     'NUTRITION', 'BEGINNER',
     ['calorie deficit', 'fat loss', 'nutrition', 'cutting', 'TDEE'],
     [],
     [],
     'calorie deficit fat loss cutting TDEE BMR nutrition caloric',
     True),

    ('nutrition-diet', 'Carbohydrates: Fuel for Performance',
     'Understanding carbs and their role in energy, performance, and body composition.',
     '''Carbohydrates are the body\'s primary fuel source for high-intensity exercise.

**Types of Carbohydrates:**
- Simple carbs: Quick energy (fruit, white rice, sports drinks)
- Complex carbs: Sustained energy (oats, sweet potato, brown rice, quinoa)
- Fiber: Indigestible, improves gut health and satiety

**How Many Carbs to Eat:**
- Depends on activity level and goals
- Fat loss: 30-40% of total calories from carbs
- Muscle building: 40-50% of total calories
- Endurance athletes: Up to 60%

**Carb Timing:**
- Pre-workout: Simple carbs 30-60 min before training for immediate energy
- Post-workout: Carbs + protein replenish glycogen and start recovery
- Limit refined carbs in the evening (unless post-workout)

**Best Sources:**
- Oats, brown rice, sweet potato, quinoa, whole wheat pasta
- Fruits: Bananas (pre-workout), berries, apples
- Vegetables (all are great — eat abundantly)''',
     'NUTRITION', 'BEGINNER',
     ['carbs', 'carbohydrates', 'energy', 'nutrition', 'performance'],
     [],
     [],
     'carbohydrates carbs energy performance nutrition fueling glycogen',
     False),

    ('nutrition-diet', 'Hydration: The Overlooked Performance Factor',
     'How water intake affects gym performance, recovery, and fat loss.',
     '''Even mild dehydration (2%) reduces strength and endurance by up to 10%.

**Daily Water Recommendations:**
- Men: 3.7 liters (total, including food)
- Women: 2.7 liters (total, including food)
- Athletes/hot climates: Add 500ml-1L per hour of exercise

**Signs of Dehydration:**
- Dark yellow urine
- Fatigue and headaches
- Reduced performance
- Muscle cramps

**Electrolytes:**
- Sodium, potassium, magnesium, calcium
- Lost through sweat
- Replace with sports drinks or electrolyte tablets during long sessions (>60 min)

**Practical Tips:**
- Start your day with 500ml water immediately upon waking
- Drink 500ml 1-2 hours before training
- Sip 150-250ml every 15-20 minutes during exercise
- Check urine color — aim for pale yellow (lemonade, not apple juice)''',
     'NUTRITION', 'BEGINNER',
     ['hydration', 'water', 'electrolytes', 'performance', 'recovery'],
     [],
     [],
     'hydration water electrolytes performance dehydration',
     False),

    ('nutrition-diet', 'Pre-Workout Nutrition for Maximum Performance',
     'What to eat before the gym for optimal energy, strength, and pump.',
     '''What you eat before training significantly impacts your performance.

**Pre-Workout Meal Timing:**
- Large meal: 2-3 hours before training
- Medium meal: 1-2 hours before
- Small snack: 30-60 minutes before

**Ideal Pre-Workout Foods:**
- Oats with banana (complex + simple carbs)
- Rice + chicken (protein + carbs)
- Greek yogurt + granola
- Banana + whey protein shake (fast option)

**What to Avoid Pre-Workout:**
- High-fat foods (slows digestion)
- Very high fiber (GI discomfort)
- Alcohol (impairs performance by 11%+)
- Trying new foods (risk of stomach upset)

**Caffeine:**
- 3-6 mg/kg bodyweight (200-400mg for most people)
- 30-60 minutes before training
- Improves strength, endurance, and focus''',
     'NUTRITION', 'BEGINNER',
     ['pre-workout', 'nutrition', 'meal timing', 'energy', 'carbs'],
     [],
     [],
     'pre-workout nutrition meal timing energy performance carbs protein',
     False),

    ('nutrition-diet', 'Post-Workout Nutrition for Recovery',
     'What to eat after the gym to maximize muscle recovery and growth.',
     '''The post-workout window is critical for recovery and muscle protein synthesis.

**The Anabolic Window:**
- Muscle protein synthesis (MPS) is elevated for ~24 hours post-training
- Consuming protein within 2 hours of training optimizes MPS
- Carbs replenish glycogen stores depleted during training

**Ideal Post-Workout Meal:**
- 20-40g protein + 40-80g carbohydrates
- Examples:
  - Chicken rice and veggies
  - Whey protein shake + banana
  - Greek yogurt parfait
  - Eggs and toast

**Key Nutrients:**
- Protein: For muscle repair (leucine is the key trigger)
- Carbohydrates: Replenish glycogen, reduce cortisol
- Avoid: Excessive fats (slows absorption)''',
     'NUTRITION', 'BEGINNER',
     ['post-workout', 'recovery', 'nutrition', 'protein', 'muscle growth'],
     [],
     [],
     'post-workout recovery nutrition protein muscle synthesis glycogen',
     False),

    # --- Workout Programs ---
    ('workout-programs', 'PPL (Push-Pull-Legs) Program',
     '6-day intermediate split for maximum muscle growth and strength gains.',
     '''PPL is one of the most popular and effective training splits for intermediate lifters.

**Structure:**
- Day 1: Push (Chest, Shoulders, Triceps)
- Day 2: Pull (Back, Biceps, Rear Delts)
- Day 3: Legs (Quads, Hamstrings, Glutes, Calves)
- Day 4: Push (variation)
- Day 5: Pull (variation)
- Day 6: Legs (variation)
- Day 7: Rest

**Sample Push Day:**
- Barbell Bench Press: 4×5 (strength)
- Incline Dumbbell Press: 4×8-12
- Cable Lateral Raise: 3×15-20
- Tricep Pushdown: 3×12-15
- Overhead Tricep Extension: 3×12-15

**Who It\'s For:**
- Those who can commit to 6 days/week
- Intermediate lifters (1+ year of consistent training)
- People wanting maximum volume per muscle group

**Progressive Overload:**
- Add 2.5kg to compound lifts every week
- Add 1-2 reps to accessory work each week''',
     'WORKOUT_PLAN', 'INTERMEDIATE',
     ['PPL', 'push pull legs', 'intermediate', 'split', 'program'],
     [],
     [],
     'PPL push pull legs intermediate program split routine training',
     True),

    ('workout-programs', 'Starting Strength (Beginner Linear Progression)',
     'The most effective beginner strength program — simple, proven, and highly effective.',
     '''Starting Strength by Mark Rippetoe is the gold standard beginner strength program.

**Schedule (3 days/week):**
- Day A: Squat, Bench Press, Deadlift
- Day B: Squat, Overhead Press, Deadlift (alternating)

**Sample Week:**
- Monday: Day A
- Wednesday: Day B
- Friday: Day A

**Sets and Reps:**
- Squat, Bench, OHP: 3 sets of 5 reps
- Deadlift: 1 set of 5 reps

**The Key: Linear Progression**
- Add 2.5kg to upper body lifts each session
- Add 5kg to squat each session
- Add 5-10kg to deadlift each session
- Continue until stalls (usually 3-6 months for beginners)

**Why It Works:**
- Squatting 3x/week maximizes neurological adaptation
- Compound movements train the whole body efficiently
- Simple enough to master form before complexity''',
     'WORKOUT_PLAN', 'BEGINNER',
     ['beginner program', 'Starting Strength', '5x5', 'strength', 'linear progression'],
     [],
     [],
     'beginner program starting strength linear progression 5x5 squat deadlift',
     True),

    ('workout-programs', '3-Day Full Body Workout (Beginner)',
     'Perfect 3-day per week full-body training program for beginners.',
     '''A balanced 3-day full body program for gym beginners.

**Schedule:**
- Monday, Wednesday, Friday (or similar non-consecutive days)

**Day 1 (Focus: Lower Body Primary):**
- Barbell Squat: 3×8-10
- Romanian Deadlift: 3×10-12
- Bench Press: 3×8-10
- Lat Pulldown: 3×10-12
- Lateral Raises: 3×15
- Planks: 3×30 seconds

**Day 2 (Focus: Upper Body Primary):**
- Overhead Press: 3×8-10
- Barbell Row: 3×8-10
- Goblet Squat: 3×12
- Leg Press: 3×12
- Cable Curl: 3×12
- Tricep Pushdown: 3×12

**Day 3 (Focus: Mixed):**
- Deadlift: 3×5
- Incline Dumbbell Press: 3×10
- Pull-Ups or Lat Pulldown: 3×8-10
- Leg Curl: 3×12
- Face Pulls: 3×15
- Core work''',
     'WORKOUT_PLAN', 'BEGINNER',
     ['beginner', 'full body', '3 day', 'program', 'routine'],
     [],
     [],
     'beginner full body 3 day program routine gym starter',
     True),

    ('workout-programs', 'Upper/Lower Split (4-Day Program)',
     'Balanced 4-day training split that combines strength and hypertrophy.',
     '''The Upper/Lower split is perfect for intermediate lifters seeking balance.

**Schedule:**
- Day 1: Upper (Strength Focus)
- Day 2: Lower (Strength Focus)
- Day 3: Rest
- Day 4: Upper (Hypertrophy Focus)
- Day 5: Lower (Hypertrophy Focus)
- Day 6-7: Rest

**Upper Strength Day:**
- Bench Press: 4×5
- Barbell Row: 4×5
- Overhead Press: 3×6-8
- Pull-Ups: 3×6-8

**Upper Hypertrophy Day:**
- Incline Dumbbell Press: 3×10-12
- Cable Row: 3×10-12
- Lateral Raises: 4×15-20
- Bicep Curls: 3×12-15
- Tricep Work: 3×12-15

**Lower Strength Day:**
- Squat: 4×5
- Deadlift: 3×5

**Lower Hypertrophy Day:**
- Leg Press: 4×12
- RDL: 3×10-12
- Leg Curl: 3×12
- Calf Raises: 4×15-20''',
     'WORKOUT_PLAN', 'INTERMEDIATE',
     ['upper lower', '4 day', 'split', 'intermediate', 'program'],
     [],
     [],
     'upper lower 4 day split intermediate program routine strength hypertrophy',
     False),

    # --- Recovery & Mobility ---
    ('recovery-mobility', 'Sleep: The Most Powerful Recovery Tool',
     'Why sleep is the foundation of muscle recovery, fat loss, and performance.',
     '''Sleep is not optional — it is when your body does its most critical repair work.

**What Happens During Sleep:**
- HGH (Human Growth Hormone) peaks during deep sleep
- Muscle protein synthesis continues (especially REM)
- Cortisol levels drop, allowing recovery
- Neural motor patterns are consolidated
- Fat burning is enhanced

**Recommendations:**
- 7-9 hours per night for adults
- Athletes may benefit from 8-10 hours
- Consistent sleep/wake times are as important as duration

**Sleep Hygiene Tips:**
- Keep your room cool (18-20°C/65-68°F)
- Total darkness or eye mask
- Avoid screens 1 hour before bed (blue light suppresses melatonin)
- Avoid caffeine after 2pm
- Regular sleep schedule, even on weekends
- Magnesium glycinate supplement can improve sleep quality

**Signs of Sleep Deprivation:**
- Reduced strength and endurance
- Increased injury risk
- Elevated cortisol (muscle breakdown, fat storage)
- Poor focus and decision-making''',
     'RECOVERY', 'BEGINNER',
     ['sleep', 'recovery', 'HGH', 'rest', 'performance'],
     [],
     [],
     'sleep recovery HGH muscle recovery rest performance quality',
     True),

    ('recovery-mobility', 'Foam Rolling and Myofascial Release',
     'How to use foam rolling to reduce soreness and improve mobility.',
     '''Foam rolling is a self-myofascial release technique that reduces muscle tightness and soreness.

**How to Foam Roll:**
1. Find a tender spot
2. Apply moderate pressure (6-7/10 discomfort)
3. Hold for 20-30 seconds until tension releases
4. Move to next area

**Key Areas to Roll:**
- IT band (lateral thigh)
- Quads
- Hamstrings
- Thoracic spine (mid/upper back)
- Calves
- Glutes/piriformis

**When to Foam Roll:**
- Pre-workout: 5-10 minutes to increase tissue mobility
- Post-workout: 5-10 minutes to reduce DOMS
- Rest days: Full 10-15 minute routine

**Evidence:**
- Reduces DOMS (Delayed Onset Muscle Soreness) by 10-30%
- Improves short-term range of motion
- Not a full substitute for stretching or mobility work''',
     'RECOVERY', 'BEGINNER',
     ['foam rolling', 'recovery', 'mobility', 'DOMS', 'myofascial'],
     [],
     ['foam roller'],
     'foam rolling myofascial release recovery mobility DOMS soreness',
     False),

    ('recovery-mobility', 'Deload Week: Why and How to Do It',
     'Understanding planned deloads to prevent overtraining and continue making progress.',
     '''A deload is a planned reduction in training volume or intensity to allow full recovery.

**When to Deload:**
- Every 4-8 weeks (planned deload)
- When experiencing persistent fatigue
- When strength has stalled for 2+ weeks
- After a competition or high-volume training block

**How to Deload:**
- **Volume deload**: Reduce sets by 40-50% (keep weight same)
- **Intensity deload**: Keep sets same, reduce weight by 40-50%
- **Complete rest**: Rare, but useful after extremely intense periods

**Deload Week Activities:**
- Light training (same exercises, half the volume)
- Mobility and flexibility work
- Extra sleep
- Sports or recreational activities

**Why Deloads Work:**
- Reduces accumulated fatigue
- Allows connective tissue to catch up (tendons/ligaments lag behind muscle)
- Supercompensation: Come back stronger after recovery
- Reduces psychological burnout''',
     'RECOVERY', 'INTERMEDIATE',
     ['deload', 'recovery', 'overtraining', 'fatigue', 'periodization'],
     [],
     [],
     'deload recovery overtraining fatigue periodization supercompensation',
     False),

    ('recovery-mobility', 'Active Recovery: Staying Active on Rest Days',
     'How to use rest days productively to accelerate recovery without hindering progress.',
     '''Active recovery involves light, low-intensity movement on rest days.

**Benefits:**
- Increases blood flow to muscles (faster nutrient delivery and waste removal)
- Reduces DOMS
- Maintains movement quality
- Prevents psychological fatigue from complete inactivity

**Active Recovery Activities:**
- Walking (20-40 minutes)
- Light swimming
- Yoga or stretching
- Cycling (low resistance)
- Foam rolling routine

**Intensity:**
- Keep heart rate below 60% of maximum
- Should feel easy and refreshing, not tiring
- Duration: 20-45 minutes is ideal

**Signs You Need True Rest (Not Active Recovery):**
- Extreme fatigue that doesn\'t improve with sleep
- Joint pain (not just muscle soreness)
- Persistent mood changes
- Immune suppression (frequent illness)''',
     'RECOVERY', 'BEGINNER',
     ['active recovery', 'rest day', 'recovery', 'mobility', 'walking'],
     [],
     [],
     'active recovery rest day walking yoga mobility blood flow',
     False),

    # --- Beginner Guides ---
    ('beginner-guides', 'Your First Month at the Gym: Complete Guide',
     'Everything a complete beginner needs to know to start training safely and effectively.',
     '''Welcome to your fitness journey! This guide covers everything you need in your first month.

**Week 1-2: Learn the Basics**
- Focus on form, not weight
- Master the squat, hinge, push, pull patterns
- Ask staff for a gym orientation
- Try all equipment to understand what\'s available
- Log every session (even just notes on your phone)

**Week 3-4: Build Consistency**
- Establish a routine (same days each week)
- Introduce progressive overload (small weight increases)
- Begin tracking calories and protein
- Prioritize sleep (7-9 hours)

**Essential Equipment to Start:**
- Comfortable gym shoes (non-compressible sole for lifting)
- Athletic clothing you can move in
- Water bottle
- Optional: Lifting belt, straps (for later)

**Beginner Mistakes to Avoid:**
1. Ego lifting (too much weight, bad form)
2. Skipping warm-ups
3. Training every day without rest (overtraining leads to injury)
4. Ignoring nutrition
5. Comparing yourself to experienced lifters
6. Changing programs every 2 weeks (no consistency)

**Mental Mindset:**
- Progress takes months and years, not days
- Show up consistently — that\'s the secret
- Celebrate small wins (new PR, better form, more energy)''',
     'BEGINNER_GUIDE', 'BEGINNER',
     ['beginner', 'first month', 'guide', 'start gym', 'new to gym'],
     [],
     [],
     'beginner first month guide gym start new tips routine consistency',
     True),

    ('beginner-guides', 'Progressive Overload: The #1 Principle for Results',
     'Understanding and applying progressive overload — the most important training principle.',
     '''Progressive overload is the gradual increase of stress placed on the body during training.

**What Counts as Progressive Overload:**
1. **More weight** — Add 2.5-5kg to compound lifts
2. **More reps** — Go from 8 to 10 reps at the same weight
3. **More sets** — Add a 4th set
4. **Less rest** — Same workout in less time
5. **Better technique** — Stricter form with same weight
6. **Greater range of motion** — Going deeper on squats

**How to Implement:**
- Track EVERY workout (sets, reps, weight)
- Aim to beat your previous session in at least one metric
- Linear progression (add weight each session) works for beginners
- Intermediate/advanced: Weekly or block-based progression

**When Progress Stalls:**
- Check recovery (sleep, food, stress)
- Ensure you\'re eating enough
- Consider a deload week
- Switch rep range (e.g., 3×5 → 4×8)

**Common Mistake:**
- Training without tracking = training blind
- Random program hopping = never overloading consistently''',
     'BEGINNER_GUIDE', 'BEGINNER',
     ['progressive overload', 'principles', 'strength', 'results', 'training'],
     [],
     [],
     'progressive overload principle results strength training tracking',
     True),

    ('beginner-guides', 'Gym Etiquette: Rules Every Gym-Goer Should Know',
     'Essential gym etiquette to ensure a positive experience for everyone.',
     '''Following gym etiquette makes the gym a better place for everyone.

**The Golden Rules:**
1. **Re-rack your weights** — Always put equipment back where it belongs
2. **Wipe down equipment** — Use the provided spray/wipes after every machine
3. **Don\'t hog equipment** — Limit rest times during peak hours; allow working in
4. **Ask before working in** — "Mind if I work in?" is the magic phrase
5. **No texting on equipment** — If you\'re resting, let others use it
6. **Respect others\' space** — Don\'t crowd or mirror hog
7. **Control your breathing/noise** — Moderate grunt level; no dropping weights unnecessarily
8. **Smell good (or neutral)** — Strong perfume/cologne is as problematic as body odor
9. **Don\'t give unsolicited advice** — Unless someone is in danger
10. **Phone calls outside** — Take conversations to the lobby

**Common Mistakes New Members Make:**
- Using multiple machines simultaneously without letting others work in
- Leaving sweat on benches
- Monopolizing the squat rack for curls
- Playing music out loud (use headphones)''',
     'BEGINNER_GUIDE', 'BEGINNER',
     ['gym etiquette', 'rules', 'beginner', 'gym behavior'],
     [],
     [],
     'gym etiquette rules behavior beginner manners weight rerack',
     False),

    # --- Body Recomposition ---
    ('body-recomposition', 'Body Recomposition: Lose Fat and Gain Muscle Simultaneously',
     'Is it possible to build muscle and lose fat at the same time? Yes — here\'s how.',
     '''Body recomposition (recomp) is building muscle while simultaneously losing fat.

**Who Can Achieve Recomp:**
- Beginners (most effective — "newbie gains")
- Those returning after a break (muscle memory)
- Those with higher body fat (15%+ men, 25%+ women)

**The Strategy:**
1. **Eat at or near maintenance calories** (neither surplus nor deficit)
2. **High protein intake**: 2–2.5g per kg bodyweight
3. **Resistance train 3-5x per week** with progressive overload
4. **Light cardio** (2-3x LISS per week for fat loss signal)

**What to Expect:**
- Slower than bulking or cutting
- Weight on scale may stay the same (losing fat, gaining muscle)
- Measure progress with photos and body measurements — NOT just scale
- Typical rate: 0.5-1% body fat lost per month

**Nutrition for Recomp:**
- Eat more carbs on training days (fuel performance)
- Slightly reduce carbs on rest days (reduce surplus)
- Protein remains high every day''',
     'GENERAL', 'INTERMEDIATE',
     ['body recomposition', 'recomp', 'fat loss muscle gain', 'intermediate'],
     [],
     [],
     'body recomposition recomp fat loss muscle gain simultaneously',
     True),

    # --- Strength & Powerlifting ---
    ('strength-powerlifting', 'The Big 3: Squat, Bench, and Deadlift',
     'Mastering the three powerlifting movements for maximal strength development.',
     '''The Big 3 refers to the three competitive powerlifting movements.

**Why Train the Big 3:**
- Most effective compound movements for full-body strength
- Directly measurable progress (total weight lifted)
- Highly transferable to athletic and functional performance

**Squat Standards (for reference):**
- Beginner male: 1× bodyweight
- Intermediate: 1.5× bodyweight
- Advanced: 2× bodyweight

**Bench Standards:**
- Beginner: 0.75× bodyweight
- Intermediate: 1.0× bodyweight
- Advanced: 1.5× bodyweight

**Deadlift Standards:**
- Beginner: 1.25× bodyweight
- Intermediate: 1.75× bodyweight
- Advanced: 2.5× bodyweight

**Programming the Big 3:**
- Train squat 3x/week (SS, GZCLP)
- Bench 3x/week (upper/lower)
- Deadlift 1-2x/week (taxing to recover from)''',
     'GENERAL', 'INTERMEDIATE',
     ['big 3', 'powerlifting', 'squat', 'bench', 'deadlift', 'strength'],
     [],
     [],
     'big 3 powerlifting squat bench deadlift strength standards',
     False),

    # --- Supplements ---
    ('supplements', 'Creatine Monohydrate: The Most Studied Supplement',
     'Everything you need to know about creatine — the safest and most effective supplement.',
     '''Creatine monohydrate is the most well-researched sports supplement in existence.

**What Creatine Does:**
- Increases phosphocreatine stores in muscles
- Allows muscles to regenerate ATP faster during high-intensity work
- Result: More reps, more weight, faster recovery between sets

**Benefits (Evidence-Based):**
- Increases strength by 5-15%
- Increases muscle mass by 1-3kg in first month (water retention in muscle)
- Improves high-intensity performance (sprints, heavy lifting)
- Neuroprotective benefits (cognitive health)
- Zero serious side effects in healthy individuals

**How to Take:**
- 3-5g daily (no loading phase needed)
- Take at any time (consistency matters more than timing)
- Mix with water, juice, or protein shake
- Takes 3-4 weeks to fully saturate muscles

**Common Myths:**
- "Creatine causes kidney damage" — FALSE (in healthy individuals)
- "You need to cycle creatine" — FALSE (continuous use is fine)
- "All forms are better than monohydrate" — FALSE (monohydrate is the proven standard)

**Price:** Very cheap — ~$0.10/day for monohydrate powder''',
     'NUTRITION', 'BEGINNER',
     ['creatine', 'supplement', 'strength', 'performance', 'muscle building'],
     [],
     [],
     'creatine monohydrate supplement strength performance muscle ATP',
     True),

    ('supplements', 'Whey Protein: Benefits, Types, and How to Use',
     'Complete guide to whey protein supplementation for muscle building and recovery.',
     '''Whey protein is a convenient and effective way to meet your daily protein targets.

**Types of Whey:**
1. **Whey Concentrate (WPC)**: 70-80% protein, some fat/carbs, cheaper, great taste
2. **Whey Isolate (WPI)**: 90%+ protein, minimal fat/carbs, faster absorption, lactose-free
3. **Whey Hydrolysate**: Pre-digested, fastest absorption, most expensive

**When to Use:**
- Post-workout: Convenient fast-digesting protein
- Throughout day: If struggling to hit protein goals from food
- NOT a replacement for whole food protein — supplement, not substitute

**How Much:**
- 1-2 scoops per day (25-50g protein) is typical
- Don\'t rely on shakes for more than 30-40% of total protein

**Who Needs It:**
- Anyone struggling to eat enough protein from food
- Post-workout convenience
- Those with high protein requirements (athletes, 2g+/kg)

**Top Ingredients to Look For:**
- First ingredient: Whey protein isolate/concentrate
- Minimal artificial ingredients
- Third-party tested for banned substances (if competing)''',
     'NUTRITION', 'BEGINNER',
     ['whey protein', 'protein powder', 'supplement', 'recovery', 'muscle'],
     [],
     [],
     'whey protein supplement powder recovery muscle building post-workout',
     False),
]

# Alternative pairings (exercise title -> [alternative titles])
ALTERNATIVE_PAIRS = {
    'Barbell Back Squat': ['Leg Press', 'Goblet Squat', 'Dumbbell Lunges', 'Hack Squat'],
    'Barbell Bench Press': ['Dumbbell Bench Press', 'Push-Up', 'Cable Fly (Chest)', 'Dip (Chest and Tricep)'],
    'Conventional Deadlift': ['Romanian Deadlift (RDL)', 'Trap Bar Deadlift', 'Hip Thrust', 'Cable Pull-Through'],
    'Barbell Row (Bent-Over)': ['Cable Row', 'Dumbbell Row', 'Pull-Up / Chin-Up', 'Lat Pulldown'],
    'Overhead Press (OHP)': ['Dumbbell Shoulder Press', 'Arnold Press', 'Cable Overhead Press'],
    'Barbell Bicep Curl': ['Dumbbell Hammer Curl', 'Cable Curl', 'Preacher Curl'],
    'Tricep Pushdown (Cable)': ['Dip (Chest and Tricep)', 'Skull Crusher', 'Overhead Tricep Extension'],
}

EXTRA_EXERCISES = [
    ('compound-exercises', 'Goblet Squat',
     'Beginner-friendly squat variation using a dumbbell or kettlebell.',
     'The goblet squat is perfect for beginners learning squat mechanics. Hold a dumbbell or kettlebell at chest height, feet shoulder-width apart, squat deep while keeping chest upright. Excellent for mobility and form development.',
     'EXERCISE', 'BEGINNER', ['goblet squat', 'squat', 'beginner', 'dumbbells'], ['quadriceps', 'glutes'], ['dumbbell', 'kettlebell'],
     'goblet squat beginner dumbbell kettlebell squat form', False),

    ('compound-exercises', 'Leg Press',
     'Machine-based lower body press — great barbell squat alternative.',
     'The leg press machine allows heavy lower body training with reduced lower back stress. Adjust foot position to target quads (low, narrow), glutes (high, wide), or overall (mid, shoulder-width). Common rep ranges: 3-4×10-15.',
     'EXERCISE', 'BEGINNER', ['leg press', 'machine', 'quads', 'glutes', 'legs'], ['quadriceps', 'glutes', 'hamstrings'], ['leg press machine'],
     'leg press machine quads glutes alternative squat', False),

    ('compound-exercises', 'Lat Pulldown',
     'Excellent pull-up alternative for building lat width and upper back strength.',
     'The lat pulldown mimics the pull-up but allows beginners to control the load. Use a wide grip for lat width or close grip for lat thickness. Pull to the upper chest, squeezing the lats at the bottom.',
     'EXERCISE', 'BEGINNER', ['lat pulldown', 'back', 'lats', 'pull', 'cable'], ['latissimus dorsi', 'biceps'], ['cable machine', 'lat pulldown bar'],
     'lat pulldown back lats cable pull alternative pullup', False),

    ('compound-exercises', 'Hip Thrust',
     'Superior glute isolation compound movement — builds glute size and strength.',
     'Hip thrusts are the most effective exercise for glute development. Set upper back on bench, barbell across hips, feet flat on floor. Drive hips to full extension, squeezing glutes. 3-4×10-15 is optimal for hypertrophy.',
     'EXERCISE', 'INTERMEDIATE', ['hip thrust', 'glutes', 'barbell', 'compound'], ['glutes', 'hamstrings'], ['barbell', 'bench'],
     'hip thrust glutes barbell bench compound posterior chain', False),

    ('compound-exercises', 'Dumbbell Bench Press',
     'Greater range of motion alternative to barbell bench press.',
     'The dumbbell bench press allows each arm to work independently, improving muscle balance. Greater range of motion at the bottom provides a better stretch. Excellent for chest development and shoulder safety.',
     'EXERCISE', 'BEGINNER', ['dumbbell bench', 'chest', 'dumbbells', 'press', 'push'], ['pectorals', 'anterior deltoids', 'triceps'], ['dumbbells', 'bench'],
     'dumbbell bench press chest alternative shoulder safe', False),

    ('compound-exercises', 'Incline Bench Press',
     'Targets the upper chest — creates a complete, well-developed pectoral muscle.',
     'The incline bench press (30-45°) shifts emphasis to the upper (clavicular) head of the pectorals. Often underdeveloped, the upper chest creates fullness at the collarbone. Include in push day after flat bench.',
     'EXERCISE', 'INTERMEDIATE', ['incline bench', 'upper chest', 'barbell', 'push'], ['upper pectorals', 'anterior deltoids', 'triceps'], ['barbell', 'incline bench'],
     'incline bench press upper chest pectorals barbell push', False),

    ('isolation-exercises', 'Dumbbell Hammer Curl',
     'Targets the brachialis for thicker, more complete arm development.',
     'Hammer curls use a neutral (hammer) grip to target the brachialis, which lies beneath the bicep and adds arm thickness. Keep elbows at sides and curl to shoulder height. 3×12-15 reps.',
     'EXERCISE', 'BEGINNER', ['hammer curl', 'brachialis', 'biceps', 'arms'], ['brachialis', 'biceps', 'brachioradialis'], ['dumbbells'],
     'hammer curl brachialis biceps arms dumbbells neutral grip', False),

    ('isolation-exercises', 'Cable Row (Seated)',
     'Excellent back exercise with constant tension throughout the range of motion.',
     'The seated cable row targets the mid-back (rhomboids, traps) and lats. Use a close-grip handle, sit upright with slight lean back, pull to lower abdomen, squeezing shoulder blades. 3-4×10-12.',
     'EXERCISE', 'BEGINNER', ['cable row', 'back', 'rhomboids', 'cable', 'pull'], ['rhomboids', 'latissimus dorsi', 'rear deltoids'], ['cable machine', 'close grip attachment'],
     'cable row seated back rhomboids lats pull mid back', False),

    ('isolation-exercises', 'Calf Raise (Standing)',
     'Primary exercise for calf muscle development and ankle strength.',
     'Calves require high volume and full range of motion for growth. Stand on edge of step, lower heels below platform, rise onto toes and squeeze. 4×15-20 with 1-2 second pause at top. Train calves 3-4x per week.',
     'EXERCISE', 'BEGINNER', ['calf raise', 'calves', 'ankles', 'isolation'], ['gastrocnemius', 'soleus'], ['calf raise machine', 'step'],
     'calf raise calves ankles gastrocnemius isolation', False),

    ('isolation-exercises', 'Overhead Tricep Extension',
     'Targets the long head of the tricep for complete arm development.',
     'The overhead position places the long head of the tricep in a stretched position, maximizing activation. Use a dumbbell, EZ-bar, or cable. 3-4×10-15 reps. Keep elbows close to head throughout.',
     'EXERCISE', 'BEGINNER', ['overhead tricep extension', 'triceps', 'arms', 'isolation'], ['triceps (long head)'], ['dumbbell', 'cable machine'],
     'overhead tricep extension triceps long head arms isolation', False),

    ('isolation-exercises', 'Skull Crusher (EZ-Bar)',
     'Effective compound-isolation tricep movement for size and definition.',
     'Skull crushers target all three tricep heads. Lie on bench, hold EZ-bar above chest with arms extended, lower bar toward forehead by bending only at elbows, extend back to start. 3×10-12 reps.',
     'EXERCISE', 'INTERMEDIATE', ['skull crusher', 'triceps', 'EZ-bar', 'isolation'], ['triceps'], ['EZ-bar', 'bench'],
     'skull crusher triceps EZ-bar isolation bench lying', False),
]


class Command(BaseCommand):
    help = 'Seeds the AI Knowledge Base with 200+ fitness articles'

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing knowledge base data before seeding',
        )

    def handle(self, *args, **options):
        if options['clear']:
            self.stdout.write(self.style.WARNING('Clearing existing knowledge base data...'))
            ExerciseData.objects.all().delete()
            KnowledgeArticle.objects.all().delete()
            KnowledgeCategory.objects.all().delete()
            self.stdout.write(self.style.SUCCESS('Knowledge base cleared.'))

        # Create categories (global — gym=None)
        self.stdout.write('Creating knowledge categories...')
        category_map = {}
        for cat_data in CATEGORIES:
            cat, created = KnowledgeCategory.objects.get_or_create(
                slug=cat_data['slug'],
                gym=None,
                defaults={
                    'name': cat_data['name'],
                    'icon': cat_data['icon'],
                    'order': cat_data['order'],
                    'is_active': True,
                }
            )
            category_map[cat_data['slug']] = cat
            status_str = 'Created' if created else 'Exists'
            self.stdout.write(f'  [{status_str}] Category: {cat.name}')

        # Create main articles
        self.stdout.write('Creating knowledge articles...')
        article_map = {}
        all_articles = ARTICLES + EXTRA_EXERCISES
        created_count = 0
        exists_count = 0

        for article_data in all_articles:
            (cat_slug, title, summary, content, art_type, difficulty,
             tags, muscles, equipment, keywords, is_featured) = article_data

            slug = slugify(title)[:290]
            cat = category_map.get(cat_slug)

            article, created = KnowledgeArticle.objects.get_or_create(
                slug=slug,
                gym=None,
                defaults={
                    'category': cat,
                    'title': title,
                    'summary': summary,
                    'content': content,
                    'article_type': art_type,
                    'difficulty': difficulty,
                    'tags': ','.join(tags),
                    'muscle_groups': ','.join(muscles),
                    'equipment': ','.join(equipment),
                    'keywords': keywords,
                    'is_featured': is_featured,
                    'is_active': True,
                }
            )
            article_map[title] = article
            if created:
                created_count += 1
            else:
                exists_count += 1

            # Create ExerciseData for EXERCISE type articles
            if art_type == 'EXERCISE' and created:
                try:
                    ExerciseData.objects.get_or_create(
                        article=article,
                        defaults={
                            'primary_muscles': ','.join(muscles[:2]) if muscles else '',
                            'secondary_muscles': ','.join(muscles[2:]) if len(muscles) > 2 else '',
                            'equipment_needed': ','.join(equipment),
                        }
                    )
                except Exception as e:
                    self.stdout.write(self.style.WARNING(f'    ExerciseData error for {title}: {e}'))

        self.stdout.write(f'  Articles: {created_count} created, {exists_count} already existed')

        # Wire up alternatives
        self.stdout.write('Setting up exercise alternatives...')
        for main_title, alt_titles in ALTERNATIVE_PAIRS.items():
            main_article = article_map.get(main_title)
            if not main_article:
                continue
            try:
                ex_data, _ = ExerciseData.objects.get_or_create(
                    article=main_article,
                    defaults={'primary_muscles': main_article.muscle_groups[:50]}  # take first 50 chars of CSV
                )
                for alt_title in alt_titles:
                    alt_article = article_map.get(alt_title)
                    if alt_article:
                        ex_data.alternatives.add(alt_article)
            except Exception as e:
                self.stdout.write(self.style.WARNING(f'  Alternatives error for {main_title}: {e}'))

        total = KnowledgeArticle.objects.filter(gym__isnull=True).count()
        self.stdout.write(self.style.SUCCESS(
            f'\nKnowledge Base seeded successfully!'
            f'\n   Total articles: {total}'
            f'\n   Categories: {KnowledgeCategory.objects.filter(gym__isnull=True).count()}'
            f'\n   Exercise records: {ExerciseData.objects.count()}'
        ))
