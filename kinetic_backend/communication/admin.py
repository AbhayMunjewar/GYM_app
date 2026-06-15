from django.contrib import admin
from .models import (
    Question, Answer,
    Group, GroupMember, GroupPost,
    Announcement,
    ChatRoom, ChatParticipant, Message,
    ForumCategory, ForumTopic, ForumReply,
    Event, EventRegistration,
    Report
)

@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ['title', 'member', 'trainer', 'gym', 'status', 'created_at']
    list_filter = ['status', 'gym']
    search_fields = ['title', 'question', 'member__email', 'trainer__email']

@admin.register(Answer)
class AnswerAdmin(admin.ModelAdmin):
    list_display = ['question', 'trainer', 'created_at']

@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    list_display = ['group_name', 'gym', 'group_type', 'created_by', 'is_active', 'created_at']
    list_filter = ['group_type', 'is_active', 'gym']
    search_fields = ['group_name', 'description']

admin.site.register(GroupMember)
admin.site.register(GroupPost)

@admin.register(Announcement)
class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ['title', 'gym', 'created_by', 'priority', 'created_at']
    list_filter = ['priority', 'gym']
    search_fields = ['title', 'description']

admin.site.register(ChatRoom)
admin.site.register(ChatParticipant)
admin.site.register(Message)

admin.site.register(ForumCategory)
admin.site.register(ForumTopic)
admin.site.register(ForumReply)

@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ['title', 'gym', 'start_date', 'end_date', 'capacity', 'status']
    list_filter = ['status', 'gym']
    search_fields = ['title', 'description']

admin.site.register(EventRegistration)
admin.site.register(Report)
