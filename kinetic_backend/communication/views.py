from rest_framework import viewsets, generics, status, serializers, permissions
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated

from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from gyms.models import Gym
from members.models import Member
from accounts.models import UserRole
from .models import (
    Question, Answer, QuestionStatus,
    Group, GroupMember, GroupPost, GroupType,
    Announcement, AnnouncementPriority,
    ChatRoom, ChatParticipant, Message, MessageType,
    ForumCategory, ForumTopic, ForumReply,
    Event, EventRegistration,
    Report, ReportContentType, ReportStatus
)
from .serializers import (
    QuestionSerializer, AnswerSerializer,
    GroupSerializer, GroupMemberSerializer, GroupPostSerializer,
    AnnouncementSerializer,
    ChatRoomSerializer, MessageSerializer,
    ForumCategorySerializer, ForumTopicSerializer, ForumReplySerializer,
    EventSerializer, EventRegistrationSerializer,
    ReportSerializer
)
from .services import (
    QAService, GroupService, AnnouncementService,
    ChatService, ForumService, EventService, ModerationService
)
from .permissions import get_user_gyms, IsGymParticipant, IsOwnerOrTrainer, IsModeratorOrOwner

class QuestionViewSet(viewsets.ModelViewSet):
    serializer_class = QuestionSerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        # Filters questions for the user's gym.
        # Members only see their own questions, trainers and owners see all questions in the gym.
        qs = Question.objects.filter(gym__in=gyms).select_related('member', 'trainer', 'gym')
        if user.role == UserRole.MEMBER:
            qs = qs.filter(member=user)
        return qs

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")
        
        # Auto-resolve gym
        gym = gyms[0]
        trainer = serializer.validated_data.get('trainer')

        serializer.instance = QAService.create_question(
            member=user,
            trainer=trainer,
            gym=gym,
            title=serializer.validated_data.get('title'),
            question_text=serializer.validated_data.get('question')
        )

    # Custom action to post answers: POST /api/questions/{id}/answers/
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated, IsOwnerOrTrainer])
    def answers(self, request, pk=None):
        question = self.get_object()
        answer_text = request.data.get('answer')
        if not answer_text:
            return failure_response("Answer text is required.", status_code=status.HTTP_400_BAD_REQUEST)
        
        try:
            answer = QAService.create_answer(question, request.user, answer_text)
            serializer = AnswerSerializer(answer, context={'request': request})
            return success_response("Answer posted successfully.", data=serializer.data, status_code=status.HTTP_201_CREATED)
        except ValueError as e:
            return failure_response(str(e))


class GroupViewSet(viewsets.ModelViewSet):
    serializer_class = GroupSerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return Group.objects.filter(gym__in=gyms, is_active=True).select_related('gym', 'created_by')

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")
        
        # Verify Owner or Trainer role
        if user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            raise serializers.ValidationError("Only trainers and gym owners can create groups.")

        serializer.instance = GroupService.create_group(
            gym=gyms[0],
            group_name=serializer.validated_data.get('group_name'),
            description=serializer.validated_data.get('description'),
            group_type=serializer.validated_data.get('group_type', GroupType.PUBLIC),
            created_by=user
        )

    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        group = self.get_object()
        try:
            member = GroupService.join_group(group, request.user)
            serializer = GroupMemberSerializer(member, context={'request': request})
            return success_response("Joined group successfully.", data=serializer.data)
        except Exception as e:
            return failure_response(str(e))

    @action(detail=True, methods=['post'])
    def leave(self, request, pk=None):
        group = self.get_object()
        success = GroupService.leave_group(group, request.user)
        if success:
            return success_response("Left group successfully.")
        return failure_response("You are not a member of this group.")

    @action(detail=True, methods=['get', 'post'])
    def posts(self, request, pk=None):
        group = self.get_object()
        if request.method == 'GET':
            posts_qs = group.posts.filter(is_deleted=False).select_related('author').order_by('-created_at')
            page = self.paginate_queryset(posts_qs)
            if page is not None:
                serializer = GroupPostSerializer(page, many=True, context={'request': request})
                return self.get_paginated_response(serializer.data)
            
            serializer = GroupPostSerializer(posts_qs, many=True, context={'request': request})
            return success_response("Group feed posts retrieved.", data=serializer.data)

        elif request.method == 'POST':
            content = request.data.get('content')
            if not content:
                return failure_response("Content is required.", status_code=status.HTTP_400_BAD_REQUEST)
            
            try:
                post = GroupService.create_group_post(
                    group=group,
                    author=request.user,
                    content=content,
                    image=request.FILES.get('image')
                )
                serializer = GroupPostSerializer(post, context={'request': request})
                return success_response("Post created successfully.", data=serializer.data, status_code=status.HTTP_201_CREATED)
            except ValueError as e:
                return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)


