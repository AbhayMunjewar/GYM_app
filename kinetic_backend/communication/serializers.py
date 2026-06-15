from rest_framework import serializers
from django.contrib.auth import get_user_model
from community.serializers import AuthorDetailsSerializer
from .models import (
    Question, Answer,
    Group, GroupMember, GroupPost,
    Announcement,
    ChatRoom, ChatParticipant, Message,
    ForumCategory, ForumTopic, ForumReply,
    Event, EventRegistration,
    Report
)

User = get_user_model()

# --- MODULE 1: Q&A ---

class AnswerSerializer(serializers.ModelSerializer):
    trainer_details = AuthorDetailsSerializer(source='trainer', read_only=True)

    class Meta:
        model = Answer
        fields = ['id', 'question', 'trainer', 'trainer_details', 'answer', 'created_at', 'updated_at']
        read_only_fields = ['id', 'trainer', 'created_at', 'updated_at']


class QuestionSerializer(serializers.ModelSerializer):
    member_details = AuthorDetailsSerializer(source='member', read_only=True)
    trainer_details = AuthorDetailsSerializer(source='trainer', read_only=True)
    answers = AnswerSerializer(many=True, read_only=True)
    answers_count = serializers.SerializerMethodField()

    class Meta:
        model = Question
        fields = [
            'id', 'member', 'member_details', 'trainer', 'trainer_details',
            'gym', 'title', 'question', 'status', 'answers', 'answers_count',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'member', 'gym', 'created_at', 'updated_at']

    def get_answers_count(self, obj):
        return obj.answers.count()


# --- MODULE 2: GROUPS ---

class GroupMemberSerializer(serializers.ModelSerializer):
    user_details = AuthorDetailsSerializer(source='user', read_only=True)

    class Meta:
        model = GroupMember
        fields = ['id', 'group', 'user', 'user_details', 'role', 'joined_at']
        read_only_fields = ['id', 'joined_at']


class GroupSerializer(serializers.ModelSerializer):
    creator_details = AuthorDetailsSerializer(source='created_by', read_only=True)
    members_count = serializers.SerializerMethodField()
    is_member = serializers.SerializerMethodField()

    class Meta:
        model = Group
        fields = [
            'id', 'gym', 'group_name', 'description', 'group_type',
            'created_by', 'creator_details', 'is_active', 'members_count', 'is_member',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'gym', 'created_by', 'created_at', 'updated_at']

    def get_members_count(self, obj):
        return obj.memberships.count()

    def get_is_member(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.memberships.filter(user=request.user).exists()
        return False


class GroupPostSerializer(serializers.ModelSerializer):
    author_details = AuthorDetailsSerializer(source='author', read_only=True)

    class Meta:
        model = GroupPost
        fields = ['id', 'group', 'author', 'author_details', 'content', 'image', 'is_deleted', 'created_at', 'updated_at']
        read_only_fields = ['id', 'author', 'is_deleted', 'created_at', 'updated_at']


# --- MODULE 3: ANNOUNCEMENTS ---

class AnnouncementSerializer(serializers.ModelSerializer):
    created_by_details = AuthorDetailsSerializer(source='created_by', read_only=True)

    class Meta:
        model = Announcement
        fields = ['id', 'gym', 'created_by', 'created_by_details', 'title', 'description', 'priority', 'created_at', 'updated_at']
        read_only_fields = ['id', 'gym', 'created_by', 'created_at', 'updated_at']


# --- MODULE 4: REAL-TIME CHAT ---

class MessageSerializer(serializers.ModelSerializer):
    sender_details = AuthorDetailsSerializer(source='sender', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'room', 'sender', 'sender_details', 'content', 'message_type', 'is_read', 'is_deleted', 'sent_at']
        read_only_fields = ['id', 'sender', 'is_read', 'is_deleted', 'sent_at']


class ChatParticipantSerializer(serializers.ModelSerializer):
    user_details = AuthorDetailsSerializer(source='user', read_only=True)

    class Meta:
        model = ChatParticipant
        fields = ['id', 'room', 'user', 'user_details']


class ChatRoomSerializer(serializers.ModelSerializer):
    participants = ChatParticipantSerializer(many=True, read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['id', 'participants', 'last_message', 'unread_count', 'created_at']

    def get_last_message(self, obj):
        msg = obj.messages.filter(is_deleted=False).last()
        if msg:
            return MessageSerializer(msg, context=self.context).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.messages.filter(is_read=False).exclude(sender=request.user).count()
        return 0


# --- MODULE 5: DISCUSSION FORUMS ---

class ForumReplySerializer(serializers.ModelSerializer):
    author_details = AuthorDetailsSerializer(source='author', read_only=True)

    class Meta:
        model = ForumReply
        fields = ['id', 'topic', 'author', 'author_details', 'content', 'created_at', 'updated_at']
        read_only_fields = ['id', 'author', 'created_at', 'updated_at']


class ForumTopicSerializer(serializers.ModelSerializer):
    creator_details = AuthorDetailsSerializer(source='creator', read_only=True)
    replies_count = serializers.SerializerMethodField()
    category_name = serializers.CharField(source='category.name', read_only=True)

    class Meta:
        model = ForumTopic
        fields = [
            'id', 'category', 'category_name', 'creator', 'creator_details', 'title',
            'content', 'is_pinned', 'is_locked', 'replies_count', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'creator', 'created_at', 'updated_at']

    def get_replies_count(self, obj):
        return obj.replies.count()


class ForumCategorySerializer(serializers.ModelSerializer):
    topics_count = serializers.SerializerMethodField()

    class Meta:
        model = ForumCategory
        fields = ['id', 'gym', 'name', 'description', 'topics_count']
        read_only_fields = ['id', 'gym']

    def get_topics_count(self, obj):
        return obj.topics.count()


# --- MODULE 6: EVENTS ---

class EventRegistrationSerializer(serializers.ModelSerializer):
    user_details = AuthorDetailsSerializer(source='user', read_only=True)

    class Meta:
        model = EventRegistration
        fields = ['id', 'event', 'user', 'user_details', 'registered_at', 'attended']
        read_only_fields = ['id', 'registered_at', 'attended']


class EventSerializer(serializers.ModelSerializer):
    creator_details = AuthorDetailsSerializer(source='created_by', read_only=True)
    registrations_count = serializers.SerializerMethodField()
    is_registered = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = [
            'id', 'gym', 'title', 'description', 'start_date', 'end_date',
            'capacity', 'created_by', 'creator_details', 'status', 'registrations_count',
            'is_registered', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'gym', 'created_by', 'created_at', 'updated_at']

    def get_registrations_count(self, obj):
        return obj.registrations.count()

    def get_is_registered(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.registrations.filter(user=request.user).exists()
        return False


# --- MODULE 7: MODERATION ---

class ReportSerializer(serializers.ModelSerializer):
    reporter_details = AuthorDetailsSerializer(source='reporter', read_only=True)

    class Meta:
        model = Report
        fields = ['id', 'reporter', 'reporter_details', 'content_type', 'content_id', 'reason', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'reporter', 'status', 'created_at', 'updated_at']
