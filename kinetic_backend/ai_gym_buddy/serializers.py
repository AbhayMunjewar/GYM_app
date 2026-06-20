from rest_framework import serializers
from .models import (
    KnowledgeCategory, KnowledgeArticle, ExerciseData,
    AIConversation, AIMessage, KnowledgeQA,
)


class KnowledgeCategorySerializer(serializers.ModelSerializer):
    article_count = serializers.SerializerMethodField()

    class Meta:
        model = KnowledgeCategory
        fields = ['id', 'name', 'slug', 'description', 'icon', 'article_count', 'order']

    def get_article_count(self, obj):
        return obj.articles.filter(is_active=True).count()


def _csv_to_list(csv_str):
    """Convert a comma-separated string to a list."""
    if not csv_str:
        return []
    return [item.strip() for item in csv_str.split(',') if item.strip()]


class KnowledgeArticleListSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    tags_list = serializers.SerializerMethodField()
    muscle_groups_list = serializers.SerializerMethodField()
    equipment_list = serializers.SerializerMethodField()

    class Meta:
        model = KnowledgeArticle
        fields = [
            'id', 'title', 'slug', 'summary', 'article_type', 'difficulty',
            'tags', 'tags_list', 'muscle_groups', 'muscle_groups_list',
            'equipment', 'equipment_list', 'category_name',
            'is_featured', 'view_count',
        ]

    def get_tags_list(self, obj):
        return _csv_to_list(obj.tags)

    def get_muscle_groups_list(self, obj):
        return _csv_to_list(obj.muscle_groups)

    def get_equipment_list(self, obj):
        return _csv_to_list(obj.equipment)


class ExerciseDataSerializer(serializers.ModelSerializer):
    alternatives = KnowledgeArticleListSerializer(many=True, read_only=True)
    primary_muscles_list = serializers.SerializerMethodField()
    secondary_muscles_list = serializers.SerializerMethodField()
    equipment_needed_list = serializers.SerializerMethodField()

    class Meta:
        model = ExerciseData
        fields = [
            'primary_muscles', 'primary_muscles_list',
            'secondary_muscles', 'secondary_muscles_list',
            'equipment_needed', 'equipment_needed_list',
            'movement_pattern', 'common_mistakes', 'cues',
            'reps_range', 'rest_seconds', 'calories_per_minute', 'alternatives',
        ]

    def get_primary_muscles_list(self, obj):
        return _csv_to_list(obj.primary_muscles)

    def get_secondary_muscles_list(self, obj):
        return _csv_to_list(obj.secondary_muscles)

    def get_equipment_needed_list(self, obj):
        return _csv_to_list(obj.equipment_needed)


class KnowledgeArticleDetailSerializer(serializers.ModelSerializer):
    category = KnowledgeCategorySerializer(read_only=True)
    exercise_data = ExerciseDataSerializer(read_only=True)
    tags_list = serializers.SerializerMethodField()
    muscle_groups_list = serializers.SerializerMethodField()
    equipment_list = serializers.SerializerMethodField()

    class Meta:
        model = KnowledgeArticle
        fields = [
            'id', 'title', 'slug', 'summary', 'content', 'article_type',
            'difficulty', 'tags', 'tags_list', 'muscle_groups', 'muscle_groups_list',
            'equipment', 'equipment_list', 'category', 'exercise_data',
            'is_featured', 'view_count', 'created_at', 'updated_at',
        ]

    def get_tags_list(self, obj):
        return _csv_to_list(obj.tags)

    def get_muscle_groups_list(self, obj):
        return _csv_to_list(obj.muscle_groups)

    def get_equipment_list(self, obj):
        return _csv_to_list(obj.equipment)


class AIMessageSerializer(serializers.ModelSerializer):
    sources_detail = serializers.SerializerMethodField()
    sources_list = serializers.SerializerMethodField()

    class Meta:
        model = AIMessage
        fields = [
            'id', 'role', 'content', 'sources', 'sources_list',
            'sources_detail', 'response_source', 'created_at',
        ]

    def get_sources_list(self, obj):
        return obj.sources_list  # uses the property on the model

    def get_sources_detail(self, obj):
        """Return minimal article info for cited sources."""
        source_ids = obj.sources_list
        if not source_ids:
            return []
        articles = KnowledgeArticle.objects.filter(
            id__in=source_ids, is_active=True
        ).values('id', 'title', 'slug', 'article_type')
        return [{'id': str(a['id']), 'title': a['title'], 'article_type': a['article_type']} for a in articles]


class AIConversationSerializer(serializers.ModelSerializer):
    last_message = serializers.SerializerMethodField()
    message_count = serializers.SerializerMethodField()

    class Meta:
        model = AIConversation
        fields = [
            'id', 'conversation_type', 'title', 'last_message',
            'message_count', 'created_at', 'updated_at',
        ]

    def get_last_message(self, obj):
        last = obj.messages.order_by('-created_at').first()
        if last:
            return {'role': last.role, 'content': last.content[:100], 'created_at': str(last.created_at)}
        return None

    def get_message_count(self, obj):
        return obj.messages.count()


class AIConversationDetailSerializer(serializers.ModelSerializer):
    messages = AIMessageSerializer(many=True, read_only=True)

    class Meta:
        model = AIConversation
        fields = ['id', 'conversation_type', 'title', 'messages', 'created_at', 'updated_at']


class AIChatRequestSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=2000)
    conversation_id = serializers.UUIDField(required=False, allow_null=True)


class ExerciseAlternativeRequestSerializer(serializers.Serializer):
    exercise_name = serializers.CharField(max_length=200)
    constraint = serializers.CharField(max_length=200, required=False, allow_blank=True)


class KnowledgeQASerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = KnowledgeCategory
        fields = [
            'id', 'category_name', 'subcategory', 'question', 'answer',
            'keywords', 'difficulty', 'safety_notes', 'related_topics',
            'is_active', 'language', 'created_at', 'updated_at'
        ]


class AISearchRequestSerializer(serializers.Serializer):
    query = serializers.CharField(max_length=500)
    category = serializers.CharField(max_length=120, required=False, allow_blank=True)
    difficulty = serializers.CharField(max_length=50, required=False, allow_blank=True)


class AIProgressAnalysisRequestSerializer(serializers.Serializer):
    member_id = serializers.IntegerField(required=False, allow_null=True)


class AIGoalCoachingRequestSerializer(serializers.Serializer):
    goal = serializers.CharField(max_length=100)
    progress_pct = serializers.FloatField(required=False, default=0.0)


class AIBeginnerCoachRequestSerializer(serializers.Serializer):
    goal = serializers.CharField(max_length=100)
    fitness_level = serializers.CharField(max_length=50, required=False, default='BEGINNER')
    attendance_rate = serializers.FloatField(required=False, default=100.0)

