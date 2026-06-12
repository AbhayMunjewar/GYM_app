from django.urls import path
from .views import (
    TrainerAssignmentListCreateView,
    TrainerAssignmentDetailView
)

urlpatterns = [
    path('', TrainerAssignmentListCreateView.as_view(), name='assignment-list-create'),
    path('<uuid:pk>/', TrainerAssignmentDetailView.as_view(), name='assignment-detail'),
]
