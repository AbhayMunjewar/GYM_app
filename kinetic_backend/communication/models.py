import uuid
import json
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from gyms.models import Gym

class JSONTextField(models.TextField):
    """
    A simple database-agnostic JSON field that uses TextField under the hood.
    Prevents SQLite JSON_VALID issues on older sqlite installations.
    """
    def from_db_value(self, value, expression, connection):
        if value is None:
            return {}
        try:
            return json.loads(value)
        except Exception:
            return {}

    def to_python(self, value):
        if isinstance(value, (dict, list)):
            return value
        if value is None:
            return {}
        try:
            return json.loads(value)
        except Exception:
            return {}

    def get_prep_value(self, value):
        if value is None:
            return "{}"
        return json.dumps(value)


# --- MODULE 1: TRAINER Q&A ---

class QuestionStatus(models.TextChoices):
    OPEN = 'OPEN', _('Open')
    ANSWERED = 'ANSWERED', _('Answered')
    CLOSED = 'CLOSED', _('Closed')

class Question(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='asked_questions'
    )
    trainer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_questions'
    )
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='questions'
    )
    title = models.CharField(max_length=255)
    question = models.TextField()
    status = models.CharField(
        max_length=20,
        choices=QuestionStatus.choices,
        default=QuestionStatus.OPEN,
        db_index=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_questions'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.member.email}"


class Answer(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    question = models.ForeignKey(
        Question,
        on_delete=models.CASCADE,
        related_name='answers'
    )
    trainer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='trainer_answers'
    )
    answer = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_answers'
        ordering = ['created_at']

    def __str__(self):
        return f"Answer to Question {self.question.id} by {self.trainer.email}"


# --- MODULE 2: GROUPS ---

class GroupType(models.TextChoices):
    PUBLIC = 'PUBLIC', _('Public')
    PRIVATE = 'PRIVATE', _('Private')

class Group(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='groups'
    )
    group_name = models.CharField(max_length=255)
    description = models.TextField()
    group_type = models.CharField(
        max_length=20,
        choices=GroupType.choices,
        default=GroupType.PUBLIC
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='created_groups'
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_groups'
        ordering = ['-created_at']
        unique_together = ('gym', 'group_name')

    def __str__(self):
        return f"{self.group_name} - {self.gym.gym_name}"


class GroupMemberRole(models.TextChoices):
    MEMBER = 'MEMBER', _('Member')
    MODERATOR = 'MODERATOR', _('Moderator')
    ADMIN = 'ADMIN', _('Admin')

class GroupMember(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    group = models.ForeignKey(
        Group,
        on_delete=models.CASCADE,
        related_name='memberships'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='group_memberships'
    )
    role = models.CharField(
        max_length=20,
        choices=GroupMemberRole.choices,
        default=GroupMemberRole.MEMBER
    )
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'communication_group_members'
        unique_together = ('group', 'user')

    def __str__(self):
        return f"{self.user.email} in {self.group.group_name}"


class GroupPost(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    group = models.ForeignKey(
        Group,
        on_delete=models.CASCADE,
        related_name='posts'
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='group_posts'
    )
    content = models.TextField()
    image = models.ImageField(upload_to='group_posts/', null=True, blank=True)
    is_deleted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_group_posts'
        ordering = ['-created_at']

    def __str__(self):
        return f"Post by {self.author.email} in {self.group.group_name}"


# --- MODULE 3: ANNOUNCEMENTS ---

class AnnouncementPriority(models.TextChoices):
    LOW = 'LOW', _('Low')
    MEDIUM = 'MEDIUM', _('Medium')
    HIGH = 'HIGH', _('High')
    CRITICAL = 'CRITICAL', _('Critical')

class Announcement(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='announcements'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='announcements'
    )
    title = models.CharField(max_length=255)
    description = models.TextField()
    priority = models.CharField(
        max_length=20,
        choices=AnnouncementPriority.choices,
        default=AnnouncementPriority.MEDIUM
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_announcements'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.gym.gym_name}"


# --- MODULE 4: REAL-TIME CHAT ---

class ChatRoom(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'communication_chat_rooms'


class ChatParticipant(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='participants'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='chat_participants'
    )

    class Meta:
        db_table = 'communication_chat_participants'
        unique_together = ('room', 'user')

    def __str__(self):
        return f"{self.user.email} in Room {self.room.id}"


class MessageType(models.TextChoices):
    TEXT = 'TEXT', _('Text')
    IMAGE = 'IMAGE', _('Image')
    FILE = 'FILE', _('File')

class Message(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    content = models.TextField()
    message_type = models.CharField(
        max_length=20,
        choices=MessageType.choices,
        default=MessageType.TEXT
    )
    is_read = models.BooleanField(default=False)
    is_deleted = models.BooleanField(default=False)
    sent_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'communication_messages'
        ordering = ['sent_at']

    def __str__(self):
        return f"Msg from {self.sender.email} in Room {self.room.id}"


# --- MODULE 5: DISCUSSION FORUMS ---

class ForumCategory(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='forum_categories'
    )
    name = models.CharField(max_length=255)
    description = models.TextField()

    class Meta:
        db_table = 'communication_forum_categories'
        unique_together = ('gym', 'name')

    def __str__(self):
        return f"{self.name} - {self.gym.gym_name}"


class ForumTopic(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    category = models.ForeignKey(
        ForumCategory,
        on_delete=models.CASCADE,
        related_name='topics'
    )
    creator = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='forum_topics'
    )
    title = models.CharField(max_length=255)
    content = models.TextField()
    is_pinned = models.BooleanField(default=False)
    is_locked = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_forum_topics'
        ordering = ['-is_pinned', '-created_at']

    def __str__(self):
        return f"{self.title} in {self.category.name}"


class ForumReply(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    topic = models.ForeignKey(
        ForumTopic,
        on_delete=models.CASCADE,
        related_name='replies'
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='forum_replies'
    )
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_forum_replies'
        ordering = ['created_at']

    def __str__(self):
        return f"Reply by {self.author.email} on Topic {self.topic.id}"


# --- MODULE 6: EVENTS ---

class EventStatus(models.TextChoices):
    UPCOMING = 'UPCOMING', _('Upcoming')
    ACTIVE = 'ACTIVE', _('Active')
    COMPLETED = 'COMPLETED', _('Completed')
    CANCELLED = 'CANCELLED', _('Cancelled')

class Event(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='events'
    )
    title = models.CharField(max_length=255)
    description = models.TextField()
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    capacity = models.PositiveIntegerField()
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='created_events'
    )
    status = models.CharField(
        max_length=20,
        choices=EventStatus.choices,
        default=EventStatus.UPCOMING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_events'
        ordering = ['start_date']

    def __str__(self):
        return f"{self.title} - {self.gym.gym_name}"


class EventRegistration(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(
        Event,
        on_delete=models.CASCADE,
        related_name='registrations'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='event_registrations'
    )
    registered_at = models.DateTimeField(auto_now_add=True)
    attended = models.BooleanField(default=False)

    class Meta:
        db_table = 'communication_event_registrations'
        unique_together = ('event', 'user')

    def __str__(self):
        return f"{self.user.email} registered for {self.event.title}"


# --- MODULE 7: MODERATION ---

class ReportContentType(models.TextChoices):
    POST = 'POST', _('Post')
    COMMENT = 'COMMENT', _('Comment')
    MESSAGE = 'MESSAGE', _('Message')
    FORUM_TOPIC = 'FORUM_TOPIC', _('Forum Topic')

class ReportStatus(models.TextChoices):
    PENDING = 'PENDING', _('Pending')
    REVIEWED = 'REVIEWED', _('Reviewed')
    RESOLVED = 'RESOLVED', _('Resolved')

class Report(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='filed_reports'
    )
    content_type = models.CharField(
        max_length=20,
        choices=ReportContentType.choices
    )
    content_id = models.UUIDField()
    reason = models.TextField()
    status = models.CharField(
        max_length=20,
        choices=ReportStatus.choices,
        default=ReportStatus.PENDING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'communication_reports'
        ordering = ['-created_at']

    def __str__(self):
        return f"Report {self.id} on {self.content_type} by {self.reporter.email}"