class AnnouncementViewSet(viewsets.ModelViewSet):
    serializer_class = AnnouncementSerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return Announcement.objects.filter(gym__in=gyms).select_related('gym', 'created_by')

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")

        try:
            serializer.instance = AnnouncementService.create_announcement(
                gym=gyms[0],
                created_by=user,
                title=serializer.validated_data.get('title'),
                description=serializer.validated_data.get('description'),
                priority=serializer.validated_data.get('priority', AnnouncementPriority.MEDIUM)
            )
        except ValueError as e:
            raise serializers.ValidationError(str(e))


class ChatRoomViewSet(viewsets.GenericViewSet):
    serializer_class = ChatRoomSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # Return all rooms where the user is a participant
        room_ids = ChatParticipant.objects.filter(user=user).values_list('room_id', flat=True)
        return ChatRoom.objects.filter(id__in=room_ids).prefetch_related('participants', 'participants__user')

    def list(self, request):
        qs = self.get_queryset()
        serializer = self.get_serializer(qs, many=True)
        return success_response("Active DMs retrieved.", data=serializer.data)

    def create(self, request):
        target_user_id = request.data.get('user_id')
        if not target_user_id:
            return failure_response("user_id is required.", status_code=status.HTTP_400_BAD_REQUEST)
        
        try:
            target_user = User.objects.get(id=target_user_id, is_active=True)
        except (User.DoesNotExist, ValueError):
            return failure_response("Recipient user not found.", status_code=status.HTTP_404_NOT_FOUND)

        # Enforce gym isolation
        user_gyms = get_user_gyms(request.user)
        target_gyms = get_user_gyms(target_user)
        if not set(user_gyms).intersection(target_gyms):
            return failure_response("You can only chat with users in your gym.", status_code=status.HTTP_403_FORBIDDEN)

        room = ChatService.get_or_create_room(request.user, target_user)
        serializer = self.get_serializer(room)
        return success_response("Chat room created.", data=serializer.data, status_code=status.HTTP_201_CREATED)


class MessageView(APIView):
    permission_classes = [IsAuthenticated]
    pagination_class = StandardResultsSetPagination

    def get(self, request):
        room_id = request.query_params.get('room_id')
        if not room_id:
            return failure_response("room_id is required.")

        # Ensure user is a participant of the room
        if not ChatParticipant.objects.filter(room_id=room_id, user=request.user).exists():
            return failure_response("Unauthorized to view messages in this room.", status_code=status.HTTP_403_FORBIDDEN)

        # Mark messages as read
        ChatService.mark_messages_as_read(room_id, request.user)

        messages_qs = Message.objects.filter(room_id=room_id, is_deleted=False).select_related('sender').order_by('sent_at')
        
        # Pagination
        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(messages_qs, request)
        if page is not None:
            serializer = MessageSerializer(page, many=True, context={'request': request})
            return paginator.get_paginated_response(serializer.data)

        serializer = MessageSerializer(messages_qs, many=True, context={'request': request})
        return success_response("Message history retrieved.", data=serializer.data)


class ForumCategoryViewSet(viewsets.ModelViewSet):
    serializer_class = ForumCategorySerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return ForumCategory.objects.filter(gym__in=gyms)

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")
        
        serializer.instance = ForumService.create_category(
            gym=gyms[0],
            name=serializer.validated_data.get('name'),
            description=serializer.validated_data.get('description')
        )


