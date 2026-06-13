from django.urls import path
from .views import OwnerAnalyticsView, TrainerAnalyticsView, MemberAnalyticsView

urlpatterns = [
    path('owner/', OwnerAnalyticsView.as_view(), name='owner-analytics'),
    path('trainer/', TrainerAnalyticsView.as_view(), name='trainer-analytics'),
    path('member/', MemberAnalyticsView.as_view(), name='member-analytics'),
]
