import logging
from django.db import transaction
from django.contrib.auth import get_user_model
from django.db.models import F

from notifications.services import NotificationService
from notifications.models import NotificationType, NotificationPriority
from members.models import Member
from trainers.models import Trainer
from gyms.models import Gym
from .models import (
    CommunityPost, PostReaction, PostComment, CommunityEvent, Follow,
    PostType, PostVisibility, PostStatus, ReactionType, CommunityEventType
)

logger = logging.getLogger(__name__)
User = get_user_model()

class CommunityService:
    @staticmethod
    @transaction.atomic
    def create_post(author, gym, post_type, title, content, image=None, visibility=PostVisibility.GYM_ONLY):
        """
        Creates a community post and triggers announcements if needed.
        """
        post = CommunityPost.objects.create(
            author=author,
            gym=gym,
            post_type=post_type,
            title=title,
            content=content,
            image=image,
            visibility=visibility,
            status=PostStatus.ACTIVE
        )

        # Trigger notifications for Trainer announcements
        if author.role == 'TRAINER' and post_type == PostType.ANNOUNCEMENT:
            members = Member.objects.filter(gym=gym, is_deleted=False)
            for m in members:
                # Resolve User associated with Member email
                member_user = User.objects.filter(email=m.email).first()
                if member_user and member_user != author:
                    NotificationService.create_notification(
                        recipient=member_user,
                        title="Trainer Announcement",
                        message=f"Trainer {author.full_name} posted: {title}",
                        notification_type=NotificationType.SYSTEM,
                        priority=NotificationPriority.MEDIUM,
                        action_url=f"/member/community"
                    )

        return post

    @staticmethod
    def delete_post(post_id, user):
        """
        Soft deletes a community post.
        """
        try:
            post = CommunityPost.objects.get(id=post_id, is_deleted=False)
            # Ownership check or Owner role check
            if post.author == user or (user.role == 'OWNER' and post.gym.owner == user):
                post.soft_delete()
                return True
            return False
        except CommunityPost.DoesNotExist:
            return False

    @staticmethod
    @transaction.atomic
    def add_reaction(post_id, user, reaction_type):
        """
        Upserts a user reaction to a post.
        """
        try:
            post = CommunityPost.objects.get(id=post_id, is_deleted=False)
        except CommunityPost.DoesNotExist:
            raise ValueError("Post not found.")

        if reaction_type not in ReactionType.values:
            raise ValueError(f"Invalid reaction type: {reaction_type}")

        reaction, created = PostReaction.objects.update_or_create(
            post=post,
            member=user,
            defaults={'reaction_type': reaction_type}
        )

        # Notify post author
        if post.author != user:
            NotificationService.create_notification(
                recipient=post.author,
                title="New Reaction!",
                message=f"{user.full_name} reacted {reaction_type.lower()} to your post.",
                notification_type=NotificationType.ACHIEVEMENT,
                priority=NotificationPriority.LOW,
                action_url=f"/member/community"
            )

        return reaction

    @staticmethod
    def remove_reaction(post_id, user):
        """
        Removes a user reaction from a post.
        """
        deleted_count, _ = PostReaction.objects.filter(post_id=post_id, member=user).delete()
        return deleted_count > 0

    @staticmethod
    @transaction.atomic
    def add_comment(post_id, author, content, parent_comment_id=None):
        """
        Adds a comment or nested reply to a post.
        """
        try:
            post = CommunityPost.objects.get(id=post_id, is_deleted=False)
        except CommunityPost.DoesNotExist:
            raise ValueError("Post not found.")

        parent_comment = None
        if parent_comment_id:
            try:
                parent_comment = PostComment.objects.get(id=parent_comment_id, post=post)
            except PostComment.DoesNotExist:
                raise ValueError("Parent comment not found.")

        comment = PostComment.objects.create(
            post=post,
            author=author,
            content=content,
            parent_comment=parent_comment
        )

        # Notify post author
        if post.author != author:
            NotificationService.create_notification(
                recipient=post.author,
                title="New Comment!",
                message=f"{author.full_name} commented on your post.",
                notification_type=NotificationType.ACHIEVEMENT,
                priority=NotificationPriority.MEDIUM,
                action_url=f"/member/community"
            )

        # Notify parent comment author if it's a nested reply
        if parent_comment and parent_comment.author != author and parent_comment.author != post.author:
            NotificationService.create_notification(
                recipient=parent_comment.author,
                title="New Reply!",
                message=f"{author.full_name} replied to your comment.",
                notification_type=NotificationType.ACHIEVEMENT,
                priority=NotificationPriority.MEDIUM,
                action_url=f"/member/community"
            )

        return comment

    @staticmethod
    def edit_comment(comment_id, author, content):
        """
        Edits a comment if the author matches.
        """
        try:
            comment = PostComment.objects.get(id=comment_id, author=author)
            comment.content = content
            comment.save(update_fields=['content', 'updated_at'])
            return comment
        except PostComment.DoesNotExist:
            return None

    @staticmethod
    def delete_comment(comment_id, user):
        """
        Deletes a comment.
        Author or gym Owner can delete.
        """
        try:
            comment = PostComment.objects.get(id=comment_id)
            if comment.author == user or (user.role == 'OWNER' and comment.post.gym.owner == user):
                comment.delete()
                return True
            return False
        except PostComment.DoesNotExist:
            return False

    @staticmethod
    def follow_user(follower, following):
        """
        Follows a user.
        """
        if follower == following:
            raise ValueError("You cannot follow yourself.")
        
        follow, created = Follow.objects.get_or_create(
            follower=follower,
            following=following
        )
        return follow

    @staticmethod
    def unfollow_user(follower, following):
        """
        Unfollows a user.
        """
        deleted_count, _ = Follow.objects.filter(follower=follower, following=following).delete()
        return deleted_count > 0

    @staticmethod
    @transaction.atomic
    def create_event_from_milestone(member, event_type, title, description, metadata=None):
        """
        Creates a CommunityEvent, notifies the member, and automatically publishes a CommunityPost.
        """
        if metadata is None:
            metadata = {}

        # 1. Create CommunityEvent
        event = CommunityEvent.objects.create(
            member=member,
            event_type=event_type,
            title=title,
            description=description,
            metadata=metadata
        )

        # 2. Resolve User associated with Member email
        member_user = User.objects.filter(email=member.email).first()
        if not member_user:
            logger.warning(f"No active User account matches member email {member.email}. Cannot post feed entry.")
            return event

        # 3. Create CommunityPost
        post_title = f"{member.full_name} - {title}"
        post_content = f"{description}\n\n🏆 Milestone reached on Velocity AI!"
        
        CommunityPost.objects.create(
            author=member_user,
            gym=member.gym,
            post_type=PostType.ACHIEVEMENT,
            title=post_title,
            content=post_content,
            visibility=PostVisibility.PUBLIC_GYM,
            status=PostStatus.ACTIVE
        )

        # 4. Notify member
        NotificationService.create_notification(
            recipient=member_user,
            title="Milestone Shared! 🚀",
            message=f"Your milestone '{title}' has been posted to the gym community feed.",
            notification_type=NotificationType.ACHIEVEMENT,
            priority=NotificationPriority.MEDIUM,
            action_url=f"/member/community"
        )

        return event