class ForumTopicViewSet(viewsets.ModelViewSet):
    serializer_class = ForumTopicSerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return ForumTopic.objects.filter(category__gym__in=gyms).select_related('category', 'creator')

    def perform_create(self, serializer):
        category = serializer.validated_data.get('category')
        # Enforce category belongs to user's gym
        user_gyms = get_user_gyms(self.request.user)
        if category.gym not in user_gyms:
            raise serializers.ValidationError("Unauthorized category selection.")

        serializer.instance = ForumService.create_topic(
            category=category,
            creator=self.request.user,
            title=serializer.validated_data.get('title'),
            content=serializer.validated_data.get('content')
        )

    # Custom action to post replies: POST /api/forums/replies/
    @action(detail=True, methods=['post'])
    def replies(self, request, pk=None):
        topic = self.get_object()
        content = request.data.get('content')
        if not content:
            return failure_response("Content is required.")

        try:
            reply = ForumService.create_reply(topic, request.user, content)
            serializer = ForumReplySerializer(reply, context={'request': request})
            return success_response("Reply posted successfully.", data=serializer.data, status_code=status.HTTP_201_CREATED)
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['get'])
    def replies_list(self, request, pk=None):
        topic = self.get_object()
        replies_qs = topic.replies.select_related('author').order_by('created_at')
        page = self.paginate_queryset(replies_qs)
        if page is not None:
            serializer = ForumReplySerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        
        serializer = ForumReplySerializer(replies_qs, many=True, context={'request': request})
        return success_response("Replies retrieved.", data=serializer.data)


class EventViewSet(viewsets.ModelViewSet):
    serializer_class = EventSerializer
    permission_classes = [IsAuthenticated, IsGymParticipant]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        gyms = get_user_gyms(user)
        return Event.objects.filter(gym__in=gyms).select_related('gym', 'created_by')

    def perform_create(self, serializer):
        user = self.request.user
        gyms = get_user_gyms(user)
        if not gyms:
            raise serializers.ValidationError("User is not associated with any active gym.")
        
        if user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            raise serializers.ValidationError("Only gym owners and trainers can create events.")

        serializer.instance = EventService.create_event(
            gym=gyms[0],
            title=serializer.validated_data.get('title'),
            description=serializer.validated_data.get('description'),
            start_date=serializer.validated_data.get('start_date'),
            end_date=serializer.validated_data.get('end_date'),
            capacity=serializer.validated_data.get('capacity'),
            created_by=user
        )

    @action(detail=True, methods=['post'])
    def register(self, request, pk=None):
        event = self.get_object()
        try:
            registration = EventService.register_for_event(event, request.user)
            serializer = EventRegistrationSerializer(registration, context={'request': request})
            return success_response("Registered for event successfully.", data=serializer.data)
        except ValueError as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        event = self.get_object()
        success = EventService.cancel_event_registration(event, request.user)
        if success:
            return success_response("Cancelled event registration successfully.")
        return failure_response("You are not registered for this event.")


class ReportViewSet(viewsets.ModelViewSet):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        user = self.request.user
        if user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            # Members can only see their own filed reports
            return Report.objects.filter(reporter=user)

        # Owners and Trainers can list reports of users within their own gym
        gyms = get_user_gyms(user)
        reporter_emails = Member.objects.filter(gym__in=gyms, is_deleted=False).values_list('email', flat=True)
        return Report.objects.filter(reporter__email__in=reporter_emails).select_related('reporter')

    def perform_create(self, serializer):
        serializer.instance = ModerationService.create_report(
            reporter=self.request.user,
            content_type=serializer.validated_data.get('content_type'),
            content_id=serializer.validated_data.get('content_id'),
            reason=serializer.validated_data.get('reason')
        )

    def partial_update(self, request, pk=None):
        # Resolve report (restricted to Owners and Trainers)
        if request.user.role not in [UserRole.OWNER, UserRole.TRAINER]:
            return failure_response("Only moderators can resolve content reports.", status_code=status.HTTP_403_FORBIDDEN)

        report = self.get_object()
        action_taken = request.data.get('action_taken', 'RESOLVED') # HIDE, DELETE, RESOLVED
        
        try:
            resolved_report = ModerationService.resolve_report(report, request.user, action_taken)
            serializer = self.get_serializer(resolved_report)
            return success_response("Report resolved successfully.", data=serializer.data)
        except ValueError as e:
            return failure_response(str(e))
