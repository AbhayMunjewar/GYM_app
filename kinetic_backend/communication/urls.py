from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    QuestionViewSet, GroupViewSet, AnnouncementViewSet,
    ChatRoomViewSet, MessageView,
    ForumCategoryViewSet, ForumTopicViewSet,
    EventViewSet, ReportViewSet
)

router = DefaultRouter()
router.register(r'questions', QuestionViewSet, basename='question')
router.register(r'groups', GroupViewSet, basename='group')
router.register(r'announcements', AnnouncementViewSet, basename='announcement')
router.register(r'chat/rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'forums/categories', ForumCategoryViewSet, basename='forumcategory')
router.register(r'forums/topics', ForumTopicViewSet, basename='forumtopic')
router.register(r'events', EventViewSet, basename='event')
router.register(r'reports', ReportViewSet, basename='report')

urlpatterns = [
    path('', include(router.urls)),
    path('chat/messages/', MessageView.as_view(), name='chat-messages'),
]
