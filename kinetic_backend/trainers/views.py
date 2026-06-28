from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied, NotFound, ValidationError
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from core.permissions import IsGymOwner
from core.responses import success_response, failure_response
from core.pagination import StandardResultsSetPagination
from gyms.models import Gym
from members.models import Member
from .models import Trainer, TrainerAssignment, TrainerAuditLog, AssignmentStatus
from .services import TrainerService, TrainerAssignmentService
from .serializers import (
    TrainerSerializer, TrainerCreateSerializer, TrainerUpdateSerializer,
    TrainerAssignmentSerializer, TrainerAssignmentCreateSerializer,
    TrainerAuditLogSerializer
)

class TrainerListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="List Trainers",
        manual_parameters=[
            openapi.Parameter('search', openapi.IN_QUERY, description="Search by name, email, employee id, or specialization", type=openapi.TYPE_STRING),
            openapi.Parameter('status', openapi.IN_QUERY, description="Filter by status (ACTIVE, INACTIVE, SUSPENDED)", type=openapi.TYPE_STRING),
            openapi.Parameter('gym', openapi.IN_QUERY, description="Filter by Gym UUID", type=openapi.TYPE_STRING),
            openapi.Parameter('experience', openapi.IN_QUERY, description="Minimum years of experience", type=openapi.TYPE_INTEGER),
            openapi.Parameter('ordering', openapi.IN_QUERY, description="Order by name, joining_date, experience, created_at (prefix with '-' for desc)", type=openapi.TYPE_STRING),
        ],
        responses={200: TrainerSerializer(many=True)}
    )
    def get(self, request):
        queryset = TrainerService.get_trainers_for_owner(request.user, request.query_params)
        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request)
        if page is not None:
            serializer = TrainerSerializer(page, many=True)
            return success_response(
                "Trainers retrieved successfully",
                data=paginator.get_paginated_response(serializer.data).data
            )
        
        serializer = TrainerSerializer(queryset, many=True)
        return success_response("Trainers retrieved successfully", data=serializer.data)

    @swagger_auto_schema(
        operation_summary="Create Trainer Account and Profile",
        request_body=TrainerCreateSerializer,
        responses={201: TrainerSerializer}
    )
    def post(self, request):
        serializer = TrainerCreateSerializer(data=request.data)
        if serializer.is_valid():
            try:
                trainer = TrainerService.create_trainer(request.user, serializer.validated_data)
                return success_response(
                    "Trainer created successfully",
                    data=TrainerSerializer(trainer).data,
                    status_code=status.HTTP_201_CREATED
                )
            except (ValidationError, PermissionDenied) as e:
                msg = str(e.detail[0]) if hasattr(e, 'detail') and isinstance(e.detail, list) else str(e)
                return failure_response(msg, status_code=status.HTTP_400_BAD_REQUEST)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class TrainerDetailView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    def get_object(self, pk, owner_user):
        try:
            trainer = Trainer.objects.get(id=pk, is_deleted=False)
        except (Trainer.DoesNotExist, ValueError):
            raise NotFound("Trainer not found.")

        # Cross-gym protection
        gyms = Gym.objects.filter(owner=owner_user, is_deleted=False)
        if trainer.gym not in gyms:
            raise PermissionDenied("You do not have permission to access this trainer profile.")
        return trainer

    @swagger_auto_schema(
        operation_summary="Get Trainer Details",
        responses={200: TrainerSerializer}
    )
    def get(self, request, pk):
        trainer = self.get_object(pk, request.user)
        return success_response("Trainer details retrieved", data=TrainerSerializer(trainer).data)

    @swagger_auto_schema(
        operation_summary="Update Trainer profile/user details",
        request_body=TrainerUpdateSerializer,
        responses={200: TrainerSerializer}
    )
    def patch(self, request, pk):
        trainer = self.get_object(pk, request.user)
        serializer = TrainerUpdateSerializer(data=request.data, partial=True)
        if serializer.is_valid():
            trainer = TrainerService.update_trainer(request.user, trainer, serializer.validated_data)
            return success_response("Trainer updated successfully", data=TrainerSerializer(trainer).data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    @swagger_auto_schema(
        operation_summary="Soft Delete Trainer",
        responses={200: openapi.Response("Trainer deleted successfully")}
    )
    def delete(self, request, pk):
        trainer = self.get_object(pk, request.user)
        TrainerService.delete_trainer(request.user, trainer)
        return success_response("Trainer deleted successfully")


class TrainerAssignmentListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_summary="List Trainer Assignments",
        manual_parameters=[
            openapi.Parameter('trainer_id', openapi.IN_QUERY, description="Filter by Trainer UUID", type=openapi.TYPE_STRING),
            openapi.Parameter('member_id', openapi.IN_QUERY, description="Filter by Member UUID", type=openapi.TYPE_STRING),
            openapi.Parameter('status', openapi.IN_QUERY, description="Filter by status (ACTIVE, COMPLETED, REMOVED)", type=openapi.TYPE_STRING),
        ],
        responses={200: TrainerAssignmentSerializer(many=True)}
    )
    def get(self, request):
        role = request.user.role
        queryset = TrainerAssignment.objects.all()

        if role == 'OWNER':
            gyms = Gym.objects.filter(owner=request.user, is_deleted=False)
            queryset = queryset.filter(trainer__gym__in=gyms)
        elif role == 'TRAINER':
            trainer = Trainer.objects.filter(user=request.user, is_deleted=False).first()
            if not trainer:
                queryset = TrainerAssignment.objects.none()
            else:
                queryset = queryset.filter(trainer=trainer)
        elif role == 'MEMBER':
            member = Member.objects.filter(email=request.user.email).first()
            if not member:
                queryset = TrainerAssignment.objects.none()
            else:
                queryset = queryset.filter(member=member)

        # Filters
        trainer_id = request.query_params.get('trainer_id')
        if trainer_id:
            queryset = queryset.filter(trainer_id=trainer_id)

        member_id = request.query_params.get('member_id')
        if member_id:
            queryset = queryset.filter(member_id=member_id)

        status_filter = request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        else:
            queryset = queryset.filter(status=AssignmentStatus.ACTIVE)

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request)
        if page is not None:
            serializer = TrainerAssignmentSerializer(page, many=True)
            return success_response(
                "Assignments retrieved successfully",
                data=paginator.get_paginated_response(serializer.data).data
            )

        serializer = TrainerAssignmentSerializer(queryset, many=True)
        return success_response("Assignments retrieved successfully", data=serializer.data)

    @swagger_auto_schema(
        operation_summary="Assign Trainer to Member",
        request_body=TrainerAssignmentCreateSerializer,
        responses={201: TrainerAssignmentSerializer}
    )
    def post(self, request):
        if request.user.role != 'OWNER':
            return failure_response("Only Gym Owners can assign trainers.", status_code=status.HTTP_403_FORBIDDEN)

        serializer = TrainerAssignmentCreateSerializer(data=request.data)
        if serializer.is_valid():
            try:
                assignment = TrainerAssignmentService.assign_trainer(
                    owner_user=request.user,
                    trainer_id=serializer.validated_data['trainer_id'],
                    member_id=serializer.validated_data['member_id'],
                    notes=serializer.validated_data.get('notes', '')
                )
                return success_response(
                    "Trainer assigned successfully",
                    data=TrainerAssignmentSerializer(assignment).data,
                    status_code=status.HTTP_201_CREATED
                )
            except (ValidationError, NotFound) as e:
                msg = str(e.detail[0]) if hasattr(e, 'detail') and isinstance(e.detail, list) else str(e)
                return failure_response(msg, status_code=status.HTTP_400_BAD_REQUEST)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class TrainerAssignmentDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get_object(self, pk, user):
        try:
            assignment = TrainerAssignment.objects.get(id=pk)
        except (TrainerAssignment.DoesNotExist, ValueError):
            raise NotFound("Assignment not found.")

        # Access check
        if user.role == 'OWNER':
            gyms = Gym.objects.filter(owner=user, is_deleted=False)
            if assignment.trainer.gym not in gyms:
                raise PermissionDenied("Unauthorized access to this assignment.")
        elif user.role == 'TRAINER':
            if assignment.trainer.user != user:
                raise PermissionDenied("Unauthorized access to this assignment.")
        elif user.role == 'MEMBER':
            if assignment.member.email != user.email:
                raise PermissionDenied("Unauthorized access to this assignment.")
        
        return assignment

    @swagger_auto_schema(
        operation_summary="Get Assignment Details",
        responses={200: TrainerAssignmentSerializer}
    )
    def get(self, request, pk):
        assignment = self.get_object(pk, request.user)
        return success_response("Assignment details retrieved", data=TrainerAssignmentSerializer(assignment).data)

    @swagger_auto_schema(
        operation_summary="Update Assignment (Notes/Status)",
        request_body=TrainerAssignmentSerializer,
        responses={200: TrainerAssignmentSerializer}
    )
    def patch(self, request, pk):
        if request.user.role != 'OWNER':
            return failure_response("Only Gym Owners can update assignments.", status_code=status.HTTP_403_FORBIDDEN)
            
        assignment = self.get_object(pk, request.user)
        assignment = TrainerAssignmentService.update_assignment(request.user, assignment, request.data)
        return success_response("Assignment updated successfully", data=TrainerAssignmentSerializer(assignment).data)

    @swagger_auto_schema(
        operation_summary="Remove Assignment (Soft Delete)",
        responses={200: openapi.Response("Assignment removed successfully")}
    )
    def delete(self, request, pk):
        if request.user.role != 'OWNER':
            return failure_response("Only Gym Owners can remove assignments.", status_code=status.HTTP_403_FORBIDDEN)

        assignment = self.get_object(pk, request.user)
        TrainerAssignmentService.remove_assignment(request.user, assignment)
        return success_response("Assignment removed successfully")


class TrainerDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_summary="Get Trainer Dashboard Stats",
        responses={200: openapi.Response("Dashboard stats object")}
    )
    def get(self, request):
        if request.user.role != 'TRAINER':
            return failure_response("Access denied. Trainer role required.", status_code=status.HTTP_403_FORBIDDEN)
        
        stats = TrainerService.get_trainer_dashboard_stats(request.user)
        return success_response("Trainer dashboard statistics retrieved", data=stats)


class TrainerMembersView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_summary="Get Assigned Members list for Trainer",
        manual_parameters=[
            openapi.Parameter('search', openapi.IN_QUERY, description="Search by member name", type=openapi.TYPE_STRING)
        ],
        responses={200: openapi.Response("List of assigned member summaries")}
    )
    def get(self, request, pk):
        # Access validation
        try:
            trainer = Trainer.objects.get(id=pk, is_deleted=False)
        except (Trainer.DoesNotExist, ValueError):
            return failure_response("Trainer not found.", status_code=status.HTTP_404_NOT_FOUND)

        if request.user.role == 'OWNER':
            gyms = Gym.objects.filter(owner=request.user, is_deleted=False)
            if trainer.gym not in gyms:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'TRAINER':
            if trainer.user != request.user:
                return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)
        else:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)

        queryset = TrainerService.get_trainer_members(trainer, request.query_params)
        
        # Paginate
        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request)
        
        def serialize_member_data(members):
            res_data = []
            for m in members:
                # Use prefetched active memberships if present
                active_mem = None
                if hasattr(m, 'active_memberships_prefetched') and m.active_memberships_prefetched:
                    active_mem = m.active_memberships_prefetched[0]
                else:
                    active_mem = m.memberships.filter(status='ACTIVE').first()

                mem_status = active_mem.status if active_mem else 'NO_ACTIVE_PLAN'
                plan_name = active_mem.membership_plan.plan_name if active_mem else None
                
                # Fetch pre-computed counts from annotation
                total_att = getattr(m, 'total_attendance_count', 0)
                present_att = getattr(m, 'present_attendance_count', 0)
                att_pct = round((present_att / total_att) * 100, 2) if total_att > 0 else 0.0

                res_data.append({
                    "id": str(m.id),
                    "full_name": m.full_name,
                    "email": m.email,
                    "phone_number": m.phone_number,
                    "membership_status": mem_status,
                    "plan_name": plan_name,
                    "attendance_percentage": att_pct,
                    "recent_activity": "Checked in" if total_att > 0 else "No check-ins logged"
                })
            return res_data

        if page is not None:
            serialized = serialize_member_data(page)
            return success_response(
                "Trainer members retrieved successfully",
                data=paginator.get_paginated_response(serialized).data
            )
        
        serialized = serialize_member_data(queryset)
        return success_response("Trainer members retrieved successfully", data=serialized)


