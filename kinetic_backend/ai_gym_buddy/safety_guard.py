import re
import logging

logger = logging.getLogger(__name__)

DANGEROUS_KEYWORDS = [
    r'\bstarve\b', r'\bstarvation\b', r'\bdehydrate\b', r'\bdiuretic\b',
    r'\banabolic\b', r'\bsteroid\b', r'\bsarms\b', r'\bclenbuterol\b',
    r'\bsuicide\b', r'\bkill myself\b', r'\bhurt myself\b', r'\bself-harm\b',
    r'\bextreme weight loss\b', r'\bcrash diet\b'
]

PAIN_KEYWORDS = [
    r'\bchest pain\b', r'\bdizzy\b', r'\bdizziness\b', r'\bsharp pain\b',
    r'\bheart palpitations\b', r'\bshortness of breath\b', r'\bpassing out\b'
]

class SafetyGuard:
    """
    Safety validator for input prompts and output responses.
    Ensures safe fitness advice, triggers disclaimers, and screens dangerous behavior.
    """

    @classmethod
    def check_input(cls, query: str) -> dict:
        """
        Validates user queries.
        Returns:
        {
          'is_safe': bool,
          'needs_trainer_redirect': bool,
          'medical_flag': bool,
          'message': str or None
        }
        """
        query_lower = query.lower()

        # 1. Check for medical emergency triggers (chest pain, dizziness)
        for pattern in PAIN_KEYWORDS:
            if re.search(pattern, query_lower):
                return {
                    'is_safe': False,
                    'needs_trainer_redirect': True,
                    'medical_flag': True,
                    'message': (
                        "Warning: You mentioned symptoms that could indicate a medical emergency (e.g. chest pain, dizziness). "
                        "Please stop exercising immediately and consult a healthcare professional or contact emergency services."
                    )
                }

        # 2. Check for dangerous fitness behaviors or self-harm keywords
        for pattern in DANGEROUS_KEYWORDS:
            if re.search(pattern, query_lower):
                return {
                    'is_safe': False,
                    'needs_trainer_redirect': True,
                    'medical_flag': False,
                    'message': (
                        "I cannot assist with queries regarding extreme crash diets, illegal supplements (like steroids/SARMs), or self-harm. "
                        "Please speak with a certified trainer or medical professional at the gym for safe, sustainable health practices."
                    )
                }

        return {
            'is_safe': True,
            'needs_trainer_redirect': False,
            'medical_flag': False,
            'message': None
        }

    @classmethod
    def clean_and_wrap_output(cls, response_content: str, intent: str = None) -> str:
        """
        Post-processes the output to append standard safety disclaimers, especially
        for injury recovery or intensity-based topics.
        """
        disclaimer = (
            "\n\n*Disclaimer: I am your AI Gym Buddy, not a certified doctor or physical therapist. "
            "Always consult with gym trainers before starting new routines or if you feel pain.*"
        )

        # Check if the content already has a disclaimer to prevent duplicates
        if "Disclaimer" in response_content:
            return response_content

        # Append standard disclaimer
        return response_content + disclaimer
