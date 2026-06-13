from rest_framework import viewsets, generics, status, serializers
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated

from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from gyms.models import Gym
from accounts.models import UserRole
from .models import CommunityPost, PostComment, PostReaction, CommunityEvent
from .serializers import (
    CommunityPostSerializer, PostCommentSerializer, PostReactionSerializer,
    CommunityEventSerializer
)
from .services import CommunityService
from .feed_engine import FeedEngine
from .permissions import IsGymMemberOrStaff, IsPostAuthorOrStaff, IsCommentAuthorOrStaff, get_user_gyms

class CommunityPostViewSet(viewsets.ModelViewSet):
    serializer_class = CommunityPostSerializer
    permission_classes = [IsAuthenticated, IsPostAuthorOrStaff]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        # Filter posts only within user's gym
        return CommunityPost.objects.filter(
            gym__in=gyms, 
            is_deleted=False
        ).select_related('author', 'gym').order_by('-created_at')

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")
        
        # Determine the target gym
        gym = gyms[0]
        if user.role == UserRole.OWNER and 'gym' in self.request.data:
            gym_id = self.request.data.get('gym')
            try:
                gym = Gym.objects.get(id=gym_id, owner=user, is_deleted=False)
            except (Gym.DoesNotExist, ValueError):
                raise serializers.ValidationError("Invalid gym ID or you do not own this gym.")

        # Save post via service pattern to handle announcement alerts and set instance
        serializer.instance = CommunityService.create_post(
            author=user,
            gym=gym,
            post_type=serializer.validated_data.get('post_type', 'GENERAL'),
            title=serializer.validated_data.get('title'),
            content=serializer.validated_data.get('content'),
            image=serializer.validated_data.get('image'),
            visibility=serializer.validated_data.get('visibility', 'GYM_ONLY')
        )

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        success = CommunityService.delete_post(instance.id, request.user)
        if success:
            return success_response("Post deleted successfully.")
        return failure_response("Failed to delete post or unauthorized.", status_code=status.HTTP_400_BAD_REQUEST)

    # Reactions action: POST /api/community/posts/{id}/react/ and DELETE /api/community/posts/{id}/react/
    @action(detail=True, methods=['post', 'delete'], permission_classes=[IsAuthenticated, IsGymMemberOrStaff])
    def react(self, request, pk=None):
        user = request.user
        if request.method == 'POST':
            reaction_type = request.data.get('reaction_type', 'LIKE')
            try:
                CommunityService.add_reaction(pk, user, reaction_type)
                return success_response(f"Reacted with {reaction_type}.", data={"reaction_type": reaction_type})
            except ValueError as e:
                return failure_response(str(e))
        elif request.method == 'DELETE':
            success = CommunityService.remove_reaction(pk, user)
            if success:
                return success_response("Reaction removed.")
            return failure_response("No reaction to remove.", status_code=status.HTTP_404_NOT_FOUND)

    # Comments action: POST /api/community/posts/{id}/comments/ and GET /api/community/posts/{id}/comments/
    @action(detail=True, methods=['get', 'post'], permission_classes=[IsAuthenticated, IsGymMemberOrStaff])
    def comments(self, request, pk=None):
        if request.method == 'GET':
            comments_qs = PostComment.objects.filter(
                post_id=pk, 
                parent_comment__isnull=True
            ).select_related('author').order_by('created_at')
            
            page = self.paginate_queryset(comments_qs)
            if page is not None:
                serializer = PostCommentSerializer(page, many=True, context={'request': request})
                return self.get_paginated_response(serializer.data)
            
            serializer = PostCommentSerializer(comments_qs, many=True, context={'request': request})
            return success_response("Comments retrieved.", data=serializer.data)

        elif request.method == 'POST':
            content = request.data.get('content')
            parent_comment_id = request.data.get('parent_comment_id')
            if not content:
                return failure_response("Content is required.")
            
            try:
                comment = CommunityService.add_comment(
                    post_id=pk,
                    author=request.user,
                    content=content,
                    parent_comment_id=parent_comment_id
                )
                serializer = PostCommentSerializer(comment, context={'request': request})
                return success_response("Comment posted successfully.", data=serializer.data, status_code=status.HTTP_201_CREATED)
            except ValueError as e:
                return failure_response(str(e))


class CommentViewSet(viewsets.GenericViewSet):
    serializer_class = PostCommentSerializer
    permission_classes = [IsAuthenticated, IsCommentAuthorOrStaff]
    queryset = PostComment.objects.all()

    def partial_update(self, request, pk=None):
        content = request.data.get('content')
        if not content:
            return failure_response("Content is required.")
        
        comment = CommunityService.edit_comment(pk, request.user, content)
        if comment:
            serializer = self.get_serializer(comment)
            return success_response("Comment updated.", data=serializer.data)
        return failure_response("Comment not found or unauthorized.", status_code=status.HTTP_403_FORBIDDEN)

    def destroy(self, request, pk=None):
        success = CommunityService.delete_comment(pk, request.user)
        if success:
            return success_response("Comment deleted.")
        return failure_response("Failed to delete comment or unauthorized.", status_code=status.HTTP_400_BAD_REQUEST)


class FeedView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CommunityPostSerializer
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        return FeedEngine.get_community_feed(self.request.user)


class EventListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated, IsGymMemberOrStaff]
    serializer_class = CommunityEventSerializer
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return CommunityEvent.objects.filter(
            member__gym__in=gyms
        ).select_related('member', 'member__gym').order_by('-created_at')


class AnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        analytics_data = CommunityService.get_community_analytics(request.user)
        return success_response("Analytics retrieved.", data=analytics_data)
