from rest_framework import viewsets, status
from rest_framework.decorators import action
from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from django.db.models import Q
from .models import MembershipPlan, Membership
from .serializers import MembershipPlanSerializer, MembershipSerializer
from .services import MembershipService
from core.permissions import IsGymOwner
from gyms.models import Gym

class MembershipPlanViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipPlanSerializer
    permission_classes = [IsGymOwner]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        queryset = MembershipPlan.objects.filter(
            gym__owner=self.request.user, 
            is_deleted=False
        )

        # Basic filtering
        is_active = self.request.query_params.get('is_active')
        if is_active is not None:
            if is_active.lower() == 'true':
                queryset = queryset.filter(is_active=True)
            elif is_active.lower() == 'false':
                queryset = queryset.filter(is_active=False)

        # Basic search
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(plan_name__icontains=search)

        return queryset.order_by('-created_at')

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.soft_delete()
        return success_response("Membership plan deleted successfully.", status_code=status.HTTP_200_OK)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            self.perform_create(serializer)
            return success_response("Membership plan created.", data=serializer.data, status_code=status.HTTP_201_CREATED)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        if serializer.is_valid():
            self.perform_update(serializer)
            return success_response("Membership plan updated.", data=serializer.data, status_code=status.HTTP_200_OK)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return success_response("Plans retrieved successfully", data=self.get_paginated_response(serializer.data).data)
        serializer = self.get_serializer(queryset, many=True)
        return success_response("Plans retrieved successfully", data=serializer.data)

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return success_response("Plan retrieved successfully", data=serializer.data)

class MembershipViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipSerializer
    permission_classes = [IsGymOwner]
    pagination_class = StandardResultsSetPagination

    def get_queryset(self):
        queryset = Membership.objects.filter(
            member__gym__owner=self.request.user,
            member__is_deleted=False
        )

        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)

        # Filter by plan
        plan_filter = self.request.query_params.get('plan_id')
        if plan_filter:
            queryset = queryset.filter(membership_plan_id=plan_filter)

        # Search by member name or email
        search = self.request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(member__full_name__icontains=search) | 
                Q(member__email__icontains=search)
            )

        return queryset.order_by('-created_at')

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
             return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)
        
        member_id = request.data.get('member_id') or request.data.get('member')
        plan_id = request.data.get('membership_plan_id') or request.data.get('membership_plan')
        notes = request.data.get('notes', '')

        try:
            membership = MembershipService.assign_membership(
                member_id=member_id,
                plan_id=plan_id,
                notes=notes
            )
            response_serializer = self.get_serializer(membership)
            return success_response("Membership assigned.", data=response_serializer.data, status_code=status.HTTP_201_CREATED)
        except Exception as e:
            return failure_response(str(e), status_code=status.HTTP_400_BAD_REQUEST)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return success_response("Memberships retrieved successfully", data=self.get_paginated_response(serializer.data).data)
        serializer = self.get_serializer(queryset, many=True)
        return success_response("Memberships retrieved successfully", data=serializer.data)

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return success_response("Membership retrieved successfully", data=serializer.data)
        
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        if serializer.is_valid():
            self.perform_update(serializer)
            return success_response("Membership updated.", data=serializer.data, status_code=status.HTTP_200_OK)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        instance.delete()
        return success_response("Membership deleted successfully.", status_code=status.HTTP_200_OK)

    @action(detail=False, methods=['get'], url_path='dashboard-stats')
    def dashboard_stats(self, request):
        gym_id = request.query_params.get('gym_id')
        if not gym_id:
            gym = Gym.objects.filter(owner=request.user, is_deleted=False).first()
            if not gym:
                return failure_response("No active gym found for owner.")
            gym_id = gym.id
        else:
            try:
                gym = Gym.objects.get(id=gym_id, owner=request.user)
            except Gym.DoesNotExist:
                 return failure_response("Gym not found or you don't have access.", status_code=status.HTTP_404_NOT_FOUND)

        stats = MembershipService.get_dashboard_stats(gym_id)
        return success_response("Stats retrieved", data=stats, status_code=status.HTTP_200_OK)
