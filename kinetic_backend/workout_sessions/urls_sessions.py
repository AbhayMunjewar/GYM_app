from django.urls import path
from .views import (
    WorkoutSessionListCreateView, GymSessionsView,
    TrainerSessionsView, WorkoutSessionDetailView
)

urlpatterns = [
    path('', WorkoutSessionListCreateView.as_view(), name='session-list-create'),
    path('gym/<uuid:gym_id>/', GymSessionsView.as_view(), name='gym-sessions'),
    path('trainer/<uuid:trainer_id>/', TrainerSessionsView.as_view(), name='trainer-sessions'),
    path('<uuid:session_id>/', WorkoutSessionDetailView.as_view(), name='session-detail'),
]
