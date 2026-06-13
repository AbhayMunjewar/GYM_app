import logging
from django.db.models import Count, OuterRef, Exists
from accounts.models import UserRole
from members.models import Member
from trainers.models import Trainer
from .models import CommunityPost, PostReaction, PostStatus, PostVisibility

logger = logging.getLogger(__name__)

class FeedEngine:
    @staticmethod
    def get_community_feed(user, limit=20, offset=0):
        """
        Compiles the community feed for a user based on role boundaries and gym isolation.
        Optimized with annotations and select_related to prevent N+1 queries.
        """
        if not user or not user.is_authenticated:
            return CommunityPost.objects.none()

        queryset = CommunityPost.objects.filter(is_deleted=False)

        if user.role == UserRole.MEMBER:
            member = Member.objects.filter(email=user.email, is_deleted=False).first()
            if not member:
                return CommunityPost.objects.none()
            
            # Member sees:
            # - Same gym posts
            # - Active status
            # - Visibility GYM_ONLY or PUBLIC_GYM
            # - OR their own posts
            queryset = queryset.filter(
                gym=member.gym,
                status=PostStatus.ACTIVE
            ).filter(
                visibility__in=[PostVisibility.GYM_ONLY, PostVisibility.PUBLIC_GYM]
            ) | CommunityPost.objects.filter(
                author=user,
                is_deleted=False
            )

        elif user.role == UserRole.TRAINER:
            trainer = Trainer.objects.filter(user=user, is_deleted=False).first()
            if not trainer:
                return CommunityPost.objects.none()
            
            # Trainer sees:
            # - Same gym posts (including TRAINERS_ONLY)
            # - Active status
            queryset = queryset.filter(
                gym=trainer.gym,
                status=PostStatus.ACTIVE
            )

        elif user.role == UserRole.OWNER:
            owned_gyms = user.gyms.all()
            if not owned_gyms.exists():
                return CommunityPost.objects.none()
            
            # Owner sees:
            # - Gym-wide community feed (all gyms they own)
            # - Active or Hidden posts (for moderation)
            queryset = queryset.filter(
                gym__in=owned_gyms,
                status__in=[PostStatus.ACTIVE, PostStatus.HIDDEN]
            )
        else:
            # Anonymous or unsupported role
            return CommunityPost.objects.none()

        # Remove duplicate records that might arise from OR operations
        queryset = queryset.distinct()

        # Annotations to count reactions/comments and determine if user has reacted
        has_reacted = PostReaction.objects.filter(
            post=OuterRef('pk'),
            member=user
        )

        queryset = queryset.annotate(
            reactions_count=Count('reactions', distinct=True),
            comments_count=Count('comments', distinct=True),
            liked_by_user=Exists(has_reacted)
        )

        # Optimize querying related models
        queryset = queryset.select_related('author', 'gym').order_by('-created_at')

        return queryset
