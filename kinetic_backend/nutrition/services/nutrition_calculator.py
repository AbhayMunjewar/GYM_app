ACTIVITY_MULTIPLIERS = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'athlete': 1.9,
}

MIN_CALORIES = 1200
MAX_PROTEIN_PER_KG = 3.0

def calculate_nutrition(data: dict) -> dict:
    weight = data['weight_kg']
    height = data['height_cm']
    age = data['age']
    gender = data['gender'].lower()
    activity = data['activity_level'].lower()
    goal = data['goal'].lower()
    workout_days = data['workout_days_per_week']

    # BMR — Mifflin-St Jeor
    if gender == 'male':
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
    else:
        bmr = 10 * weight + 6.25 * height - 5 * age - 161

    multiplier = ACTIVITY_MULTIPLIERS.get(activity, 1.55)
    tdee = bmr * multiplier

    # Calorie target by goal
    if goal == 'fat_loss':
        target_calories = tdee - 500
    elif goal == 'muscle_gain':
        target_calories = tdee + 300
    else:
        target_calories = tdee

    # Safety floor
    target_calories = max(target_calories, MIN_CALORIES)

    # Macros
    protein_g = min(weight * 2.2, weight * MAX_PROTEIN_PER_KG)
    fat_g = (target_calories * 0.25) / 9
    carb_calories = target_calories - (protein_g * 4) - (fat_g * 9)
    carbs_g = carb_calories / 4

    # Water
    water_liters = round(weight * 0.033 + (0.5 * workout_days / 7), 2)

    return {
        'bmr': round(bmr, 1),
        'tdee': round(tdee, 1),
        'target_calories': int(target_calories),
        'protein_g': int(protein_g),
        'carbs_g': int(max(carbs_g, 0)),
        'fat_g': int(fat_g),
        'water_liters': water_liters,
    }
