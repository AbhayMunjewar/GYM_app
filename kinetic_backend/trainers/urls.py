from django.urls import path
from .views import (
    TrainerListCreateView,
    TrainerDetailView,
    TrainerDashboardView,
    TrainerMembersView,
    OwnerTrainerAnalyticsView,
    TrainerReportsView
)

urlpatterns = [
    path('', TrainerListCreateView.as_view(), name='trainer-list-create'),
    path('dashboard/', TrainerDashboardView.as_view(), name='trainer-dashboard'),
    path('analytics/owner/', OwnerTrainerAnalyticsView.as_view(), name='owner-trainer-analytics'),
    path('reports/', TrainerReportsView.as_view(), name='trainer-reports'),
    path('<uuid:pk>/', TrainerDetailView.as_view(), name='trainer-detail'),
    path('<uuid:pk>/members/', TrainerMembersView.as_view(), name='trainer-members'),
]
