from django.urls import path
from .views import (
    ProgressMeasurementListCreateView, ProgressMeasurementDetailView,
    ProgressPhotoListCreateView, ProgressPhotoDetailView,
    FitnessGoalListCreateView, FitnessGoalDetailView,
    ProgressAnalyticsView, ProgressComparisonView
)

urlpatterns = [
    # Progress Measurements
    path('measurements/', ProgressMeasurementListCreateView.as_view(), name='progress-measurement-list-create'),
    path('measurements/<uuid:id>/', ProgressMeasurementDetailView.as_view(), name='progress-measurement-detail'),

    # Progress Photos
    path('photos/', ProgressPhotoListCreateView.as_view(), name='progress-photo-list-create'),
    path('photos/<uuid:id>/', ProgressPhotoDetailView.as_view(), name='progress-photo-detail'),

    # Fitness Goals
    path('goals/', FitnessGoalListCreateView.as_view(), name='fitness-goal-list-create'),
    path('goals/<uuid:id>/', FitnessGoalDetailView.as_view(), name='fitness-goal-detail'),

    # Analytics & Comparison
    path('analytics/', ProgressAnalyticsView.as_view(), name='progress-analytics'),
    path('compare/', ProgressComparisonView.as_view(), name='progress-compare'),
]
