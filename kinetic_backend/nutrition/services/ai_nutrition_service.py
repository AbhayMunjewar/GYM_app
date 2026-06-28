import json
import logging
from django.conf import settings

logger = logging.getLogger(__name__)

def call_nutrition_ai(system_prompt: str, user_prompt: str, max_tokens: int = 1500) -> dict:
    # Check if API key is configured
    api_key = getattr(settings, 'ANTHROPIC_API_KEY', '')
    if api_key:
        try:
            import anthropic
            client = anthropic.Anthropic(api_key=api_key)
            message = client.messages.create(
                model="claude-3-5-sonnet-20241022",  # standard stable model
                max_tokens=max_tokens,
                system=system_prompt,
                messages=[{"role": "user", "content": user_prompt}]
            )
            raw = message.content[0].text.strip()
            # Clean possible markdown JSON wrappers
            clean = raw
            if clean.startswith("```json"):
                clean = clean.removeprefix("```json")
            if clean.endswith("```"):
                clean = clean.removesuffix("```")
            clean = clean.strip()
            return json.loads(clean)
        except Exception as e:
            logger.error(f"Anthropic API call failed: {e}. Running local fallback nutrition generator.")

    # FALLBACK GENERATOR ENGINE
    return _generate_local_fallback_json(user_prompt)


def call_coach(system_prompt: str, user_prompt: str, max_tokens: int = 300) -> str:
    api_key = getattr(settings, 'ANTHROPIC_API_KEY', '')
    if api_key:
        try:
            import anthropic
            client = anthropic.Anthropic(api_key=api_key)
            message = client.messages.create(
                model="claude-3-5-sonnet-20241022",
                max_tokens=max_tokens,
                system=system_prompt,
                messages=[{"role": "user", "content": user_prompt}]
            )
            return message.content[0].text.strip()
        except Exception as e:
            logger.error(f"Anthropic API call failed: {e}. Running local fallback coach response.")

    # FALLBACK COACH ENGINE
    return _generate_local_coach_response(user_prompt, system_prompt)


