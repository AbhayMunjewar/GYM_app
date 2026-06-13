from django.urls import path
from .views import (
    FoodListCreateView, FoodDetailView,
    MealTemplateListCreateView, MealTemplateDetailView,
    DietPlanListCreateView, DietPlanDetailView,
    DietAssignmentListCreateView, DietAssignmentDetailView,
    DietLogListCreateView, MemberDietProgressView, DietReportsView
)

urlpatterns = [
    # Food Library
    path('foods/', FoodListCreateView.as_view(), name='food-list-create'),
    path('foods/<uuid:id>/', FoodDetailView.as_view(), name='food-detail'),

    # Meal Templates
    path('meal-templates/', MealTemplateListCreateView.as_view(), name='meal-template-list-create'),
    path('meal-templates/<uuid:id>/', MealTemplateDetailView.as_view(), name='meal-template-detail'),

    # Diet Plans
    path('diet-plans/', DietPlanListCreateView.as_view(), name='diet-plan-list-create'),
    path('diet-plans/<uuid:id>/', DietPlanDetailView.as_view(), name='diet-plan-detail'),

    # Diet Assignments
    path('diet-assignments/', DietAssignmentListCreateView.as_view(), name='diet-assignment-list-create'),
    path('diet-assignments/<uuid:id>/', DietAssignmentDetailView.as_view(), name='diet-assignment-detail'),

    # Diet Logging
    path('diet-logs/', DietLogListCreateView.as_view(), name='diet-log-list-create'),
    
    # Progress
    path('member-diets/<int:member_id>/progress/', MemberDietProgressView.as_view(), name='member-diet-progress'),

    # Reports
    path('diets/reports/', DietReportsView.as_view(), name='diet-reports'),
]
