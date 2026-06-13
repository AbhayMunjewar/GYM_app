import uuid
import json
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from gyms.models import Gym
from members.models import Member

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


class PostType(models.TextChoices):
    ACHIEVEMENT = 'ACHIEVEMENT', _('Achievement')
    PROGRESS = 'PROGRESS', _('Progress')
    WORKOUT = 'WORKOUT', _('Workout')
    DIET = 'DIET', _('Diet')
    CHALLENGE = 'CHALLENGE', _('Challenge')
    ANNOUNCEMENT = 'ANNOUNCEMENT', _('Announcement')
    GENERAL = 'GENERAL', _('General')

class PostVisibility(models.TextChoices):
    GYM_ONLY = 'GYM_ONLY', _('Gym Only')
    TRAINERS_ONLY = 'TRAINERS_ONLY', _('Trainers Only')
    PUBLIC_GYM = 'PUBLIC_GYM', _('Public Gym')

class PostStatus(models.TextChoices):
    ACTIVE = 'ACTIVE', _('Active')
    HIDDEN = 'HIDDEN', _('Hidden')
    DELETED = 'DELETED', _('Deleted')

class CommunityPost(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='community_posts',
        db_index=True
    )
    gym = models.ForeignKey(
        Gym,
        on_delete=models.CASCADE,
        related_name='community_posts',
        db_index=True
    )
    post_type = models.CharField(
        max_length=50,
        choices=PostType.choices,
        default=PostType.GENERAL,
        db_index=True
    )
    title = models.CharField(max_length=255)
    content = models.TextField()
    image = models.ImageField(upload_to='community_posts/', null=True, blank=True)
    visibility = models.CharField(
        max_length=50,
        choices=PostVisibility.choices,
        default=PostVisibility.GYM_ONLY,
        db_index=True
    )
    status = models.CharField(
        max_length=50,
        choices=PostStatus.choices,
        default=PostStatus.ACTIVE,
        db_index=True
    )
    is_deleted = models.BooleanField(default=False, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'community_posts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['gym', 'is_deleted', '-created_at']),
            models.Index(fields=['author', 'is_deleted', '-created_at']),
            models.Index(fields=['post_type', 'is_deleted']),
        ]

    def __str__(self):
        return f"{self.title} by {self.author.email} - {self.gym.gym_name}"

    def soft_delete(self):
        self.is_deleted = True
        self.status = PostStatus.DELETED
        self.save(update_fields=['is_deleted', 'status', 'updated_at'])


class ReactionType(models.TextChoices):
    LIKE = 'LIKE', _('Like')
    FIRE = 'FIRE', _('Fire')
    CLAP = 'CLAP', _('Clap')
    STRONG = 'STRONG', _('Strong')
    MOTIVATED = 'MOTIVATED', _('Motivated')

class PostReaction(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(
        CommunityPost,
        on_delete=models.CASCADE,
        related_name='reactions'
    )
    member = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='post_reactions'
    )
    reaction_type = models.CharField(
        max_length=20,
        choices=ReactionType.choices,
        default=ReactionType.LIKE
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'post_reactions'
        unique_together = ('post', 'member')
        indexes = [
            models.Index(fields=['post', 'reaction_type']),
        ]

    def __str__(self):
        return f"{self.member.email} reacted {self.reaction_type} to post {self.post.id}"


class PostComment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    post = models.ForeignKey(
        CommunityPost,
        on_delete=models.CASCADE,
        related_name='comments'
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='post_comments'
    )
    parent_comment = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='replies'
    )
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'post_comments'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['post', 'created_at']),
        ]

    def __str__(self):
        return f"Comment by {self.author.email} on post {self.post.id}"


class CommunityEventType(models.TextChoices):
    BADGE_UNLOCKED = 'BADGE_UNLOCKED', _('Badge Unlocked')
    GOAL_ACHIEVED = 'GOAL_ACHIEVED', _('Goal Achieved')
    CHALLENGE_COMPLETED = 'CHALLENGE_COMPLETED', _('Challenge Completed')
    STREAK_ACHIEVED = 'STREAK_ACHIEVED', _('Streak Achieved')
    WEIGHT_LOSS_MILESTONE = 'WEIGHT_LOSS_MILESTONE', _('Weight Loss Milestone')
    MEMBERSHIP_ANNIVERSARY = 'MEMBERSHIP_ANNIVERSARY', _('Membership Anniversary')

class CommunityEvent(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    member = models.ForeignKey(
        Member,
        on_delete=models.CASCADE,
        related_name='community_events'
    )
    event_type = models.CharField(
        max_length=50,
        choices=CommunityEventType.choices,
        db_index=True
    )
    title = models.CharField(max_length=255)
    description = models.TextField()
    metadata = JSONTextField(default=dict, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table = 'community_events'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['member', '-created_at']),
        ]

    def __str__(self):
        return f"Event {self.event_type} - {self.member.full_name}"


class Follow(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    follower = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='following_relations'
    )
    following = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='follower_relations'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'follows'
        unique_together = ('follower', 'following')
        indexes = [
            models.Index(fields=['follower', 'following']),
        ]

    def __str__(self):
        return f"{self.follower.email} follows {self.following.email}"
