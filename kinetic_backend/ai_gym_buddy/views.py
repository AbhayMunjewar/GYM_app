import logging
import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q, Count, Avg

from core.responses import success_response, failure_response
from accounts.models import UserRole
from members.models import Member
from gyms.models import Gym

from .models import (
    KnowledgeArticle, KnowledgeCategory, KnowledgeQA,
    AIConversation, AIMessage, MessageRole, AIInteractionLog,
)
from .serializers import (
    KnowledgeCategorySerializer, KnowledgeArticleListSerializer,
    KnowledgeArticleDetailSerializer, AIConversationSerializer,
    AIConversationDetailSerializer, AIChatRequestSerializer,
    ExerciseAlternativeRequestSerializer, AIMessageSerializer,
    AISearchRequestSerializer, AIProgressAnalysisRequestSerializer,
    AIGoalCoachingRequestSerializer, AIBeginnerCoachRequestSerializer,
)
from .search_engine import KnowledgeBaseSearchEngine
from .context_engine import AIContextEngine
from .recommendation_engine import (
    ExerciseExplanationEngine, ExerciseAlternativeEngine,
    BeginnerCoachEngine, ProgressAnalysisEngine, GoalCoachingEngine
)
from .services import AIResponseEngine, DashboardTipService
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
    """
    GET /api/ai/knowledge/search/ — Legacy GET search.
    POST /api/ai/search/ — New search endpoint.
    """
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        category_slug = request.query_params.get('category', '').strip()
        difficulty = request.query_params.get('difficulty', '').strip() or None

        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        results = KnowledgeBaseSearchEngine.search(
            query=query, gym=gym, category_slug=category_slug,
            difficulty=difficulty, limit=20
        )
        return success_response('Search results retrieved', data={'results': results, 'count': len(results)})

    def post(self, request):
        serializer = AISearchRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid search body', errors=serializer.errors)

        query = serializer.validated_data['query']
        category_slug = serializer.validated_data.get('category')
        difficulty = serializer.validated_data.get('difficulty') or None

        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        results = KnowledgeBaseSearchEngine.search(
            query=query, gym=gym, category_slug=category_slug,
            difficulty=difficulty, limit=20
        )
        return success_response('Search results retrieved', data={'results': results, 'count': len(results)})


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
    """POST /api/ai/chat/ — Send a message to the AI Gym Buddy. Only MEMBER."""
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
    """
    GET /api/ai/conversations/<id>/ — Get conversation details.
    GET /api/ai/conversations/<id>/messages/ — Get full conversation thread.
    """
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

        result = ExerciseAlternativeEngine.suggest_alternatives(
            exercise_name,
            constraint=constraint or None,
            gym=gym,
        )
        return success_response('Exercise alternatives retrieved', data=result)


class BeginnerPlanView(APIView):
    """
    GET /api/ai/beginner-plan/ — Get a 7-day beginner plan.
    POST /api/ai/beginner-coach/ — Beginner coach suggestions based on goals & fitness level.
    """
    permission_classes = [IsAuthenticated, IsMember]

    def get(self, request):
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        plan = BeginnerCoachService.generate_beginner_plan(member=member, gym=gym)
        return success_response('Beginner plan generated', data=plan)

    def post(self, request):
        serializer = AIBeginnerCoachRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid request body', errors=serializer.errors)

        goal = serializer.validated_data['goal']
        level = serializer.validated_data.get('fitness_level', 'BEGINNER')
        rate = serializer.validated_data.get('attendance_rate', 100.0)

        plan = BeginnerCoachEngine.generate_coach_plan(goal=goal, fitness_level=level, attendance_rate=rate)
        return success_response('Beginner plan generated', data=plan)