def _generate_local_fallback_json(user_prompt: str) -> dict:
    """Generate high-quality, syntactically correct mock JSON responses mimicking Claude."""
    user_lower = user_prompt.lower()
    
    # 1. Food Replacement Request
    if "replacement" in user_lower or "replace" in user_lower:
        # Determine food type
        original_food = "chicken breast"
        if "paneer" in user_lower:
            original_food = "paneer"
        elif "egg" in user_lower:
            original_food = "eggs"
            
        return [
            {
                "food": "Tofu (Firm)",
                "quantity_per_100g_equivalent": "120g",
                "calories": 140,
                "protein_g": 15,
                "carbs_g": 3,
                "fat_g": 8,
                "similarity_score": 9,
                "notes": "Excellent high-protein plant-based alternative with similar texture."
            },
            {
                "food": "Soya Chunks",
                "quantity_per_100g_equivalent": "30g (dry)",
                "calories": 105,
                "protein_g": 16,
                "carbs_g": 10,
                "fat_g": 0.5,
                "similarity_score": 8,
                "notes": "Extremely budget-friendly. High protein concentration."
            },
            {
                "food": "Tempeh",
                "quantity_per_100g_equivalent": "100g",
                "calories": 190,
                "protein_g": 19,
                "carbs_g": 9,
                "fat_g": 11,
                "similarity_score": 7,
                "notes": "Fermented soy product, great for gut health and high protein density."
            }
        ]

    # 2. Grocery List Request
    elif "grocery list" in user_lower or "grocery" in user_lower:
        duration = "weekly"
        if "daily" in user_lower:
            duration = "daily"
        elif "monthly" in user_lower:
            duration = "monthly"
            
        multiplier = 1 if duration == "daily" else (7 if duration == "weekly" else 30)
        
        return {
            "Proteins": [
                {"name": "Paneer / Tofu", "quantity": f"{200 * multiplier}", "unit": "g", "estimated_cost_inr": 80 * multiplier},
                {"name": "Soya Chunks", "quantity": f"{50 * multiplier}", "unit": "g", "estimated_cost_inr": 15 * multiplier},
                {"name": "Whey Protein / Greek Yogurt", "quantity": f"{multiplier}", "unit": "tub/pack", "estimated_cost_inr": 120 * multiplier}
            ],
            "Vegetables": [
                {"name": "Spinach & Greens", "quantity": f"{1 * multiplier}", "unit": "bunch", "estimated_cost_inr": 20 * multiplier},
                {"name": "Broccoli & Cauliflower", "quantity": f"{300 * multiplier}", "unit": "g", "estimated_cost_inr": 40 * multiplier},
                {"name": "Tomatoes & Onions", "quantity": f"{500 * multiplier}", "unit": "g", "estimated_cost_inr": 30 * multiplier}
            ],
            "Grains & Cereals": [
                {"name": "Brown Rice / Quinoa", "quantity": f"{250 * multiplier}", "unit": "g", "estimated_cost_inr": 35 * multiplier},
                {"name": "Oats / Whole Wheat Roti", "quantity": f"{500 * multiplier}", "unit": "g", "estimated_cost_inr": 40 * multiplier}
            ],
            "Dairy": [
                {"name": "Low Fat Curd", "quantity": f"{400 * multiplier}", "unit": "g", "estimated_cost_inr": 30 * multiplier},
                {"name": "Skimmed Milk", "quantity": f"{500 * multiplier}", "unit": "ml", "estimated_cost_inr": 28 * multiplier}
            ],
            "Fruits": [
                {"name": "Bananas", "quantity": f"{2 * multiplier}", "unit": "pcs", "estimated_cost_inr": 10 * multiplier},
                {"name": "Apples", "quantity": f"{1 * multiplier}", "unit": "pcs", "estimated_cost_inr": 20 * multiplier}
            ],
            "Condiments & Spices": [
                {"name": "Olive Oil / Ghee", "quantity": f"{100 * multiplier}", "unit": "ml", "estimated_cost_inr": 50 * multiplier},
                {"name": "Turmeric, Salt, Jeera", "quantity": "1", "unit": "pack", "estimated_cost_inr": 30}
            ],
            "total_estimated_cost_inr": 285 * multiplier
        }

    # 3. Generate Meals Request (Default fallback)
    else:
        # Check preferences
        pref = "veg"
        if "non-veg" in user_lower:
            pref = "non-veg"
        elif "vegan" in user_lower:
            pref = "vegan"
            
        is_veg = pref == "veg"
        is_vegan = pref == "vegan"
        
        # Build meals
        return {
            "breakfast": {
                "name": "High Protein Breakfast Oatmeal",
                "items": [
                    {"food": "Rolled Oats", "quantity": "60g", "calories": 230, "protein_g": 8, "carbs_g": 40, "fat_g": 4, "cost_inr": 15},
                    {"food": "Almond / Soy Milk" if is_vegan else "Skimmed Milk", "quantity": "250ml", "calories": 90, "protein_g": 8, "carbs_g": 12, "fat_g": 1, "cost_inr": 15},
                    {"food": "Chia Seeds", "quantity": "10g", "calories": 49, "protein_g": 2, "carbs_g": 4, "fat_g": 3, "cost_inr": 10},
                    {"food": "Peanut Butter", "quantity": "15g", "calories": 95, "protein_g": 4, "carbs_g": 3, "fat_g": 8, "cost_inr": 8}
                ],
                "total_calories": 464,
                "total_protein_g": 22
            },
            "snacks": {
                "name": "Mid-Day Energy Snack",
                "items": [
                    {"food": "Sprouts / Moong Salad", "quantity": "100g", "calories": 120, "protein_g": 7, "carbs_g": 20, "fat_g": 0.5, "cost_inr": 10},
                    {"food": "Roasted Chana", "quantity": "30g", "calories": 110, "protein_g": 6, "carbs_g": 18, "fat_g": 2, "cost_inr": 5}
                ],
                "total_calories": 230,
                "total_protein_g": 13
            },
            "lunch": {
                "name": "Indian Balanced Lunch Platter",
                "items": [
                    {"food": "Tofu Stir-fry" if is_vegan else ("Grilled Chicken Breast" if not is_veg else "Sautéed Paneer"), "quantity": "150g", "calories": 220, "protein_g": 25, "carbs_g": 4, "fat_g": 12, "cost_inr": 60},
                    {"food": "Brown Rice / Quinoa", "quantity": "100g (cooked)", "calories": 110, "protein_g": 3, "carbs_g": 23, "fat_g": 1, "cost_inr": 12},
                    {"food": "Yellow Dal Tadka", "quantity": "150g", "calories": 130, "protein_g": 7, "carbs_g": 20, "fat_g": 3, "cost_inr": 10},
                    {"food": "Mixed Green Salad", "quantity": "1 bowl", "calories": 30, "protein_g": 1, "carbs_g": 5, "fat_g": 0.1, "cost_inr": 8}
                ],
                "total_calories": 490,
                "total_protein_g": 36
            },
            "pre_workout": {
                "name": "Pre-Workout Energy Fuel",
                "items": [
                    {"food": "Large Banana", "quantity": "1 pc", "calories": 105, "protein_g": 1.3, "carbs_g": 27, "fat_g": 0.3, "cost_inr": 5},
                    {"food": "Black Coffee (no sugar)", "quantity": "1 cup", "calories": 2, "protein_g": 0, "carbs_g": 0.5, "fat_g": 0, "cost_inr": 5}
                ],
                "total_calories": 107,
                "total_protein_g": 1
            },
            "post_workout": {
                "name": "Post-Workout Recovery Shake",
                "items": [
                    {"food": "Soy Protein Isolate" if is_vegan else "Whey Protein", "quantity": "1 scoop (30g)", "calories": 120, "protein_g": 24, "carbs_g": 2, "fat_g": 1.5, "cost_inr": 70}
                ],
                "total_calories": 120,
                "total_protein_g": 24
            },
            "dinner": {
                "name": "Lean Protein Light Dinner",
                "items": [
                    {"food": "Tofu Bhurji" if is_vegan else ("Egg Bhurji (3 eggs)" if not is_veg else "Paneer Bhurji"), "quantity": "120g", "calories": 210, "protein_g": 18, "carbs_g": 6, "fat_g": 13, "cost_inr": 35},
                    {"food": "Whole Wheat Roti", "quantity": "2 pcs", "calories": 170, "protein_g": 6, "carbs_g": 34, "fat_g": 1, "cost_inr": 6},
                    {"food": "Steamed Broccoli & Carrot", "quantity": "100g", "calories": 45, "protein_g": 2, "carbs_g": 8, "fat_g": 0.5, "cost_inr": 15}
                ],
                "total_calories": 425,
                "total_protein_g": 26
            }
        }


