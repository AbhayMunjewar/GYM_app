import uuid
from django.db import models
from django.utils import timezone
from gyms.models import Gym
from members.models import Member


# ---------------------------------------------------------------------------
# Knowledge Base Models
# ---------------------------------------------------------------------------

class KnowledgeDifficulty(models.TextChoices):
    BEGINNER = 'BEGINNER', 'Beginner'
    INTERMEDIATE = 'INTERMEDIATE', 'Intermediate'
    ADVANCED = 'ADVANCED', 'Advanced'


class KnowledgeArticleType(models.TextChoices):
    EXERCISE = 'EXERCISE', 'Exercise'
    NUTRITION = 'NUTRITION', 'Nutrition'
    WORKOUT_PLAN = 'WORKOUT_PLAN', 'Workout Plan'
    RECOVERY = 'RECOVERY', 'Recovery'
    GENERAL = 'GENERAL', 'General Fitness'
    BEGINNER_GUIDE = 'BEGINNER_GUIDE', 'Beginner Guide'


class MovementPattern(models.TextChoices):
    PUSH = 'PUSH', 'Push'
    PULL = 'PULL', 'Pull'
    HINGE = 'HINGE', 'Hinge'
    SQUAT = 'SQUAT', 'Squat'
    CARRY = 'CARRY', 'Carry'
    ROTATION = 'ROTATION', 'Rotation'
    ISOLATION = 'ISOLATION', 'Isolation'
    COMPOUND = 'COMPOUND', 'Compound'


class KnowledgeCategory(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # NULL gym = global (shared across all gyms)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, null=True, blank=True, related_name='kb_categories')
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=120)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, default='fitness_center')  # material icon name
    order = models.PositiveSmallIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ai_knowledge_categories'
        ordering = ['order', 'name']
        unique_together = ('gym', 'slug')
        indexes = [
            models.Index(fields=['gym', 'is_active']),
            models.Index(fields=['slug']),
        ]

    def __str__(self):
        return self.name


class KnowledgeArticle(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # NULL gym = global article
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, null=True, blank=True, related_name='kb_articles')
    category = models.ForeignKey(KnowledgeCategory, on_delete=models.SET_NULL, null=True, blank=True, related_name='articles')
    title = models.CharField(max_length=255)
    slug = models.SlugField(max_length=300)
    summary = models.TextField(help_text='Short 1-2 sentence summary for chat responses')
    content = models.TextField(help_text='Full article content')
    article_type = models.CharField(max_length=30, choices=KnowledgeArticleType.choices, default=KnowledgeArticleType.GENERAL)
    difficulty = models.CharField(max_length=20, choices=KnowledgeDifficulty.choices, default=KnowledgeDifficulty.BEGINNER)

    # Searchable arrays stored as JSON
    tags = models.JSONField(default=list, blank=True)          # ['squat', 'legs', 'strength']
    muscle_groups = models.JSONField(default=list, blank=True)  # ['quadriceps', 'hamstrings']
    equipment = models.JSONField(default=list, blank=True)      # ['barbell', 'rack']
    keywords = models.TextField(blank=True, help_text='Space-separated keywords for TF-IDF search')

    is_active = models.BooleanField(default=True)
    is_featured = models.BooleanField(default=False)
    view_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'ai_knowledge_articles'
        ordering = ['-is_featured', '-view_count', 'title']
        indexes = [
            models.Index(fields=['gym', 'article_type', 'is_active']),
            models.Index(fields=['difficulty', 'is_active']),
            models.Index(fields=['category', 'is_active']),
            models.Index(fields=['is_featured', 'is_active']),
        ]

    def __str__(self):
        return self.title


class ExerciseData(models.Model):
    """Extended data for EXERCISE-type KnowledgeArticles."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    article = models.OneToOneField(KnowledgeArticle, on_delete=models.CASCADE, related_name='exercise_data')
    primary_muscles = models.JSONField(default=list)     # ['quadriceps', 'glutes']
    secondary_muscles = models.JSONField(default=list)   # ['hamstrings', 'core']
    equipment_needed = models.JSONField(default=list)    # ['barbell', 'squat rack']
    movement_pattern = models.CharField(max_length=20, choices=MovementPattern.choices, default=MovementPattern.COMPOUND)
    alternatives = models.ManyToManyField(
        KnowledgeArticle,
        blank=True,
        related_name='exercise_alternatives',
        help_text='Alternative exercises to this one'
    )
    common_mistakes = models.TextField(blank=True)
    cues = models.TextField(blank=True, help_text='Coaching cues for form')
    reps_range = models.CharField(max_length=20, blank=True, default='')  # e.g. '3x8-12'
    rest_seconds = models.PositiveSmallIntegerField(default=90)
    calories_per_minute = models.FloatField(default=6.0)

    class Meta:
        db_table = 'ai_exercise_data'

    def __str__(self):
        return f"ExerciseData: {self.article.title}"


# ---------------------------------------------------------------------------
# AI Conversation Models
# ---------------------------------------------------------------------------

class ConversationType(models.TextChoices):
    GENERAL = 'GENERAL', 'General'
    WORKOUT = 'WORKOUT', 'Workout Help'
    DIET = 'DIET', 'Diet & Nutrition'
    PROGRESS = 'PROGRESS', 'Progress Analysis'
    BEGINNER = 'BEGINNER', 'Beginner Guidance'
    EXERCISE_ALT = 'EXERCISE_ALT', 'Exercise Alternatives'


class MessageRole(models.TextChoices):
    USER = 'USER', 'User'
    ASSISTANT = 'ASSISTANT', 'Assistant'


class ResponseSource(models.TextChoices):
    KB = 'KB', 'Knowledge Base'
    TEMPLATE = 'TEMPLATE', 'Template Response'
    LLM = 'LLM', 'Language Model'
    CONTEXT = 'CONTEXT', 'Context Analysis'


class AIConversation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='ai_conversations')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='ai_conversations')
    conversation_type = models.CharField(max_length=20, choices=ConversationType.choices, default=ConversationType.GENERAL)
    title = models.CharField(max_length=255, default='New Conversation')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'ai_conversations'
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['gym', 'member', '-updated_at']),
            models.Index(fields=['member', 'conversation_type']),
        ]

    def __str__(self):
        return f"{self.member.full_name}: {self.title}"


class AIMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(AIConversation, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=10, choices=MessageRole.choices)
    content = models.TextField()
    # Snapshot of member context used to generate this response
    context_data = models.JSONField(default=dict, blank=True)
    # List of KnowledgeArticle IDs that were cited in this response
    sources = models.JSONField(default=list, blank=True)
    response_source = models.CharField(
        max_length=10,
        choices=ResponseSource.choices,
        default=ResponseSource.KB,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ai_messages'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['conversation', 'created_at']),
        ]

    def __str__(self):
        return f"[{self.role}] {self.content[:60]}"


class AIInteractionLog(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, related_name='ai_interaction_logs')
    member = models.ForeignKey(Member, on_delete=models.CASCADE, related_name='ai_interaction_logs')
    query = models.TextField()
    detected_intent = models.CharField(max_length=50, blank=True)
    response_source = models.CharField(max_length=10, choices=ResponseSource.choices, default=ResponseSource.KB)
    latency_ms = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ai_interaction_logs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['gym', 'member', '-created_at']),
            models.Index(fields=['detected_intent']),
        ]

    def __str__(self):
        return f"{self.member.full_name}: {self.query[:60]}"
