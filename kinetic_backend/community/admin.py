from django.contrib import admin
from .models import CommunityPost, PostReaction, PostComment, CommunityEvent, Follow

@admin.register(CommunityPost)
class CommunityPostAdmin(admin.ModelAdmin):
    list_display = ['title', 'author', 'gym', 'post_type', 'visibility', 'status', 'is_deleted', 'created_at']
    list_filter = ['post_type', 'visibility', 'status', 'is_deleted', 'gym']
    search_fields = ['title', 'content', 'author__email', 'gym__gym_name']
    ordering = ['-created_at']

@admin.register(PostReaction)
class PostReactionAdmin(admin.ModelAdmin):
    list_display = ['post', 'member', 'reaction_type', 'created_at']
    list_filter = ['reaction_type', 'created_at']
    search_fields = ['member__email', 'post__title']

@admin.register(PostComment)
class PostCommentAdmin(admin.ModelAdmin):
    list_display = ['post', 'author', 'parent_comment', 'content_summary', 'created_at']
    list_filter = ['created_at']
    search_fields = ['author__email', 'content', 'post__title']

    def content_summary(self, obj):
        return obj.content[:50] + '...' if len(obj.content) > 50 else obj.content
    content_summary.short_description = 'Content'

@admin.register(CommunityEvent)
class CommunityEventAdmin(admin.ModelAdmin):
    list_display = ['member', 'event_type', 'title', 'created_at']
    list_filter = ['event_type', 'created_at']
    search_fields = ['member__full_name', 'member__email', 'title']

@admin.register(Follow)
class FollowAdmin(admin.ModelAdmin):
    list_display = ['follower', 'following', 'created_at']
    search_fields = ['follower__email', 'following__email']
