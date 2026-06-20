from django.urls import path
from . import views

urlpatterns = [
    # Knowledge Base
    path('knowledge/categories/', views.KnowledgeCategoryListView.as_view(), name='ai_kb_categories'),
    path('knowledge/search/', views.KnowledgeSearchView.as_view(), name='ai_kb_search'),
    path('knowledge/articles/<uuid:article_id>/', views.KnowledgeArticleDetailView.as_view(), name='ai_kb_article_detail'),

    # AI Chat
    path('chat/', views.AIChatView.as_view(), name='ai_chat'),
    path('conversations/', views.AIConversationListView.as_view(), name='ai_conversations'),
    path('conversations/<uuid:conversation_id>/messages/', views.AIConversationDetailView.as_view(), name='ai_conversation_detail'),

    # AI Features
    path('exercise-alternatives/', views.ExerciseAlternativesView.as_view(), name='ai_exercise_alternatives'),
    path('beginner-plan/', views.BeginnerPlanView.as_view(), name='ai_beginner_plan'),
    path('progress-insights/', views.ProgressInsightsView.as_view(), name='ai_progress_insights'),
    path('dashboard-tip/', views.DashboardTipView.as_view(), name='ai_dashboard_tip'),
]
