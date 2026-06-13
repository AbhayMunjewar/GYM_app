from rest_framework import serializers
from django.contrib.auth import get_user_model
from members.models import Member
from trainers.models import Trainer
from gyms.models import Gym
from .models import CommunityPost, PostReaction, PostComment, CommunityEvent, Follow

User = get_user_model()

class AuthorDetailsSerializer(serializers.ModelSerializer):
    profile_image = serializers.SerializerMethodField()
    role_display = serializers.CharField(source='get_role_display', read_only=True)

    class Meta:
        model = User
        fields = ['id', 'full_name', 'email', 'role', 'role_display', 'profile_image']

    def get_profile_image(self, obj):
        request = self.context.get('request')
        if obj.role == 'MEMBER':
            member = Member.objects.filter(email=obj.email, is_deleted=False).first()
            if member and member.profile_image:
                if request:
                    return request.build_absolute_uri(member.profile_image.url)
                return member.profile_image.url
        elif obj.role == 'TRAINER':
            trainer = Trainer.objects.filter(user=obj, is_deleted=False).first()
            if trainer and trainer.profile_image:
                # profile_image on Trainer is stored as URL/Base64 TextField
                return trainer.profile_image
        return None


class PostReactionSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)

    class Meta:
        model = PostReaction
        fields = ['id', 'post', 'member', 'member_name', 'reaction_type', 'created_at']
        read_only_fields = ['member', 'created_at']


class PostCommentSerializer(serializers.ModelSerializer):
    author_details = AuthorDetailsSerializer(source='author', read_only=True)
    replies = serializers.SerializerMethodField()

    class Meta:
        model = PostComment
        fields = [
            'id', 'post', 'author', 'author_details', 'parent_comment',
            'content', 'replies', 'created_at', 'updated_at'
        ]
        read_only_fields = ['author', 'created_at', 'updated_at']

    def get_replies(self, obj):
        # Limit nesting depth to 1 for replies list to keep payload performant
        if obj.parent_comment is None:
            replies_qs = obj.replies.select_related('author').all()
            return PostCommentSerializer(replies_qs, many=True, context=self.context).data
        return []


class CommunityPostSerializer(serializers.ModelSerializer):
    author_details = AuthorDetailsSerializer(source='author', read_only=True)
    gym_name = serializers.CharField(source='gym.gym_name', read_only=True)
    reactions_count = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    liked_by_user = serializers.SerializerMethodField()
    user_reaction_type = serializers.SerializerMethodField()

    class Meta:
        model = CommunityPost
        fields = [
            'id', 'author', 'author_details', 'gym', 'gym_name',
            'post_type', 'title', 'content', 'image', 'visibility',
            'status', 'reactions_count', 'comments_count', 'liked_by_user',
            'user_reaction_type', 'created_at', 'updated_at'
        ]
        read_only_fields = ['author', 'gym', 'created_at', 'updated_at']

    def get_reactions_count(self, obj):
        if hasattr(obj, 'reactions_count'):
            return obj.reactions_count
        return obj.reactions.count()

    def get_comments_count(self, obj):
        if hasattr(obj, 'comments_count'):
            return obj.comments_count
        return obj.comments.count()

    def get_liked_by_user(self, obj):
        if hasattr(obj, 'liked_by_user'):
            return obj.liked_by_user
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.reactions.filter(member=request.user).exists()
        return False

    def get_user_reaction_type(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            reaction = obj.reactions.filter(member=request.user).first()
            return reaction.reaction_type if reaction else None
        return None


class CommunityEventSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    gym_id = serializers.UUIDField(source='member.gym.id', read_only=True)
    gym_name = serializers.CharField(source='member.gym.gym_name', read_only=True)

    class Meta:
        model = CommunityEvent
        fields = [
            'id', 'member', 'member_name', 'gym_id', 'gym_name',
            'event_type', 'title', 'description', 'metadata', 'created_at'
        ]
        read_only_fields = ['created_at']


class FollowSerializer(serializers.ModelSerializer):
    follower_details = AuthorDetailsSerializer(source='follower', read_only=True)
    following_details = AuthorDetailsSerializer(source='following', read_only=True)

    class Meta:
        model = Follow
        fields = ['id', 'follower', 'follower_details', 'following', 'following_details', 'created_at']
        read_only_fields = ['follower', 'created_at']