class OwnerTrainerAnalyticsView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Get Trainer Analytics for Gym Owners",
        responses={200: openapi.Response("Trainer Analytics Summary")}
    )
    def get(self, request):
        analytics = TrainerService.get_owner_trainer_analytics(request.user)
        return success_response("Owner trainer analytics retrieved", data=analytics)


class TrainerReportsView(APIView):
    permission_classes = [IsAuthenticated, IsGymOwner]

    @swagger_auto_schema(
        operation_summary="Generate Trainer Reports (Performance, Activity, Utilization)",
        manual_parameters=[
            openapi.Parameter('type', openapi.IN_QUERY, description="Report Type: PERFORMANCE, ACTIVITY, UTILIZATION", type=openapi.TYPE_STRING, required=True)
        ],
        responses={200: openapi.Response("Report payload ready for export")}
    )
    def get(self, request):
        report_type = request.query_params.get('type', 'PERFORMANCE').upper()
        gyms = Gym.objects.filter(owner=request.user, is_deleted=False)
        trainers = Trainer.objects.filter(gym__in=gyms, is_deleted=False)

        report_data = []

        if report_type == 'PERFORMANCE':
            # Report containing trainers, active clients count, years of experience
            for t in trainers:
                active_clients = t.assignments.filter(status=AssignmentStatus.ACTIVE).count()
                report_data.append({
                    "employee_id": t.employee_id,
                    "name": t.user.full_name,
                    "specialization": t.specialization,
                    "experience_years": t.experience_years,
                    "active_clients": active_clients,
                    "salary": str(t.salary),
                    "status": t.status
                })
        elif report_type == 'UTILIZATION':
            # Utilization percentage calculation: assigned clients compared to avg
            total_active_members = Member.objects.filter(gym__in=gyms, status='ACTIVE', is_deleted=False).count()
            for t in trainers:
                active_clients = t.assignments.filter(status=AssignmentStatus.ACTIVE, member__status='ACTIVE').count()
                pct = round((active_clients / total_active_members) * 100, 2) if total_active_members > 0 else 0.0
                report_data.append({
                    "employee_id": t.employee_id,
                    "name": t.user.full_name,
                    "assigned_active_clients": active_clients,
                    "utilization_percentage": pct
                })
        else: # ACTIVITY (audit logs relating to trainer changes)
            logs = TrainerAuditLog.objects.filter(user__in=request.user.gyms.all() if hasattr(request.user, 'gyms') else User.objects.filter(id=request.user.id))
            # Just return latest 50 logs for activity
            for log in logs[:50]:
                report_data.append({
                    "action": log.action,
                    "timestamp": log.timestamp,
                    "user": log.user.email if log.user else "System"
                })

        return success_response(f"Trainer {report_type} report generated", data={
            "report_type": report_type,
            "generated_at": date.today(),
            "records": report_data
        })
