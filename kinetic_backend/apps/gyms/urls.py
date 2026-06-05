from django.urls import path, include
from rest_framework.routers import DefaultRouter
from gyms.views import GymViewSet

router = DefaultRouter()
router.register(r'', GymViewSet, basename='gym')

urlpatterns = [
    path('', include(router.urls)),
]
