from django.contrib import admin
from .models import (
    KnowledgeCategory, KnowledgeArticle, ExerciseData,
    AIConversation, AIMessage, AIInteractionLog,
)


@admin.register(KnowledgeCategory)
class KnowledgeCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug', 'gym', 'icon', 'order', 'is_active']
    list_filter = ['is_active', 'gym']
    search_fields = ['name', 'slug']
    ordering = ['order', 'name']


class ExerciseDataInline(admin.StackedInline):
    model = ExerciseData
    extra = 0
    filter_horizontal = ['alternatives']


@admin.register(KnowledgeArticle)
class KnowledgeArticleAdmin(admin.ModelAdmin):
    list_display = ['title', 'article_type', 'difficulty', 'category', 'is_featured', 'view_count', 'is_active', 'gym']
    list_filter = ['article_type', 'difficulty', 'is_featured', 'is_active', 'gym']
    search_fields = ['title', 'keywords', 'tags']
    readonly_fields = ['view_count', 'created_at', 'updated_at']
    inlines = [ExerciseDataInline]
    ordering = ['-is_featured', '-view_count']


@admin.register(AIConversation)
class AIConversationAdmin(admin.ModelAdmin):
    list_display = ['member', 'gym', 'conversation_type', 'title', 'created_at', 'updated_at']
    list_filter = ['conversation_type', 'gym']
    search_fields = ['member__full_name', 'title']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(AIMessage)
class AIMessageAdmin(admin.ModelAdmin):
    list_display = ['conversation', 'role', 'response_source', 'created_at']
    list_filter = ['role', 'response_source']
    readonly_fields = ['created_at']


@admin.register(AIInteractionLog)
class AIInteractionLogAdmin(admin.ModelAdmin):
    list_display = ['member', 'gym', 'detected_intent', 'response_source', 'latency_ms', 'created_at']
    list_filter = ['detected_intent', 'response_source', 'gym']
    readonly_fields = ['created_at']
