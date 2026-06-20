"""
AI Buddy Views
==============
REST API endpoints for the AI Gym Buddy platform.
All member endpoints require gym-scoped member resolution.
"""
import logging
import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q

from core.responses import success_response, failure_response
from accounts.models import UserRole
from members.models import Member
from gyms.models import Gym

from .models import (
    KnowledgeArticle, KnowledgeCategory,
    AIConversation, AIMessage, MessageRole,
)
from .serializers import (
    KnowledgeCategorySerializer, KnowledgeArticleListSerializer,
    KnowledgeArticleDetailSerializer, AIConversationSerializer,
    AIConversationDetailSerializer, AIChatRequestSerializer,
    ExerciseAlternativeRequestSerializer, AIMessageSerializer,
)
from .services import (
    KnowledgeBaseSearchService, AIResponseEngine,
    ExerciseAlternativeEngine, BeginnerCoachService,
    ProgressAnalysisService, DashboardTipService,
)
from .permissions import IsMember, IsMemberOrTrainer, IsAnyGymRole

logger = logging.getLogger(__name__)


def _resolve_member_and_gym(user):
    """
    Resolve the Member record and Gym for the authenticated user.
    Returns (member, gym) or (None, None) if not found.
    """
    if user.role == UserRole.MEMBER:
        member = Member.objects.filter(
            email=user.email, is_deleted=False
        ).select_related('gym').first()
        if not member:
            return None, None
        return member, member.gym
    return None, None


class KnowledgeCategoryListView(APIView):
    """GET /api/ai/knowledge/categories/ — List all active KB categories."""
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        qs = KnowledgeCategory.objects.filter(is_active=True)
        if gym:
            qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qs = qs.filter(gym__isnull=True)

        serializer = KnowledgeCategorySerializer(qs, many=True)
        return success_response('Knowledge categories retrieved', data=serializer.data)


class KnowledgeSearchView(APIView):
    """GET /api/ai/knowledge/search/?q=&category=&type=&difficulty= — Search KB articles."""
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        category_slug = request.query_params.get('category', '').strip()
        article_type = request.query_params.get('type', '').strip().upper() or None
        difficulty = request.query_params.get('difficulty', '').strip().upper() or None

        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        if not query and not category_slug:
            # Return featured articles
            qs = KnowledgeArticle.objects.filter(is_active=True)
            if gym:
                qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
            else:
                qs = qs.filter(gym__isnull=True)
            if article_type:
                qs = qs.filter(article_type=article_type)
            if difficulty:
                qs = qs.filter(difficulty=difficulty)
            qs = qs.order_by('-is_featured', '-view_count')[:20]
        elif category_slug and not query:
            qs = KnowledgeArticle.objects.filter(
                is_active=True, category__slug=category_slug
            )
            if gym:
                qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
            else:
                qs = qs.filter(gym__isnull=True)
        else:
            search_svc = KnowledgeBaseSearchService()
            qs = search_svc.search(
                query or category_slug, gym=gym,
                article_type=article_type, difficulty=difficulty, limit=20
            )

        serializer = KnowledgeArticleListSerializer(qs, many=True)
        return success_response('Search results retrieved', data={'results': serializer.data, 'count': len(serializer.data)})


class KnowledgeArticleDetailView(APIView):
    """GET /api/ai/knowledge/articles/<id>/ — Get full article detail."""
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request, article_id):
        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        qs = KnowledgeArticle.objects.filter(id=article_id, is_active=True)
        if gym:
            qs = qs.filter(Q(gym__isnull=True) | Q(gym=gym))
        else:
            qs = qs.filter(gym__isnull=True)

        article = qs.select_related('category', 'exercise_data').first()
        if not article:
            return failure_response('Article not found', status_code=status.HTTP_404_NOT_FOUND)

        # Increment view count
        KnowledgeArticle.objects.filter(id=article_id).update(view_count=article.view_count + 1)

        serializer = KnowledgeArticleDetailSerializer(article)
        return success_response('Article retrieved', data=serializer.data)


class AIChatView(APIView):
    """POST /api/ai/chat/ — Send a message to the AI Gym Buddy."""
    permission_classes = [IsAuthenticated, IsMember]

    def post(self, request):
        serializer = AIChatRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid request', errors=serializer.errors)

        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        message = serializer.validated_data['message']
        conversation_id = serializer.validated_data.get('conversation_id')

        # Resolve or create conversation
        conversation = None
        if conversation_id:
            conversation = AIConversation.objects.filter(
                id=conversation_id, member=member, gym=gym
            ).first()

        if not conversation:
            conversation = AIConversation.objects.create(
                gym=gym,
                member=member,
                title=message[:80],
            )

        # Save user message
        AIMessage.objects.create(
            conversation=conversation,
            role=MessageRole.USER,
            content=message,
        )

        # Generate AI response
        engine = AIResponseEngine(gym=gym, member=member)
        result = engine.process_message(message, conversation)

        # Save AI response
        ai_msg = AIMessage.objects.create(
            conversation=conversation,
            role=MessageRole.ASSISTANT,
            content=result['content'],
            sources=json.dumps(result['sources']),
            response_source=result['response_source'],
            context_data=json.dumps(result.get('context_used', {}))[:5000],
        )

        # Update conversation timestamp
        conversation.save(update_fields=['updated_at'])

        return success_response('AI response generated', data={
            'conversation_id': str(conversation.id),
            'message': AIMessageSerializer(ai_msg).data,
            'detected_intent': result['detected_intent'],
        })


class AIConversationListView(APIView):
    """GET /api/ai/conversations/ — List member's conversation history."""
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        conversations = AIConversation.objects.filter(
            member=member, gym=gym
        ).prefetch_related('messages').order_by('-updated_at')[:30]

        serializer = AIConversationSerializer(conversations, many=True)
        return success_response('Conversations retrieved', data=serializer.data)


class AIConversationDetailView(APIView):
    """GET /api/ai/conversations/<id>/messages/ — Get full conversation thread."""
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request, conversation_id):
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        conversation = get_object_or_404(
            AIConversation, id=conversation_id, member=member, gym=gym
        )
        serializer = AIConversationDetailSerializer(conversation)
        return success_response('Conversation messages retrieved', data=serializer.data)


class ExerciseAlternativesView(APIView):
    """POST /api/ai/exercise-alternatives/ — Get alternatives for a given exercise."""
    permission_classes = [IsAuthenticated, IsMemberOrTrainer]

    def post(self, request):
        serializer = ExerciseAlternativeRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid request', errors=serializer.errors)

        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        exercise_name = serializer.validated_data['exercise_name']
        constraint = serializer.validated_data.get('constraint', '')

        result = ExerciseAlternativeEngine.get_alternatives(
            exercise_name,
            constraint=constraint or None,
            gym=gym,
        )
        return success_response('Exercise alternatives retrieved', data=result)


class BeginnerPlanView(APIView):
    """GET /api/ai/beginner-plan/ — Get a 7-day beginner plan."""
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        plan = BeginnerCoachService.generate_beginner_plan(member=member, gym=gym)
        return success_response('Beginner plan generated', data=plan)


class ProgressInsightsView(APIView):
    """GET /api/ai/progress-insights/ — Get AI-generated progress analysis."""
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        insights = ProgressAnalysisService.generate_insights(member=member)
        return success_response('Progress insights generated', data=insights)


class DashboardTipView(APIView):
    """GET /api/ai/dashboard-tip/ — Get today's motivational tip."""
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        tip = DashboardTipService.get_daily_tip(gym=gym)
        return success_response('Daily tip retrieved', data=tip)
