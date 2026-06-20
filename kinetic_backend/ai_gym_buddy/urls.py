from django.urls import path
from . import views

urlpatterns = [
    # Knowledge Base search/categories
    path('knowledge/categories/', views.KnowledgeCategoryListView.as_view(), name='ai_kb_categories'),
    path('knowledge/search/', views.KnowledgeSearchView.as_view(), name='ai_kb_search'),
    path('knowledge/articles/<uuid:article_id>/', views.KnowledgeArticleDetailView.as_view(), name='ai_kb_article_detail'),

    # General Search API
    path('search/', views.KnowledgeSearchView.as_view(), name='ai_search_post'),

    # AI Chat
    path('chat/', views.AIChatView.as_view(), name='ai_chat'),
    path('conversations/', views.AIConversationListView.as_view(), name='ai_conversations'),
    path('conversations/<uuid:conversation_id>/', views.AIConversationDetailView.as_view(), name='ai_conversation_detail_direct'),
    path('conversations/<uuid:conversation_id>/messages/', views.AIConversationDetailView.as_view(), name='ai_conversation_detail_messages'),

    # Special Feature Actions
    path('exercise-alternatives/', views.ExerciseAlternativesView.as_view(), name='ai_exercise_alternatives'),
    path('beginner-plan/', views.BeginnerPlanView.as_view(), name='ai_beginner_plan'),
    path('beginner-coach/', views.BeginnerPlanView.as_view(), name='ai_beginner_coach'),
    path('progress-insights/', views.AIProgressAnalysisView.as_view(), name='ai_progress_insights'),
    path('progress-analysis/', views.AIProgressAnalysisView.as_view(), name='ai_progress_analysis'),
    path('goal-coaching/', views.AIGoalCoachingView.as_view(), name='ai_goal_coaching'),
    path('dashboard-tip/', views.DashboardTipView.as_view(), name='ai_dashboard_tip'),

    # Analytics for Owners
    path('analytics/', views.AIAnalyticsView.as_view(), name='ai_analytics'),
]