class AIProgressAnalysisView(APIView):
    """
    GET /api/ai/progress-insights/ — Legacy GET.
    POST /api/ai/progress-analysis/ — Strict RBAC. Calculates weight trends and insights.
    """
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        # Legacy GET endpoint for Member only
        if request.user.role != UserRole.MEMBER:
            return failure_response('Only members can query insights directly without a body', status_code=status.HTTP_403_FORBIDDEN)
        
        member, gym = _resolve_member_and_gym(request.user)
        if not member:
            return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)

        context = AIContextEngine.get_member_context(member)
        analysis = ProgressAnalysisEngine.analyze(context)
        return success_response('Progress analysis retrieved', data=analysis)

    def post(self, request):
        serializer = AIProgressAnalysisRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid request payload', errors=serializer.errors)

        user_role = request.user.role
        target_member_id = serializer.validated_data.get('member_id')

        # RBAC checks
        if user_role == UserRole.MEMBER:
            # Members can only view their own
            member, gym = _resolve_member_and_gym(request.user)
            if not member:
                return failure_response('Member profile not found', status_code=status.HTTP_404_NOT_FOUND)
        elif user_role in [UserRole.TRAINER, UserRole.OWNER]:
            if not target_member_id:
                return failure_response('Trainers and Owners must specify a member_id', status_code=status.HTTP_400_BAD_REQUEST)
            # Find and verify scoping
            member = get_object_or_404(Member, id=target_member_id, is_deleted=False)
            # Verify owner or trainer belongs to same gym as member
            if request.user.role == UserRole.TRAINER:
                # Trainers must belong to same gym
                trainer_profile = getattr(request.user, 'trainer_profile', None)
                if not trainer_profile or trainer_profile.gym != member.gym:
                    return failure_response('Access Denied: Cross-tenant gym boundary violated', status_code=status.HTTP_403_FORBIDDEN)
            elif request.user.role == UserRole.OWNER:
                # Owners must own the gym
                gyms = Gym.objects.filter(owner=request.user)
                if not gyms.filter(id=member.gym.id).exists():
                    return failure_response('Access Denied: Gym ownership not verified', status_code=status.HTTP_403_FORBIDDEN)
        else:
            return failure_response('Unauthorized role', status_code=status.HTTP_403_FORBIDDEN)

        context = AIContextEngine.get_member_context(member)
        analysis = ProgressAnalysisEngine.analyze(context)
        return success_response('Progress analysis completed', data=analysis)


class AIGoalCoachingView(APIView):
    """POST /api/ai/goal-coaching/ — Member-only goal coaching."""
    permission_classes = [IsAuthenticated, IsMember]

    def post(self, request):
        serializer = AIGoalCoachingRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return failure_response('Invalid payload', errors=serializer.errors)

        goal = serializer.validated_data['goal']
        progress_pct = serializer.validated_data.get('progress_pct', 0.0)

        coaching = GoalCoachingEngine.generate_coaching(goal=goal, progress_pct=progress_pct)
        return success_response('Goal coaching insights generated', data=coaching)


class DashboardTipView(APIView):
    """GET /api/ai/dashboard-tip/ — Get today's motivational tip."""
    permission_classes = [IsAuthenticated, IsAnyGymRole]

    def get(self, request):
        gym = None
        if request.user.role == UserRole.MEMBER:
            member, gym = _resolve_member_and_gym(request.user)

        tip = DashboardTipService.get_daily_tip(gym=gym)
        return success_response('Daily tip retrieved', data=tip)


class AIAnalyticsView(APIView):
    """GET /api/ai/analytics/ — AI Usage & Search performance analytics for Gym Owners."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != UserRole.OWNER:
            return failure_response('Access Denied: Only owners can check analytics.', status_code=status.HTTP_403_FORBIDDEN)

        gyms = Gym.objects.filter(owner=request.user)
        if not gyms.exists():
            return failure_response('No gym found for the owner', status_code=status.HTTP_404_NOT_FOUND)
        
        gym = gyms.first()

        # Gather interaction telemetry
        logs = AIInteractionLog.objects.filter(gym=gym)
        total_queries = logs.count()

        most_asked = logs.values('query').annotate(count=Count('query')).order_by('-count')[:5]
        popular_intents = logs.values('detected_intent').annotate(count=Count('detected_intent')).order_by('-count')[:5]
        avg_latency = logs.aggregate(avg=Avg('latency_ms'))['avg'] or 0.0

        # Search success rate (Response sources from KB vs Template defaults)
        kb_source_count = logs.filter(response_source='KB').count()
        success_rate = (kb_source_count / total_queries * 100.0) if total_queries > 0 else 100.0

        analytics_data = {
            'total_interactions': total_queries,
            'avg_latency_ms': round(avg_latency, 1),
            'kb_search_success_rate': f"{round(success_rate, 1)}%",
            'popular_questions': [{'query': q['query'], 'count': q['count']} for q in most_asked],
            'popular_categories_and_intents': [{'intent': pi['detected_intent'], 'count': pi['count']} for pi in popular_intents]
        }

        return success_response('AI analytics retrieved', data=analytics_data)