def _generate_local_coach_response(user_prompt: str, system_prompt: str) -> str:
    """Generate smart local coach replies based on text match heuristics."""
    q = user_prompt.lower()
    
    # Check for medical keywords first
    medical_keys = ['disease', 'medication', 'diabetic', 'hypertension', 'thyroid', 'cholesterol', 'kidney', 'heart', 'doctor', 'pain', 'allergy']
    if any(k in q for k in medical_keys):
        return (
            "NutriCoach: I see you mentioned details regarding medical restrictions or health concerns. "
            "Please consult your doctor or a clinical nutritionist before following any AI-generated dietary recommendations. "
            "Safety always comes first!"
        )

    if "pre workout" in q or "before workout" in q:
        return (
            "NutriCoach: For optimal energy before a workout, aim for simple carbohydrates with low fat. "
            "A great Indian option is a banana with a cup of black coffee 30 minutes prior, or oats with sliced apple. "
            "This provides fast-release glycogen without burdening your digestion."
        )
    elif "post workout" in q or "after workout" in q:
        return (
            "NutriCoach: Post-workout, focus on rebuilding muscle and replenishing glycogen. "
            "Consume 20-30g of fast-absorbing protein along with carbs. "
            "A scoop of Whey protein with water, or sattu drink with roasted paneer, or egg whites with toast are excellent options."
        )
    elif "paneer" in q or "chicken" in q or "replace" in q or "swap" in q:
        return (
            "NutriCoach: You can easily swap paneer for tofu or soya chunks to lower the fat content while maintaining a high protein intake. "
            "100g of paneer has ~18g protein and ~20g fat, whereas 100g of firm tofu has ~12g protein and only ~5g fat. "
            "Give it a try in your stir-fries!"
        )
    elif "vegetarian" in q or "veg" in q:
        return (
            "NutriCoach: Being a vegetarian is great for fitness! To hit your protein targets, center your meals around "
            "low-fat paneer, curd/greek yogurt, tofu, soya chunks, lentils (dal), and chickpea/sprout salads. "
            "If needed, adding a high-quality whey or plant protein supplement makes hitting targets much easier."
        )
    elif "budget" in q or "₹" in q or "cheap" in q:
        return (
            "NutriCoach: High protein diets do not have to be expensive! Some of the most budget-friendly Indian protein sources "
            "include eggs (₹6-8 per egg, ~6g protein), soya chunks (₹15 per 50g, ~26g protein), double-toned milk, curd, and sprouts. "
            "Focusing on these will keep your daily budget well under ₹200."
        )
    elif "muscle" in q or "gain" in q or "bulk" in q:
        return (
            "NutriCoach: To build muscle, you need to be in a caloric surplus (around 200-300 kcal above TDEE) and consume sufficient protein. "
            "Aim for 1.8-2.2g of protein per kg of bodyweight. Focus on compound lifts and pair them with calorie-dense Indian foods "
            "like nuts, peanut butter, paneer, eggs, whole milk, and banana shakes."
        )
    elif "fat loss" in q or "lose weight" in q or "cut" in q:
        return (
            "NutriCoach: For fat loss, consistency in a caloric deficit is key. Aim for 300-500 calories below your TDEE. "
            "Keep your protein high (to preserve lean muscle mass) and fill up on fibrous vegetables, green salads, and clear soups. "
            "Limit high-calorie oils and sugar, and drink plenty of water."
        )
    else:
        return (
            "NutriCoach: Hello! I'm your AI Diet Coach. I specialize in budget-friendly Indian fitness nutrition. "
            "Ask me anything about macros, meals, healthy replacements, pre/post-workout nutrition, or how to tweak your diet for "
            "muscle gain or fat loss!"
        )
