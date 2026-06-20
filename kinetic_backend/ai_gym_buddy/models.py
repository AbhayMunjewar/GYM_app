import uuid
import json
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

    # Stored as comma-separated strings for SQLite compatibility
    # Use tags_list, muscle_groups_list, equipment_list properties for Python list access
    tags = models.TextField(blank=True, default='', help_text='Comma-separated tags')
    muscle_groups = models.TextField(blank=True, default='', help_text='Comma-separated muscle groups')
    equipment = models.TextField(blank=True, default='', help_text='Comma-separated equipment')
    keywords = models.TextField(blank=True, help_text='Space-separated keywords for search')

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

    # Helper properties to handle list ↔ CSV conversion
    @property
    def tags_list(self):
        return [t.strip() for t in self.tags.split(',') if t.strip()] if self.tags else []

    @tags_list.setter
    def tags_list(self, value):
        self.tags = ','.join(value) if value else ''

    @property
    def muscle_groups_list(self):
        return [m.strip() for m in self.muscle_groups.split(',') if m.strip()] if self.muscle_groups else []

    @muscle_groups_list.setter
    def muscle_groups_list(self, value):
        self.muscle_groups = ','.join(value) if value else ''

    @property
    def equipment_list(self):
        return [e.strip() for e in self.equipment.split(',') if e.strip()] if self.equipment else []

    @equipment_list.setter
    def equipment_list(self, value):
        self.equipment = ','.join(value) if value else ''


class ExerciseData(models.Model):
    """Extended data for EXERCISE-type KnowledgeArticles."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    article = models.OneToOneField(KnowledgeArticle, on_delete=models.CASCADE, related_name='exercise_data')
    # CSV stored for SQLite compatibility
    primary_muscles = models.TextField(blank=True, default='')
    secondary_muscles = models.TextField(blank=True, default='')
    equipment_needed = models.TextField(blank=True, default='')
    movement_pattern = models.CharField(max_length=20, choices=MovementPattern.choices, default=MovementPattern.COMPOUND)
    alternatives = models.ManyToManyField(
        KnowledgeArticle,
        blank=True,
        related_name='exercise_alternatives',
        help_text='Alternative exercises to this one'
    )
    common_mistakes = models.TextField(blank=True)
    cues = models.TextField(blank=True, help_text='Coaching cues for form')
    reps_range = models.CharField(max_length=20, blank=True, default='')
    rest_seconds = models.PositiveSmallIntegerField(default=90)
    calories_per_minute = models.FloatField(default=6.0)

    class Meta:
        db_table = 'ai_exercise_data'

    def __str__(self):
        return f"ExerciseData: {self.article.title}"

    @property
    def primary_muscles_list(self):
        return [m.strip() for m in self.primary_muscles.split(',') if m.strip()] if self.primary_muscles else []

    @property
    def secondary_muscles_list(self):
        return [m.strip() for m in self.secondary_muscles.split(',') if m.strip()] if self.secondary_muscles else []

    @property
    def equipment_needed_list(self):
        return [e.strip() for e in self.equipment_needed.split(',') if e.strip()] if self.equipment_needed else []


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
            models.Index(fields=['gym', 'member']),
            models.Index(fields=['member', 'conversation_type']),
        ]

    def __str__(self):
        return f"{self.member.full_name}: {self.title}"


class AIMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(AIConversation, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=10, choices=MessageRole.choices)
    content = models.TextField()
    # Stored as JSON text for SQLite compatibility
    context_data = models.TextField(blank=True, default='{}')
    sources = models.TextField(blank=True, default='[]')  # JSON list of article IDs
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

    @property
    def sources_list(self):
        try:
            return json.loads(self.sources) if self.sources else []
        except (json.JSONDecodeError, TypeError):
            return []

    @sources_list.setter
    def sources_list(self, value):
        self.sources = json.dumps(value) if value else '[]'


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
            models.Index(fields=['gym', 'member']),
            models.Index(fields=['detected_intent']),
        ]

    def __str__(self):
        return f"{self.member.full_name}: {self.query[:60]}"


class KnowledgeQA(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(Gym, on_delete=models.CASCADE, null=True, blank=True, related_name='kb_qas')
    category = models.ForeignKey(KnowledgeCategory, on_delete=models.CASCADE, related_name='qas')
    subcategory = models.CharField(max_length=100, blank=True, default='')
    question = models.TextField()
    answer = models.TextField()
    keywords = models.TextField(blank=True, help_text='Space-separated keywords')
    difficulty = models.CharField(max_length=20, choices=KnowledgeDifficulty.choices, default=KnowledgeDifficulty.BEGINNER)
    safety_notes = models.TextField(blank=True, default='')
    related_topics = models.TextField(blank=True, default='', help_text='Comma-separated topics')
    is_active = models.BooleanField(default=True)
    language = models.CharField(max_length=10, default='en', help_text='Language code (e.g. en, es, fr)')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'ai_knowledge_qas'
        ordering = ['question']
        indexes = [
            models.Index(fields=['gym', 'category', 'is_active']),
            models.Index(fields=['language', 'is_active']),
        ]

    def __str__(self):
        return self.question[:60]

