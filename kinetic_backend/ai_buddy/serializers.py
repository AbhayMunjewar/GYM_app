from rest_framework import serializers
from .models import (
    KnowledgeCategory, KnowledgeArticle, ExerciseData,
    AIConversation, AIMessage,
)


class KnowledgeCategorySerializer(serializers.ModelSerializer):
    article_count = serializers.SerializerMethodField()

    class Meta:
        model = KnowledgeCategory
        fields = ['id', 'name', 'slug', 'description', 'icon', 'article_count', 'order']

    def get_article_count(self, obj):
        return obj.articles.filter(is_active=True).count()


class KnowledgeArticleListSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = KnowledgeArticle
        fields = [
            'id', 'title', 'slug', 'summary', 'article_type', 'difficulty',
            'tags', 'muscle_groups', 'equipment', 'category_name',
            'is_featured', 'view_count',
        ]


class ExerciseDataSerializer(serializers.ModelSerializer):
    alternatives = KnowledgeArticleListSerializer(many=True, read_only=True)

    class Meta:
        model = ExerciseData
        fields = [
            'primary_muscles', 'secondary_muscles', 'equipment_needed',
            'movement_pattern', 'common_mistakes', 'cues',
            'reps_range', 'rest_seconds', 'calories_per_minute', 'alternatives',
        ]


class KnowledgeArticleDetailSerializer(serializers.ModelSerializer):
    category = KnowledgeCategorySerializer(read_only=True)
    exercise_data = ExerciseDataSerializer(read_only=True)

    class Meta:
        model = KnowledgeArticle
        fields = [
            'id', 'title', 'slug', 'summary', 'content', 'article_type',
            'difficulty', 'tags', 'muscle_groups', 'equipment',
            'category', 'exercise_data', 'is_featured', 'view_count',
            'created_at', 'updated_at',
        ]


class AIMessageSerializer(serializers.ModelSerializer):
    sources_detail = serializers.SerializerMethodField()

    class Meta:
        model = AIMessage
        fields = [
            'id', 'role', 'content', 'sources', 'sources_detail',
            'response_source', 'created_at',
        ]

    def get_sources_detail(self, obj):
        """Return minimal article info for cited sources."""
        if not obj.sources:
            return []
        articles = KnowledgeArticle.objects.filter(
            id__in=obj.sources, is_active=True
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
