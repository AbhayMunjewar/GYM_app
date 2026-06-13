from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CommunityPostViewSet, CommentViewSet, FeedView, EventListView, AnalyticsView

router = DefaultRouter()
router.register(r'posts', CommunityPostViewSet, basename='post')
router.register(r'comments', CommentViewSet, basename='comment')

urlpatterns = [
    path('feed/', FeedView.as_view(), name='feed'),
    path('events/', EventListView.as_view(), name='events'),
    path('analytics/', AnalyticsView.as_view(), name='analytics'),
    path('', include(router.urls)),
]
