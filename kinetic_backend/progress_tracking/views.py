from rest_framework import status
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q
from datetime import date

from core.responses import success_response, failure_response
from accounts.models import UserRole
from trainers.models import Trainer
from members.models import Member
from gyms.models import Gym

from .models import ProgressMeasurement, ProgressPhoto, FitnessGoal, ProgressMilestone, GoalStatus, GoalType
from .serializers import (
    ProgressMeasurementSerializer, ProgressPhotoSerializer,
    FitnessGoalSerializer, ProgressMilestoneSerializer
)
from .services import (
    ProgressTrackingService, GoalTrackingService,
    MilestoneDetectionService, AnalyticsEngine, ProgressComparisonService
)
from .permissions import IsProgressOwnerOrTrainer

class StandardResultsSetPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100


class ProgressMeasurementListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def get(self, request):
        role = request.user.role
        queryset = ProgressMeasurement.objects.all()

        # Scoping based on Role
        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            queryset = queryset.filter(member=member)
        elif role == UserRole.TRAINER:
            trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
            queryset = queryset.filter(member__gym=trainer.gym)
        elif role == UserRole.OWNER:
            queryset = queryset.filter(member__gym__owner=request.user)

        # Filters
        member_id = request.query_params.get('member_id')
        if member_id:
            # Cross-gym safety validation for Trainer/Owner
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            elif role == UserRole.OWNER:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)
            else:
                member = get_object_or_404(Member, id=member_id, email=request.user.email)
            queryset = queryset.filter(member=member)

        # Date range filtering
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        if start_date:
            queryset = queryset.filter(recorded_date__gte=start_date)
        if end_date:
            queryset = queryset.filter(recorded_date__lte=end_date)

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = ProgressMeasurementSerializer(page, many=True)
            return success_response(
                "Measurements list retrieved",
                data={
                    "count": paginator.page.paginator.count,
                    "next": paginator.get_next_link(),
                    "previous": paginator.get_previous_link(),
                    "results": serializer.data
                }
            )

        serializer = ProgressMeasurementSerializer(queryset, many=True)
        return success_response("Measurements list retrieved", data=serializer.data)

    def post(self, request):
        role = request.user.role
        data = request.data.copy()

        # Resolve Member Context
        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            data['member'] = member.id
            trainer_id = None
        else:
            member_id = data.get('member')
            if not member_id:
                return failure_response("Member ID required.", status_code=status.HTTP_400_BAD_REQUEST)
                
            # Cross-gym safety check
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
                trainer_id = trainer.id
            else: # Owner
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)
                trainer_id = data.get('trainer')

        serializer = ProgressMeasurementSerializer(data=data)
        if serializer.is_valid():
            measurement = ProgressTrackingService.create_measurement(
                member_id=member.id,
                trainer_id=trainer_id,
                validated_data=serializer.validated_data
            )
            return success_response(
                "Measurement recorded successfully",
                data=ProgressMeasurementSerializer(measurement).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class ProgressMeasurementDetailView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def get(self, request, id):
        measurement = get_object_or_404(ProgressMeasurement, id=id)
        self.check_object_permissions(request, measurement)
        serializer = ProgressMeasurementSerializer(measurement)
        return success_response("Measurement details retrieved", data=serializer.data)

    def patch(self, request, id):
        measurement = get_object_or_404(ProgressMeasurement, id=id)
        self.check_object_permissions(request, measurement)
        
        serializer = ProgressMeasurementSerializer(measurement, data=request.data, partial=True)
        if serializer.is_valid():
            updated = ProgressTrackingService.update_measurement(
                measurement_id=measurement.id,
                validated_data=serializer.validated_data
            )
            return success_response("Measurement updated successfully", data=ProgressMeasurementSerializer(updated).data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        measurement = get_object_or_404(ProgressMeasurement, id=id)
        self.check_object_permissions(request, measurement)
        
        member = measurement.member
        measurement.delete()
        
        # Trigger recalculations after deletion
        GoalTrackingService.update_goals_for_member(member)
        MilestoneDetectionService.detect_milestones(member)
        
        return success_response("Measurement record deleted successfully")


class ProgressPhotoListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def get(self, request):
        role = request.user.role
        queryset = ProgressPhoto.objects.all()

        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            queryset = queryset.filter(member=member)
        elif role == UserRole.TRAINER:
            trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
            queryset = queryset.filter(member__gym=trainer.gym)
        elif role == UserRole.OWNER:
            queryset = queryset.filter(member__gym__owner=request.user)

        member_id = request.query_params.get('member_id')
        if member_id:
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            elif role == UserRole.OWNER:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)
            else:
                member = get_object_or_404(Member, id=member_id, email=request.user.email)
            queryset = queryset.filter(member=member)

        photo_type = request.query_params.get('photo_type')
        if photo_type:
            queryset = queryset.filter(photo_type=photo_type.upper())

        serializer = ProgressPhotoSerializer(queryset, many=True)
        return success_response("Progress photos list retrieved", data=serializer.data)

    def post(self, request):
        role = request.user.role
        data = request.data.copy()

        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            data['member'] = member.id
        else:
            member_id = data.get('member')
            if not member_id:
                return failure_response("Member ID required.", status_code=status.HTTP_400_BAD_REQUEST)
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            else:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)

        serializer = ProgressPhotoSerializer(data=data)
        if serializer.is_valid():
            photo = serializer.save(uploaded_by=request.user)
            return success_response(
                "Progress photo uploaded successfully",
                data=ProgressPhotoSerializer(photo).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class ProgressPhotoDetailView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def get(self, request, id):
        photo = get_object_or_404(ProgressPhoto, id=id)
        self.check_object_permissions(request, photo)
        serializer = ProgressPhotoSerializer(photo)
        return success_response("Progress photo details retrieved", data=serializer.data)

    def delete(self, request, id):
        photo = get_object_or_404(ProgressPhoto, id=id)
        self.check_object_permissions(request, photo)
        photo.delete()
        return success_response("Progress photo deleted successfully")


class FitnessGoalListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def get(self, request):
        role = request.user.role
        queryset = FitnessGoal.objects.all()

        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            queryset = queryset.filter(member=member)
        elif role == UserRole.TRAINER:
            trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
            queryset = queryset.filter(member__gym=trainer.gym)
        elif role == UserRole.OWNER:
            queryset = queryset.filter(member__gym__owner=request.user)

        member_id = request.query_params.get('member_id')
        if member_id:
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            elif role == UserRole.OWNER:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)
            else:
                member = get_object_or_404(Member, id=member_id, email=request.user.email)
            queryset = queryset.filter(member=member)

        goal_type = request.query_params.get('goal_type')
        if goal_type:
            queryset = queryset.filter(goal_type=goal_type.upper())

        status_filter = request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter.upper())

        paginator = StandardResultsSetPagination()
        page = paginator.paginate_queryset(queryset, request, view=self)
        if page is not None:
            serializer = FitnessGoalSerializer(page, many=True)
            return success_response(
                "Fitness goals list retrieved",
                data={
                    "count": paginator.page.paginator.count,
                    "next": paginator.get_next_link(),
                    "previous": paginator.get_previous_link(),
                    "results": serializer.data
                }
            )

        serializer = FitnessGoalSerializer(queryset, many=True)
        return success_response("Fitness goals list retrieved", data=serializer.data)

    def post(self, request):
        role = request.user.role
        data = request.data.copy()

        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
            data['member'] = member.id
        else:
            member_id = data.get('member')
            if not member_id:
                return failure_response("Member ID required.", status_code=status.HTTP_400_BAD_REQUEST)
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            else:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)

        serializer = FitnessGoalSerializer(data=data)
        if serializer.is_valid():
            goal = GoalTrackingService.create_goal(
                member_id=member.id,
                validated_data=serializer.validated_data
            )
            return success_response(
                "Fitness goal created successfully",
                data=FitnessGoalSerializer(goal).data,
                status_code=status.HTTP_201_CREATED
            )
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class FitnessGoalDetailView(APIView):
    permission_classes = [IsAuthenticated, IsProgressOwnerOrTrainer]

    def patch(self, request, id):
        goal = get_object_or_404(FitnessGoal, id=id)
        self.check_object_permissions(request, goal)
        
        serializer = FitnessGoalSerializer(goal, data=request.data, partial=True)
        if serializer.is_valid():
            updated = serializer.save()
            
            # Recalculate progress in case weight values changed
            latest_meas = ProgressMeasurement.objects.filter(member=updated.member).first()
            if latest_meas:
                GoalTrackingService.update_goal_progress(updated, latest_meas.weight_kg, latest_meas.body_fat_percentage)
                
            return success_response("Fitness goal updated successfully", data=FitnessGoalSerializer(updated).data)
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        goal = get_object_or_404(FitnessGoal, id=id)
        self.check_object_permissions(request, goal)
        goal.delete()
        return success_response("Fitness goal deleted successfully")


class ProgressAnalyticsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        role = request.user.role
        
        # Scoping target member
        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
        else:
            member_id = request.query_params.get('member_id')
            if not member_id:
                # If Trainer or Owner accesses dashboard metrics without member_id, return aggregate dashboard stats
                if role == UserRole.TRAINER:
                    trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                    stats = self.get_trainer_progress_dashboard_stats(trainer)
                else: # OWNER
                    gym = Gym.objects.filter(owner=request.user).first()
                    stats = self.get_owner_progress_dashboard_stats(gym)
                return success_response("Progress dashboard statistics retrieved", data=stats)
                
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            else: # OWNER
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)

        analytics = AnalyticsEngine.generate_analytics(member)
        return success_response("Progress analytics summary retrieved", data=analytics)

    def get_trainer_progress_dashboard_stats(self, trainer):
        # Members assigned to this trainer
        assigned_members = Member.objects.filter(trainer_assignments__trainer=trainer, trainer_assignments__status='ACTIVE')
        
        improving_count = 0
        stagnating_count = 0
        total_goals_completed = 0
        total_goals_active = 0
        
        for m in assigned_members:
            # Check weight trend from last 30 days
            recent_meas = ProgressMeasurement.objects.filter(member=m).order_by('-recorded_date', '-created_at')[:2]
            if len(recent_meas) >= 2:
                # Improving weight loss or muscle gain
                active_goal = FitnessGoal.objects.filter(member=m, status='ACTIVE').first()
                if active_goal:
                    w_diff = recent_meas[0].weight_kg - recent_meas[1].weight_kg
                    if active_goal.goal_type == GoalType.FAT_LOSS and w_diff < 0: # lost weight
                        improving_count += 1
                    elif active_goal.goal_type in [GoalType.WEIGHT_GAIN, GoalType.MUSCLE_GAIN] and w_diff > 0: # gained weight
                        improving_count += 1
                    else:
                        stagnating_count += 1
                else:
                    stagnating_count += 1
            else:
                stagnating_count += 1
                
            # Goal completion rates
            m_goals = FitnessGoal.objects.filter(member=m)
            total_goals_completed += m_goals.filter(status=GoalStatus.ACHIEVED).count()
            total_goals_active += m_goals.filter(status=GoalStatus.ACTIVE).count()
            
        goal_rate = 0.0
        tot = total_goals_completed + total_goals_active
        if tot > 0:
            goal_rate = round((total_goals_completed / tot) * 100.0, 1)

        return {
            'members_improving': improving_count,
            'members_stagnating': stagnating_count,
            'goal_completion_rate': goal_rate,
            'active_goals': total_goals_active
        }

    def get_owner_progress_dashboard_stats(self, gym):
        if not gym:
            return {'average_weight_change': 0.0, 'goal_achievement_rate': 0.0}
            
        members = Member.objects.filter(gym=gym, is_deleted=False)
        
        total_change = 0.0
        count = 0
        total_completed = 0
        total_goals = 0
        
        for m in members:
            meas = ProgressMeasurement.objects.filter(member=m).order_by('recorded_date')
            if len(meas) >= 2:
                total_change += (meas.last().weight_kg - meas.first().weight_kg)
                count += 1
                
            m_goals = FitnessGoal.objects.filter(member=m)
            total_completed += m_goals.filter(status='ACHIEVED').count()
            total_goals += m_goals.count()
            
        avg_change = round(total_change / count, 1) if count > 0 else 0.0
        achievement_rate = round((total_completed / total_goals) * 100.0, 1) if total_goals > 0 else 0.0

        return {
            'average_weight_change': avg_change,
            'goal_achievement_rate': achievement_rate,
            'active_goals': total_goals - total_completed
        }


class ProgressComparisonView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        role = request.user.role
        
        # Scoping target member
        if role == UserRole.MEMBER:
            member = get_object_or_404(Member, email=request.user.email, is_deleted=False)
        else:
            member_id = request.query_params.get('member_id')
            if not member_id:
                return failure_response("member_id required.", status_code=status.HTTP_400_BAD_REQUEST)
            if role == UserRole.TRAINER:
                trainer = get_object_or_404(Trainer, user=request.user, is_deleted=False)
                member = get_object_or_404(Member, id=member_id, gym=trainer.gym)
            else:
                member = get_object_or_404(Member, id=member_id, gym__owner=request.user)

        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')

        compare_data = ProgressComparisonService.compare(member, start_date, end_date)
        if 'error' in compare_data:
            return failure_response(compare_data['error'], status_code=status.HTTP_400_BAD_REQUEST)
            
        return success_response("Comparison calculated successfully", data=compare_data)
