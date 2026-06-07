from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MembershipPlanViewSet, MembershipViewSet

router = DefaultRouter()
router.register(r'plans', MembershipPlanViewSet, basename='membership-plan')
router.register(r'assignments', MembershipViewSet, basename='membership-assignment')

urlpatterns = [
    path('', include(router.urls)),
]
